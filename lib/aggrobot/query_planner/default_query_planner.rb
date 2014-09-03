module Aggrobot
  module QueryPlanner
    class DefaultQueryPlanner
      include ParametersValidator

      def initialize(collection, group = DEFAULT_GROUP_BY)
        @collection, @group = validate_and_extract_relation(collection), group
      end

      def sub_query(group_value)
        if @group == DEFAULT_GROUP_BY
          @collection
        else
          @collection.where(group_condition(group_value))
        end
      end

      def query_results(extra_cols = [])
        return [] if collection_is_none?
        if @group.is_a? Array
          columns = @group + [SQLFunctions.count] + extra_cols
          results_query.pluck(*columns).collect do |result_row|
            [result_row[0..(@group.count - 1)]] + result_row[@group.count..-1]
          end
        else
          columns = [@group, SQLFunctions.count] + extra_cols
          results_query.pluck(*columns)
        end
      end

      protected

      def group_condition(group_value)
        if @group.is_a?(Array)
          Hash[@group.zip(group_value)]
        else
          {@group => group_value}
        end
      end

      def results_query
        @result_query ||= @collection.group(@group)
      end

      def collection_is_none?
        @collection.extending_values.include?(ActiveRecord::NullRelation)
      end
    end
  end
end