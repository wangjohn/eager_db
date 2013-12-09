module EagerDB
  class SqlStatement
    attr_reader :non_binded_sql, :bind_values

    def initialize(non_binded_sql, bind_values = nil)
      if bind_values
        unless bind_values.is_a?(Array)
          raise ArgumentError, "Bind values must be given in an array."
        end

        @non_binded_sql = non_binded_sql
        @bind_values = bind_values
      else
        @non_binded_sql = remove_bind_values(non_binded_sql)
        @bind_values = non_binded_sql.scan(bind_values_regex).flatten
      end
    end

    def matches?(sql)
      if sql.is_a?(SqlStatement)
        nonbinded_sql = sql.non_binded_sql
      else
        nonbinded_sql = remove_bind_values(sql)
      end

      @non_binded_sql.downcase == nonbinded_sql.downcase
    end

    # Options takes +:result+ and +:sql_statement+
    #
    # +:result+ must be a QueryResult or a hash representing a result, or an
    # array of QueryResults and/or hashes.
    def inject_values(options = {})
      results = parse_result(options)
      sql_statement = parse_sql_statement(options)

      results.collect do |result|
        bind_vals = binds_with_substitutions(bind_values, result, sql_statement)
        binded_sql(bind_vals)
      end
    end

    private

      def binds_with_substitutions(bind_values, result, sql_statement)
        bind_values.collect do |bind_value|
          if bind_value.is_a?(MatchSql::MatchSqlResultVariable)
            unless result
              raise ArgumentError, "Tried using an instance of MatchSql::MatchSqlResultVariable without providing a result."
            end

            result.send(bind_value.name)
          elsif bind_value.is_a?(MatchSql::MatchSqlBindVariable) && sql_statement
            unless sql_statement
              raise ArgumentError, "Tried using an instance of MatchSql::MatchSqlBindVariable without providing a sql_statement."
            end

            sql_statement.bind_values[bind_value.index]
          else
            bind_value
          end
        end
      end

      def binded_sql(bind_vals)
        counter = -1
        non_binded_sql.gsub(/\?/) do |bind_val_marker|
          counter += 1
          bind_vals[counter]
        end
      end

      def parse_result(options)
        if (result = options[:result])
          if result.is_a?(Array)
            result.collect { |row| parse_single_row(row) }
          else
            [parse_single_row(result)]
          end
        else
          [EagerDB::QueryResult.new]
        end
      end

      def parse_single_row(result)
        if result.is_a?(EagerDB::QueryResult)
          result
        elsif result.is_a?(Hash)
          EagerDB::QueryResult.new(result)
        else
          raise ArgumentError, "Must pass either a QueryResult, a Hash, or an array of QueryResults and Hashes for the :result option"
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
