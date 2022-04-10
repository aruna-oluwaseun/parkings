FactoryBot.define do
  factory :wallet do
    amount { 100_00 } # value in cents
    user
  end
end
