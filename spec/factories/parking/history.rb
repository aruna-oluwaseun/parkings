FactoryBot.define do
  factory :parking_history, class: 'Parking::History' do
    parking_session
    user
  end
end
