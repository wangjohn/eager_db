module EagerDB
  class SqlStatement
    attr_reader :raw_sql, :bind_values

    def initialize(raw_sql, bind_values = nil)
      @raw_sql = raw_sql
      @bind_values = bind_values
    end

    def matches?(sql)
      if @bind_values && @bind_values.empty?
        @raw_sql.downcase == sql.downcase
      else
        nonbinded_sql = remove_bind_values(sql)
        @raw_sql.downcase == nonbinded_sql.downcase
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
      end
  end
end
