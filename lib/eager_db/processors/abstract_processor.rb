module EagerDB
  module Processors
    class AbstractProcessor
      def initialize(match_statement)
        @match_statement = match_statement
        @preload_statements = []
        @match_sql_result = MatchSql::MatchSqlResult.new(self)
      end

      def add_preload_statement(preload_statement)
        @preload_statements << preload_statement
      end

      def preload(sql, bind_values = nil)
        @preload_statements << SqlStatement.new(sql, bind_values)
      end

      def matches?(sql)
        @match_statement.matches?(sql)
      end

      def result_variable?(name)
        true
      end

      def match_result
        @match_sql_result
      end

      def match_bind_value(index)
        MatchSql::MatchSqlBindVariable.new(index)
      end

      def process_preloads(sql, result)
        if matches?(sql)
          options = {
            result: result,
            sql_statement: @match_statement
          }

          @preload_statements.collect do |statement|
            statement.inject_values(options)
          end
        end
      end
    end
  end
end
