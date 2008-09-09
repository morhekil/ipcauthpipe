require File.dirname(__FILE__) + '/../spec_helper'

require 'activerecord'
require 'models/member'
require 'models/member_converge'

describe 'Member' do

  before(:each) do
    Member.delete_all
    @tester_converge = mock('member_converge') #,
    @member = Member.create(:email => 'test@test.com', :name => 'tester')
    MemberConverge.stub!(:find).and_return(@tester_converge)
      #:pass_hash => '3a063c7f0d62df2ff444ca22455a7232', :pass_salt => '/yU(t') # password is 'testtest'
  end

  it "should find a member by his username and cleartext password" do
    MemberConverge.should_receive(:find).once.and_return(@tester_converge)
    @tester_converge.should_receive(:valid_password?).with('testtest').once.and_return(true)

    Member.find_by_name_and_password( @member.name, 'testtest' ).should == @member
  end

  it "should raise AuthenticationFailed exception on invalid password" do
    MemberConverge.should_receive(:find).once.and_return(@tester_converge)
    @tester_converge.should_receive(:valid_password?).with('wrongpassword').once.and_return(false)

    lambda { Member.find_by_name_and_password( @member.name, 'wrongpassword' ) }.should raise_error(IpcAuthpipe::AuthenticationFailed)
  end

  it "should raise AuthenticationFailed exception on invalid username" do
    MemberConverge.should_receive(:find).never
    @tester_converge.should_receive(:valid_password?).never

    lambda { Member.find_by_name_and_password( 'foobarname', 'wrongpassword' ) }.should raise_error(IpcAuthpipe::AuthenticationFailed)
  end

end
