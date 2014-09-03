require_relative './distribution_evaluator'
require 'rails'
require 'factory_girl'

class FactoryRobot
  FactoryGirl.find_definitions
  attr_reader :factory_name
  attr_writer :distribution, :count

  def self.start(factory, opts = {}, &block)
    original_block_context = eval "self", block.binding
    raise 'Block required for create factory method' unless block_given?
    factory = new(factory, original_block_context, opts)
    factory.instance_eval &block
    factory.finalize
  end

  def initialize(factory, caller_context, opts = {} )
    @factory_name = factory
    @factory = FactoryGirl.factory_by_name(@factory_name)
    raise 'Factory not found for #{@factory_name}' unless @factory
    @caller_context = caller_context
    @distributions = {}
    @foreach_blocks = []
    create_factory_methods
    opts = {
        count: 1
    }.merge(opts)
    opts.each do |k,v|
      send(k, v)
    end
  end

  def method_missing(method, *args, &block)
    @caller_context.send method, *args, &block
  end

  def finalize
    records = []
    @count.times do
      record = FactoryGirl.create(factory_name)
      distribute_values(record)
      execute_foreach_blocks(record)
      records << record
      record.save
    end
    records
  end

  def evaluate(*args, &block)
    instance_exec(*args, &block)
  end

  private

  def create(*args, &block)
    self.class.start(*args, &block)
  end

  def create_factory_methods
    factory_cols.each do |method_name|
      method_name = method_name.to_s
      class_eval <<-__CODE__, __FILE__, __LINE__
        def #{method_name}(val = nil)
          if val
            distribute :#{method_name}, val
          else
            @distributions[:#{method_name}] && @distributions[:#{method_name}][:src]
          end
        end
      __CODE__
    end
  end

  def count(val)
    @count = val
  end

  def each_record(&block)
    raise 'Block required for foreach method' unless block_given?
    @foreach_blocks << block
  end

  def distribute(attr, vals = nil, &block)
    raise 'Values (array/hash/object) or block required for attribute #{attr}' if vals.nil? && !block_given?
    @distributions[attr] = {:src => vals, :value => block_given? ? DistributionEvaluator.new(vals, &block) : DistributionEvaluator.new(vals)}
  end

  def factory_cols
    cols = @factory.build_class.column_names.clone
    cols.delete(@factory.build_class.primary_key)
    cols.concat(@factory.build_class.reflect_on_all_associations.collect(&:name))
  end

  def execute_foreach_blocks(record)
    if @foreach_blocks
      @foreach_blocks.each do |block|
        instance_exec(record, &block)
      end
    end
  end

  def distribute_values(record)
    @distributions.each do |attr, distribution|
      record.send("#{attr}=", distribution[:value].next_value)
    end
  end
end
