Gem::Specification.new do |s|
  s.name        = "prim"
  s.version     = "0.0.1"
  s.date        = "2012-12-19"
  s.summary     = "Easily manage Rails associations that need a primary member."
  s.description = "Prim makes it dead simple to add a primary member to any Rails one-to-many or many-to-many association. 
                  Just add a short configuration to a model, generate and run a migration, and you're all set."
  s.authors     = [ "Piers Mainwaring" ]
  s.email       = "piers@impossibly.org"
  s.files       = `git ls-files`.split("\n")
  s.homepage    = "https://github.com/orcahealth/prim"

  s.require_paths = [ "lib" ]
end