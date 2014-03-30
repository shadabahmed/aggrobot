# Aggrobot

Aggrobot is an aggregation framework in Ruby. It provides a powerfule DSL to perform aggregations over large dataset. It has been tested to work with MySQL, Postgres and SQLite. 

Many other features such as bucketing, grouping over top **n groups** and **others** and sub-aggregations (avg, sum, add, multiply, divide, percent, etc) on columns are also provided. All the aggregations are calculated in the database and only the aggregated data is sent over to Ruby, to keep it performant.

Aggrobot also allows nested aggregations and each level of sub-aggregation can be passed around as a code block and used in higher level aggregations. This provides great amount of code-reuse.

## Installation

Add this line to your application's Gemfile:

    gem 'aggrobot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aggrobot

## Usage

TODO: Write usage instructions here
TODO: Write example usage here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
