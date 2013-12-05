module EagerDB
  class ResqueEagerloadQueryJob
    @queue = :eagerload

    def self.perform(job)
      job.work
    end
  end

  class EagerloadQueryJob
    attr_reader :sql, :result, :created_at, :processor_aggregator, :communication_channel

    def initialize(options = {})
      validate_options!(options)

      @sql = options[:sql]
      @processor_aggregator = options[:processor_aggregator]
      @communication_channel = options[:communication_channel]

      @result = options[:result] || {}
      @created_at = options[:created_at] || Time.now
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
        [:sql, :processor_aggregator, :communication_channel].each do |opt|
          unless options[opt]
            raise ArgumentError, "EagerloadQueryJob must include the '#{opt}' option."
          end
        end
      end
  end
end
