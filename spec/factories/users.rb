require 'faker'
FactoryGirl.define do
  factory :user do
    name Faker::Name.name
    username {
      Faker::Internet.unique.user_name(
          "#{first_name} #{last_name}", %w(. _ -)
      )
    }
  end
end
