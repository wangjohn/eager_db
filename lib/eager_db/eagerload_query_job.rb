module EagerDB
  @queue = :eagerload_query

  class EagerloadQueryJob
    attr_reader :sql, :result, :created_at, :processor_aggregator
    def initialize(options)
      @sql = options[:sql]
      @result = options[:result]
      @created_at = options[:created_at]

      @processor_aggregator = options[:processor_aggregator]
    end

    def work
      preloads = processor_aggregator.process_job(self)
      unless preloads.empty?
        message = Message.new(preloads)
        communication_channel.send_database_message(message)
      end
    end
  end
end
