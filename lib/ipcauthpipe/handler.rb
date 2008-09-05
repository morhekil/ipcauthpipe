module IpcAuthpipe
  module Handler

    # A basic class that outlines handlers' API.
    # Right now it features only the single process method that accepts command's parameters
    # as an argument and goes on with processing the specific handler's command.
    class Base

      # Every handler access command's parameters as a string argument
      # and should return as a string it's answer that will be returned back (to STDOUT generally)
      def process(request)
        raise NotImplementedError, 'request processing should be overriden by concrete handlers'
      end

    end
  end
end

# Concrete handlers are following
require 'ipcauthpipe/handler/auth'
