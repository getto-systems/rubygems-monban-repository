lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "monban/repository/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 2.5.1"

  spec.name          = "monban-repository"
  spec.version       = Monban::Repository::VERSION
  spec.authors       = ["shun@getto.systems"]
  spec.email         = ["shun@getto.systems"]

  spec.summary       = %q{Monban - repository implementation}
  spec.description   = %q{Monban - repository implementation}
  spec.homepage      = "https://github.com/getto-systems/rubygems-monban-repository"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.extra_rdoc_files = ['README.md', 'LICENSE']
  spec.rdoc_options = %w[--title Monban::Repository --main README.md]

  spec.add_runtime_dependency "getto-initialize_with", "~> 1.0"
  spec.add_runtime_dependency "getto-repository-sequel", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "simplecov", "~> 0.16"
end
