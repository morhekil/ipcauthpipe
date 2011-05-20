require File.dirname(__FILE__) + '/../spec_helper'

require 'active_record'
require 'models/member_converge'

describe 'Member Converge' do

  before(:each) do
    salt = '/yU(t'
    password = 'testtest'
    @converge = MemberConverge.new(
      # password is testtest
      :converge_pass_hash => Digest::MD5.hexdigest(
          Digest::MD5.hexdigest(salt) + Digest::MD5.hexdigest(password)
        ),
      :converge_pass_salt => salt
    )
  end

  it "should verify cleartext password against hashed one" do
    @converge.valid_password?('foobar').should == false
    @converge.valid_password?('testtest').should == true
  end

end
