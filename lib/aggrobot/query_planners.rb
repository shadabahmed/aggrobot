require 'aggrobot/query_planners/default_query_planner'
require 'aggrobot/query_planners/group_limit_query_planner'
require 'aggrobot/query_planners/bucketed_groups_query_planner'

module Aggrobot::QueryPlanners

  def self.create_query_planner(collection, group_by, opts)
    case
    when opts.is_nil?
      DefaultQueryPlanne.new(collection, group_by)
    when opts.key?(:limit_to)
      GroupLimitQueryPlanner.new(collection, group_by, opts)
    when opts.key?(:buckets)
      BucketedGroupsQueryPlanner.new(collection, group_by, opts)
    end
  end

  module ParametersValidator
    def self.validate_options(opts, required_parameters, optional_parameters)
      params = opts.keys
      # raise errors for required parameters
      raise_argument_error(opts, required_parameters, optional_parameters) unless (required_parameters - params).empty?
      # raise errors if any extra arguments given
      raise_argument_error(opts, required_parameters, optional_parameters) unless (params - required_parameters - optional_parameters).empty?
    end

    def self.raise_argument_error(opts, required_parameters, optional_parameters)
      raise ArgumentError, <<-ERR
          Wrong arguments given - #{opts}
          Required parameters are #{required_parameters}
          Optional parameters are #{optional_parameters}
      ERR
    end
  end

end