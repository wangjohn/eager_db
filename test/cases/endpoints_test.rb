require 'cases/helper'

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

class TestResque < Array
  def enqueue(job_type, job)
    self << job
  end
end

class EagerDBEndpointTest < EagerDB::Test
  def setup
    @resque = TestResque.new
    @processor_aggregator = "Some string that will stand in for an aggregator"
    @endpoint = EagerDB::Endpoints::EagerDBEndpoint.new(@resque, @processor_aggregator)

    db_endpoint = EagerDB::Endpoints::DatabaseEndpoint.new(Proc.new { |k| })
    @channel = EagerDB::CommunicationChannel.new(db_endpoint, @endpoint)
  end

  def test_creates_simple_job
    statement = "SELECT * FROM tables WHERE name = 'john'"
    message = EagerDB::Message.new({sql: statement})
    @endpoint.process_payload(message)

    assert_equal 1, @resque.length
    assert @resque[0].is_a?(EagerDB::EagerloadQueryJob)
    assert_equal statement, @resque[0].sql
  end

  def test_creates_multiple_jobs
    q1 = "First query"
    q2 = "Second query"
    q3 = "This is the third query"

    @endpoint.process_payload(EagerDB::Message.new(sql: q1))
    @endpoint.process_payload(EagerDB::Message.new(sql: q2))
    @endpoint.process_payload(EagerDB::Message.new(sql: q3))

    assert_equal 3, @resque.length
    @resque.each do |job|
      assert job.is_a?(EagerDB::EagerloadQueryJob)
    end
  end

  def test_can_remove_and_add_jobs_to_the_resque
    assert_equal 0, @resque.length
    @endpoint.process_payload(EagerDB::Message.new(sql: "Some Query"))
    assert_equal 1, @resque.length

    assert @resque.pop.is_a?(EagerDB::EagerloadQueryJob)
    assert_equal 0, @resque.length

    @endpoint.process_payload(EagerDB::Message.new(sql: "Some Query"))
    @endpoint.process_payload(EagerDB::Message.new(sql: "Some Query"))
    assert_equal 2, @resque.length

    assert @resque.pop.is_a?(EagerDB::EagerloadQueryJob)
    assert_equal 1, @resque.length

    @endpoint.process_payload(EagerDB::Message.new(sql: "Some Query"))
    assert_equal 2, @resque.length
  end
end
