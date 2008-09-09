Gem::Specification.new do |s|
  s.name     = "ipcauthpipe"
  s.version  = "0.1"
  s.date     = "2008-09-10"
  s.summary  = "Implementation of Courier's authpipe protocol over Invision Power Board / Converge."
  s.email    = "tom@rubyisawesome.com"
  s.homepage = "http://github.com/schacon/grit"
  s.description = "ipcauthpipe gem implements Courier's authpipe protocol to interface Courier POP/IMAP server with Invision Power Board / Converge members database."
  s.has_rdoc = false

  s.author  = "Oleg Ivanov"
  s.email = "morhekil@morhekil.net"
  s.homepage = "http://twitter.com/morhekil"

  s.files = Dir['lib/*.rb'] +
    Dir['lib/ipcauthpipe/*.rb'] +
    Dir['lib/ipcauthpipe/handler/*.rb'] +
    Dir['lib/models/*.rb'] +
    ['bin/ipcauthpipe', 'ipcauthpipe.gemspec', 'README', 'config.yml']

  s.test_files = ["test/config.yml", "test/spec_helper.rb"] +
    Dir['test/ipcauthpipe/*.rb'] +
    Dir['test/ipcauthpipe/handler/*.rb'] +
    Dir['test/models/*.rb']

  s.bindir = 'bin'
  s.executables = ['ipcauthpipe']

  s.require_path = 'lib'

  s.add_dependency("activerecord", ">= 2.1.0")
end