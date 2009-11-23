require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "Spy-Vs-Spy"
    s.description = s.summary = "Rack middleware to detect and provide more detail on the requesting user agent edit"
    s.email = "kuccello@gmail.com"
    s.homepage = "http://github.com/kuccello/Spy-Vs-Spy"
    s.authors = ['Kristan "Krispy" Uccello']
    s.files = FileList["[A-Z]*", "{lib,test}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*-test.rb']
  t.verbose = true
end

require 'rake/rdoctask'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end
