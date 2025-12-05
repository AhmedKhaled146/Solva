require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    describe 'email' do
      it "requires presence" do
        user = User.new(password: "password123")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it "requires uniqueness" do
        user1 = User.create(
          email: "test@example.com",
          password: "password123"
        )
        expect(user1).to be_valid

        user2 = User.new(
          email: "test@example.com",
          password: "password123"
        )
        expect(user2).not_to be_valid
        expect(user2.errors[:email]).to include("has already been taken")
      end
    end

    describe 'password' do
      it "requires presence" do
        user = User.new(email: "test@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it "requires minimum length of 6 characters" do
        user = User.new(
          email: "test@example.com",
          password: "short"
        )
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      it "accepts valid password length" do
        user = User.new(
          email: "test@example.com",
          password: "password123"
        )
        expect(user).to be_valid
      end

      it "rejects blank password" do
        user = User.new(
          email: "test@example.com",
          password: ""
        )
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it "rejects nil password" do
        user = User.new(
          email: "test@example.com",
          password: nil
        )
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end
    end

    describe "password confirmation" do
      it "requires matching password confirmation" do
        user = User.new(
          email: "confirm@example.com",
          password: "password123",
          password_confirmation: "wrong123"
        )
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it "is valid when confirmation matches" do
        user = User.new(
          email: "confirm@example.com",
          password: "password123",
          password_confirmation: "password123"
        )
        expect(user).to be_valid
      end
    end
  end
end