module Benchmark
  class MarkovProcess
    def initialize(transaction_types, connection, sleep_time = 2.0)
      @markov_transition = MarkovTransition.new(transaction_types)
      @connection = connection
      @sleep_time = sleep_time
    end

    def run(times = 60)
      previous_result = nil

      1.upto(times) do |i|
        statement = @markov_transition.generate_statement(previous_result)
        puts statement
        start = Time.now
        previous_result = @connection.query(statement)
        finish = Time.now
        puts "Executed in: #{finish - start}"
        sleep(@sleep_time)
      end
    end
  end

  class MarkovTransition
    def initialize(transaction_types)
      @transaction_types = transaction_types
      @current_transaction = nil
      @previous_binds = nil
    end

    def generate_statement(previous_result)
      if @current_transaction && @current_transaction.current_child
        prev_transaction = @current_transaction
        @current_transaction = @current_transaction.current_child
        bind_values = @current_transaction.continuation_bind_values(
          prev_transaction, @previous_binds, previous_result)
      else
        @current_transaction = pick_starting_transaction
        bind_values = @current_transaction.random_bind_values
      end

      @current_transaction.generate(bind_values)
    end

    private

      def pick_starting_transaction
        random_num = rand

        @transaction_types.inject(0) do |sum, transaction|
          return transaction[0] if random_num <= sum + transaction[1]
          sum + transaction[1]
        end
      end
  end

  class AbstractTransactionType
    attr_reader :non_binded_sql, :potential_children, :current_child

    # potential_children is a hash of children transactions to probabilities
    def initialize(potential_children)
      @potential_children = potential_children
      validate_children_probability!

      @current_child = nil
    end

    def add_child(child_transaction, prob)
      @potential_children[child_transaction] = prob
      validate_children_probability!
    end

    def non_binded_sql
      raise "Not implemented"
    end

    def continuation_bind_values(previous_transaction, previous_binds, previous_result)
      raise "Not implemented"
    end

    def random_bind_values
      raise "Not implemented"
    end

    def random_row_attribute(result, attribute)
      index = rand(result.count)
      result.each_with_index { |row, i| return row[attribute] if index == index }
    end

    def generate(bind_values)
      counter = -1
      set_current_child!

      non_binded_sql.gsub(/\?/) do |match|
        counter += 1
        bind_values[counter]
      end
    end

    private

      def validate_children_probability!
        total_prob = @potential_children.inject(0) do |sum, element|
          sum += element[1]
        end

        if total_prob > 1.0
          raise ArgumentError, "Too much probability assigned to children"
        end
      end

      def set_current_child!
        random_num = rand

        @potential_children.inject(0) do |sum, element|
          if random_num <= sum + element[1]
            @current_child = element[0]
            return
          end

          sum + element[1]
        end

        @current_child = nil
      end
  end
end
