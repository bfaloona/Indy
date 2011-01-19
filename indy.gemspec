require File.dirname(__FILE__) + "/lib/indy"

module Indy

  def self.show_version_changes(version)
    date = ""
    changes = []  
    grab_changes = false

    File.open("#{File.dirname(__FILE__)}/History.txt",'r') do |file|
      while (line = file.gets) do

        if line =~ /^===\s*#{version.gsub('.','\.')}\s*\/\s*(.+)\s*$/
          grab_changes = true
          date = $1.strip
        elsif line =~ /^===\s*.+$/
          grab_changes = false
        elsif grab_changes
          changes = changes << line
        end

      end
    end

    { :date => date, :changes => changes }
  end
end

Gem::Specification.new do |s|
  s.name        = 'indy'
  s.version     = ::Indy::VERSION
  s.authors     = ["Franklin Webber","Brandon Faloona"]
  s.description = %{ Indy is a log archelogy library that treats logs like data structures. Search fixed format or custom logs by field and/or time. }
  s.summary     = "Log Search Library"
  s.email       = 'franklin.webber@gmail.com'
  s.homepage    = "http://github.com/burtlo/Indy"
  s.license     = 'MIT'

  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.5'
  s.add_dependency('activesupport', '>= 2.3.5')

  s.add_development_dependency('cucumber', '>= 0.9.2')
  s.add_development_dependency('yard', '>= 0.6.4')
  s.add_development_dependency('cucumber-in-the-yard', '>= 1.7.7')
  s.add_development_dependency('rspec', '>= 2.4.0')
  s.add_development_dependency('rspec-mocks', '>= 2.4.0')
  s.add_development_dependency('rspec-prof', '>= 0.0.3')
  s.add_development_dependency('rcov', '>= 0.9.9')
  s.add_development_dependency('flog', '>= 2.5.0')

  changes = Indy.show_version_changes(::Indy::VERSION)

  s.post_install_message = %{
    [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>]

    Thank you for installing Indy #{::Indy::VERSION} / #{changes[:date]}.

    Changes:
    #{changes[:changes].collect{|change| "  #{change}"}.join("")}
    [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>] [<>]

  }

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.extra_rdoc_files = ["README.md", "History.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
