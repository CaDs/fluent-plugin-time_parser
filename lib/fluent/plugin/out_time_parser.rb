require 'time'
require 'tzinfo'

module Fluent
  class TimeParserOutput < Output
    include Fluent::HandleTagNameMixin
    Fluent::Plugin.register_output('time_parser', self)

    config_param :key, :string, :default => 'time'
    config_param :time_zone, :string
    config_param :parsed_time_tag, :string, :default => 'parsed_time'
    config_param :parsed_hour_tag, :string, :default => 'parsed_hour'
    config_param :parsed_date_tag, :string, :default => 'parsed_date'

    def configure(conf)
      super
      if (
          !remove_tag_prefix &&
          !remove_tag_suffix &&
          !add_tag_prefix    &&
          !add_tag_suffix
      )
        raise ConfigError, "out_extract_query_params: At least one of remove_tag_prefix/remove_tag_suffix/add_tag_prefix/add_tag_suffix is required to be set."
        raise ConfigError, "You must specify a time zone" unless time_zone
      end
    end

    def start
      super
    end

    def shutdown
      super
    end

    def emit(tag, es, chain)
      es.each {|time,record|
        t = tag.dup
        filter_record(t, time, record)
        Engine.emit(t, time, record)
      }
      chain.next
    end

    def filter_record(tag, time, record)
      begin
        original_time = DateTime.parse(record[key])
        tz = TZInfo::Timezone.get(time_zone.capitalize)

        period = tz.period_for_utc(original_time)
        rational_offset = period.utc_total_offset_rational

        converted_time = tz.utc_to_local(original_time).new_offset(rational_offset) -
                         period.utc_total_offset_rational

        date = converted_time.to_date.to_s
        hour = converted_time.hour.to_s

        record[parsed_time_tag] = converted_time.to_s
        record[parsed_date_tag] = date
        record[parsed_hour_tag] = hour

      rescue ArgumentError => error
        $log.warn("out_extract_query_params: #{error.message}")
      rescue TZInfo::InvalidTimezoneIdentifier
        $log.warn("Timezone Not Valid, please refer to http://tzinfo.rubyforge.org/doc/classes/TZInfo/Timezone.html for valid timezones")
      end
      super(tag, time, record)
    end
  end
end
