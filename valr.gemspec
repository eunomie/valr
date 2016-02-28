Gem::Specification.new do |s|
  s.name = 'valr'
  s.version = '0.1.0'
  s.date = '2015-10-20'
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

  s.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.0'
  s.add_development_dependency 'guard', '~> 2.13', '>= 2.13.0'
  s.add_development_dependency 'guard-rspec', '~> 4.6', '>= 4.6.4'
  s.add_development_dependency 'simplecov', '~> 0.10', '>= 0.10.0'
  s.add_development_dependency 'cucumber', '~> 2.3', '>= 2.3.2'
  s.add_development_dependency 'guard-cucumber', '~> 2.0'
  s.add_dependency 'rugged', '~> 0.23.2'
  s.add_dependency 'koios', '~> 0.2.0'
end
