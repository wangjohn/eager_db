module EagerDB
  class SqlStatement
    attr_reader :raw_sql, :bind_values

    def initialize(raw_sql, bind_values = nil)
      if bind_values
        @raw_sql = raw_sql
        @bind_values = bind_values
      else
        @raw_sql = remove_bind_values(raw_sql)
        @bind_values = raw_sql.scan(bind_values_regex).flatten
      end
    end

    def matches?(sql)
      if sql.is_a?(SqlStatement)
        nonbinded_sql = sql.raw_sql
      else
        nonbinded_sql = remove_bind_values(sql)
      end

      @raw_sql.downcase == nonbinded_sql.downcase
    end

    # Options takes +:result+ and +:sql_statement+
    def inject_values(options = {})
      result = parse_result(options)
      sql_statement = parse_sql_statement(options)

      bind_vals = bind_values.collect do |bind_value|
        if bind_value.is_a?(MatchSql::MatchSqlResultVariable) && result
          result.send(bind_value.name)
        elsif bind_value.is_a?(MatchSql::MatchSqlBindVariable) && sql_statement
          sql_statement.bind_values[bind_value.index]
        else
          bind_value
        end
      end

      counter = -1
      raw_sql.gsub(/\?/) do |bind_val_marker|
        counter += 1
        bind_vals[counter]
      end
    end

    private

      def parse_result(options)
        if (result = options[:result])
          if result.is_a?(EagerDB::QueryResult)
            result
          elsif result.is_a?(Hash)
            EagerDB::QueryResult.new(result)
          else
            raise ArgumentError, "Must pass either a QueryResult or a Hash for the :result option"
          end
        end
      end

      def parse_sql_statement(options)
        if (statement = options[:sql_statement])
          if statement.is_a?(EagerDB::SqlStatement)
            statement
          elsif statement.is_a?(String)
            EagerDB::SqlStatement.new(statement)
          else
            raise ArgumentError, "Must pass either a SqlStatement or a String for the :sql_statement option"
          end
        end
      end

      # Removes bind values from a SQL query and replaces them with "?". This
      # allows for comparison between the structure of two SQL statements. 
      # For example:
      #
      #   s = "SELECT * FROM users WHERE id = '5' AND name = 'john'"
      #
      #   remove_bind_values(s)
      #       # => "SELECT * FROM users WHERE id = ? AND name = ?"
      #
      def remove_bind_values(sql)
        sql.gsub(bind_values_regex, '?')
      end

      def bind_values_regex
        @bind_values_regex ||= /('.*?'|[0-9]+|\".*?\")/
      end
  end
end
