module EagerDB
  @queue = :eagerload_query

  class EagerloadQueryJob
    attr_reader :sql, :result, :created_at, :processor_aggregator
    def initialize(sql, result, created_at, processor_aggregator)
      @sql = sql
      @result = result
      @created_at = created_at

      @processor_aggregator = processor_aggregator
    end

    def work
      result = processor_aggregator.process_job(self)
      if !result.empty?
        communication_channel.database_job(
      end
    end
  end
end
