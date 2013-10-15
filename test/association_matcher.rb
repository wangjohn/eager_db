require 'eager_db'
require 'minitest/autorun'

class AssociationMatcherTest < Minitest::Test
  class SomeMatcher < AssociationMatcher
    match_on "SELECT * FROM users WHERE id = ?"

    preload "SELECT * FROM products WHERE user_id = ?", result.id
  end

  def test_matcher_raw_sql
    assert_equal "SELECT * FROM users WHERE id = ?", SomeMatcher.match_sql.raw_sql
    assert_equal "SELECT * FROM products WHERE user_id = ?", SomeMatcher.preloads.first.raw_sql
  end

  def test_matcher_result
    assert_equal SomeMatcher, SomeMatcher.result.matcher

    assert SomeMatcher.result.respond_to?(:some_variable_name)
    assert SomeMatcher.result.respond_to?(:another_name)
    assert SomeMatcher.result.respond_to?(:duuudes_name)
  end

  def test_matcher_result_variable
    var = SomeMatcher.result.get_variable(:some_variable)
    assert_equal SomeMatcher.result, var.result
    assert_equal :some_variable, var.name
  end
end
