module EagerDB
  @queue = :eagerload_query

  class EagerloadQueryJob
    def initialize(sql, created_at, processors = [])
      @sql = sql
      @created_at = created_at
      @processors = EagerDB::Processors.aggregate_processors(processors)
    end

    def perform
    end
  end
end
