FactoryBot.define do
  factory :ai_error_report, class: Ai::ErrorReport do
    error_type { Ai::ErrorReport::ERROR_TYPES.keys.sample }
    parking_session

    trait :with_parking_session do
      before :create do |ai_error|
        ai_error.parking_session = create :parking_session, created_at: ai_error.created_at
      end
    end
  end
end
