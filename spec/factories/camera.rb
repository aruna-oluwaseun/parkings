FactoryBot.define do
  factory :camera do
    name { Faker::Name.name[0..12] }
    login { Faker::Internet.username }
    password { Faker::Internet.password }
    stream { Faker::Internet.url(Faker::Internet.ip_v4_address, '/MediaInput/stream_1', 'rtsp') }
    vmarkup { JSON.parse(File.read(Rails.root.join('spec/fixtures/camera.vmarkup'))) }
    number { Faker::Number.unique.number(3).to_i }
    parking_lot
  end
end
