module EagerDB
  module Processors
    class AbstractProcessor
      def initialize(match_statement)
        @match_statement = match_statement
        @preload_statements = []
      end

      def add_preload_statement(preload_statement)
        @preload_statements << preload_statement
      end

      def process_preloads(sql, result)
        if @match_statement.matches?(sql)
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
