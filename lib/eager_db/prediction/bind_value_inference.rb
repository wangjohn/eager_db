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
          binds = []

          binded_preloads.each do |match, preload|

          end
        end
  end
end
