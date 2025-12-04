class WorkspaceInviteMailer < ApplicationMailer
  default from: "no-reply@solva.com"

  def invite_email(user_email, workspace)
    @workspace = workspace
    @invite_url = join_from_email_workspace_url(@workspace.invited_token)

    mail(to: user_email, subject: "Invitation to join workspace #{@workspace.name} on Solva")
  end
end
