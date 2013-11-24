module EagerDB
  module Processors
    class AbstractProcessor
      def initialize
        @match_statements = []
      end

      def add_match_statement(match_statement)
        @match_statements << match_statement
      end

      def process_preloads(sql, result)
        preloads = @match_statements.collect do |statement|
          statement.process(sql, result)
        end

        preloads.flatten
      end
    end
  end
end
