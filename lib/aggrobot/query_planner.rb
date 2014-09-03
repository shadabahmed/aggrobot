require 'aggrobot/query_planner/parameters_validator'
require 'aggrobot/query_planner/default_query_planner'
require 'aggrobot/query_planner/group_limit_query_planner'
require 'aggrobot/query_planner/bucketed_groups_query_planner'


# plans queries in a Aggrobot
module Aggrobot::QueryPlanner

  # creates query object
  def self.create(collection, group_by, opts = nil)
    case
    when opts.nil?
      DefaultQueryPlanner.new(collection, group_by)
    when opts.key?(:limit_to)
      # GROUP attrs by 'group_by' with limit
      GroupLimitQueryPlanner.new(collection, group_by, opts)
    when opts.key?(:buckets)
      # GROUP attrs by 'group_by' in buckets of opts[:buckets], e.g. 1..100, 101..200 etc
      BucketedGroupsQueryPlanner.new(collection, group_by, opts)
    else
      raise ArgumentError.new "Invalid options to group_by : #{opts}"
    end
  end
end