module TestEnv
  GIT_PROVIDER_URL         = 'github.com'
  OMNIAUTH_STRATEGY        = 'github'
  COURSE_ORGANIZATION      = 'anacapa-test-organization'
  OMNIAUTH_PROVIDER_KEY    = 'keykeykey'
  OMNIAUTH_PROVIDER_SECRET = 'secretsecretsecret'
  MACHINE_USER_NAME        = 'anacapa-test-machine-user'
  MACHINE_USER_KEY         = 'testkeytestkeytestkeytestkey'
end

ENV['GIT_PROVIDER_URL']         = TestEnv::GIT_PROVIDER_URL
ENV['OMNIAUTH_STRATEGY']        = TestEnv::OMNIAUTH_STRATEGY
ENV['COURSE_ORGANIZATION']      = TestEnv::COURSE_ORGANIZATION
ENV['OMNIAUTH_PROVIDER_KEY']    = TestEnv::OMNIAUTH_PROVIDER_KEY
ENV['OMNIAUTH_PROVIDER_SECRET'] = TestEnv::OMNIAUTH_PROVIDER_SECRET
ENV['MACHINE_USER_NAME']        = TestEnv::MACHINE_USER_NAME
ENV['MACHINE_USER_KEY']         = TestEnv::MACHINE_USER_KEY

module Opts
  opts = JSON.parse(
    JSON.dump(YAML.load_file(File.expand_path("../../config.yml", __FILE__))), 
    symbolize_names: true)
end


RSpec.configure do |config|
  config.include TestEnv
  config.include Opts
  # print(config.opts[:TestGithubOrgs][:CiTestOrg])
end
