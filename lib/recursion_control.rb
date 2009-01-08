module RecursionControl
  class << self
    def stack
      @stack ||= {}
    end
  end

  # Shortcuts recursion by assuming a default return value.
  #
  # For example: consider what would happen if two associated
  # records each tried to validate the other. They would loop
  # recursively calling #valid? on the other until Ruby grew
  # tired and raised StackTooDeep. But in this situation, each
  # record is in fact valid because the other does in fact
  # exist. So by replacing recursive references with a default
  # value of true, we can remove the recursion without changing
  # the result.
  def without_recursion(method, default = true, &block)
    RecursionControl.stack[method] ||= []
    
    return default if RecursionControl.stack[method].include? self
    RecursionControl.stack[method] << self
    result = yield
  ensure
    RecursionControl.stack[method].delete(self)
    result
  end
end
