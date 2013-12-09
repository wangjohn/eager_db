require 'cases/helper'

class MarkovProbabilityStorageTest < EagerDB::Test
  def setup
    @storage = EagerDB::Prediction::MarkovProbabilityStorage.new("SELECT * FROM users WHERE name = ?")
  end

  def test_no_probabilities_returned_for_empty_storage_class
    probs = @storage.probabilities

    assert_equal 0, probs.length
  end

  def test_single_probability_of_1_returned_for_single_transition
    statement = "Some statement"
    @storage.add_transition(0.3, statement)
    probs = @storage.probabilities

    assert_equal 1, probs.length
    assert_equal 1.0, probs[statement]
  end

  def test_half_and_half_probability_for_two_different_statements
    statement1 = "statement1"
    statement2 = "statement2"
    @storage.add_transition(0.5, statement1)
    @storage.add_transition(0.5, statement2)
    probs = @storage.probabilities

    assert_equal 2, probs.length
    assert_equal 0.5, probs[statement1]
    assert_equal 0.5, probs[statement2]
  end
end
