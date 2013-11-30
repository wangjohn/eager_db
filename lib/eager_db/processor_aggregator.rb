module EagerDB
  module ProcessorAggregator
    class AbstractProcessorAggregator
      attr_reader :processors

      def initialize
        @processors = []
      end

      def add_processor(processor)
        @processors << processor
      end

      def matching_processors(sql)
        @processors.select do |processor|
          processor.matches?(sql)
        end
      end

      def process_job(query_job)
        statement = EagerDB::SqlStatement.new(query_job.sql)
        preloads = matching_processors(statement.raw_sql).collect do |processor|
          processor.process_preloads(statement.raw_sql, query_job.result)
        end

        preloads.flatten
      end
    end

    class ExactMatchProcessorAggregator < AbstractProcessorAggregator
      def initialize
        @processors = {}
      end

      def add_processor(processor)
        @processors[processor.match_statement.raw_sql] ||= []
        @processors[processor.match_statement.raw_sql] << processor
      end

      def matching_processors(sql)
        statement = EagerDB::SqlStatement.new(sql)

        @processors[statement.raw_sql].collect do |processor|
          processor.matches?(sql)
        end
      end
    end
  end
end
