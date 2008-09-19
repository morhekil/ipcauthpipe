require File.dirname(__FILE__) + '/../../spec_helper'

require 'ipcauthpipe/handler'
require 'ipcauthpipe/handler/auth'
require 'ipcauthpipe/reader'
require 'models/member'

describe "AUTH handler" do

  before(:all) do
    IpcAuthpipe::Log.logger = stub_everything
  end
  
  before(:each) do
    @auth = IpcAuthpipe::Handler::Auth.new
  end

  it "should read given number of bytes from the input stream and pass them onto the analyzer splitted into an array" do
    IpcAuthpipe::Reader.should_receive(:getbytes).once.with(29).and_return("imap \nlogin \n vasya \n parol ")
    # we're expecting array as an argument for auth_method
    @auth.should_receive(:auth_method).once.with( duck_type(:is_array) )
    @auth.getdata(29)
  end

  it "should raise ArgumentError exception on invalid payload" do
    IpcAuthpipe::Reader.should_receive(:getbytes).once.with(33).and_return("imap \nlogin \n vasya \n parol \n wtf")
    lambda { @auth.getdata(33) }.should raise_error(ArgumentError)
  end

  it "should properly handle both CR-delimited and non-CR-delimited payloads" do
    @auth.should_receive(:auth_method).twice.with(['imap', 'login', 'vasya', 'parol'])

    IpcAuthpipe::Reader.should_receive(:getbytes).once.with(29).and_return("imap \nlogin \n vasya \n parol ")
    @auth.getdata(29)

    IpcAuthpipe::Reader.should_receive(:getbytes).once.with(30).and_return("imap \nlogin \n vasya \n parol \n")
    @auth.getdata(30)
  end

  it "should convert LOGIN's payload into a hash with username and password" do
    @auth.auth_method( ['imap', 'login', 'vasya', 'parol'] ).should == {
      :method => 'login', :username => 'vasya', :password => 'parol'
    }
  end

  it "should convert CRAM's payload into a hash with challenge and response" do
    @auth.auth_method( ['imap', 'cram-md5', 'vasya', 'parol'] ).should == {
      :method => 'cram-md5', :challenge => 'vasya', :response => 'parol'
    }
  end

  it "should return FAIL for unsupported authentication types" do
    @auth.validate(:method => 'foobar').should == "FAIL\n"
  end

  it "should delegate processing onto a handler for supported authentication types" do
    authdata = { :method => 'login', :username => 'vasya', :password => 'parol' }
    @auth.should_receive(:validate_with_login).once.with(authdata).and_return('LOGIN-success')
    @auth.validate(authdata).should == "LOGIN-success"
  end

  it "should return FAIL for failed authentication" do
    authdata = { :method => 'login', :username => 'vasya', :password => 'parol' }
    @auth.should_receive(:validate_with_login).once.with(authdata).and_raise(IpcAuthpipe::AuthenticationFailed)
    @auth.validate(authdata).should == "FAIL\n"
  end

  describe "with LOGIN auth type" do

    it "should find member and return it formatted" do
      member = mock('member')
      Member.should_receive(:find_by_name_and_password).with('vasya', 'parol').once.and_return(member)
      member.should_receive(:to_authpipe).once.and_return("TEXT\nDUMP\nUSER\n.")

      @auth.validate_with_login(:username => 'vasya', :password => 'parol').should == "TEXT\nDUMP\nUSER\n."
    end

  end


#  it "should detect authentication method being used" do
#    IpcAuthpipe::Handler::Auth.
#  end
end
