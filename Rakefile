
require 'rake'
require 'rake/rdoctask'

desc 'Default task (test)'
task :default => [:test]

desc 'Run unit tests'
task :test do
  ruby 'test_twofish.rb'
end

desc 'Generate rdoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'twofish.rb'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '-A cattr_accessor=object'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.options << '--all'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('twofish.rb')
  rdoc.rdoc_files.include('test_twofish.rb')
end
