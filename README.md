# fluent-plugin-time_parser, a plugin for [Fluentd](http://fluentd.org)

## Component
TimeParserOutput

Based on the great extract-query-params plugin by [@Kentaro](https://github.com/kentaro/fluent-plugin-extract_query_params).
Will take a time attribute and will extract the date and the hour for a given time zone.

## wat?!

```
<match test.**>
  type time_parser

  key            time
  tag extracted.${tag}
  time_zone      Asia/Tokyo
</match>
```

And you feed such a value into fluentd:

```
"test" => {
  "time" => "2013-05-14T15:14:36Z"
}
```

Then you'll get re-emmited tags/records like so:

```
"extracted.test" => {
  "time" => "2013-05-14T15:14:36Z",
  "parsed_time" => "2013-05-15T00:14:36+09:00",
  "parsed_date" => "2013-05-15",
  "parsed_hour" => "0"
}
```

## Configuration

### key

`key` is used to point a key whose value contains the time you want to parse.

### tag

In this param, users can write placeholders.

Please use placeholders ${tag}, ${tag[0]}, ${tag[1]} in configuration.

Note that `Fluent::HandleTagNameMixin` dependency is removed in v0.14 style of this plugin.

### time_zone

Optional. time_parser uses the TZInfo (http://tzinfo.rubyforge.org/) library to handle time zones.

### parsed_time_tag, parsed_hour_tag, parsed_date_tag

The parsed_* parameter names can be configured as well.

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-time_parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-time_parser


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

### Copyright

Copyright (c) 2013- Carlos Donderis (@CaDs)

### License

Apache License, Version 2.0
