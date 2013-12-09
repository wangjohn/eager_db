module EagerDB
  module Prediction
    class ProbabilityCalculator
      attr_reader :time_threshold, :probability_storage

      def initialize(logs, time_threshold)
        @logs = logs
        @time_threshold = time_threshold

        @probability_storage = Hash.new { |h,statement| h[statement] = MarkovProbabilityStorage.new(statement) }
        @processed = false
      end

      def process
        grouped_logs = @logs.group_by { |log| log.user }

        grouped_logs.each do |user, user_logs|
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
          rolling_group = []
          index = 1
          current_log = user_logs.first

          while index < user_logs.length or !rolling_group.empty?
            if index < user_logs.length
              log = user_logs[index]

              if log.processed_at < current_log.processed_at + time_threshold
                rolling_group << log
              else
                make_transition(current_log, rolling_group)
                current_log = log
              end
              index += 1
            else
              make_transition(current_log, rolling_group)
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
