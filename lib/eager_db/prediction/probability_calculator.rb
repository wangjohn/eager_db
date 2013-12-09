module EagerDB
  module Prediction
    class ProbabilityCalculator
      attr_reader :time_threshold, :probability_storage

      def initialize(logs, time_threshold)
        @logs = logs
        @time_threshold = time_threshold

        @probability_storage = Hash.new { |h,k| h[statement] = MarkovProbabilityStorage.new(statement) }
        @processed = false
      end

      def process
        @logs.each do |user, user_logs|
          process_user_logs(user_logs)
        end

        @processed = true
      end

      def likely_transitions(probability_threshold = 0.8)
        process unless @processed
        transitions = Hash.new { |h,k| h[k] = [] }

        probability_storage.each do |match, markov_storage|
          markov_storage.probabilities.select do |preload, probability|
            if probability > probability_threshold
              transitions[match] << preload
            end
          end
        end

        transitions
      end

      private

        def process_user_logs(user_logs)
          current_log = nil
          rolling_group = []

          user_logs.each do |log|
            if current_log
              if log.processed_at < current_log.processed_at + time_threshold
                rolling_group << log
              else
                make_transition(current_log, rolling_group)
                current_log = nil
              end
            elsif rolling_group.empty?
              rolling_group << log
            else
              current_log = rolling_group.shift
            end
          end
        end

        def make_transition(current_log, rolling_group)
          current_storage = probability_storage[current_log.non_binded_sql]

          rolling_group.each do |log|
            time_difference = log.processed_at - current_log.processed_at
            current_storage.add_transition(time_difference, log.non_binded_sql)
          end
        end
    end
  end
end
