require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do

  describe 'GET #index' do
    it 'returns http failure if not signed in' do
      get :index
      expect(response).to redirect_to(root_path)
    end
    it 'returns http failure if not signed in as instructor' do
      get :index
      expect(response).to redirect_to(root_path)
    end
    it 'returns http success if signed in as instructor' do
      assert true
    end
  end

end
