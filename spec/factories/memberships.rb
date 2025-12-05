FactoryBot.define do
  factory :membership do
    association :user
    association :workspace
    role { :member }

    trait :owner do
      role { :owner }
    end

    trait :admin do
      role { :admin }
    end

    trait :member do
      role { :member }
    end
  end
end