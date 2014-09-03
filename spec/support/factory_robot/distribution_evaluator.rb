class DistributionEvaluator
  attr_reader :count, :value

  def initialize(value = nil, &block)
    @count = 0
    @value = value || block
    @evaluator_name = evaluator_name(@value)
  end

  def next_value
    current_val = send @evaluator_name
    @count += 1
    current_val
  end

  private

  def evaluator_name(value)
    case
      when value.is_a?(Array)
        :array_dist_value
      when value.is_a?(Hash)
        :hash_dist_value
      when value.respond_to?(:call)
        :block_dist_value
      else
        :value
    end
  end

  def array_dist_value
    value[@count % value.size]
  end

  def block_dist_value
    value.call(@count)
  end

  def hash_dist_value
    idx = value[:rest] ? @count : @count % value.keys.last
    matching_value = value.find{|k, _| k.is_a?(Integer) && k > idx }
    (matching_value && matching_value.last) || value[:rest]
  end
end