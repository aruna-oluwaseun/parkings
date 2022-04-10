FactoryBot.define do
  factory :citation_ticket, class: 'Parking::CitationTicket' do
    association :violation, factory: :parking_violation
  end
end
