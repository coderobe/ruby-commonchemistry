Gem::Specification.new do |spec|
  spec.name          = "commonchemistry"
  spec.version       = CommonChemistry::VERSION
  spec.summary       = "commonchemistry.cas.org api wrapper"
  spec.description   = "commonchemistry api module"
  spec.authors       = ["coderobe"]
  spec.email         = ["git@coderobe.net"]

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
end
