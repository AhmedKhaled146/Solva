FactoryBot.define do
  factory :channel do
    sequence(:name) { |n| "Channel #{n}" }
    association :workspace
    privacy { :public }

    trait :private do
      privacy { :private }
    end

    trait :with_members do
      after(:create) do |channel|
        create_list(:channel_membership, 3, channel: channel)
      end
    end

    trait :with_messages do
      after(:create) do |channel|
        create_list(:message, 5, channel: channel)
      end
    end
  end
end