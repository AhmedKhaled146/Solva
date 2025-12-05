FactoryBot.define do
  factory :message do
    body { Faker::Lorem.sentence }
    association :user
    association :channel

    trait :with_replies do
      after(:create) do |message|
        create_list(:reply, 3, message: message)
      end
    end
  end
end