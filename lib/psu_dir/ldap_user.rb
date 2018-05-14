# frozen_string_literal: true

class PsuDir::LdapUser < PsuDir::Ldap
  class << self
    def get_groups(login)
      return [] if login.blank?
      retry_if { parse_ldap_groups(group_response_from_ldap(login)) } || []
    end

    def check_ldap_exist!(login)
      return false if login.blank?
      retry_if { Hydra::LDAP.does_user_exist?(Net::LDAP::Filter.eq('uid', login)) } || false
    end

    def filter_for(*people)
      return '' if people.empty?
      '(| ' + people.map { |p| "(eduPersonPrimaryAffiliation=#{p.to_s.upcase})" }.join(' ') + ')))'
    end

    private

      def parse_ldap_groups(result)
        return [] if result.empty?
        result.first[:psmemberof].select { |y| y.start_with? 'cn=umg/' }.map do |x|
          x.sub(/^cn=/, '').sub(/,dc=psu,dc=edu/, '')
        end
      end

      # Response from LDAP
      # We have to pass a block, see https://github.com/projecthydra-labs/hydra-ldap/issues/8
      def group_response_from_ldap(login)
        Hydra::LDAP.groups_for_user(Net::LDAP::Filter.eq('uid', login)) { |r| r }
      end
  end
end
