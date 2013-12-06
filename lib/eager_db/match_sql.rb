module EagerDB
  module MatchSql
    class MatchSqlBindVariable
      attr_reader :index

      def initialize(index)
        @index = index.to_i
      end
    end

    class MatchSqlResultVariable
      attr_reader :result, :name

      def initialize(result, name)
        @result = result
        @name = name
      end
    end

    class MatchSqlResult
      attr_reader :processor

      def initialize(processor)
        @processor = processor
        @result_variables = {}
      end

      def get_variable(name)
        @result_variables[name] ||= MatchSqlResultVariable.new(processor, name)
      end

      def method_missing(method, *args, &block)
        if processor.result_variable?(method)
          self.class.instance_eval do
            define_method(method) { get_variable(method) }
          end

          get_variable(method)
        else
          super
        end
      end

      def respond_to?(method)
        if processor.result_variable?(method)
          true
        else
          super
        end
      end
    end
  end
end
