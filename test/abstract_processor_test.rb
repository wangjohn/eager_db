require './helper'

class AbstractProcessorTest < EagerDB::Test
  def setup
    @match_statement = EagerDB::SqlStatement.new("SELECT * FROM users WHERE user_id = ?")
    @processor = EagerDB::Processors::AbstractProcessor.new(@match_statement)
  end
end
