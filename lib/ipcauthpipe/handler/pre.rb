module IpcAuthpipe
  module Handler

    # AUTH command handler performs actual authentication of user's data.
    # It gets authentication type and parameters from the input stream and
    # responds with FAIL on failure or user data on success
    class Pre < IpcAuthpipe::Handler::Base
      def self.process(request)
        Log.debug "Processing request [#{request}] in AUTH handler"
        handler = Pre.new
        handler.user_details handler.split_request(request)
      end

      # Splits request into service and username parts, raises
      # ArgumentError if request string is invalid
      def split_request(request)
        raise ArgumentError, "Invalid PRE request #{request.inspect}" unless /^\. (\w+) (\w+)$/.match( request )
        { :service => $~[1], :username => $~[2] }
      end

      # Finds member by his username and dumps his details, returns FAIL if not member were found
      def user_details(request)
        member = Member.find_by_name(request[:username])
        member.create_homedir unless member.nil? # make sure the homedir exists

        member.nil? ? "FAIL\n" : member.to_authpipe
      end

    end
  end
end