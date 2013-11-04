def add_should_receive_exp(obj, method, params, result)
  if params.is_a?(Array)
    obj.should_receive(method).with(*params).and_return(result)
  elsif params.nil?
    obj.should_receive(method).and_return(result)
  else
    obj.should_receive(method).with(params).and_return(result)
  end
end

def should_receive_queries(obj, result, method_chain)
  method_chain.each_with_index do |(method, params) , idx|
    return_val = (idx + 1) == method_chain.size ? result : obj
    add_should_receive_exp(obj, method, params, return_val)
  end
end