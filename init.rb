# encoding: utf-8

def patch_class(clazz, patch)
  clazz.send(:include, patch) unless clazz.include?(patch)
end

Rails.configuration.to_prepare do
  patch_class Mailer, IssueReminder::Patches::MailerPatch
end


Redmine::Plugin.register :redmine_issue_reminder do
  name 'Inactive Issue Reminder'
  author 'Jens Krämer'
  description 'Notifications for issues that havent been updated for a configurable number of days'
  version '1.0.0'
  author_url 'https://jkraemer.net/'

  requires_redmine version_or_higher: '2.5.2'

  # in case this plugin is added before running the first migrations,
  # issue_statuses table doesn't exist, therefore the rescue
  resolved_state_id = IssueStatus.find_by_name('Gelöst').try(:id) rescue nil
  closed_state_id   = IssueStatus.find_by_name('Geschlossen').try(:id) rescue nil

  settings :default => {
    'remind_after_days' => '90',
    'close_issues_after_days' => '120',
    'resolved_state_id' => resolved_state_id,
    'closed_state_id' => closed_state_id
  }, :partial => 'issue_reminder/settings'

  project_module :issue_reminder do
    permission :receive_issue_reminders, {}
    permission :receive_due_issues, {}
  end
end
