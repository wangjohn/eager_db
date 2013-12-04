module EagerDB
  class Message
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end
  end
end
