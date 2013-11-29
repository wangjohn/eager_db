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

    def send_database_message(message)
      @database_endpoint.process_payload(message)
    end

    def send_eager_db_message(message)
      @eager_db_endpoint.process_payload(message)
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

  # TODO: Figure out how to process this.
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
      options = {
        sql: message.payload[:sql],
        result: message.payload[:result],
        created_at: Time.now,
        processor_aggregator: processor_aggregator
      }

      @resque << EagerloadQueryJob.new(options)
    end
  end
end
