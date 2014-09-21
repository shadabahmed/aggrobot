module Aggrobot
  module QueryPlanner
    class DefaultQueryPlanner
      include ParametersValidator

      def initialize(collection, group = nil)
        @collection, @group = validate_and_extract_relation(collection), group
      end

      def sub_query(group_value)
        unless @group
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
        elsif @group
          columns = [@group, SQLFunctions.count] + extra_cols
          results_query.pluck(*columns)
        else
          columns = [SQLFunctions.count] + extra_cols
          [[@group] + results_query.pluck(*columns).first]
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
        @result_query ||= (@group ? @collection.group(@group) : @collection)
      end

      def collection_is_none?
        @collection.extending_values.include?(ActiveRecord::NullRelation)
      end
    end
  end
end