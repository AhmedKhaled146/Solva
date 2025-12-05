require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:channel) }
    it { should have_many(:replies).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
end
