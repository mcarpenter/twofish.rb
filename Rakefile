
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'

desc 'Default task (test)'
task :default => [:test]

Rake::TestTask.new('test') do |test|
  test.pattern = 'test/*.rb'
  test.warning = true
end

SPECFILE = 'twofish.gemspec'
if File.exist?(SPECFILE)
  spec = eval( File.read(SPECFILE) )
  Gem::PackageTask.new(spec) do |pkg|
    pkg.need_tar = true
  end
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'twofish.rb'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '-A cattr_accessor=object'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.options << '--all'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/twofish.rb')
  rdoc.rdoc_files.include('test/test_twofish.rb')
end

