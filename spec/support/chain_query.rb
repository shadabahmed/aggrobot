def add_expectations(obj, method, params)
  if params.is_a?(Array)
    obj.should_receive(method).with(*params)
  elsif params.nil?
    obj.should_receive(method)
  else
    obj.should_receive(method).with(params)
  end
end

def should_receive_queries(obj, method_chain)
  method_chain.each_with_index do |(method, params), idx|
    if (idx + 1) == method_chain.size
      return add_expectations(obj, method, params)
    else
      proxy = add_expectations(obj, method, params)
      proxy.and_return(obj)
    end
  end
end