$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'ostruct'

require 'ipcauthpipe/processor'
require 'ipcauthpipe/handler'

module IpcAuthpipe

  class << self
    attr_reader :config

    # Starts the processing - initializes the configuration and feeds incoming requests
    # to request processor
    def start(cfgfile)
      initialize cfgfile

      ipc = IpcAuthpipe::Processor.new
      while (line = STDIN.gets("\n")) do
        puts ipc.process(line) unless line.empty?
      end
    end

    # Reads and stores config file and uses it's data to initialize ActiveRecord connection
    def initialize(cfgfile)
      # Read and parse YAML config
      cfgdata = YAML::load_file(cfgfile)

      # Create the global config object
      @config = OpenStruct.new cfgdata

      # And init the ActiveRecord
      ActiveRecord::Base.establish_connection(@config.database)
    end

  end

end