require './helper'

# FIXME: These tests are currently broken because the SqlParse hasn't been
# written yet. So, I guess we should write it!
class SqlParserTest < EagerDB::Test
  def test_single_bind_value_statement
    sql = "SELECT * FROM some_table WHERE name = 'hello'"
    parsed_result = EagerDB::SqlStatement.new(sql)
    assert_equal ["'hello'"], parsed_result.bind_values
    assert_equal "SELECT * FROM some_table WHERE name = ?", parsed_result.raw_sql
  end

  def test_multiple_bind_values_statement
    sql = "SELECT * FROM some_table WHERE name = 'hello' AND created_at > 5"
    parsed_result = EagerDB::SqlStatement.new(sql)
    assert_equal ["'hello'", "5"], parsed_result.bind_values
    assert_equal "SELECT * FROM some_table WHERE name = ? AND created_at > ?", parsed_result.raw_sql
  end

  def test_correctly_find_single_table
    sql = "SELECT * FROM some_table WHERE name = 'hello'"
    parsed_result = EagerDB::SqlStatement.new(sql)
    assert_equal ["'hello'"], parsed_result.bind_values
    assert_equal "SELECT * FROM some_table WHERE name = ?", parsed_result.raw_sql
  end

  def test_correctly_find_multiple_tables
    sql = "SELECT * FROM some_table AS st, another_table AS at WHERE st.name = 'hello'"
    parsed_result = EagerDB::SqlStatement.new(sql)
    assert_equal ["'hello'"], parsed_result.bind_values
    assert_equal "SELECT * FROM some_table AS st, another_table AS at WHERE st.name = ?", parsed_result.raw_sql
  end

  def test_correctly_find_group_by_values
    sql = "SELECT COUNT(*) FROM some_table WHERE id > 5 GROUP BY name"
    parsed_result = EagerDB::SqlStatement.new(sql)
    assert_equal ['5'], parsed_result.bind_values
    assert_equal "SELECT COUNT(*) FROM some_table WHERE id > ? GROUP BY name", parsed_result.raw_sql
  end
end
