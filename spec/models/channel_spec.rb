require 'rails_helper'

RSpec.describe Channel, type: :model do
  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:channel_memberships).dependent(:destroy) }
    it { should have_many(:users).through(:channel_memberships) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:privacy) }
  end

  describe 'enums' do
    let(:channel) { create(:channel) }

    it 'defaults to public privacy' do
      expect(channel.privacy_public?).to be true
    end

    it 'can be set to private' do
      channel.update(privacy: :private)
      expect(channel.privacy_private?).to be true
    end
  end
end
