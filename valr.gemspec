Gem::Specification.new do |s|
	s.name = 'valr'
	s.version = '0.1.0'
	s.date = '2015-10-07'
	s.summary = 'Changelog generator'
	s.description = 'A markdown powered CHANGELOG generator using git commit messages.'
	s.authors = ['Yves Brissaud']
	s.email = 'yves.brissaud@gmail.com'
	all_files       = `git ls-files -z`.split("\x0")
	s.files         = all_files.grep(%r{^(bin|lib)/})
	s.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
	s.require_paths = ['lib']
	s.homepage = 'https://github.com/eunomie/valr'
	s.license = 'MIT'

	s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'simplecov'
  s.add_dependency 'rugged', '~> 0.23.2'
end
