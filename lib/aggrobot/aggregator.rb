module Aggrobot
  class Aggregator

    include Helper

    def initialize(collection)
      @collection = collection
      @group_name_attribute, @count_attribute = :name, :count
      @group_labels_map = {}
      @attribute_mapping = {}
      self.collection(collection) if collection
    end

    # returns hash of group label(s) as key and actual column(s) as value 
    def group_labels(map = nil, &block)
      if map || block
        if map.is_a?(Hash)
          @group_labels_map = ActiveSupport::HashWithIndifferentAccess.new(map)
        elsif map.respond_to?(:call) || block
          @group_labels_map = block || map
        end
      else
        @group_labels_map
      end
    end

    # returns collection if it is ActiveRecord::Relation or ActiveRecord::Base
    # raises error when collection is none of the above
    # returns @collection otherwise (which is nil)
    def collection(values = nil)
      if values
        raise_error 'Collection should be an ActiveRecord::Relation or ActiveRecord::Base' unless
            [ActiveRecord::Relation, ActiveRecord::Base].any?{|m| values.is_a?(m) or values < m}
        @collection = values
      else
        @collection
      end
    end

    # when 
    #     : opts is nil, groups by group on @collection
    #     : opts is a map as {limit_to: limit}, creats groups by group on @collection with a limit
    #     : opts is a map as {buckets: [list_items]}, creats groups by [list_items] on @collection
    def group_by(group, opts = nil)
      raise_error "Group_by takes only symbol or a string as argument" unless group.is_a?(Symbol) or group.is_a?(String)
      @query_planner = QueryPlanner.create(@collection, group, opts)
    end

    def override(attr, override_attr = false)
      case attr
        when :name
          @group_name_attribute = override_attr
        when :count
          @count_attribute = override_attr
        when Hash
          attr.each { |k, v| override(k, v) }
      end
    end

    # creates attribute map
    # when: 
    #     given as hash, sets all keys as attributes to show and values as columns to fetch
    #     given as list (of 2 items), first item is key to show and second item is column to fetch
    def set(name = nil, opts)
      if opts.is_a? Hash
        @attribute_mapping.merge!(opts)
      elsif name && opts
        @attribute_mapping[name] = opts
      end
    end

    def query_planner
      @query_planner ||= QueryPlanner.create(@collection, DEFAULT_GROUP_BY)
    end

    def yield_results
      # yield on actual query results
      query_planner.query_results(extra_columns).each do |real_group_name, count, *rest|
        mapped_group_name = @group_labels_map[real_group_name] || real_group_name
        relation = @query_planner.sub_query(real_group_name)
        yield(mapped_attributes(mapped_group_name, count, rest), mapped_group_name, relation)
      end
    end

    private

    def extra_columns
      @attribute_mapping.values
    end

    def extra_attributes
      @attribute_mapping.keys
    end

    def mapped_attributes(group_name, count, result_row)
      ActiveSupport::HashWithIndifferentAccess.new.tap do |attributes|
        attributes.merge!(Hash[extra_attributes.zip(result_row)]) unless result_row.empty?
        attributes[@count_attribute] = count if @count_attribute
        attributes[@group_name_attribute] = group_name if @group_name_attribute
      end
    end

  end
end