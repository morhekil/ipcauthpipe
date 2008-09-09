require File.dirname(__FILE__) + '/../../spec_helper'

require 'ipcauthpipe/handler'
require 'ipcauthpipe/handler/auth'
require 'ipcauthpipe/reader'
require 'models/member'

describe "PRE handler" do

  before(:all) do
    IpcAuthpipe::Log.logger = stub_everything
  end

  before(:each) do
    @pre = IpcAuthpipe::Handler::Pre.new
  end

  it "should split request and find a member" do
    request = '. imap tester'
    splitted_request = { :service => 'imap', :username => 'tester' }
    @pre.should_receive(:split_request).with(request).once.and_return(splitted_request)
    @pre.should_receive(:user_details).with(splitted_request).once.and_return("MEMBER\nDUMP\n.")
    IpcAuthpipe::Handler::Pre.should_receive(:new).once.and_return(@pre)

    IpcAuthpipe::Handler::Pre.process(request)
  end

  it "should split request into authservice and username parts" do
    @pre.split_request('. pop3 tester').should == { :service => 'pop3', :username => 'tester' }
  end

  it "should raise ArgumentError if request string is invalid" do
    lambda { @pre.split_request('wtfisthis') }.should raise_error(ArgumentError)
  end

  it "should find and return user's info by his name" do
    member = mock('member')
    Member.should_receive(:find_by_name).once.with('tester').and_return(member)
    member.should_receive(:to_authpipe).once.and_return("MEMBER\nINFO\n.")

    request = { :service => 'pop3', :username => 'tester' }
    @pre.user_details(request).should == "MEMBER\nINFO\n."
  end

  it "should return FAIL for invalid username" do
    Member.should_receive(:find_by_name).once.with('foobar').and_return(nil)
    request = { :service => 'pop3', :username => 'foobar' }
    @pre.user_details(request).should == "FAIL\n"
  end
end