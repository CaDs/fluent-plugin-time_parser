require 'time'
require 'tzinfo'
require 'fluent/plugin/output'

module Fluent::Plugin
  class TimeParserOutput < Output
    Fluent::Plugin.register_output('time_parser', self)

    helpers :event_emitter, :compat_parameters

    DEFAULT_BUFFER_TYPE = "memory"

    config_param :tag, :string
    config_param :key, :string, :default => 'time'
    config_param :time_zone, :string, :default => ''
    config_param :parsed_time_tag, :string, :default => 'parsed_time'
    config_param :parsed_hour_tag, :string, :default => 'parsed_hour'
    config_param :parsed_date_tag, :string, :default => 'parsed_date'

    config_section :buffer do
      config_set_default :@type, DEFAULT_BUFFER_TYPE
      config_set_default :chunk_keys, ['tag']
    end

    def configure(conf)
      compat_parameters_convert(conf, :buffer)
      super
      raise Fluent::ConfigError, "'tag' in chunk_keys is required." if not @chunk_key_tag
    end

    def start
      super
    end

    def shutdown
      super
    end

    def write(chunk)
      tag = extract_placeholders(@tag, chunk.metadata)
      chunk.msgpack_each {|time,record|
        t = tag.dup
        filter_record(t, time, record)
        router.emit(t, time, record)
      }
    end

    def filter_record(tag, time, record)
      begin
        record_time = DateTime.parse(record[key])

        if time_zone && time_zone != ""
          tz = TZInfo::Timezone.get(time_zone)

          period = tz.period_for_utc(record_time)
          rational_offset = period.utc_total_offset_rational

          record_time = tz.utc_to_local(record_time).new_offset(rational_offset) -
                        period.utc_total_offset_rational

        end
        date = record_time.to_date.to_s
        hour = record_time.hour.to_s

        record[parsed_time_tag] = record_time.to_s
        record[parsed_date_tag] = date
        record[parsed_hour_tag] = hour

      rescue ArgumentError => error
        log.warn("out_extract_query_params: #{error.message}")
      rescue TZInfo::InvalidTimezoneIdentifier
        log.warn("Timezone Not Valid, please refer to http://tzinfo.rubyforge.org/doc/classes/TZInfo/Timezone.html for valid timezones")
      end
    end
  end
end
