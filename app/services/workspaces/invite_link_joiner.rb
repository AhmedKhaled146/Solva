module Workspaces
  class InviteLinkJoiner < BaseService
    attr_reader :workspace, :errors

    def initialize(invite_link, user)
      @invite_link = invite_link
      @user = user
      @workspace = nil
      @errors = []
    end

    def call
      token = extract_token
      return false if token.nil?

      find_workspace(token)
      return false if @workspace.nil?

      join_workspace
    end

    private

    def extract_token
      raw_input = @invite_link.to_s.strip

      if raw_input.include?("http")
        uri = URI.parse(raw_input) rescue nil
        if uri && uri.path
          uri.path.split("/").last
        end
      else
        raw_input
      end
    end

    def find_workspace(token)
      @workspace = Workspace.find_by(invited_token: token)
      @errors << "Invalid or expired invite link." if @workspace.nil?
    end

    def join_workspace
      membership = @workspace.memberships.find_or_initialize_by(user: @user)

      if membership.persisted?
        @errors << "You already joined this workspace."
        return false
      end

      membership.role = :member
      membership.save!
      true
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      false
    end
  end
end