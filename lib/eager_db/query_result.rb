module EagerDB
  class QueryResultError < StandardError
  end

  class QueryResult
    def initialize(values_mapping = {})
      values_mapping.each do |name, value|
        add_value_mapping(name, value)
      end
    end

    def add_value_mapping(name, value)
      self.class.instance_eval do
        define_method(name) { value }
      end
    end

    def method_missing(method, *args, &block)
      # TODO: This is a bad error message. We should give the user some context
      # about which QueryResult he is looking at.
      raise QueryResultError, "The attribute `#{method}` does not exist for this QueryResult. Try checking to make sure your match statements and preload statements conform to your database schema. Especially check to make that instances of `match_result.some_attribute_name` occur with a valid attribute name."
    end
  end
end
