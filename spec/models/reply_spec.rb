require 'rails_helper'

RSpec.describe Reply, type: :model do
  describe 'associations' do
    it { should belong_to(:message) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
end
