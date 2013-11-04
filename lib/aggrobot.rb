require 'active_support/core_ext/module/delegation.rb'
require 'active_support/core_ext/hash/indifferent_access'
require 'aggrobot/version'
require 'aggrobot/aggrobot_error'
require 'aggrobot/helper'
require 'aggrobot/query_planners/default_query_planner'
require 'aggrobot/query_planners/group_limit_query_planner'
require 'aggrobot/query_planners/default_groups_query_planner'
require 'aggrobot/sql_attributes'
require 'aggrobot/aggregator'
require 'aggrobot/aggrobot'


module Aggrobot

  DEFAULT_GROUP_BY = SqlAttributes.sanitize('aggrobot_default_group')

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

end