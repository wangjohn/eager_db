module EagerDB
  module Prediction
    class MarkovProbabilityStorage
      attr_reader :sql_statement

      def initialize(sql_statement)
        @sql_statement = sql_statement
        @total_occurrences = 0

        @transitions = Hash.new { |h,k| h[k] = [] }
      end

      def binded_preloads(preload)
        @transitions[preload]
      end

      def increment_total_occurrences
        @total_occurrences += 1
      end

      def add_transition(match, statement)
        @transitions[match.non_binded_sql] << [match, statement]
      end

      def probabilities
        result = {}
        @transitions.each do |match, statement_tuples|
          result[match.non_binded_sql] = statement_tuples.length.to_f / @total_occurrences
        end

        result
      end
    end
  end
end
