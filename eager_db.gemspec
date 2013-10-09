Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'eager_db'
  s.version     = '0.0.0'
  s.summary     = 'Database management layer for preloading queries'
  s.description = 'Database management layer for preloading queries'

  s.required_ruby_version = '>= 1.9.3'

  s.license  = 'MIT'

  s.author   = 'John J. Wang'
  s.email    = 'jwcitadel@gmail.com'

  s.files        = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.require_path = 'lib'

  s.add_runtime_dependency('activesupport', '~> 4.0.0')
  s.add_runtime_dependency('resque')
end

