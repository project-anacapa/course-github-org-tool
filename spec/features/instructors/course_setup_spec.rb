require 'strategies'

# Feature: Course Setup
#   As an instructor
#   I want to set up my course organization with this application
#   So I can manage course activity and information
feature 'Course Setup' do

  # person who is not admin of org signs in first, it fails
  #   - instructors == []
  #   - machine user should not have been invited to org
  #   - Setting.course_setup should be false
  #   - Should see error message on front page
  # Scenario: Non-Instructor signin does not trigger course setup
  #   Given I am the first user to sign in to the application
  #   And I am a "member" of the configured github organization
  #   When I sign in
  #   Then I the course should not be set up
  #   And I should not be recognized as an instructor
  scenario 'non-instructor sign in does not trigger course setup' do
    allow_any_instance_of(Strategies::GitTestStrategy).to receive(:org_membership).and_return(
        {:role => 'member', :state => 'active'}
    )
    expect(Setting.instructors).to eq([])
    expect(Setting.course_setup).to be_falsey
    signin
    expect(page).to have_content("Uh oh!")
    expect(Setting.instructors).to eq([])
    expect(Setting.course_setup).to be_falsey
  end

  # person who is admin of org signs in
  #   - before, instructors == []
  #   - app adds machine user to org
  #   - app adds github id to instructors[]
  #   - now, instructors == [person]
  #   - Setting.course_setup should be true
  #   - should see success message on front page
  # Scenario: Instructor signin triggers course setup
  #   Given I am the first user to sign in to the application
  #   And I am an "admin" of the configured github organization
  #   When I sign in
  #   Then I the course should be set up with me as the instructor
  scenario 'instructor sign in triggers course setup' do
    allow_any_instance_of(Strategies::GitTestStrategy).to receive(:org_membership).and_return(
        {:role => 'admin', :state => 'active'}
    )
    expect(Setting.instructors).to eq([])
    expect(Setting.course_setup).to be_falsey
    called = false
    allow_any_instance_of(Strategies::GitTestStrategy).to receive(:update_org_membership) do |_, _, params|
      called ||= params[:user].eql? ENV['MACHINE_USER_NAME']
    end
    signin
    expect(called).to be_truthy
    expect(page).to have_content("Welcome")
    expect(Setting.instructors).to eq(['mockuser'])
    expect(Setting.course_setup).to be_truthy

    visit students_path
    expect(page).to have_css('.students-list tr', count: 0)
  end

  # Scenario: Initial course setup means no students
  #   Given I am the first user to sign in to the application
  #   And I am able to set up the course
  #   When I sign in and look at the course roster
  #   Then it should have no students
  scenario 'initial course setup means no students' do
    allow_any_instance_of(Strategies::GitTestStrategy).to receive(:org_membership).and_return(
        {:role => 'admin', :state => 'active'}
    )
    signin
    visit students_path
    expect(page).to have_css('.students-list tr', count: 0)
  end

end
