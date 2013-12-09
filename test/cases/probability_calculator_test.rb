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
    assert_equal 1.0, some_sql_probs["big sql statement"]

    assert_equal 3, transitions.length
    assert_equal ["another sql statement", "big sql statement"], transitions["some sql statement"]
    assert_equal ["another sql statement"], transitions["big sql statement"]
  end
end
