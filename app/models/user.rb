class User < ApplicationRecord
  include RailsSettings::Extend

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        user.username = auth['info']['nickname'] || ''
        user.name = auth['info']['name'] || ''
      end
    end
  end

  def discoverable?
    self.settings['discoverable']
  end

  def self.discoverable_users
    User.with_settings_for('discoverable').select {|u| u.discoverable? }
  end

  def attempt_match_to_student(client, machine)
    course = Setting.course
    return unless course
    emails = client.emails
    emails.each do |e|
      student = Student.where(email: e.email).first
      next unless student
      student.username = self.username
      student.save!

      begin
        # if already a member, skip (will raise exception if not a member)
        machine.org_membership(course, { user: self.username })
      rescue
        machine.update_org_membership(course, {
          role: 'member',
          state: 'pending',
          user: self.username
        })
      end
      return true
    end

    false
  end

end
