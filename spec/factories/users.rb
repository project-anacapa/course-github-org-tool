require 'faker'
FactoryGirl.define do
  factory :user do
    name Faker::Name.name
    username {
      Faker::Internet.unique.user_name(
          "#{name}", %w(. _ -)
      )
    }
  end
end
