module Memberships
  class Remover < BaseService
    attr_reader :errors

    def initialize(membership, current_user)
      @membership = membership
      @current_user = current_user
      @errors = []
    end

    def call
      return false unless can_remove?

      @membership.destroy
      true
    end

    private

    def can_remove?
      if @membership.role_owner?
        @errors << "Owner cannot be removed from the workspace."
        return false
      end

      if @membership.user_id == @current_user.id
        @errors << "You cannot remove yourself from the workspace."
        return false
      end

      true
    end
  end
end