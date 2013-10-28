
require 'benchmark'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'

desc 'Default task (test)'
task :default => [:test]

Rake::TestTask.new('test') do |test|
  test.pattern = 'test/test_*.rb'
  test.warning = true
end

Rake::TestTask.new('benchmark') do |test|
  test.pattern = 'test/benchmark.rb'
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
  rdoc.options << '--line-numbers'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.options << '--main' << 'README.rdoc'
  rdoc.options << '--all'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include(Dir[ 'lib/**/*' ])
end

