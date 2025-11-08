require_relative "lib/gemfather/cli/version"

Gem::Specification.new do |spec|
  spec.name = "gemfather-cli"
  spec.version = Gemfather::Cli::VERSION
  spec.authors = ["k0va1"]
  spec.email = ["al3xander.koval@gmail.com"]

  spec.summary = "Gem for creating other gems"
  spec.description = "Ask some questions & create a new gem template"
  spec.homepage = "https://gitlab.com/k0va1/gemfather-cli"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.glob("{lib,templates}/**/*", File::FNM_DOTMATCH) + %w[LICENSE.txt README.md CHANGELOG.md]
  spec.bindir = "exe"
  spec.executables = ["gemfather"]

  spec.add_dependency "zeitwerk", "~> 2.7"
  spec.add_dependency "tty-prompt", "~> 0.23"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "1.51.0"
end
