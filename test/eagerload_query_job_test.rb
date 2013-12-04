require 'helper'

class EagerloadQueryJobTest < EagerDB::Test
  def setup
    @aggregator = create_aggregator
    @channel = create_communication_channel(@aggregator)
 end

  def create_aggregator
    aggregator = EagerDB::ProcessorAggregator::AbstractProcessorAggregator.new
    processor = EagerDB::Processors::AbstractProcessor.new("SELECT * FROM users WHERE name = ?")
    processor.preload("SELECT * FROM products WHERE user_name = ?", [processor.match_bind_value(0)])
    aggregator.add_processor(processor)

    aggregator
  end

  def create_communication_channel(aggregator)
    @database_history = []
    @resque = []
    database_endpoint = EagerDB::Endpoints::DatabaseEndpoint.new(Proc.new { |sql| @database_history << sql })
    eager_db_endpoint = EagerDB::Endpoints::EagerDBEndpoint.new(@resque, aggregator)
    EagerDB::CommunicationChannel.new(database_endpoint, eager_db_endpoint)
  end

  def test_no_communication_channel_raises_error
    job = EagerDB::EagerloadQueryJob.new({
      sql: "SELECT * FROM users WHERE name = 'ryan'",
      result: {id: 12345, name: 'ryan', brother: 'john'}, 
      processor_aggregator: @aggregator,
    })
    assert_raises ArgumentError do
      job.work
    end
  end

  def test_job_which_does_not_match_in_aggregator
    job = EagerDB::EagerloadQueryJob.new({
      sql: "SELECT * FROM blahblahs WHERE name = 'david' GROUP BY company",
      result: {id: 12345, name: 'ryan', brother: 'john'}, 
      processor_aggregator: @aggregator,
      communication_channel: @channel
    })
    job.work

    assert_equal 0, @database_history.length
  end

  def test_job_which_matches_a_single_processor_in_aggregator
    job = EagerDB::EagerloadQueryJob.new({
      sql: "SELECT * FROM users WHERE name = 'ryan'",
      result: {id: 12345, name: 'ryan', brother: 'john'}, 
      processor_aggregator: @aggregator,
      communication_channel: @channel
    })
    job.work

    assert_equal 1, @database_history.flatten.length
    assert_equal ["SELECT * FROM products WHERE user_name = 'ryan'"], @database_history.flatten
  end

  def test_multiple_job_runs_on_an_aggregator
    job1 = EagerDB::EagerloadQueryJob.new({
      sql: "SELECT * FROM users WHERE name = 'ryan'",
      result: {id: 12345, name: 'ryan', brother: 'john'}, 
      processor_aggregator: @aggregator,
      communication_channel: @channel
    })
    job1.work

    job2 = EagerDB::EagerloadQueryJob.new({
      sql: "SELECT * FROM users WHERE name = 'CRAZYMAN'",
      result: {id: 54321, name: 'CRAZYMAN', brother: 'CRAZYDUDE'},
      processor_aggregator: @aggregator,
      communication_channel: @channel
    })
    job2.work

    result = @database_history.flatten
    assert_equal 2, result.length
    assert_equal "SELECT * FROM products WHERE user_name = 'ryan'", result[0]
    assert_equal "SELECT * FROM products WHERE user_name = 'CRAZYMAN'", result[1]
  end
end
