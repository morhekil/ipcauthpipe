module IpcAuthpipe
  module Handler

    class Auth < IpcAuthpipe::Handler::Base
      def self.process(request)
        "processing #{request}"
      end
    end

  end
end