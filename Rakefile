require 'rake/testtask'

task :default => :test

task :test => ["test:unit", "test:functional"]

namespace :test do
  Rake::TestTask.new("unit") do |t|
    t.libs << "lib"
    t.test_files = FileList['test/unit/*_test.rb']
    t.verbose = true
  end

  Rake::TestTask.new("functional") do |t|
    t.libs << "lib"
    t.test_files = FileList['test/functional/*_test.rb']
    t.verbose = true
  end
end
