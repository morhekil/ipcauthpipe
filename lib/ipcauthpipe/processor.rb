module IpcAuthpipe

  # This is the main entry point that accepts incoming request strings,
  # validates and splits them into command/parameters parts and delegates processing
  # to the command's handler
  class Processor

    # Accepts request as a single string, splits it into parts goes onto delegating.
    # Returns handler's response back to the caller
    def process(request)
      call_handler_for split_request(request)
    end

    # Splits request into a command and it's parameters, validating command on the way.
    # Raises RuntimeError on invalid command or (that's actually the same thing) unparsable request
    def split_request(req)
      raise RuntimeError, 'Invalid request received' unless /^(PRE|AUTH|PASSWD|ENUMERATE)(?:$| (.*)$)/.match(req)
      {
        :command => $1,
        :params => $2.nil? || $2.empty? ? nil : $2
      }
    end

    # Delegates processing to a concrete handler of request's command
    def call_handler_for(request)
      IpcAuthpipe::Handler.const_get(request[:command].capitalize).process(request[:params])
    end
  end
  
end