module EagerDB
  @queue = :eagerload_query

  class EagerloadQueryJob
    attr_reader :sql, :result, :created_at
    def initialize(sql, result, created_at)
      @sql = sql
      @result = result
      @created_at = created_at
    end
  end
end
