# -*- encoding: utf-8 -*-
require 'test_helper'
require 'time'
require 'tzinfo'

class TimeParserOutputTest < Test::Unit::TestCase

  TIME = "2013-04-14T06:14:36Z"
  GIRIGIRI_TIME = "2013-05-14T15:14:36Z"

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf, tag = 'test')
    Fluent::Test::OutputTestDriver.new(
      Fluent::TimeParserOutput, tag
    ).configure(conf)
  end

  def test_configure
    d = create_driver(%[
      key            test
      add_tag_prefix extracted.
      time_zone      Tokyo
    ])
    assert_equal 'test', d.instance.key
    assert_equal 'extracted.', d.instance.add_tag_prefix
    assert_equal 'Tokyo',   d.instance.time_zone

    #Default Key
    d = create_driver(%[
      add_tag_prefix extracted.
      time_zone      Tokyo
    ])
    assert_equal 'time', d.instance.key
    assert_equal 'extracted.', d.instance.add_tag_prefix
    assert_equal 'Tokyo',   d.instance.time_zone

    #No Prefix
    assert_raise(Fluent::ConfigError) do
      create_driver(%[
        time_zone      Tokyo
      ])
    end
    #No TimeZone
    assert_raise(Fluent::ConfigError) do
      create_driver(%[
        key            test
        add_tag_prefix extracted.
      ])
    end
  end

  def test_filter_record
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
      time_zone      Japan
    ])
    tag    = 'test'
    record = {'time' => TIME}
    d.instance.filter_record('test', Time.now, record)

    assert_equal record['time'], TIME
    assert_equal record['parsed_time'], "2013-04-14T15:14:36+09:00"
    assert_equal record['parsed_date'], "2013-04-14"
    assert_equal record['parsed_hour'], "15"
  end

  def test_girigiri_records
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
      time_zone      Japan
    ])
    tag    = 'test'
    record = {'time' => GIRIGIRI_TIME}
    d.instance.filter_record('test', Time.now, record)

    assert_equal record['time'], GIRIGIRI_TIME
    assert_equal record['parsed_time'], "2013-05-15T00:14:36+09:00"
    assert_equal record['parsed_date'], "2013-05-15"
    assert_equal record['parsed_hour'], "0"
  end

  def test_filter_record_bad_parameters
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
      time_zone      myPlace
    ])
    tag    = 'test'
    record = {'time' => TIME}

    d.instance.filter_record('test', Time.now, record)
    assert_equal record['parsed_time'], nil
    assert_equal record['parsed_date'], nil
    assert_equal record['parsed_hour'], nil

    record = {'time' => "this is not a date"}
    d.instance.filter_record('test', Time.now, record)
    assert_equal record['parsed_time'], nil
    assert_equal record['parsed_date'], nil
    assert_equal record['parsed_hour'], nil
  end

  def test_emit
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
      time_zone      Japan
    ])

    d.run { d.emit('time' => TIME) }
    emits = d.emits

    assert_equal 1, emits.count
    assert_equal 'extracted.test', emits[0][0]
    assert_equal TIME, emits[0][2]['time']
  end

  def test_emit_multi
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
      time_zone      Japan
    ])

    d.run do
      d.emit('time' => TIME)
      d.emit('time' => TIME)
      d.emit('time' => TIME)
    end
    emits = d.emits

    assert_equal 3, emits.count
    0.upto(2) do |i|
      assert_equal 'extracted.test', emits[i][0]
      assert_equal TIME, emits[i][2]['time']
    end
  end

  def test_emit_with_invalid_time
    d = create_driver(%[
      key            time
      add_tag_prefix extracted.
      time_zone      Japan
    ])
    wrong_time = 'wrong time'
    d.run { d.emit('time' => wrong_time) }
    emits = d.emits

    assert_equal 1, emits.count
    assert_equal 'extracted.test', emits[0][0]
    assert_equal wrong_time, emits[0][2]['time']
  end

end
