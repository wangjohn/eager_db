require 'resque'

module EagerDB
  module Core
    def create_channel(db_proc, options = {})
      processor_aggregator = options[:processor_aggregator] ||
        ProcessorAggregator::AbstractProcessorAggregator.new
      resque = options[:resque] || Resque

      db_endpoint = Endpoints::DatabaseEndpoint.new(db_proc)
      eager_db_endpoint = Endpoints::EagerDBEndpoint.new(resque, processor_aggregator)

      CommunicationChannel.new(db_endpoint, eager_db_endpoint)
    end
  end
end

