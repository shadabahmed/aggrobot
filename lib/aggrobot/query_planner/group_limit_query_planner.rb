module Aggrobot
  module QueryPlanner
    class GroupLimitQueryPlanner < DefaultQueryPlanner

      def initialize(collection, group, opts)
        ParametersValidator.validate_options(opts, [:limit_to, :sort_by], [:always_include, :other_group, :order, :always_include_at])
        raise_error 'limit_to has to be a number' unless opts[:limit_to].is_a?(Fixnum)
        super(collection, group)
        @query_map = {}
        process_top_groups_options(opts)
      end

      def sub_query(group_name)
        group_name == @other_group ? @collection.where.not(@top_groups_conditions) : @collection.where(@group => group_name)
      end

      def query_results(extra_cols = [])
        return [] if collection_is_none?
        columns = [@group, SqlFunctions.count] + extra_cols
        top_group_results = results_query.where(@top_groups_conditions).pluck(*columns)
        top_group_results + other_group_results(columns)
      end

      protected

      def other_group_results(columns)
        if @other_group
          columns[0] = SqlFunctions.sanitize(@other_group)
          @collection.where.not(@top_groups_conditions).group(columns[0]).pluck(*columns)
        else
          []
        end
      end

      def results_query
        @results_query ||= @collection.group(@group)
      end

      def calculate_top_groups(opts)
        @collection.group(@group).order("#{opts[:sort_by]} #{opts[:order]}").limit(opts[:limit_to]).pluck(@group).flatten
      end

      def process_top_groups_options(opts)
        opts[:order] ||= 'desc'
        top_groups = calculate_top_groups(opts)
        if always_include_group = opts[:always_include]
          top_groups.delete(always_include_group) || top_groups.pop
          top_groups.insert(opts[:always_include_at] || 0, always_include_group)
        end
        @top_groups_conditions = {@group => top_groups}
        @other_group = opts[:other_group]
      end

    end
  end
end