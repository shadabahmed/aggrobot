module Aggrobot
  module QueryPlanner
    class GroupLimitQueryPlanner < DefaultQueryPlanner

      def initialize(collection, group, opts)
        required_params = [:limit_to, :sort_by]
        optional_params = [:always_include, :other_group, :order]
        validate_options(opts, required_params, optional_params)
        raise_error 'limit_to has to be a number' unless opts[:limit_to].is_a?(Fixnum)
        super(collection, group)
        @query_map = {}
        process_top_groups_options(opts)
      end

      def sub_query(group_value)
        group_value == @other_group ? @collection.where.not(@top_groups_conditions) : @collection.where(group_condition(group_value))
      end

      def query_results(extra_cols = [])
        return [] if collection_is_none?
        top_group_results = if @group.is_a? Array
          columns = @group + [SQLFunctions.count] + extra_cols
          results_query.where(@top_groups_conditions).pluck(*columns).collect do |result_row|
            [result_row[0..(@group.count - 1)]] + result_row[@group.count..-1]
          end
        else
          columns = [@group, SQLFunctions.count] + extra_cols
          results_query.where(@top_groups_conditions).pluck(*columns)
        end
        top_group_results + other_group_results(columns)
      end

      protected

      def other_group_results(columns)
        if @other_group
          columns[0] = SQLFunctions.sanitize(@other_group)
          @collection.where.not(@top_groups_conditions).pluck(*columns)
        else
          []
        end
      end

      def results_query
        @results_query ||= @collection.group(@group)
      end

      def get_top_groups(opts)
        @collection.group(@group).order("#{opts[:sort_by]} #{opts[:order]}").limit(opts[:limit_to]).pluck(*@group)
      end

      def process_top_groups_options(opts)
        opts[:order] ||= 'desc'
        top_groups = get_top_groups(opts)
        if opts[:always_include] && !top_groups.include?(opts[:always_include])
          top_groups.pop
          top_groups << opts[:always_include]
        end
        calculate_top_groups_conditions(top_groups)
        @other_group = opts[:other_group]
      end

      def calculate_top_groups_conditions(top_groups)
        if @group.is_a?(Array)
          @top_groups_conditions = {}
          @group.each_with_index do |group, idx|
            @top_groups_conditions[group] = top_groups.collect{|v| v[idx]}
          end
        else
          @top_groups_conditions = {@group => top_groups}
        end
      end

    end
  end
end