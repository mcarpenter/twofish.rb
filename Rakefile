
require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/testtask'

desc 'Default task (test)'
task :default => [:test]

desc 'Run unit tests'
Rake::TestTask.new('test') do |test|
  test.pattern = 'test/*.rb'
  test.warning = true
end

task :gem
spec = eval( File.read('twofish.gemspec') )
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc 'Generate rdoc'
Rake::RDocTask.new do |rdoc|
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

desc 'Clean up'
task :clean do
  FileUtils.rm( Dir.glob( File.join('pkg', '*') ) )
  FileUtils.rm_r( Dir.glob( File.join('rdoc', '*') ) )
end

