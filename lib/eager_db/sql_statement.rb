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

    # To execute a SqlStatement, you need an +execute_method+ which can be
    # called.
    def execute(execute_method, sql_statement, result)
      bind_vals = @bind_values.collect do |bind_value|
        if bind_value.is_a?(PreloaderResultVariable)
          result.send(bind_value.name)
        else if bind_value.is_a?(PreloaderBindVariable)
          sql_statement.bind_values[bind_value.index]
        else
          bind_value
        end
      end

      execute_method.call(sql_statement.raw_sql, binds = bind_vals)
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
