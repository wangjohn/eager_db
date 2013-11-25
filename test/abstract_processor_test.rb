require './helper'

class AbstractProcessorTest < EagerDB::Test
  def setup
    @match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE user_id = ?")
    @processor = EagerDB::Processors::AbstractProcessor.new(@match_statement)
  end

  def test_basic_preloading
    @processor.add_preload_statement(EagerDB::SqlStatement.new("SELECT * FROM products WHERE user_id = ?", [@processor.match_result.user_id]))
  end

  def test_basic_preloading_with_add_preload
    @processor.preload("SELECT * FROM products WHERE user_id = ?", [@processor.match_result.user_id])
  end
end
