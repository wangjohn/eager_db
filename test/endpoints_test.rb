require './helper'

class AbstractEndpointTest < EagerDB::Test
  def test_abstract_endpoint_cannot_be_called
    message = EagerDB::Message.new('payload')

    assert_raises NoMethodError do
      endpoint = EagerDB::Endpoints::AbstractEndpoint.new
      endpoint.process_payload(message)
    end
  end
end

class DatabaseEndpointTest < EagerDB::Test
  def setup
    @history = []
    @db_proc = Proc.new { |sql| @history << sql }
    @endpoint = EagerDB::Endpoints::DatabaseEndpoint.new(@db_proc)
  end

  def test_simple_proc
    query = "SELECT * FROM users WHERE id = 5"
    message = EagerDB::Message.new(query)
    @endpoint.process_payload(message)

    assert_equal [query], @history
  end

  def test_multiple_queries
    q1 = "First query"
    q2 = "Second query"
    q3 = "This is the third query"

    @endpoint.process_payload(EagerDB::Message.new(q1))
    assert_equal [q1], @history

    @endpoint.process_payload(EagerDB::Message.new(q2))
    assert_equal [q1, q2], @history

    @endpoint.process_payload(EagerDB::Message.new(q3))
    assert_equal [q1, q2, q3], @history
  end
end
