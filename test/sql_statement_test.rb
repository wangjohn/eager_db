require 'eager_db'
require 'minitest/autorun'

class SqlStatementTest < Minitest::Unit::TestCase
  def setup
    @complex_sql = "SELECT * FROM users WHERE id = 5 AND name = 'john' AND created_at > 2342342 GROUP BY name LIMIT 5"
    @simple_sql = "SELECT * FROM users WHERE id = '5' AND name = 'john'"
    @complex_raw = "SELECT * FROM users WHERE id = ? AND name = ? AND created_at > ? GROUP BY name LIMIT ?"
    @simple_raw = "SELECT * FROM users WHERE id = ? AND name = ?"
  end

  def test_sql_parsing
    complex_statement = SqlStatement.new(@complex_sql)

    assert_equal [5, 'john', 2342342, 5], complex_statement.bind_values
    assert_equal @complex_raw.downcase, complex_statement.raw_sql
    assert complex_statement.matches?(@complex_sql)
    assert complex_statement.matches?(@complex_raw)

    simple_statement = SqlStatement.new(@simple_sql)

    assert_equal ['5', 'john'], simple_statement.bind_values
    assert_equal @simple_raw.downcase, simple_statement.raw_sql
    assert simple_statement.matches?(@simple_sql)
    assert simple_statement.matches?(@simple_raw)
  end

  def test_sql_matching
    complex_statement = SqlStatement.new(@complex_raw)
    assert complex_statement.matches(@complex_sql)

    simple_statement = SqlStatement.new(@simple_raw)
    assert simple_statement.matches(@simple_sql)
  end

  # TODO: finish writing this test.
  def test_execute_statement
    execute_method = Proc.new do |sql, name, binds|
      assert "asdf", sql
      assert "SQL", name
      assert [], binds
    end

    SqlStatement.new(@simple_raw)
  end
end
