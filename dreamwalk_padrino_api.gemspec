# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dreamwalk_padrino_api/version'

Gem::Specification.new do |spec|
  spec.name          = "dreamwalk_padrino_api"
  spec.version       = DreamwalkPadrinoApi::VERSION
  spec.authors       = ["Thiago Campezzi"]
  spec.email         = ["thiago@dreamwalk.com.au"]
  spec.description   = %q{Register the Dreamwalk::Padrino::Api extension in a Padrino app to make it compatible with our iOS/Android API clients. This extension enables request validation and conditional requests and provides helper methods that simplify outputting partial responses.}
  spec.summary       = %q{DreamWalk's Padrino API Extension}
  spec.homepage      = "http://git.dreamwalk.co"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency 'sequel'
  spec.add_dependency 'sequel-paranoid'
  spec.add_dependency 'oj'
  spec.add_dependency 'uuidtools'
end
