FactoryBot.define do
  factory :workspace do
    sequence(:name) { |n| "Workspace #{n}" }

    trait :with_owner do
      after(:create) do |workspace|
        user = create(:user)
        create(:membership, workspace: workspace, user: user, role: :owner)
      end
    end

    trait :with_members do
      after(:create) do |workspace|
        create_list(:membership, 3, workspace: workspace, role: :member)
      end
    end

    trait :with_channels do
      after(:create) do |workspace|
        create_list(:channel, 2, workspace: workspace)
      end
    end
  end
end