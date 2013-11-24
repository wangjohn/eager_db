module EagerDB
  class SqlStatement
    attr_reader :raw_sql, :bind_values

    def initialize(raw_sql, bind_values = nil)
      if bind_values
        @raw_sql = raw_sql
        @bind_values = bind_values
      else
        parse_bind_values!(raw_sql)
      end
    end

    def matches?(sql)
      nonbinded_sql = remove_bind_values(sql)
      @raw_sql.downcase == nonbinded_sql.downcase
    end

    def inject_values(sql_statement, result)
      bind_vals = @bind_values.collect do |bind_value|
        if bind_value.is_a?(MatchSqlResultVariable)
          result.send(bind_value.name)
        elsif bind_value.is_a?(MatchSqlBindValue)
          sql_statement.bind_values[bind_value.index]
        else
          bind_value
        end
      end

      counter = 0
      raw_sql.gsub(/\?/) do |bind_val_marker|
        bind_vals[counter]
        counter += 1
      end
    end

    private

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

      def parse_bind_values!(sql)
        @bind_values = sql.scan(bind_values_regex).flatten
        @raw_sql = remove_bind_values(sql)
      end

      def bind_values_regex
        @bind_values_regex ||= /('.*?'|[0-9]+|\".*?\")/
      end
  end
end
