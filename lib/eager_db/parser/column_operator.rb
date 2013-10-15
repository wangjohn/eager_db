module EagerDB
  class ColumnOperator
    VALID_OPERATORS = [
      '=',
      'IS',
      '<',
      '>',
      'LIKE',
    ]

    def initialize(sql)
      @sql = sql
    end

    def parse
      @sql
    end
  end
end
