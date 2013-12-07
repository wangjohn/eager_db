module EagerDB
  module Prediction
    class SqlLog
      attr_reader :raw_sql, :processed_at

      def initialize(raw_sql, processed_at)
        @raw_sql = raw_sql
        @processed_at = processed_at
      end

      def non_binded_sql
        @sql_statement ||= EagerDB::SqlStatement.new(sql)
        @sql_statement.raw_sql
      end

      def bind_values
        @sql_statement ||= EagerDB::SqlStatement.new(sql)
        @sql_statement.bind_values
      end
    end

    class MarkovProbabilityStorage
      attr_reader :sql_statement

      def initialize(sql_statement)
        @sql_statement = sql_statement
        @total_occurrences = 0

        @transitions = Hash.new { |h,k| h[k] = [] }
      end

      def add_transition(time_difference, statement)
        @transitions[statement] << time_difference
        @total_occurrences += 1
      end

      def probabilities
        result = {}
        @transitions.each do |statement, time_differences|
          result[statement] = time_differences.length.to_f / @total_occurrences
        end

        result
      end
    end

    class CalculateProbability
      attr_reader :time_threshold

      def initialize(logs, time_threshold)
        @logs = logs
        @time_threshold = time_threshold

        probability_storage = Hash.new { |h,k| h[k] = MarkovProbabilityStorage.new(k) }
      end

      def process
        @logs.each do |user, user_logs|
          process_user_logs(user_logs)
        end
      end

      private

        def process_user_logs(user_logs)
          current_log = nil
          rolling_group = []

          user_logs.each do |log|
            if current_log
              if log.date < current_log.date + time_threshold
                rolling_group << log
              else
                current_storage = probability_storage[current_log.raw_sql]

                rolling_group.each do |log|
                  current_storage.add_transition(log.date - current_log.date, log.raw_sql)
                end
              end
            elsif rolling_group.empty?
              rolling_group << log
            else
              current_log = rolling_group.shift
            end
          end
        end
    end
  end
end
