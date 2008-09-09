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

  def to_authpipe
    [
      "USERNAME=#{IpcAuthpipe::config.mail['owner_username']}",
      "GID=#{IpcAuthpipe::config.mail['owner_gid']}",
      "HOME=#{IpcAuthpipe::config.mail['home_dir'] % name}",
      "ADDRESS=#{IpcAuthpipe::config.mail['address_format'] % name}",
      "."
    ].join("\n")+"\n"
  end
end