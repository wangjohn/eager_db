module EagerDB
  module Prediction
    class SqlLog
      attr_reader :raw_sql, :processed_at

      def initialize(raw_sql, processed_at)
        @raw_sql = raw_sql
        @processed_at = processed_at
      end

      def non_binded_sql
        @sql_statement ||= EagerDB::SqlStatement.new(raw_sql)
        @sql_statement.raw_sql
      end

      def bind_values
        @sql_statement ||= EagerDB::SqlStatement.new(raw_sql)
        @sql_statement.bind_values
      end
    end
  end
end
