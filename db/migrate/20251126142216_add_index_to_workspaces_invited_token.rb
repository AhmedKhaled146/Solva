class AddIndexToWorkspacesInvitedToken < ActiveRecord::Migration[8.1]
  def change
    add_index :workspaces, :invited_token, unique: true
  end
end
