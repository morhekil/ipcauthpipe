$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'ostruct'

require 'ipcauthpipe/processor'
require 'ipcauthpipe/handler'
require 'ipcauthpipe/reader'
require 'ipcauthpipe/log'

module IpcAuthpipe

  # Failed authentication (unknown username/password) exception class
  class AuthenticationFailed < StandardError
  end

  class << self
    attr_reader :config

    # Starts the processing - initializes the configuration and feeds incoming requests
    # to request processor
    def start(cfgfile)
      init cfgfile
      Log::info 'ipcauthpipe is started'

      ipc = IpcAuthpipe::Processor.new
      while (line = IpcAuthpipe::Reader.getline) do
        reply = ipc.process(line.strip) unless line.strip.empty?
        Log::debug "Reply is: #{reply.inspect}"
        STDOUT.puts reply
        STDOUT.flush
      end
    end

    # Reads and stores config file and uses it's data to initialize ActiveRecord connection
    def init(cfgfile)
      # Read and parse YAML config
      cfgdata = YAML::load_file(cfgfile)

      # Create the global config object
      @config = OpenStruct.new cfgdata

      # Init logger - set up it's level and log file
      IpcAuthpipe::Log.init(@config.log['file'], @config.log['level'])

      # And init the ActiveRecord
      ActiveRecord::Base.establish_connection(@config.database)
      ActiveRecord::Base.logger = IpcAuthpipe::Log.logger

      # and require model classes (we can't do it before as we need initialized config to be available)
      require 'models/member_converge'
      require 'models/member'
    end

  end

end
