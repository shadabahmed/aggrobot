module Aggrobot
  module Helper

    def block_from_args(block_arg, block, required = true)
      block = block_arg if block_arg && block_arg.respond_to?(:call)
      raise ArgumentError.new 'Block parameter required' if required && !block
      block
    end

    def raise_error(msg)
      raise AggrobotError.new(msg)
    end
  end
end