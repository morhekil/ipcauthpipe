Gem::Specification.new do |s|
  s.name     = "ipcauthpipe"
  s.version  = "0.2.3"
  s.date     = "2009-08-24"
  s.summary  = "Implementation of Courier's authpipe protocol over Invision Power Board / Converge."
  s.description = "ipcauthpipe gem implements Courier's authpipe protocol to interface Courier POP/IMAP server with Invision Power Board / Converge members database."
  s.has_rdoc = false

  s.author  = "Oleg Ivanov"
  s.email = "morhekil@morhekil.net"
  s.homepage = "http://morhekil.net"

  s.files = ['lib/ipcauthpipe/handler/auth.rb',
    'lib/ipcauthpipe/handler/enumerate.rb',
    'lib/ipcauthpipe/handler/passwd.rb',
    'lib/ipcauthpipe/handler/pre.rb',
    'lib/ipcauthpipe/handler.rb',
    'lib/ipcauthpipe/log.rb',
    'lib/ipcauthpipe/processor.rb',
    'lib/ipcauthpipe/reader.rb',
    'lib/models/member.rb',
    'lib/models/member_converge.rb',
    'lib/ipcauthpipe.rb',
    'bin/ipcauthpipe',
    'ipcauthpipe.gemspec',
    'README',
    'config.yml'
  ]

  s.test_files = ['test/ipcauthpipe/handler/auth_spec.rb',
    'test/ipcauthpipe/handler/pre_spec.rb',
    'test/ipcauthpipe/log_spec.rb',
    'test/ipcauthpipe/processor_spec.rb',
    'test/models/member_spec.rb',
    'test/models/member_converge_spec.rb',
    'test/spec_helper.rb',
    'test/config.yml'
  ]

  s.bindir = 'bin'
  s.executables = ['ipcauthpipe']

  s.require_path = 'lib'

  s.add_dependency("activerecord", ">= 2.1.0")
end