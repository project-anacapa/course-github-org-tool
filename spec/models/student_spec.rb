require 'rails_helper'

RSpec.describe Student, type: :model do

  before(:each) {
    @student = FactoryGirl.create(
        :student,
        perm: '123456',
        first_name: 'First',
        last_name: 'Last',
        email: 'test@umail.ucsb.edu'
    )
  }

  subject { @student }

  it { should respond_to(:perm) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:username) }

  it "#perm returns a string" do
    expect(@student.perm).to match '123456'
  end

  it "#first_name returns a string" do
    expect(@student.first_name).to match 'First'
  end

  it "#last_name returns a string" do
    expect(@student.last_name).to match 'Last'
  end

  it "#email returns a string" do
    expect(@student.email).to match 'test@umail.ucsb.edu'
  end

  it "#username should start as empty" do
    expect(@student.username.to_s).to eql("")
  end

end