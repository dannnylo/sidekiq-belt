# frozen_string_literal: true

require_relative "lib/sidekiq/belt/version"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-belt"
  spec.version = Sidekiq::Belt::VERSION
  spec.authors = ["Danilo Jeremias da Silva"]
  spec.email = ["daniloj.dasilva@gmail.com"]

  spec.summary = "This Ruby gem enhances the capabilities of Sidekiq, Sidekiq Pro, and Sidekiq Enterprise by adding " \
                 "essential utilities."
  spec.description = "This Ruby gem enhances the capabilities of Sidekiq, Sidekiq Pro, and Sidekiq Enterprise by " \
                     "adding essential utilities."

  spec.homepage = "https://github.com/dannnylo/sidekiq-belt"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 8"
  spec.metadata["rubygems_mfa_required"] = "true"
end
