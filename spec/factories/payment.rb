FactoryBot.define do
  factory :payment do
    parking_session
    amount { Faker::Number.decimal(2).to_f }
    status { Faker::Number.between(0, 1) }
    payment_method { Payment.payment_methods.values.sample }

    trait(:success) do
      status { :success }
    end

    trait(:with_parking_session) do
      before :create do |payment|
        payment.parking_session = create(:parking_session, parking_lot: create(:parking_lot), created_at: payment.created_at.utc)
      end
    end
  end
end
