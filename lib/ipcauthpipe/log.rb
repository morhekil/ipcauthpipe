require 'forwardable'
require 'logger'

module IpcAuthpipe
  module Log

    class << self
      extend Forwardable
      attr_reader :logger
      
      def init(filename, loglevel)
        @logger = Logger.new(filename)
        @logger.level = Logger.const_get(loglevel.upcase)
        @logger.formatter = Logger::Formatter.new
        @logger.info "Logger is started"
      end

      def_delegators :@logger, :add, :debug, :info, :warn, :error, :fatal, :unknown, :close
    end

  end
end