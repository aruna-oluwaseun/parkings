FactoryBot.define do
  factory :vehicle do
    plate_number { "#{Faker::Car.number}#{Faker::Number.between(100, 999)}" }
    color { 'Red' }
    model { 'Audi' }
    vehicle_type { 'sedan' }
    status { :active }
    manufacturer { Manufacturer.last }
    registration_state { Faker::Address.country }
    user

    after :create do |vehicle, evaluator|
      vehicle.registration_card.attach(
        io: File.open('spec/files/test.jpg'),
        filename: "vehicle_card_#{vehicle.id}.jpg",
        content_type: 'image/jpg'
      )
    end
  end
end
