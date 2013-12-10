module EagerDB
  module Prediction
    class SqlLog
      attr_reader :raw_sql, :processed_at, :user, :sql_statement

      def initialize(raw_sql, processed_at, user)
        @raw_sql = raw_sql
        @processed_at = processed_at
        @user = user

        @sql_statement = EagerDB::SqlStatement.new(raw_sql)
      end

      def non_binded_sql
        sql_statement.non_binded_sql
      end

      def bind_values
        sql_statement.bind_values
      end
    end
  end
end
