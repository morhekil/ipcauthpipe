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
    IpcAuthpipe::config.mail['home_dir'] % "#{name[0..0]}/#{name}"
  end
  
  # Create user's home dir if it's not present
  def create_homedir
    FileUtils.mkdir(member.homedir, :mode => '0755') unless File.exists?(member.homedir)
  end

  def to_authpipe
    IpcAuthpipe::Log.debug "Dumping authpipe string for member data #{inspect}"
    stringdump = [
      "UID=#{IpcAuthpipe::config.mail['owner_uid']}",
      "GID=#{IpcAuthpipe::config.mail['owner_gid']}",
      "HOME=#{homedir}/",
      "MAILDIR=#{homedir}/",
      "ADDRESS=#{IpcAuthpipe::config.mail['address_format'] % name}",
      "."
    ].join("\n")+"\n"
    IpcAuthpipe::Log.debug "Authpipe dump: #{stringdump.inspect}"

    stringdump
  end
end
