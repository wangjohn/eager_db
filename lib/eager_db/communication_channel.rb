module EagerDB
  # This is a class that encapsulates how SQL statements get passed around.
  # A +CommunicationChannel+ is initialized with two endpoints:
  #
  #   - database_endpoint connects EagerDB to the database of an application
  #   - eager_db_endpoint connects the database of an application to EagerDB
  #
  # Each endpoint is passed messages which contain sql queries. Once the message
  # is passed across the communication channel, the endpoint needs to know how
  # to process the message.
  #
  # Each message has a payload which consists of a SQL string. The endpoint will
  # run its +process_payload+ method on each message to deal with the message.
  class CommunicationChannel
    attr_reader :database_endpoint, :eager_db_endpoint

    def initialize(database_endpoint, eager_db_endpoint)
      @database_endpoint = database_endpoint
      @eager_db_endpoint = eager_db_endpoint
    end
  end

  class Message
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end
  end

  class AbstractEndpoint
    def process_payload(message)
      raise "AbstractEndpoint cannot process payload because it's abstract."
    end
  end

  class DatabaseEndpoint < AbstractEndpoint
    def initialize
    end

    def process_payload(message)

    end
  end

  class EagerDBEndpoint < AbstractEndpoint
    attr_reader :processor_aggregator

    def initialize(resque, processor_aggregator)
      @resque = resque
      @processor_aggregator = processor_aggregator
    end

    def process_payload(message)
      @resque << EagerloadQueryJob.new(message.payload[:sql], message.payload[:result], Time.now, processor_aggregator)
    end
  end
end
