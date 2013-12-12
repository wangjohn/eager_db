module Benchmark
  class MarkovTransition
    def initialize(transaction_types)
      @transaction_types = transaction_types
      @current_transaction = nil
    end

    def generate_statement(previous_binds, previous_result)
      @current_transaction ||= pick_starting_transaction

      if @current_transaction.current_child
        @current_transaction = @current_transaction.current_child
        bind_values = @current_transaction.continuation_bind_values(previous_binds, previous_result)
      else
        bind_values = @current_transaction.random_bind_values
      end

      @current_transaction.generate(random_bind_values)
    end

    private

      def pick_starting_transaction
        random_num = rand

        @transaction_types.inject(0) do |sum, transaction|
          sum += transaction[1]
          return transaction[0] if random_num <= sum
        end
      end
  end

  class AbstractTransactionType
    attr_reader :non_binded_sql, :potential_children, :current_child

    # potential_children is a hash of children transactions to probabilities
    def initialize(non_binded_sql, potential_children)
      @non_binded_sql = non_binded_sql
      @potential_children = potential_children
      validate_children_probability!

      @current_child = nil
    end

    def add_child(child_transaction, prob)
      @potential_children[child_transaction] = prob
      validate_children_probability!
    end

    def random_bind_values
      raise "Not implemented"
    end

    def generate(bind_values)
      counter = 0

      @non_binded_sql.gsub(/\?/) do |match|
        bind_values[counter]
        counter += 1
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

      def set_current_child
        random_num = rand

        @potential_children.inject(0) do |sum, element|
          sum += element[1]
          if random_num <= sum
            @current_child = element[0]
            return
          end
        end

        @current_child = nil
      end
  end
end
