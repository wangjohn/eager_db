require 'rake/testtask'

test_path = File.expand_path("../test", __FILE__)
Rake::TestTask.new do |t|
  t.libs << test_path
  t.test_files = FileList[File.expand_path("*test.rb", test_path)]
  t.verbose = true
end
