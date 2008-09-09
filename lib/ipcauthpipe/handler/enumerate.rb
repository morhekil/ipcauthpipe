module IpcAuthpipe
  module Handler

    # AUTH command handler performs actual authentication of user's data.
    # It gets authentication type and parameters from the input stream and
    # responds with FAIL on failure or user data on success
    class Enumerate < IpcAuthpipe::Handler::Base
      def self.process(request)
        Log.warn "Unsupported command ENUMERATE received with request #{request.inspect}"
        "FAIL\n"
      end
    end
  end
end