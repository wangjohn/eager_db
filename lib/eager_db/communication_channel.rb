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

      @database_endpoint.set_communication_channel(self)
      @eager_db_endpoint.set_communication_channel(self)
    end

    def send_database_message(message)
      @database_endpoint.process_payload(message)
    end

    def send_eager_db_message(message)
      @eager_db_endpoint.process_payload(message)
    end

    def process_sql(sql, result = nil)
      message = Message.new({sql: sql, result: result})
      send_eager_db_message(message)
    end
  end
end
