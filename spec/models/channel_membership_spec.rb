require 'rails_helper'

RSpec.describe ChannelMembership, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:channel) }
  end

  describe 'validations' do
    subject { create(:channel_membership) }

    it { should validate_presence_of(:channel_id) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:channel_id) }
  end

  describe 'uniqueness constraint' do
    let(:channel) { create(:channel) }
    let(:user) { create(:user) }

    it 'prevents duplicate memberships for same user and channel' do
      create(:channel_membership, user: user, channel: channel)
      duplicate = build(:channel_membership, user: user, channel: channel)

      expect(duplicate).not_to be_valid
    end

    it 'allows same user in different channels' do
      channel2 = create(:channel)
      create(:channel_membership, user: user, channel: channel)
      membership2 = build(:channel_membership, user: user, channel: channel2)

      expect(membership2).to be_valid
    end
  end
end
