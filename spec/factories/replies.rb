FactoryBot.define do
  factory :reply do
    body { Faker::Lorem.sentence }
    association :message
    association :user
  end
end