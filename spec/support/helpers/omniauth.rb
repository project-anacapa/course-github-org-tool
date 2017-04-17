module Omniauth

  module Mock
    def auth_mock
      OmniAuth.config.mock_auth[:github] = {
        :provider => 'github',
        :uid => '123545',
        :info => {
          :nickname => 'mockuser',
          :name => 'Mock User'
        },
        :credentials => {
          :token => 'mock_token',
          :secret => 'mock_secret'
        }
      }
    end
  end

  module SessionHelpers
    def signin
      visit root_path
      expect(page).to have_content('Sign in')
      auth_mock
      click_link 'Sign in'
    end
  end

end
