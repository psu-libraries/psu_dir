# frozen_string_literal: true

module PsuDir
  class Ldap
    class << self
      def get_users(filter, fields = [])
        retry_if { Hydra::LDAP.get_user(filter, fields) } || []
      end

      # Retries the LDAP command up to .tries times, or catches any other kind of LDAP error without retrying.
      # return [block or nil]
      def retry_if
        tries.times.each do
          result = yield
          return result unless unwilling?
          sleep(PsuDir.ldap_unwilling_sleep)
        end
        PsuDir.logger.warn 'LDAP is unwilling to perform this operation, try upping the number of tries'
        nil
      rescue Net::LDAP::Error => e
        PsuDir.logger.warn "Error getting LDAP response: #{ldap_error_message(e)}"
        nil
      end

      def tries
        7
      end

      # Numeric code returned by LDAP if it is feeling "unwilling"
      def unwilling?
        Hydra::LDAP.connection.get_operation_result.code == 53
      end

      def ldap_error_message(e)
        "#{Hydra::LDAP.connection.get_operation_result.message}\nException: #{e.exception}\n#{e.backtrace.join("\n")}"
      end
    end
  end
end
