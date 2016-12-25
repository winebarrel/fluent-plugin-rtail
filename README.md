# fluent-plugin-rtail

Fluentd output plugin for [rtail](http://rtail.org/).

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-rtail.svg)](https://badge.fury.io/rb/fluent-plugin-rtail)
[![Build Status](https://travis-ci.org/winebarrel/fluent-plugin-rtail.svg?branch=master)](https://travis-ci.org/winebarrel/fluent-plugin-rtail)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-rtail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-rtail

## Configuration

```
<match rtail.data>
  @type rtail

  #host 127.0.0.1
  #port 9999
  #id_key id
  #content_key content
  #use_tag_as_id false
  #use_record_as_content false
  flush_interval 0s
</match>
```
