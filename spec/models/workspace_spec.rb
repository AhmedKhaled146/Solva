require 'rails_helper'

RSpec.describe Workspace, type: :model do
  describe 'associations' do
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:channels).dependent(:destroy) }
    it { should have_many(:users).through(:memberships) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'callbacks' do
    describe '#set_invited_token' do
      it 'generates invited_token before creation' do
        workspace = create(:workspace)
        expect(workspace.invited_token).to be_present
        expect(workspace.invited_token.length).to eq(32)
      end

      it 'does not override existing invited_token' do
        token = SecureRandom.hex(16)
        workspace = create(:workspace, invited_token: token)
        expect(workspace.invited_token).to eq(token)
      end
    end
  end

  describe 'instance methods' do
    let(:workspace) { create(:workspace) }
    let(:owner) { create(:user) }
    let(:admin) { create(:user) }
    let(:member) { create(:user) }

    before do
      create(:membership, workspace: workspace, user: owner, role: :owner)
      create(:membership, workspace: workspace, user: admin, role: :admin)
      create(:membership, workspace: workspace, user: member, role: :member)
    end

    describe '#owner_membership' do
      it 'returns the owner membership' do
        expect(workspace.owner_membership.user).to eq(owner)
        expect(workspace.owner_membership.role).to eq('owner')
      end
    end

    describe '#owner' do
      it 'returns the workspace owner' do
        expect(workspace.owner).to eq(owner)
      end
    end

    describe '#membership_for' do
      it 'returns membership for given user' do
        membership = workspace.membership_for(member)
        expect(membership.user).to eq(member)
      end

      it 'returns nil for non-member' do
        non_member = create(:user)
        expect(workspace.membership_for(non_member)).to be_nil
      end
    end

    describe '#role_for' do
      it 'returns correct role for owner' do
        expect(workspace.role_for(owner)).to eq('owner')
      end

      it 'returns correct role for admin' do
        expect(workspace.role_for(admin)).to eq('admin')
      end

      it 'returns correct role for member' do
        expect(workspace.role_for(member)).to eq('member')
      end

      it 'returns nil for non-member' do
        non_member = create(:user)
        expect(workspace.role_for(non_member)).to be_nil
      end
    end

    describe 'role checking methods' do
      describe '#role_owner?' do
        it 'returns true for owner' do
          expect(workspace.role_owner?(owner)).to be true
        end

        it 'returns false for non-owner' do
          expect(workspace.role_owner?(member)).to be false
        end
      end

      describe '#role_admin?' do
        it 'returns true for admin' do
          expect(workspace.role_admin?(admin)).to be true
        end

        it 'returns false for non-admin' do
          expect(workspace.role_admin?(member)).to be false
        end
      end

      describe '#role_member?' do
        it 'returns true for member' do
          expect(workspace.role_member?(member)).to be true
        end

        it 'returns false for non-member role' do
          expect(workspace.role_member?(owner)).to be false
        end
      end
    end
  end
end
