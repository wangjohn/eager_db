module EagerDB
  class EagerloadQueryJob
    attr_reader :sql, :result, :created_at, :processor_aggregator

    def initialize(options = {})
      validate_options!(options)

      @sql = options[:sql]
      @result = options[:result] || {}
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

    private

      def validate_options!(options)
        [:sql, :created_at, :processor_aggregator].each do |opt|
          unless options[opt]
            raise ArgumentError, "EagerloadQueryJob must included the '#{opt}' option."
          end
        end
      end
  end
end
