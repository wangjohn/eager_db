require 'helper'

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
    preload = EagerDB::SqlStatement.new("SELECT * FROM products WHERE user_name = ?", [processor.match_bind_value(0)])
    processor.add_preload_statement(preload)
    @processor_aggregator.add_processor(processor)

    assert_equal 1, @processor_aggregator.processors.length

    result = @processor_aggregator.process_job(job)

    assert result.is_a?(Array)
    assert_equal 1, result.length
    assert_equal "SELECT * FROM products WHERE user_name = 'john'", result[0]
  end

  def test_multiple_processors_in_processor_aggregator
    job = EagerDB::EagerloadQueryJob.new(
      sql: "SELECT * FROM users WHERE name = 'john'",
      processor_aggregator: @processor_aggregator)

    match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE name = ?")
    processor1 = EagerDB::Processors::AbstractProcessor.new(match_statement)
    preload1 = EagerDB::SqlStatement.new("SELECT * FROM products WHERE user_name = ?", [processor1.match_bind_value(0)])
    processor1.add_preload_statement(preload1)
    @processor_aggregator.add_processor(processor1)

    processor2 = EagerDB::Processors::AbstractProcessor.new(match_statement)
    preload2 = EagerDB::SqlStatement.new("SELECT * FROM suits WHERE suit_name = ?", [processor2.match_bind_value(0)])
    processor2.add_preload_statement(preload2)
    @processor_aggregator.add_processor(processor2)

    assert_equal 2, @processor_aggregator.processors.length
    result = @processor_aggregator.process_job(job)

    assert result.is_a?(Array)
    assert_equal 2, result.length
    assert_equal "SELECT * FROM products WHERE user_name = 'john'", result[0]
    assert_equal "SELECT * FROM suits WHERE suit_name = 'john'", result[1]
  end

  def test_multiple_processors_where_only_one_matches
    job = EagerDB::EagerloadQueryJob.new(
      sql: "SELECT * FROM users WHERE name = 'john'",
      result: { id: 12345 },
      processor_aggregator: @processor_aggregator)

    match_statement1 = EagerDB::SqlStatement.new("SELECT * FROM users WHERE name = ?")
    processor1 = EagerDB::Processors::AbstractProcessor.new(match_statement1)
    preload1 = EagerDB::SqlStatement.new("SELECT * FROM products WHERE user_name = ? AND id = ?", 
                                         [processor1.match_bind_value(0), processor1.match_result.id])
    processor1.add_preload_statement(preload1)
    @processor_aggregator.add_processor(processor1)

    match_statement2 = EagerDB::SqlStatement.new("SELECT * FROM poopies WHERE id = ?")
    processor2 = EagerDB::Processors::AbstractProcessor.new(match_statement2)
    preload2 = EagerDB::SqlStatement.new("SELECT * FROM suits WHERE suit_name = ?", [processor2.match_bind_value(0)])
    processor2.add_preload_statement(preload2)
    @processor_aggregator.add_processor(processor2)

    assert_equal 2, @processor_aggregator.processors.length
    result = @processor_aggregator.process_job(job)

    assert result.is_a?(Array)
    assert_equal 1, result.length
    assert_equal "SELECT * FROM products WHERE user_name = 'john' AND id = 12345", result[0]
  end
end
