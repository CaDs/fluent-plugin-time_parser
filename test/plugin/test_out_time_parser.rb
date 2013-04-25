# -*- encoding: utf-8 -*-
require 'test_helper'
require 'debugger'

class TimeParserOutputTest < Test::Unit::TestCase

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
    
  end

  def test_emit

  end

  def test_emit_multi
    
  end

  def test_emit_with_invalid_time
    
  end

end