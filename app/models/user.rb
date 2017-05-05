class User < ApplicationRecord
  include RailsSettings::Extend

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth[:provider]
      user.uid = auth[:uid]
      if auth[:info]
        user.username = auth[:info][:nickname] || ''
        user.name = auth[:info][:name] || ''
      end
    end
  end

  def is_instructor?
    instructors = Setting['instructors']
    !instructors.blank? && \
        instructors.is_a?(Array) && \
        instructors.include?(self.username)
  end

  def discoverable?
    self.settings['discoverable']
  end

  def self.discoverable_users
    User.with_settings_for('discoverable').select {|u| u.discoverable? }
  end

  def attempt_match_to_student(client, machine)
    course = ENV['COURSE_ORGANIZATION']
    return unless course
    emails = client.emails
    emails.each do |e|
      student = Student.where(email: e[:email]).first
      next unless student
      student.username = self.username
      student.save!

      begin
        # if already a member, skip (this function will raise exception if not a member)
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


  def instructorize(client, machine)
    course = ENV['COURSE_ORGANIZATION']
    begin
      m = client.org_membership(course, { user: self.username })

      # if the user is not an admin, then ignore them for now
      return false unless m[:role].eql? "admin"

      # since the user is an admin, add current user as an instructor
      instructors = Setting['instructors'] || []
      instructors << self.username
      Setting.instructors = instructors

      # add machine user as admin to the organization (idempotent operation)
      client.update_org_membership(course, {
          role: 'admin',
          state: 'pending',
          user: ENV['MACHINE_USER_NAME']
      })
      machine.update_org_membership(course, {
          state: 'active',
      })

      # the course is now set up
      Setting['course_setup'] = true
      true
    rescue
      # if the user is not part of the organization or the organization doesn't exist, ignore them
      false
    end
  end

end
