
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bayesic_matching/version"

Gem::Specification.new do |spec|
  spec.name          = "bayesic_matching"
  spec.version       = BayesicMatching::VERSION
  spec.authors       = ["Michael Ries"]
  spec.email         = ["michael@riesd.com"]

  spec.summary       = "bayesian approach to matching one list of strings with another"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mmmries/bayesic_matching"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "benchmark-ips", "~> 2.7"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
