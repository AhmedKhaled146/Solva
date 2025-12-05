FactoryBot.define do
  factory :channel_membership do
    association :user
    association :channel
  end
end