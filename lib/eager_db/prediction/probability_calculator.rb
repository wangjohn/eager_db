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
          current_log = user_logs[0]

          while index < user_logs.length or !rolling_group.empty?
            if index < user_logs.length
              log = user_logs[index]

              if log.processed_at > current_log.processed_at + time_threshold
                current_log = make_transitions(current_log, rolling_group)
              end

              rolling_group << log
              index += 1
            else
              current_log = make_transitions(current_log, rolling_group)
            end
          end
        end

        def make_transitions(current_log, rolling_group)
          current_storage = probability_storage[current_log.non_binded_sql]
          current_storage.increment_total_occurrences

          verified_transitions = rolling_group.take_while do |log|
            (log.processed_at - current_log.processed_at) <= time_threshold
          end

          unique_logs = verified_transitions.uniq do |log|
            log.non_binded_sql
          end

          unique_logs.each do |log|
            current_storage.add_transition(
              log.processed_at - current_log.processed_at,
              log.non_binded_sql)
          end

          rolling_group.shift
        end
    end
  end
end
