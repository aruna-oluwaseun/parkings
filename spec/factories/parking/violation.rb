FactoryBot.define do
  factory :parking_violation, class: 'Parking::Violation' do
    association :vehicle_rule, factory: :parking_vehicle_rule
    association :rule, factory: :parking_rule
    association :session, factory: :parking_session
    description { Faker::ChuckNorris.fact }

    trait :with_image do
      after :create do |violation|
        create(:image, imageable: violation)
      end
    end

    trait :with_parking_session do
      after :create do |parking_ticket|
        parking_ticket.session = create :parking_session, created_at: parking_ticket.created_at
      end
    end

    trait :with_opened_violation_ticket do
      after :create do |violation|
        create(:parking_ticket, status: Parking::Ticket::STATUSES[:opened], violation: violation)
      end
    end


    trait :with_violation_ticket_unassigned_admin do
      after :create do |violation|
        create(:parking_ticket,
          :unassigned,
          status: Parking::Ticket::STATUSES[:opened],
          violation: violation
        )
      end
    end

    trait :with_opened_violation_ticket_and_session do
      after :create do |violation, citation_ticket|
        create(:citation_ticket, status: Parking::CitationTicket::STATUSES[:unsettled], violation: violation)
        citation_ticket.session = create :parking_session, created_at: citation_ticket.created_at
      end
    end

    trait :with_rejected_violation_ticket do
      after :create do |violation|
        create(:parking_ticket, status: Parking::Ticket::STATUSES[:rejected], violation: violation)
      end
    end
  end

  trait :with_unsettled_violation_citation_ticket do
    after :create do |violation|
      create(:citation_ticket, status: :unsettled, violation: violation, created_at: violation.created_at)
    end
  end

  trait :with_settled_violation_citation_ticket do
    after :create do |violation|
      create(:citation_ticket, status: :settled, violation: violation, created_at: violation.created_at)
    end
  end
end
