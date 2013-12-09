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
    @storage.increment_total_occurrences
    @storage.add_transition(0.3, statement)
    probs = @storage.probabilities

    assert_equal 1, probs.length
    assert_equal 1.0, probs[statement]
  end

  def test_half_and_half_probability_for_two_different_statements
    statement1 = "statement1"
    statement2 = "statement2"
    @storage.increment_total_occurrences
    @storage.add_transition(0.5, statement1)

    @storage.increment_total_occurrences
    @storage.add_transition(0.5, statement2)
    probs = @storage.probabilities

    assert_equal 2, probs.length
    assert_equal 0.5, probs[statement1]
    assert_equal 0.5, probs[statement2]
  end

  def test_many_statements_and_non_uniform_distribution
    statements = 1.upto(20).collect { |i| "statement#{i}" }
    statements += 1.upto(10).collect { |i| "statement#{(i % 5) + 1}" }
    statements += 1.upto(5).collect { |i| "statement15" }

    statements.each do |statement|
      @storage.increment_total_occurrences
      @storage.add_transition(1.0, statement)
    end
    probs = @storage.probabilities

    assert_equal 20, probs.length
    assert_equal 1.0/35, probs["statement20"]
    assert_equal 3.0/35, probs["statement1"]
    assert_equal 6.0/35, probs["statement15"]
  end

  def test_many_transitions_for_a_single_statement
    @storage.increment_total_occurrences
    @storage.add_transition(0.1, "statement1")
    @storage.add_transition(0.1, "statement2")
    @storage.add_transition(0.1, "statement3")

    @storage.increment_total_occurrences
    @storage.add_transition(0.1, "statement1")

    probs = @storage.probabilities
    assert_equal 1.0, probs["statement1"]
    assert_equal 0.5, probs["statement2"]
    assert_equal 0.5, probs["statement3"]
  end
end
