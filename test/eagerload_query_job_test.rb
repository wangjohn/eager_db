require './helper'

class EagerloadQueryJobTest < EagerDB::Test
  def setup
    @aggregator = EagerDB::ProcessorAggregator::AbstractProcessorAggregator.new
    match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE name = ?")
    processor = EagerDB::Processors::AbstractProcessor.new(match_statement)
    processor.preload("SELECT * FROM products WHERE user_name = ?", [processor.match_bind_value(0)])
    options = {
      sql: "SELECT * FROM users WHERE name = 'ryan'",
      result: {id: 12345, name: 'ryan', brother: 'john'}, 
      processor_aggregator: @aggregator
    }
    @job = EagerDB::EagerloadQueryJob.new(options)
  end

  def test_no_communication_channel_raises_error
    assert_raises ArgumentError do
      @job.work
    end
  end

  def test_job_with_no_processors_in_aggregator
  end
end
