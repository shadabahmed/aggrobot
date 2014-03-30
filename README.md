# Aggrobot

Aggrobot is an aggregation framework in Ruby. It provides a powerful DSL to perform aggregations over large dataset. It has been tested to work with MySQL, Postgres and SQLite. 

Many other features are provided:
* Bucketing over data ranges. For e.g. grouping orders over price ranges like 100-200, 200-300 and 300+
* Grouping over top **n groups**. For e.g. group top 2 selling products based on quantity, while group rest of the products in a single bucket of **others**
*  Sub-aggregations (avg, sum, add, multiply, divide, percent, etc) on columns are also provided.

All the aggregations are calculated in the database and only the aggregated data is sent over to Ruby, to keep it performant. This greatly speeds up performance and reduces the memory requirement, had the aggregations been done directly in Ruby.

Aggrobot also allows nested aggregations and each level of aggregation can be passed around as a code block and used in higher level aggregations. This provides great amount of code-reuse.

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
