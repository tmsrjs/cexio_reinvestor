# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cexio_reinvestor/version'

Gem::Specification.new do |spec|
  spec.name          = "cexio_reinvestor"
  spec.version       = CexioReinvestor::VERSION
  spec.authors       = ["Tomas Rojas"]
  spec.email         = ["tmsrjs@gmail.com"]
  spec.description   = %q{CEX.io Reinvestor reinvests earned BTC and NMC.}
  spec.summary       = %q{CEX.io Reinvestor.}
  spec.homepage      = "https://github.com/tmsrjs/cexio_reinvestor"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cexio"
  spec.add_dependency "micro-optparse"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "webmock", "~> 1.17.2"
  spec.add_development_dependency "debugger"
end
