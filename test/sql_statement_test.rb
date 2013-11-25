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
end
