require './helper'

class EagerloadQueryJobTest < EagerDB::Test
  def setup
    @aggregator = create_aggregator
    @channel = create_communication_channel(@aggregator)

    options = {
      sql: "SELECT * FROM users WHERE name = 'ryan'",
      result: {id: 12345, name: 'ryan', brother: 'john'}, 
      processor_aggregator: @aggregator,
      communication_channel: @channel
    }
    @job = EagerDB::EagerloadQueryJob.new(options)
  end

  def create_aggregator
    aggregator = EagerDB::ProcessorAggregator::AbstractProcessorAggregator.new
    match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE name = ?")
    processor = EagerDB::Processors::AbstractProcessor.new(match_statement)
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

  def test_job_with_no_processors_in_aggregator
  end
end
