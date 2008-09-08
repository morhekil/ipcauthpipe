require File.dirname(__FILE__) + '/../spec_helper'

require 'ipcauthpipe/log'

describe 'Log' do

  before(:each) do
    # stubbing new instance and returning our mock instead
    @logger = mock('log_instance', :level= => nil, :info => nil, :formatter= => nil)
    Logger.should_receive(:new).with('test.log').once.and_return(@logger)
  end

  it "should init logger with given filename and log level" do
    # log level should be set to debug
    @logger.should_receive(:level=).with(Logger::DEBUG).once

    # formatter should be initialized with our mock
    formatter = mock('log_formatter')
    Logger::Formatter.should_receive(:new).once.and_return(formatter)
    @logger.should_receive(:formatter=).once.with(formatter)

    # and info message should be logged
    @logger.should_receive(:info).once
    
    IpcAuthpipe::Log.init('test.log', 'debug')
  end

  it "should delegate all common logging methods to stdlib's logger" do
    IpcAuthpipe::Log.init('test.log', 'debug')

    [ :debug, :info, :warn, :error, :fatal, :add, :unknown].each do |msg|
      @logger.should_receive(msg).with('test').once
      IpcAuthpipe::Log.send(msg, 'test')
    end
  end

end