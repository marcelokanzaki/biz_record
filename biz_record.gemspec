# frozen_string_literal: true

require_relative "lib/biz_record/version"

Gem::Specification.new do |spec|
  spec.name = "biz_record"
  spec.version = BizRecord::VERSION
  spec.authors = [ "Marcelo Kanzaki" ]
  spec.email = "marcelo@hey.com"
  spec.homepage = "https://github.com/marcelokanzaki/biz_record"
  spec.summary = "Persistence layer for the biz gem."
  spec.description = "Persistence layer for schedules used by the biz gem."
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "LICENSE.txt",
      "README.md",
      "lib/**/*"
    ]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "biz", "~> 1.8"
  spec.add_dependency "activerecord", ">= 7.1", "< 9.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "railties", ">= 7.1", "< 9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "sqlite3", "~> 2.0"
end
