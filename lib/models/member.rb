class Member < ActiveRecord::Base
  set_table_name IpcAuthpipe::config.invision['tables_prefix'] + 'members'

  def self.find_by_name_and_password(username, password)
    member = find_by_name(username)
    raise(
        IpcAuthpipe::AuthenticationFailed, 'invalid password'
      ) unless member.kind_of?(Member) && member.valid_password?(password) && member.has_mail_access?

    member
  end
  
  def has_mail_access?
    allowed_group = IpcAuthpipe::config.invision['allowed_group']
    if allowed_group
      # if allowed_group is defined - make sure that user is in this group
      # before allowing him to access email
      groups = [ member_group_id.to_s ] + mgroup_others.split(',')
      groups.include?(allowed_group.to_s)
    else
      # if allowed group is not set - allow all users to use the mail service
      true
    end
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

  # Verifies if the given clear password matches hash and salt stored in IPB's database,
  # returns true/false depending on the result
  def valid_password?(cleartext)
    return salted_hash(cleartext) == members_pass_hash
  end

  # Calculates and returns IPB-style salted hash for a given text string
  def salted_hash(text)
    return Digest::MD5.hexdigest(
      Digest::MD5.hexdigest(members_pass_salt) + Digest::MD5.hexdigest(text)
    )
  end
  
end
