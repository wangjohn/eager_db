module EagerDB
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
  end
end
