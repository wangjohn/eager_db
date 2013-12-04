module EagerDB
  module Endpoints
    class AbstractEndpoint
      def process_payload(message)
        raise NoMethodError, "AbstractEndpoint cannot process payload because it's abstract."
      end
    end

    # This class needs to be initialization with a proc that can be called with
    # some SQL. The message that is passed to the DatabaseEndpoint will have a
    # SQL string as it's payload, and the +db_proc+ should be able to prcoess 
    # that payload.
    #
    # For example, one could use the following as a database endpoint, if you
    # wanted the SQL statements to be processed by ActiveRecord:
    #
    #   db_proc = Proc.new do { |sql| ActiveRecord::Base.connection.execute(sql) }
    #   endpoint = DatabaseEndpoint.new(db_proc)
    #
    # The resulting endpoint would be able to process SQL messages like so:
    #
    #   message = Message.new("SELECT * FROM users WHERE id = 234")
    #   endpoint.process_payload(message)
    #
    # This would executive the SQL statement of the message payload.
    class DatabaseEndpoint < AbstractEndpoint
      def initialize(db_proc)
        @db_proc = db_proc
      end

      def process_payload(message)
        @db_proc.call(message.payload)
      end
    end

    # This class takes an instance of a resque and an instance of a
    # ProcessorAggregator. When messages are sent to this endpoint, a new 
    # EagerloadQueryJob is created and placed on the resque. Messages must be
    # hashes and contain fields values for +:sql+ and +:result+.
    #
    #   :sql    - contains a raw SQL string
    #   :result - contains a hash of the result of running the SQL statement,
    #             can optionally be empty.
    #
    class EagerDBEndpoint < AbstractEndpoint
      attr_reader :processor_aggregator

      def initialize(resque, processor_aggregator)
        @resque = resque
        @processor_aggregator = processor_aggregator
      end

      def process_payload(message)
        options = {
          sql: message.payload[:sql],
          result: message.payload[:result],
          created_at: Time.now,
          processor_aggregator: processor_aggregator
        }

        job = EagerloadQueryJob.new(options)
        @resque.enqueue(ResqueEagerloadQueryJob, job)
      end
    end
  end
end
