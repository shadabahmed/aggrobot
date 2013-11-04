module Aggrobot
  class DefaultQueryPlanner
    include Helper

    def initialize(collection, group)
      @collection, @group = collection, group
    end

    def sub_query(group_name)
      @group == DEFAULT_GROUP_BY ? @collection : @collection.where(@group => group_name)
    end

    def query_results(extra_cols = [])
      return [] if collection_is_none?
      columns = [@group, SqlFunctions.count] + extra_cols
      results_query.pluck(*columns)
    end

    protected
    def results_query
      @result_query ||= @collection.group(@group)
    end

    def collection_is_none?
      @collection.extending_values.include?(ActiveRecord::NullRelation)
    end
  end
end