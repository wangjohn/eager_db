require './helper'

class EagerDB::SqlStatementTest < EagerDB::Test
  def setup
    @complex_sql = "SELECT * FROM users WHERE id = 5 AND name = 'john' AND created_at > 2342342 GROUP BY name LIMIT 5"
    @simple_sql = "SELECT * FROM users WHERE id = '5' AND name = 'john'"
    @complex_raw = "SELECT * FROM users WHERE id = ? AND name = ? AND created_at > ? GROUP BY name LIMIT ?"
    @simple_raw = "SELECT * FROM users WHERE id = ? AND name = ?"
  end

  class FakeProcessor
    VARIABLES = [:v1, :v2, :v3, :v4]
    def result_variable?(name)
      VARIABLES.include?(name)
    end
  end

  def test_sql_parsing
    complex_statement = EagerDB::SqlStatement.new(@complex_sql)

    assert_equal ["5", "'john'", "2342342", "5"], complex_statement.bind_values
    assert_equal @complex_raw.downcase, complex_statement.raw_sql.downcase
    assert complex_statement.matches?(@complex_sql)
    assert complex_statement.matches?(@complex_raw)

    simple_statement = EagerDB::SqlStatement.new(@simple_sql)

    assert_equal ["'5'", "'john'"], simple_statement.bind_values
    assert_equal @simple_raw.downcase, simple_statement.raw_sql.downcase
    assert simple_statement.matches?(@simple_sql)
    assert simple_statement.matches?(@simple_raw)
  end

  def test_sql_matching
    complex_statement = EagerDB::SqlStatement.new(@complex_raw)
    assert complex_statement.matches?(@complex_sql)

    simple_statement = EagerDB::SqlStatement.new(@simple_raw)
    assert simple_statement.matches?(@simple_sql)
  end

  def test_inject_result_values
    processor = FakeProcessor.new
    match_result = EagerDB::MatchSql::MatchSqlResult.new(FakeProcessor.new)
    simple_statement = EagerDB::SqlStatement.new("SELECT * FROM ?", [match_result.v1])
    result = EagerDB::QueryResult.new({v1: 'value1'})

    injected_statement = simple_statement.inject_values(result: result)

    assert_equal "SELECT * FROM value1", injected_statement
  end

  def test_inject_bind_values
    processor = FakeProcessor.new

    bind0 = EagerDB::MatchSql::MatchSqlBindVariable.new(0)
    bind1 = EagerDB::MatchSql::MatchSqlBindVariable.new(1)
    bind2 = EagerDB::MatchSql::MatchSqlBindVariable.new(2)

    simple_statement = EagerDB::SqlStatement.new("SELECT * FROM ? WHERE user_id = ? AND name = ?", [bind2, bind1, bind0])

    bind_value0 = 'johnny boi'
    bind_value1 = 'sherwinning'
    bind_value2 = 'pokerbot'

    statement = EagerDB::SqlStatement.new("", [bind_value0, bind_value1, bind_value2])

    injected_statement = simple_statement.inject_values(sql_statement: statement)
    assert_equal "SELECT * FROM #{bind_value2} WHERE user_id = #{bind_value1} AND name = #{bind_value0}", injected_statement
  end
end
