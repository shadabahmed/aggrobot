module Aggrobot
  class Aggregator

    include Helper

    def initialize(collection)
      @collection = collection
      @group = DEFAULT_GROUP_BY
      @group_name_attribute, @count_attribute = :name, :count
      @group_labels_map = {}
      @attribute_mapping = {}
      self.collection(collection) if collection
    end


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

    def collection(values = nil)
      if values
        raise_error "Collection should be an ActiveRecord::Relation" unless values.is_a? ActiveRecord::Relation
        @collection = values
      else
        @collection
      end
    end

    def group_by(attr = nil, opts = nil)
      if attr
        raise_error "Group_by takes only symbol or a string as argument" unless attr.is_a?(Symbol) or attr.is_a?(String)
        @group = attr
        if opts.is_a?(Hash)
          @query_planner = GroupLimitQueryPlanner.new(@collection, @group, opts)
        end
      else
        @group
      end
    end

    def default_groups(groups = nil, opts = {})
      if groups
        @default_groups = groups
        @query_planner = DefaultGroupsQueryPlanner.new(@collection, @group, groups, opts)
      else
        @default_groups
      end
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

    def set(name = nil, opts)
      if opts.is_a? Hash
        @attribute_mapping.merge!(opts)
      elsif name && opts
        @attribute_mapping[name] = opts
      end
    end

    def yield_results
      @query_planner ||= DefaultQueryPlanner.new(@collection, @group)

      # yield on actual query results
      @query_planner.query_results(extra_columns).each do |real_group_name, count, *rest|
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