# frozen_string_literal: true

require 'psu_dir/version'
require 'net-ldap'
require 'hydra-ldap'
require 'namae'
require 'logger'
require 'mail'

module PsuDir
  autoload :Disambiguate, 'psu_dir/disambiguate'
  autoload :LdapUser, 'psu_dir/ldap_user'
  autoload :Ldap, 'psu_dir/ldap'

  class << self
    def logger
      @logger ||= if Rails.try(:logger)
                    Rails.logger
                  else
                    Logger.new(STDOUT)
                  end
    end

    def ldap_unwilling_sleep
      @ldap_unwilling_sleep ||= ENV.fetch('ldap_unwilling_sleep', 2).to_i
    end
  end
end
