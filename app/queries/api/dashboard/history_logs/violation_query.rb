module Api
  module Dashboard
    module HistoryLogs
      class ViolationQuery < ApplicationQuery
        def call
          activity_log = options[:activity_log]

          scope = ::HistoryLogs::Violation.run(violation_report: options[:parking_violation]).result
          if options.dig(:range, :from) && activity_log
            from, to = ranges(options)
            scope = scope.select do |log|
              (from..to).include?(Time.at(log[:created_at])) && log[:attribute] == activity_log.capitalize
            end
          elsif options.dig(:range, :from) && !activity_log
            from, to = ranges(options)
            scope = scope.select { |log| (from..to).include?(Time.at(log[:created_at])) }
          elsif activity_log && !options.dig(:range, :from)
            scope = scope.select { |log| log[:attribute] == activity_log }
          else
            scope
          end
        end

        private

        def ranges(options)
          from = options.dig(:range, :from).to_date.beginning_of_day
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day

          return [from, to]
        end
      end
    end
  end
end
