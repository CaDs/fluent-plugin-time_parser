Gem::Specification.new do |gem|
  gem.name          = 'fluent-plugin-time_parser'
  gem.version       = '0.0.5'
  gem.authors       = ['Carlos Donderis', 'Michael H. Oshita']
  gem.email         = ['cdonderis@gmail.com', 'ijinpublic+github@gmail.com']
  gem.homepage      = 'http://github.com/cads/fluent-plugin-time_parser'
  gem.description   = %q{Fluentd plugin to parse the time parameter.}
  gem.summary       = %q{Fluentd plugin to parse the time parameter.}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'fluentd'
  gem.add_development_dependency 'tzinfo'
  gem.add_runtime_dependency     'tzinfo'
  gem.add_runtime_dependency     'fluentd'
end
