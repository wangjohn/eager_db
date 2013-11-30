require './helper'

class EndpointsTest < EagerDB::Test

  def test_abstract_endpoint_cannot_be_called
    message = EagerDB::Message.new('payload')

    assert_raises NoMethodError do
      endpoint = EagerDB::Endpoints::AbstractEndpoint.new
      endpoint.process_payload(message)
    end
  end
end
