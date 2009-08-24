class Member < ActiveRecord::Base
  set_table_name IpcAuthpipe::config.invision['tables_prefix'] + 'members'

  has_one :converge, :class_name => 'MemberConverge', :foreign_key => 'converge_id'

  def self.find_by_name_and_password(username, password)
    member = find_by_name(username)
    raise(
        IpcAuthpipe::AuthenticationFailed, 'invalid password'
      ) unless member.kind_of?(Member) && member.converge.valid_password?(password)

    member
  end
  
  def homedir
    (IpcAuthpipe::config.mail['home_dir'] % "#{name[0..0]}/#{name}").downcase
  end
  
  # Create user's home dir if it's not present
  def create_homedir
    unless File.exists?(homedir)
      FileUtils.mkdir_p(homedir, :mode => 0750)
      FileUtils.mkdir_p("#{homedir}/cur", :mode => 0750)
      FileUtils.mkdir_p("#{homedir}/new", :mode => 0750)
      FileUtils.mkdir_p("#{homedir}/tmp", :mode => 0750)
      FileUtils.chown(IpcAuthpipe::config.mail['owner_name'], IpcAuthpipe::config.mail['owner_group'], "#{homedir}/..")
      FileUtils.chown_R(IpcAuthpipe::config.mail['owner_name'], IpcAuthpipe::config.mail['owner_group'], homedir)
    end
  end

  def to_authpipe
    IpcAuthpipe::Log.debug "Dumping authpipe string for member data #{inspect}"
    stringdump = [
      "UID=#{IpcAuthpipe::config.mail['owner_uid']}",
      "GID=#{IpcAuthpipe::config.mail['owner_gid']}",
      "HOME=#{homedir}/",
      "MAILDIR=#{homedir}/",
      "ADDRESS=#{(IpcAuthpipe::config.mail['address_format'] % name).downcase}",
      "."
    ].join("\n")+"\n"
    IpcAuthpipe::Log.debug "Authpipe dump: #{stringdump.inspect}"

    stringdump
  end
end
