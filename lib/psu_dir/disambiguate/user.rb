# frozen_string_literal: true

module PsuDir::Disambiguate
  # This class provides an api for querying LDAP with different portions of the user's
  # information (name parts or id)
  class User < PsuDir::Ldap
    class << self
      def directory_attributes(login, attrs = [])
        filter = Net::LDAP::Filter.eq('uid', login)
        result = get_users(filter, attrs)
        format_users(result, attrs)
      end

      def query_ldap_by_mail(email, attrs = [])
        filter = Net::LDAP::Filter.construct(email_filter(email))
        users  = get_filtered_users(filter, attrs)
        format_users(users, attrs)
      end

      def query_ldap_by_name(given_name, surname, attrs = [])
        return [] if given_name.blank? # this method only work if we have a first name to play with

        first_names = given_name.split(/[\s.]+/)
        users = []
        name_filters(first_names[0], first_names[1], surname).each do |filter|
          users = get_filtered_users(filter, attrs)
          break if users.count.positive? # stop running through the filters if we get results
        end
        format_users(users, attrs)
      end

      def get_filtered_users(name_filter, attrs = [])
        attrs = (attrs + default_attributes).uniq
        filter = Net::LDAP::Filter.construct("(& (& #{name_filter}) #{person_filter})")
        get_users(filter, attrs)
      end

      def results_hash(opts)
        {
          id:          fetch(opts, :uid).first,
          given_name:  fetch(opts, :givenname).first,
          surname:     fetch(opts, :sn).first,
          email:       fetch(opts, :mail).first,
          affiliation: fetch(opts, :eduPersonPrimaryAffiliation, []),
          displayname: fetch(opts, :displayname).first
        }
      end

      private

      def fetch(opts, key, default = [''])
        opts[key].presence || default
      end

      def format_users(users, attrs)
        user_attrs = attrs - default_attributes
        users.map { |u| format_user(u, user_attrs) }
      end

      def format_user(user, extra_attrs)
        hash = results_hash(user)
        extra_attrs.each { |attr| hash[attr] = user[attr].first }
        hash
      end

      def size_limit_exceeded?
        Hydra::LDAP.connection.get_operation_result[:message] == 'Size Limit Exceeded'
      end

      def email_filter(email)
        '(& (|'\
        "  (psmailid=#{email})"\
        "  (mail=#{email})"\
        "  (psmailbox=#{email})"\
        "  (edupersonprincipalname=#{email})"\
        ") #{person_filter})"
      end

      def person_filter
        '(|'\
        '  (eduPersonPrimaryAffiliation=STUDENT)'\
        '  (eduPersonPrimaryAffiliation=FACULTY)'\
        '  (eduPersonPrimaryAffiliation=STAFF)'\
        '  (eduPersonPrimaryAffiliation=EMPLOYEE)'\
        '  (eduPersonPrimaryAffiliation=RETIREE)'\
        '  (eduPersonPrimaryAffiliation=EMERITUS)'\
        '  (eduPersonPrimaryAffiliation=MEMBER)'\
        '))'
      end

      def name_filters(first_name, middle_name, surname)
        filters = []
        if middle_name.blank?
          filters << "(givenname=#{first_name}) (sn=#{surname})"
          filters << "(givenname=#{first_name}*) (sn=#{surname})"
        else
          filters << "(givenname=#{first_name}*) (givenname=* #{middle_name}*) (sn=#{surname})"
          middle_initial = middle_name[0]
          filters << "(givenname=#{first_name}* #{middle_initial}*) (sn=#{surname})"
        end
        filters << "(givenname=#{first_name}) (sn=#{surname})"
        filters
      end

      def default_attributes
        %i[uid givenname sn mail eduPersonPrimaryAffiliation displayname]
      end

      def cache
        @cache ||= {}
      end
    end
  end
end
