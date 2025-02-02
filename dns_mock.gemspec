# frozen_string_literal: true

require_relative 'lib/dns_mock/version'

Gem::Specification.new do |spec|
  spec.name          = 'dns_mock'
  spec.version       = DnsMock::VERSION
  spec.authors       = ['Vladislav Trotsenko']
  spec.email         = ['admin@bestweb.com.ua']

  spec.summary       = %(dns_mock)
  spec.description   = %(💎 Ruby DNS mock. Mimic any DNS records for your test environment and even more.)

  spec.homepage      = 'https://github.com/mocktools/ruby-dns-mock'
  spec.license       = 'MIT'

  spec.metadata = {
    'homepage_uri' => 'https://github.com/mocktools/ruby-dns-mock',
    'changelog_uri' => 'https://github.com/mocktools/ruby-dns-mock/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/mocktools/ruby-dns-mock',
    'documentation_uri' => 'https://github.com/mocktools/ruby-dns-mock/blob/master/README.md',
    'bug_tracker_uri' => 'https://github.com/mocktools/ruby-dns-mock/issues'
  }

  spec.required_ruby_version = '>= 2.5.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| ::File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'simpleidn', '~> 0.2.1'

  spec.add_development_dependency 'ffaker', '~> 2.21'
  spec.add_development_dependency 'net-ftp', '~> 0.1.3' if ::RUBY_VERSION >= '3.1.0'
  spec.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rspec-dns', '~> 0.1.8'
end
