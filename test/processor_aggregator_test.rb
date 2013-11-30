require './helper'

class AbstractProcessorAggregatorTest < EagerDB::Test
  def setup
    @processor_aggregator = EagerDB::ProcessorAggregator::AbstractProcessorAggregator.new
  end

  def test_empty_processor_aggregator
    job = EagerDB::EagerloadQueryJob.new(
      sql: "SELECT * FROM users WHERE name = 'john'",
      processor_aggregator: @processor_aggregator)
    result = @processor_aggregator.process_job(job)

    assert result.is_a?(Array)
    assert_equal 0, result.length
  end

  def test_single_processor_in_processor_aggregator
    job = EagerDB::EagerloadQueryJob.new(
      sql: "SELECT * FROM users WHERE name = 'john'",
      processor_aggregator: @processor_aggregator)

    match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE name = ?")
    processor = EagerDB::Processors::AbstractProcessor.new(match_statement)
    @processor_aggregator.add_processor(processor)
    assert_equal 1, @processor_aggregator.processors.length

    result = @processor_aggregator.process_job(job)

    assert result.is_a?(Array)
    assert_equal 1, result.length
    assert_equal 1, result[0]
  end
end
