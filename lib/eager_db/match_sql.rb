module EagerDB
  module MatchSql
    class MatchSqlStatement
      attr_reader :match_sql, :preloads

      def initialize(execute_method)
        @execute_method = execute_method
      end

      def match_on(sql, bind_values = nil)
        @match_sql = SqlStatement.new(sql, bind_values)
      end

      def preload(sql, bind_values = nil)
        (@preloads ||= []) << SqlStatement.new(sql, bind_values)
      end

      def process(sql, result)
        statement = SqlStatement.new(sql)
        if match_sql.matches?(sql)
          preloads.collect do |preload|
            preload.inject_values(statement, result)
          end
        end
      end

      class << self
        def result
          @result ||= MatchSqlResult.new(self)
        end

        def bind_value(index)
          MatchSqlBindVariable.new(index)
        end

        def result_variable?(name)
          true
        end
      end
    end

    class MatchSqlBindVariable
      attr_reader :index

      def initialize(index)
        @index = index
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
