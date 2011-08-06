$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'indy/platform'


Gem::Specification.new do |s|
  s.name        = 'indy'
  s.version     = ::Indy::VERSION
  s.authors     = ["Franklin Webber","Brandon Faloona"]
  s.description = %{ Indy is a log archelogy library that treats logs like data structures. Search fixed format or custom logs by field and/or time. }
  s.summary     = "indy-#{s.version}"
  s.email       = 'brandon@faloona.net'
  s.homepage    = "http://github.com/burtlo/Indy"
  s.license     = 'MIT'

  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.5'
  s.add_dependency('activesupport', '>= 2.3.5')

  s.add_development_dependency('i18n')
  s.add_development_dependency('cucumber', '>= 0.10.0')
  s.add_development_dependency('yard', '>= 0.7.2')
  s.add_development_dependency('yard-cucumber', '>= 2.1.1')
  s.add_development_dependency('rspec', '>= 2.4.0')
  s.add_development_dependency('rspec-mocks', '>= 2.4.0')
  s.add_development_dependency('flog', '>= 2.5.0')
#  s.add_development_dependency('rspec-prof', '>= 0.0.3')
#  s.add_development_dependency('simplecov', '>= 0.4.0')
#  s.add_development_dependency('ruby-debug19', '>= 0.11.0')
#  s.add_development_dependency('rbx-linecache')

  changes = Indy.show_version_changes(::Indy::VERSION)

  s.post_install_message =
  %{
    [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>]

    Thank you for installing Indy #{::Indy::VERSION} / #{changes[:date]}.

    Changes:
    #{changes[:changes].collect{|change| "  #{change}"}.join("")}
    [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>]

  }

  
  s.rubygems_version  = "1.6.1"

  exclusions          = [File.join("performance", "large.log")]
  s.files             = `git ls-files`.split("\n") - exclusions
  s.test_files       = `git ls-files -- {spec,features,performance}/*`.split("\n")

  s.extra_rdoc_files  = ["README.md", "History.txt"]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.require_path      = "lib"
end
