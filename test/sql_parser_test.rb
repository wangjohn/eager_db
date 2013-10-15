require 'minitest'

class SqlParserTest < MiniTest

  def setup
    @parser = EagerDB::SqlParser.new
  end

  def test_single_bind_value_statement
    sql = "SELECT * FROM some_table WHERE name = 'hello'"
    parsed_result = @parser.parse(sql)
    assert_equal ["hello"], parsed_result.bind_values
    assert_equal "SELECT * FROM some_table WHERE name = ?", parsed_result.non_binded_result
  end

  def test_multiple_bind_values_statement
    sql = "SELECT * FROM some_table WHERE name = 'hello' AND created_at > 5"
    parsed_result = @parser.parse(sql)
    assert_equal ["hello", 5], parsed_result.bind_values
    assert_equal "SELECT * FROM some_table WHERE name = ? AND created_at > ?", parsed_result.non_binded_result
  end

  def test_correctly_find_single_table
    sql = "SELECT * FROM some_table WHERE name = 'hello'"
    parsed_result = @parser.parse(sql)
    assert_equal ['some_table'], parsed_result.table_names
  end

  def test_correctly_find_multiple_tables
    sql = "SELECT * FROM some_table AS st, another_table AS at WHERE st.name = 'hello'"
    parsed_result = @parser.parse(sql)
    assert_equal ['some_table', 'another_table'], parsed_result.table_names
  end

  def test_correctly_find_group_by_values
    sql = "SELECT COUNT(*) FROM some_table WHERE id > 5 GROUP BY name"
    parsed_result = @parser.parse(sql)
    assert_equal ['name'], parsed_result.grouped_by_columns
  end

  def test_total_parser
    sql = "SELECT COUNT(*) FROM some_table WHERE id > 5 GROUP BY name"
    parsed_result = @parser.parse(sql)
    assert_equal "SELECT OPERATOR(*) FROM TABLE_NAME WHERE (COLUMN_NAME OPERATOR ?) (GROUP BY COLUMN_NAME)", parsed_result.abstract_result
  end
end
