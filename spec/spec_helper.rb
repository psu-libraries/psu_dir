# frozen_string_literal: true

require 'bundler/setup'
require 'psu_dir'
require 'support/ldap'
require 'byebug'

ENV['ldap_unwilling_sleep'] = '0'

def in_travis
  ENV['TRAVIS']
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
