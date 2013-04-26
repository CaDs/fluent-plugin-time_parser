# fluent-plugin-time_parser

## Component
TimeParserOutput

Based on the great extract-query-params plugin by @Kentaro (https://github.com/kentaro/fluent-plugin-extract_query_params).
Will take a time attribute and will extract the date and the hour for a given time zone.

## wat?!

```
<match test.**>
  type time_parser

  key            time
  add_tag_prefix extracted.
  time_zone      Tokyo
</match>
```

And you feed such a value into fluentd:

```
"test" => {
  "time" => ""2013-04-14T06:14:36Z""
}
```

Then you'll get re-emmited tag/record-s below:

```
"extracted.test" => {
  "time" => "2013-04-14T06:14:36Z"
  "date" => "2013-04-14",
  "hour" => "15"
}
```
## Configuration

### key

`key` is used to point a key whose value contains the time you want to parse.

### remove_tag_prefix, remove_tag_suffix, add_tag_prefix, add_tag_suffix

These params are included from `Fluent::HandleTagNameMixin`. See the code for details.

You must add at least one of these params.

### time_zone

time_parser is using TZInfo (http://tzinfo.rubyforge.org/) library to handle time zones.

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
