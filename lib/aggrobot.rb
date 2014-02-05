require 'aggrobot/railtie'
require 'active_support/core_ext/module/delegation.rb'
require 'active_support/core_ext/hash/indifferent_access'
require 'aggrobot/version'
require 'aggrobot/aggrobot_error'
require 'aggrobot/helper'
require 'aggrobot/sql_functions'
require 'aggrobot/query_planner'
require 'aggrobot/aggregator'
require 'aggrobot/aggrobot'


module Aggrobot

  DEFAULT_GROUP_BY = SqlFunctions.sanitize('aggrobot_default_group')

  # when
  #     collection is given, starts aggregation by evaluating block on collection
  #     collection is not given, starts aggregation by evaluating block on full data set
  def self.start(collection = nil, block_arg = nil, block_opts = nil, &block)
    block_opts ||= block_arg if block
    block = block_arg if block_arg && block_arg.respond_to?(:call)
    raise 'Block parameter required' unless block
    original_block_context = eval "self", block.binding
    attrs = if block.arity > 0
              block_opts.is_a?(Hash) ? block_opts : {count: collection.count}
            end
    Aggrobot.new(original_block_context, collection).instance_exec(attrs, &block)
  end

  def self.block(&block)
    block
  end

  # sets ROUNDING_DIGITS to percent_precision, default is 2
  def self.setup(app)
    SqlFunctions.const_set(:ROUNDING_DIGITS, app.config.aggrobot.percent_precision || 2)
  end

end