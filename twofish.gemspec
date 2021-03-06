
Gem::Specification.new do |s|
  s.authors = [ 'Martin Carpenter' ]
  s.date = Time.now.strftime('%Y-%m-%d')
  s.description = 'Twofish symmetric cipher in pure Ruby with ECB and CBC cipher modes derived from an original Perl implementation by Guido Flohr'
  s.email = 'martin.carpenter@gmail.com'
  s.extra_rdoc_files = %w{ LICENSE Rakefile README.rdoc }
  s.files = Dir[ 'lib/**/*', 'test/**/*' ]
  s.homepage = 'http://mcarpenter.org/projects/twofish'
  s.licenses = [ 'BSD-2-Clause' ]
  s.name = 'twofish'
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = nil
  s.summary = 'Twofish symmetric cipher in pure Ruby'
  s.test_files = Dir[ "test/**/test_*.rb" ]
  s.version = '1.0.8'
end

