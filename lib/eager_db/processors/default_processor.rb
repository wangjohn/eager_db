module EagerDB
  module Processors
    class DefaultProcessor
      class << self
        attr_reader :match_sql, :preloads

        def match_on(sql, bind_values = nil)
          @match_sql = SqlStatement.new(sql, bind_values)
        end

        def preload(sql, bind_values = nil)
          (@preloads ||= []) << SqlStatement.new(sql, bind_values)
        end

        def result
          @result ||= PreloaderResult.new(self)
        end

        def result_variable?(name)
          true
        end

        def process(sql)
          statement = SqlStatement.new(sql)
          if match_sql.matches?(sql)
            execute_preloads!(statement)
          end
        end

        protected

          # TODO: This should go through all the preloads and execute them
          # based on the sql that is passed in.
          def execute_preloads!(sql_statement)
            raise "Unimplemented"
          end
      end
    end

    class PreloaderResultVariable
      attr_reader :result, :name

      def initializer(result, name)
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
