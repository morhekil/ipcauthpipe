$spec = Gem::Specification.new do |s|
  s.name = 'ipcauthpipe'
  s.version = "0.1"
  s.summary = "Implementation of Courier's authpipe protocol over Invision Power Board / Converge."
  s.description = %{ipcauthpipe gem implements Courier's authpipe protocol to interface Courier POP/IMAP server with
  Invision Power Board / Converge members database.%}
  s.files = Dir['lib/*.rb'] + Dir['lib/ipcauthpipe/*.rb'] + Dir['lib/ipcauthpipe/handler/*.rb'] + Dir['bin/ipcauthpipe']

  s.bindir = 'bin'
  s.executables = ['ipcauthpipe']

  s.require_path = 'lib'

  s.author = "Oleg Ivanov"
  s.email = "morhekil@morhekil.net"
  s.homepage = "http://twitter.com/morhekil"
end
