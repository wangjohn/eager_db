module EagerDB
  module Prediction
    class SqlLog
      attr_reader :raw_sql

      def initialize(raw_sql)
        @raw_sql = raw_sql
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

    class CalculateProbability
      attr_reader :time_threshold

      def initialize(logs, time_threshold)
        @logs = logs
        @time_threshold = time_threshold
      end

      def process
        sql_count = Hash.new { |h,k| h[k] = {} }
        total_occurences = Hash.new { |h,k| h[k] = 0 }
        current_log = nil

        @logs.each do |user, user_logs|
          rolling_group = []
          user_logs.each do |log|
            if current_log
              if log.date < current_log.date + time_threshold
                rolling_group << log
              else
                current_sql_count = sql_count[current_log.raw_sql]

                rolling_group.each do |log|
                  current_sql_count[log.raw_sql] += 1
                end
              end
            elsif current_group.empty?
              current_group << log
            else
              current_log = rolling_group.shift
            end
          end
        end
      end
    end
  end
end
