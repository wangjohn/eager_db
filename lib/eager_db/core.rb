require 'resque'

module EagerDB
  module Core
    # 
    # == Create Channel Options
    #
    # * <tt>:processor_aggregator</tt>
    # * <tt>:resque</tt>
    # * <tt>:processor_file</tt>
    #
    def create_channel(db_proc, options = {})
      processor_aggregator = options[:processor_aggregator] ||
        ProcessorAggregator::AbstractProcessorAggregator.new
      resque = options[:resque] || Resque

      if processor_file = options[:processor_file]
        attach_processors_from_file(processor_file, processor_aggregator)
      end

      db_endpoint = Endpoints::DatabaseEndpoint.new(db_proc)
      eager_db_endpoint = Endpoints::EagerDBEndpoint.new(resque, processor_aggregator)

      CommunicationChannel.new(db_endpoint, eager_db_endpoint)
    end

    private

      def attach_processors_from_file(processor_file, aggregator)
        converter = FileConverter.new(aggregator)
        converter.convert_file_processors(processor_file)
      end
  end
end

