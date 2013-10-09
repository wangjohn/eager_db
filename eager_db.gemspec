Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'eager_db'
  s.version     = '0.0.0'
  s.summary     = 'Database management layer for preloading queries'
  s.description = 'Database management layer for preloading queries'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'MIT'

  s.author   = 'John Wang'
  s.email    = 'jwcitadel@gmail.com'

  s.files        = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.require_path = 'lib'
end

