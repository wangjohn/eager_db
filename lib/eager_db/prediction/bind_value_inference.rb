module EagerDB
  module Prediction
    class BindValueInference
      attr_reader :probability_storage, :transitions

      def initialize(probability_storage, transitions)
        @probability_storage = probability_storage
        @transitions = transitions
      end

      def infer
        transitions.each do |match, preloads|
          preloads.each do |preload|
            binded_preloads = probability_storage[match].binded_preloads(preload)
            perform_bind_value_inference(binded_preloads)
          end
        end
      end

      private

        def perform_bind_value_inference(binded_preloads)
          bind_counter = TransitionBindValueCounter.new

          binded_preloads.each do |match, preload|
            match_bind_indices = {}
            match.sql_statement.bind_values.each_with_index do |val, index|
              match_bind_indices[val] = index
            end

            preload.sql_statement.bind_values.each_with_index do |val, index|
              if match_bind_indices.include?(val)
                bind_counter.add_bind_equality(match_index, preload_index)
              end
            end
          end

          bind_counter
        end
    end

    class TransitionBindValueCounter
      attr_reader :storage

      def initialize
        @storage = Hash.new { |h,k| h[k] = 0 }
      end

      def add_bind_equality(match_index, preload_index)
        storage[match_index][preload_index] += 1
      end
    end
  end
end
