require './helper'

class AbstractProcessorTest < EagerDB::Test
  def setup
    @match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE user_id = ?")
    @processor = EagerDB::Processors::AbstractProcessor.new(@match_statement)
  end

  def test_basic_preloading
    preload = EagerDB::SqlStatement.new("SELECT * FROM products WHERE user_id = ?", [@processor.match_result.user_id])
    @processor.add_preload_statement(preload)
    assert_equal @match_statement, @processor.match_statement
    assert_equal [preload], @processor.preload_statements

    @processor.preload("SELECT * FROM tables WHERE table_id = ?", [@processor.match_result.table_id])
    assert_equal 2, @processor.preload_statements.length

    second_preload = @processor.preload_statements[1]
    assert_equal "SELECT * FROM tables WHERE table_id = ?", second_preload.raw_sql
    assert_equal 1, second_preload.bind_values.length
    assert_equal :table_id, second_preload.bind_values[0].name
  end

  def test_preload_processing_for_non_matching_statement
    @processor.preload("SELECT * FROM parents WHERE parent_id = ?", [@processor.match_result.parent_id])

    result1 = @processor.process_preloads("some non-matching sql dude", {})
    assert_equal 0, result1.length

    result2 = @processor.process_preloads("SELECT * FROM parents WHERE parent_id = 234", {})
    assert_equal 0, result2.length
  end

  def test_preload_processing_for_matching_statement
    @processor.preload("SELECT * FROM parents WHERE parent_id = ?", [@processor.match_result.parent_id])

    result = @processor.process_preloads("SELECT * FROM users WHERE user_id = 3452123", {parent_id: 234242})
    assert_equal 1, result.length
    assert_equal "SELECT * FROM parents WHERE parent_id = 234242", result[0]
  end

end
