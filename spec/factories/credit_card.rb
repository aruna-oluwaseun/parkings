FactoryBot.define do
  factory :credit_card do
    sequence(:number) do |n|
      next '4242424242424242' if n == 1
      next '5555555555554444' if n == 2
      next '4000056655665556' if n == 3
      next '2223003122003222' if n == 4
      ['4242424242424242', '4000056655665556', '5555555555554444', '2223003122003222'].sample
    end
    holder_name { Faker::Name.name }
    expiration_year { Faker::Number.between(21, 28) }
    expiration_month { Faker::Number.between(1, 12) }
  end
end
