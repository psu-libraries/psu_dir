# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'psu_dir/version'

Gem::Specification.new do |spec|
  spec.name          = 'psu_dir'
  spec.version       = PsuDir::VERSION
  spec.authors       = ['Carolyn Cole', 'Adam Wead']
  spec.email         = ['cam156@psu.edu', 'amsterdamos@gmail.com']

  spec.summary       = 'Directory services at Penn State University.'
  spec.description   = "Performs queries against Penn State's directory services to find users and return preferred"\
                       ' names, email address, and other information.'
  spec.homepage      = 'https://github.com/psu-stewardship/psu_dir'
  spec.licenses      = ['Apache-2.0']

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hydra-ldap'
  spec.add_dependency 'mail', '~> 2.6'
  spec.add_dependency 'namae', '0.9.3'
  spec.add_dependency 'net-ldap', '~> 0.16.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug', '~> 9.1'
  spec.add_development_dependency 'niftany', '~> 0.0.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
end
