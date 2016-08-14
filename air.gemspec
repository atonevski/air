# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','air','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'air'
  s.version = Air::VERSION
  s.author = 'Your Name Here'
  s.email = 'your@email.address.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','air.rdoc']
  s.rdoc_options << '--title' << 'air' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'air'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.13.4')

  s.add_dependency 'activesupport'
  s.add_dependency 'json'
  s.add_dependency 'colorize'
  s.add_dependency 'sqlite3'
  s.add_dependency 'active_record_migrations'
end
