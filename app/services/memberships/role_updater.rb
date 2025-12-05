module Memberships
  class RoleUpdater < BaseService
    attr_reader :errors

    def initialize(membership, role_params, current_user)
      @membership = membership
      @role_params = role_params
      @current_user = current_user
      @errors = []
    end

    def call
      return false unless can_update_role?

      @membership.update(@role_params)
    end

    private

    def can_update_role?
      if @membership.role_owner?
        @errors << "You cannot change the owner's role."
        return false
      end

      if @membership.user_id == @current_user.id
        @errors << "You cannot change your own role."
        return false
      end

      true
    end
  end
end