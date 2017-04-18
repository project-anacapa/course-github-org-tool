require 'faker'
FactoryGirl.define do
  factory :student do
    perm Faker::Number.unique.number(7)
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email { "#{first_name}.#{last_name}@umail.ucsb.edu"}
  end
end