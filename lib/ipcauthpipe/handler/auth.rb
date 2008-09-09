module IpcAuthpipe
  module Handler

    # AUTH command handler performs actual authentication of user's data.
    # It gets authentication type and parameters from the input stream and
    # responds with FAIL on failure or user data on success
    class Auth < IpcAuthpipe::Handler::Base

      # Main point of entry - accepts additional command's parameters
      # (in case of AUTH - number of data bytes following the command)
      # and proceeds with processing the command
      def self.process(request)
        Log.debug "Processing request [#{request}] in AUTH handler"
        auth = Auth.new
        auth.validate auth.getdata(request.to_i)
      end

      # Reads the given number of bytes from the input stream and splits
      # them up into a hash of parameters ready for further processing
      def getdata(count)
        Log.debug "Reading [#{count}] bytes from input stream"
        splits = Reader::getbytes(count).strip.split(/\s+/m)
        raise ArgumentError, 'Invalid AUTH payload' unless splits.size == 3

        Log.debug "Analyzing splits [#{splits.inspect}]"
        auth_method(splits)
      end

      # Analyzes splitted AUTH payload and converts splits into hash
      # of :method, :username and :password for LOGIN authentication and
      # :method, :challenge and :response for CRAM-style authentications
      def auth_method(splits)
        result = { :method => splits[0].strip.downcase }
        result.merge!(
          result[:method] == 'login' ?
            { :username => splits[1].strip, :password => splits[2].strip } :
            { :challenge => splits[1].strip, :response => splits[2].strip }
        )
        
        Log.debug "Converted splits into [#{result.inspect}]"
        result
      end

      # Accepts analyzed AUTH payload hash and delegated processing onto the
      # specific authentication method's handler. In case of not implemented
      # auth method raises NotImplementedError
      def validate(authdata)
        Log.debug "Validating #{authdata.inspect}"
        begin
          # convert auth type name to a handler's symbol
          method_sym = ( 'validate_with_'+authdata[:method].gsub( /[- ]/, '_' ) ).to_sym
          # and raise an error if it's not implemented
          raise NotImplementedError, "Authentication type #{authdata[:method]} is not supported" unless
            self.respond_to?(method_sym)
          # or delegate processing to the handler if it's here
          Log.debug "Delegating validation to #{method_sym.to_s}"
          self.send(method_sym, authdata)

        rescue NotImplementedError
          # requested authentication type is not supported
          Log.error "Unsupported authentication type requested with #{authdata.inspect}"
          "FAIL\n"
        rescue AuthenticationFailed
          Log.info "Authentication failed for #{authdata.inspect}"
          "FAIL\n"
        end
      end

      # LOGIN type authentication handler
      def validate_with_login(authdata)
        Member.find_by_name_and_password(authdata[:username], authdata[:password]).to_authpipe
      end
    end

  end
end