FactoryBot.define do
  factory :image, class: Image do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'files', 'test.jpg'), 'image/jpg') }
    association :imageable, factory: :parking_session

    trait (:for_parking_session) do
      association :imageable, factory: :parking_session
   end
  end
end
