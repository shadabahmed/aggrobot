module Aggrobot
  module QueryPlanner
    class BucketedGroupsQueryPlanner < DefaultQueryPlanner

      def initialize(collection, group, opts = {})
        required_params = [:buckets]
        optional_params = [:keep_empty]
        validate_options(opts, required_params, optional_params)
        raise_error 'Need to set group first' unless group
        super(collection, group)
        create_query_map(opts[:buckets])
        @keep_empty = opts[:keep_empty]
      end

      def sub_query(group_value)
        @query_map[group_value]
      end

      def query_results(extra_cols = [])
        return empty_buckets if collection_is_none?
        results = collect_query_results(extra_cols)
        results.reject! { |r| r[1] == 0 } unless @keep_empty
        results
      end

      private

      def collect_query_results(extra_cols)
        columns = [SQLFunctions.count] + extra_cols
        @query_map.collect do |group_value, query|
          results = query.limit(1).pluck(*columns).flatten
          if results[0] == 0
            @query_map[group_value] = @query_map[group_value].none
            results = [0]
          end
          results.unshift(group_value)
        end
      end

      def empty_buckets
        @keep_empty ? @query_map.keys.collect { |k| [k, 0] } : []
      end

      def create_query_map(buckets)
        @query_map = {}
        buckets.each do |bucket|
          @query_map[bucket] = @collection.where(group_condition(bucket))
        end
      end

    end
  end
end