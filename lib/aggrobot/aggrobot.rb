module Aggrobot
  class Aggrobot

    include SqlFunctions
    include Helper

    delegate :collection, :group_by, :default_groups, :override, :set, :group_labels, :to => :@aggregator

    def run(block, args = {})
      instance_exec(args, &block)
    end

    def initialize(caller_context, collection = nil)
      @caller_context = caller_context
      @aggregator = Aggregator.new(collection)
    end

    def method_missing(method, *args, &block)
      @caller_context.send method, *args, &block
    end

    # creates top level data structure as hash and call block to process further
    def hash(collection = nil, opts = {}, &block)
      self.collection(collection) if collection
      @top_level_object = ActiveSupport::HashWithIndifferentAccess.new
      proceed(block, opts)
    end

    # creates top level data structure as array and call block to process further
    def list(collection = nil, opts = {}, &block)
      self.collection(collection) if collection
      @top_level_object = []
      proceed(block, opts)
    end

    # sets default/current values to top_level_object hash/list
    def default(default_val = nil, &block)
      block = block_from_args(default_val, block, false)
      default_val = ::Aggrobot.start(collection, &block) if block
      @top_level_object = default_val
    end

    alias set_current_value default

    # sets default group attrs as a hash, if opts is passed as param
    def default_group_attrs(opts = nil)
      if opts
        raise_error 'Arguments must be  a hash' unless opts.is_a?(Hash)
        @default_group_attrs = ActiveSupport::HashWithIndifferentAccess.new(opts)
      else
        @default_group_attrs
      end
    end

    # returns top level object hash/list
    def current_value
      @top_level_object
    end

    # starts aggrobot on collection and block, when block is given and
    # adds {attribute: value} pair to the top level object
    def attr(attribute, value = nil, &block)
      block = block_from_args(value, block, false)
      raise_error 'attr can only be used with a hash type' unless @top_level_object.is_a?(Hash)
      raise_error 'attribute should be a symbol or a string' unless attribute.is_a?(Symbol) || attribute.is_a?(String)
      raise_error 'attr should receive a block or a value' if value.nil? && block.nil?
      value = ::Aggrobot.start(collection, &block) if block
      @top_level_object[attribute] = value
    end

    # gets attribute's value from top level object, only works when top level is hash
    def get_attr(attribute)
      @top_level_object[attribute]
    end

    def collect_each_group_attributes
      each_group do |attr|
        attr
      end
    end

    def each_group(block_arg = nil, &block)
      block = block_from_args(block_arg, block)
      @aggregator.yield_results do |attrs, group_name, sub_collection|
        attrs = @default_group_attrs.merge(attrs) if @default_group_attrs
        block_value = ::Aggrobot.start(sub_collection) do
          instance_exec(attrs, &block)
        end
        update_top_level_obj(group_name, block_value)
      end
    end

    def evaluate(block_arg = nil, &block)
      block = block_from_args(block_arg, block)
      list(&block).first
    end

    private

    def evaluate_opts(opts)
      opts.each do |method_name, arg|
        send(method_name, arg)
      end
    end

    def update_top_level_obj(group, val)
      if @top_level_object.is_a? Hash
        @top_level_object[group] = val
      elsif @top_level_object.is_a? Array
        @top_level_object << val
      end
    end

    def proceed(block, opts)
      raise_error "no block given for api" unless block
      evaluate_opts(opts)
      instance_eval(&block)
      @top_level_object
    end

  end
end

