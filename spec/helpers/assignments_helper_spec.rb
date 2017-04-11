require 'rails_helper'

RSpec.describe AssignmentsHelper, :type => :helper do
  before(:each) do
    # irrelevant repos
    @non_repos = []
    @non_repos << double('repo', :name => 'test-repo')
    @non_repos << double('repo', :name => 'foo-barb')
    @non_repos << double('repo', :name => 'assignment')
    @non_repos << double('repo', :name => 'assignment-')
    @non_repos << double('repo', :name => 'repo1')
    @non_repos << double('repo', :name => 'repo1-')
    @non_repos << double('repo', :name => 'repo3-user1-user2') # irrelevant because no corresponding assignment master
    # repos with names that look like assignment master repos
    @assignment_repos = []
    @assignment_repos << double('repo', :name => 'assignment-repo1')
    @assignment_repos << double('repo', :name => 'assignment-repo2')
    # repos with names that look like student code repos
    @student_repos = []
    @student_repos << double('repo', :name => 'repo1-user1')
    @student_repos << double('repo', :name => 'repo1-user1-user2')
    @student_repos << double('repo', :name => 'repo2-user1')
    @student_repos << double('repo', :name => 'repo2-user1-user2')
  end

  describe '#assignment_repos' do
    context 'when there are no repos' do
      before(:each) do
        @repos = []
      end

      it 'return an empty array' do
        expect(helper.assignment_repos(@repos)).to eq([])
      end
    end

    context 'when there are repos, but no assignment master repos or student repos' do
      before(:each) do
        @repos = @non_repos
      end

      it 'return an empty array' do
        expect(helper.assignment_repos(@repos)).to eq([])
      end
    end

    context 'when there are assignment master repos' do
      before(:each) do
        @repos = @non_repos + @assignment_repos
      end

      it 'returns only assignment repos' do
        expect(helper.assignment_repos(@repos)).to eq(@assignment_repos)
      end
    end

    context 'when there are assignment master repos and student repos' do
      before(:each) do
        @repos = @non_repos + @assignment_repos + @student_repos
      end

      it 'returns only assignment repos' do
        expect(helper.assignment_repos(@repos)).to eq(@assignment_repos)
      end
    end
  end

  describe '#student_repos' do
    context 'when there are no repos' do
      before(:each) do
        @repos = []
      end

      it 'return an empty array' do
        expect(helper.student_repos(@repos)).to eq([])
      end
    end

    context 'when there are repos, but no student repos' do
      before(:each) do
        @repos = @non_repos + @assignment_repos
      end

      it 'return an empty array' do
        expect(helper.student_repos(@repos)).to eq([])
      end
    end

    context 'when there are student repos, but no assignment master repos' do
      before(:each) do
        @repos = @non_repos + @student_repos
      end

      it 'returns an empty array' do
        expect(helper.student_repos(@repos)).to eq([])
      end
    end

    context 'when there are assignment master repos and student repos' do
      before(:each) do
        @repos = @non_repos + @assignment_repos + @student_repos
      end

      it 'returns only student repos' do
        expect(helper.student_repos(@repos)).to eq(@student_repos)
      end
    end
  end
end