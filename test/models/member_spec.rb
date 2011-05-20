require File.dirname(__FILE__) + '/../spec_helper'

require 'active_record'
require 'models/member'
require 'models/member_converge'

describe Member do

  before(:all) do
    IpcAuthpipe::Log.logger = stub('stub').as_null_object
  end

  before(:each) do
    Member.delete_all
    @tester = mock('member', :kind_of? => true) #,
    @member = Member.create(:email => 'test@test.com', :name => 'tester')
      #:pass_hash => '3a063c7f0d62df2ff444ca22455a7232', :pass_salt => '/yU(t') # password is 'testtest'
  end

  it "should find a member by his username and cleartext password" do
    Member.should_receive(:find_by_name).once.with(@member.name).and_return(@tester)
    @tester.should_receive(:valid_password?).with('testtest').once.and_return(true)
    @tester.should_receive(:has_mail_access?).once.and_return(true)

    Member.find_by_name_and_password( @member.name, 'testtest' ).should == @tester
  end

  it "should raise AuthenticationFailed exception on invalid password" do
    Member.should_receive(:find).once.and_return(@tester)
    @tester.should_receive(:valid_password?).with('wrongpassword').once.and_return(false)

    lambda { Member.find_by_name_and_password( @member.name, 'wrongpassword' ) }.should raise_error(IpcAuthpipe::AuthenticationFailed)
  end

  it "should raise AuthenticationFailed exception on invalid username" do
    MemberConverge.should_receive(:find).never
    @tester.should_receive(:valid_password?).never

    lambda { Member.find_by_name_and_password( 'foobarname', 'wrongpassword' ) }.should raise_error(IpcAuthpipe::AuthenticationFailed)
  end

  it "should dump itself into text string for authlib" do
    member = Member.new(
      :name => 'Tester'
    )

    member.to_authpipe.should == [
      "UID=#{IpcAuthpipe::config.mail['owner_uid']}",
      "GID=#{IpcAuthpipe::config.mail['owner_gid']}",
      "HOME=/home/vmail/t/tester/",
      "MAILDIR=/home/vmail/t/tester/",
      "ADDRESS=tester@poker.ru",
      "."
    ].join("\n") + "\n"
  end

  describe 'password validation' do

    before(:each) do
      salt = '/yU(t'
      password = 'testtest'
      @member = Member.new(
        # password is testtest
        :members_pass_hash => Digest::MD5.hexdigest(
            Digest::MD5.hexdigest(salt) + Digest::MD5.hexdigest(password)
          ),
        :members_pass_salt => salt
      )
    end

    it "should verify cleartext password against hashed one" do
      @member.valid_password?('foobar').should == false
      @member.valid_password?('testtest').should == true
    end

  end
end

