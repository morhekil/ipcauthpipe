require 'readbytes'

module IpcAuthpipe

  # Abstracting read operations to substitute them with mocks in our tests and also
  # to give potentially a way to replace STDIN operation with something different - file based,
  # for example
  class Reader

    # Returns next line waiting on the input
    def self.getline
      STDIN.gets("\n")
    end

    # Returns exactly count number of bytes waiting on the input
    def self.getbytes(count)
      STDIN.readbytes(count)
    end

  end

end