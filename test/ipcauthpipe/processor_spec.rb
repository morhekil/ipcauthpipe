require File.dirname(__FILE__) + '/../spec_helper'

require 'ipcauthpipe/processor'

describe 'Request processor' do

  before(:each) do
    @processor = IpcAuthpipe::Processor.new
  end

  it "should split a request into a command and it's parameters" do
    @processor.split_request('PRE . pop3 myname').should == { :command => 'PRE', :params => '. pop3 myname'}
    @processor.split_request('ENUMERATE').should == { :command => 'ENUMERATE', :params => nil}
    @processor.split_request('ENUMERATE ').should == { :command => 'ENUMERATE', :params => nil}
  end

  it "should raise an exception for invalid request" do
    lambda { @processor.split_request('FOOBAR') }.should raise_error(RuntimeError)
    lambda { @processor.split_request('NO . COMMAND') }.should raise_error(RuntimeError)
  end

  it "should delegate processing to the command's handler" do
    # Set up a fake Auth handler
    module IpcAuthpipe
      module Handler
        module Auth
          class << self
            def process
            end
          end
        end
      end
    end

    # And try to call it
    IpcAuthpipe::Handler::Auth.should_receive(:process).with('53').once
    @processor.call_handler_for(:command => 'AUTH', :params => '53')
  end
end