module HistoryLogs
  # @example instantiate and execute as
  #   ::ViolationReports::List.new(params).result
  # @param :violation_report Object
  # @return [Hash]
  class Violation < ApplicationInteraction
    object :violation_report, class: ::Parking::Violation

    def execute
      serialized_violation_report.values.flatten.compact.sort do |a, b|
        a[:created_at] <=> b[:created_at]
      end
    end

    def serialized_violation_report
      ::Api::V1::Parking::Violation::ViolationLogSerializer.new(violation_report).serializable_hash.symbolize_keys
    end
  end
end
