require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:workspace) }
  end

  describe 'validations' do
    subject { create(:membership) }

    it { should validate_presence_of(:role) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:workspace_id) }
  end

  describe 'enums' do
    let(:membership) { create(:membership) }

    it 'defaults to member role' do
      expect(membership.role_member?).to be true
    end

    it 'can be set to owner' do
      membership.update(role: :owner)
      expect(membership.role_owner?).to be true
    end

    it 'can be set to admin' do
      membership.update(role: :admin)
      expect(membership.role_admin?).to be true
    end
  end

  describe 'uniqueness constraint' do
    let(:workspace) { create(:workspace) }
    let(:user) { create(:user) }

    it 'prevents duplicate memberships for same user and workspace' do
      create(:membership, user: user, workspace: workspace)
      duplicate = build(:membership, user: user, workspace: workspace)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('has already been taken')
    end

    it 'allows same user in different workspaces' do
      workspace2 = create(:workspace)
      create(:membership, user: user, workspace: workspace)
      membership2 = build(:membership, user: user, workspace: workspace2)

      expect(membership2).to be_valid
    end
  end
end
