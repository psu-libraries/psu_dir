# frozen_string_literal: true

module PsuDir::Disambiguate
  autoload :Base, 'psu_dir/disambiguate/base'
  autoload :Name, 'psu_dir/disambiguate/name'
  autoload :Email, 'psu_dir/disambiguate/email'
  autoload :User, 'psu_dir/disambiguate/user'
  autoload :MultipleUserError, 'psu_dir/disambiguate/multiple_user_error'
end
