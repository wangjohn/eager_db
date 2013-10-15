module EagerDB
  module Processors
    class DefaultProcessor
      attr_reader :match_sql, :preloads

      def initialize(execute_method)
        @execute_method = execute_method
      end

      class << self
        def match_on(sql, bind_values = nil)
          @match_sql = SqlStatement.new(sql, bind_values)
        end

        def preload(sql, bind_values = nil)
          (@preloads ||= []) << SqlStatement.new(sql, bind_values)
        end

        def result
          @result ||= PreloaderResult.new(self)
        end

        def bind_value(index)
          PreloaderBindVariable.new(index)
        end

        def result_variable?(name)
          true
        end
      end

      def process(sql, result)
        statement = SqlStatement.new(sql)
        if match_sql.matches?(sql)
          execute_preloads!(statement, result)
        end
      end

      protected

        def execute_preloads!(sql_statement, result)
          @preloads.each do |preload|
            preload.execute(@execute_method, sql_statement, result)
          end
        end
    end

    class PreloaderBindVariable
      attr_reader :index

      def initialize(index)
        @index = index
      end
    end

    class PreloaderResultVariable
      attr_reader :result, :name

      def initialize(result, name)
        @result = result
        @name = name
      end
    end

    class PreloaderResult
      attr_reader :matcher

      def initialize(matcher)
        @matcher = matcher
      end

      def get_variable(name)
        PreloaderResultVariable.new(matcher, name)
      end

      def method_missing(method, *args, &block)
        if matcher.result_variable?(method)
          get_variable(name)
        else
          super
        end
      end

      def respond_to?(method)
        if matcher.result_variable?(method)
          true
        else
          super
        end
      end
    end
  end
end
