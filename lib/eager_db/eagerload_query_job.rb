module EagerDB
  @queue = :eagerload_query

  class EagerloadQueryJob
    def initialize(sql, created_at, query_processor = nil)
      @sql = sql
      @created_at = created_at
      @query_processor = EagerDB::Processor.find_processor(query_processor)
    end

    def perform
    end
  end
end
