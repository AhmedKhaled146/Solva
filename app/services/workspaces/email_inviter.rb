module Workspaces
  class EmailInviter < BaseService
    attr_reader :errors

    def initialize(email, workspace)
      @email = email.to_s.strip
      @workspace = workspace
      @errors = []
    end

    def call
      return false if invalid_email?

      send_invitation
      true
    end

    private

    def invalid_email?
      if @email.blank?
        @errors << "Email can't be blank"
        return true
      end
      false
    end

    def send_invitation
      WorkspaceInviteMailer.invite_email(@email, @workspace).deliver_now
    end
  end
end
