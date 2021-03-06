require 'cases/helper'

class ProbabilityCalculatorTest < EagerDB::Test
  def test_empty_log_files_returns_no_likely_transitions
    calculator = EagerDB::Prediction::ProbabilityCalculator.new([], 10)
    transitions = calculator.likely_transitions

    assert_equal 0, transitions.length
  end

  def test_single_log_file_returns_no_likely_transitions
    log_files = [EagerDB::Prediction::SqlLog.new("some sql statement", Time.now, "user1")]
    calculator = EagerDB::Prediction::ProbabilityCalculator.new(log_files, 10)
    transitions = calculator.likely_transitions

    assert_equal 0, transitions.length
  end

  def test_two_log_files_from_same_user_returns_a_single_transition
    t = Time.now
    log_files = [
      EagerDB::Prediction::SqlLog.new("some sql statement", t, "user1"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 1, "user1")
    ]

    calculator = EagerDB::Prediction::ProbabilityCalculator.new(log_files, 10)
    transitions = calculator.likely_transitions

    assert_equal 1, transitions.length
    assert_equal ["another sql statement"], transitions["some sql statement"]
    assert_equal 1.0, calculator.probability_storage["some sql statement"].probabilities["another sql statement"]
  end

  def test_many_log_files_from_same_user_returns_multiple_transitions
    t = Time.now
    log_files = [
      EagerDB::Prediction::SqlLog.new("some sql statement", t, "user1"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 1, "user1"),
      EagerDB::Prediction::SqlLog.new("some sql statement", t + 20, "user1"),
      EagerDB::Prediction::SqlLog.new("big sql statement", t + 22, "user1"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 24, "user1"),
    ]

    calculator = EagerDB::Prediction::ProbabilityCalculator.new(log_files, 10)
    transitions = calculator.likely_transitions

    some_sql_probs = calculator.probability_storage["some sql statement"].probabilities
    assert_equal 2, some_sql_probs.length
    assert_equal 1.0, some_sql_probs["another sql statement"]
    assert_equal 0.5, some_sql_probs["big sql statement"]

    another_sql_probs = calculator.probability_storage["another sql statement"].probabilities
    assert_equal 0, another_sql_probs.length

    big_sql_probs = calculator.probability_storage["big sql statement"].probabilities
    assert_equal 1, big_sql_probs.length
    assert_equal 1.0, big_sql_probs["another sql statement"]

    assert_equal 2, transitions.length
    assert_equal ["another sql statement"], transitions["some sql statement"]
    assert_equal ["another sql statement"], transitions["big sql statement"]
  end

  def test_many_log_files_from_different_users_returns_multiple_transitions
    t = Time.now
    log_files = [
      EagerDB::Prediction::SqlLog.new("some sql statement", t, "user1"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 1, "user1"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 2, "user2"),
      EagerDB::Prediction::SqlLog.new("big sql statement", t + 3, "user2"),
      EagerDB::Prediction::SqlLog.new("some sql statement", t + 20, "user1"),
      EagerDB::Prediction::SqlLog.new("big sql statement", t + 20, "user2"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 21, "user2"),
      EagerDB::Prediction::SqlLog.new("big sql statement", t + 22, "user1"),
      EagerDB::Prediction::SqlLog.new("another sql statement", t + 24, "user1"),
      EagerDB::Prediction::SqlLog.new("some sql statement", t + 25, "user2"),
    ]

    calculator = EagerDB::Prediction::ProbabilityCalculator.new(log_files, 10)
    transitions = calculator.likely_transitions

    some_sql_probs = calculator.probability_storage["some sql statement"].probabilities
    assert_equal 2, some_sql_probs.length
    assert_equal 1.0, some_sql_probs["another sql statement"]
    assert_equal 0.5, some_sql_probs["big sql statement"]

    another_sql_probs = calculator.probability_storage["another sql statement"].probabilities
    assert_equal 2, another_sql_probs.length
    assert_equal 1.0/3, another_sql_probs["some sql statement"]
    assert_equal 1.0/3, another_sql_probs["big sql statement"]

    big_sql_probs = calculator.probability_storage["big sql statement"].probabilities
    assert_equal 2, big_sql_probs.length
    assert_equal 2.0/3, big_sql_probs["another sql statement"]

    assert_equal 1, transitions.length
    assert_equal ["another sql statement"], transitions["some sql statement"]
  end

  def test_single_user_log_files_for_sql_with_binds
    t = Time.now
    log_files = [
      EagerDB::Prediction::SqlLog.new("SELECT * FROM users WHERE name = 'ryan'", t, "user1"),
      EagerDB::Prediction::SqlLog.new("SELECT * FROM chairs WHERE brand = 'ikea' AND type = 'mahogany'", t + 1, "user1"),
      EagerDB::Prediction::SqlLog.new("SELECT * FROM tables WHERE owner = 'ryan'", t + 4, "user1"),
      EagerDB::Prediction::SqlLog.new("SELECT * FROM users WHERE name = 'john'", t + 15, "user1"),
      EagerDB::Prediction::SqlLog.new("SELECT * FROM tables WHERE owner = 'john'", t + 18, "user1"),
    ]

    calculator = EagerDB::Prediction::ProbabilityCalculator.new(log_files, 10)
    transitions = calculator.likely_transitions

    users_probs = calculator.probability_storage[
      "SELECT * FROM users WHERE name = ?"].probabilities
    assert_equal 2, users_probs.length
    assert_equal 1.0, users_probs[
      "SELECT * FROM tables WHERE owner = ?"]
    assert_equal 0.5, users_probs[
      "SELECT * FROM chairs WHERE brand = ? AND type = ?"]

    chairs_probs = calculator.probability_storage[
      "SELECT * FROM chairs WHERE brand = ? AND type = ?"].probabilities
    assert_equal 1, chairs_probs.length
    assert_equal 1.0, chairs_probs[
      "SELECT * FROM tables WHERE owner = ?"]

    tables_probs = calculator.probability_storage[
      "SELECT * FROM tables WHERE owner = ?"].probabilities
    assert_equal 0, tables_probs.length

    assert_equal 2, transitions.length
    assert_equal ["SELECT * FROM tables WHERE owner = ?"], transitions[
      "SELECT * FROM users WHERE name = ?"]
    assert_equal ["SELECT * FROM tables WHERE owner = ?"], transitions[
      "SELECT * FROM chairs WHERE brand = ? AND type = ?"]
  end
end
