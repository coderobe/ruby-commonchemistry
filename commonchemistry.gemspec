require_relative "lib/commonchemistry/version"

Gem::Specification.new do |spec|
  spec.name          = "commonchemistry"
  spec.version       = CommonChemistry::VERSION
  spec.summary       = "commonchemistry.cas.org api wrapper"
  spec.description   = "commonchemistry api module"
  spec.authors       = ["coderobe"]
  spec.email         = ["git@coderobe.net"]
  spec.homepage      = "https://github.com/coderobe/ruby-commonchemistry"
  spec.licenses      = ["MIT"]

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", '~> 0.22.0'
end
