require 'digest/md5'

class MemberConverge < ActiveRecord::Base
  set_table_name IpcAuthpipe::config.invision['tables_prefix'] + 'members_converge'
  set_primary_key 'converge_id'

  # Verifies if the given clear password matches hash and salt stored in IPB's database,
  # returns true/false depending on the result
  def valid_password?(cleartext)
    return salted_hash(cleartext) == converge_pass_hash
  end

  # Calculates and returns IPB-style salted hash for a given text string
  def salted_hash(text)
    return Digest::MD5.hexdigest(
      Digest::MD5.hexdigest(converge_pass_salt) + Digest::MD5.hexdigest(text)
    )
  end
end