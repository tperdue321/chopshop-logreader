require "optparse"

module Chopshop
  module Logreader
    class Parser
      def parse
        options = {
          follow: true, # follow output from log file
          lines: -1, # whole file always,
          status: "Running", # look for a currently running container
          namespace: "connect"
        }

        OptionParser.new do |opts|
          opts.banner = "Usage: ruby log-reader.rb SERVICE [options]"

          opts.on("-f [FOLLOW]", "--follow [FOLLOW]", "boolean true/false on whether to follow output from the file. default: true", TrueClass) do |follow|
            options[:follow] = follow
          end

          opts.on("-l [LINES]", "--lines [LINES]", "number of lines to display from the bottom of logs. default: -1(whole file)", Integer) do |lines|
            options[:lines] = lines
          end

          opts.on("-s [STATUS]", "--status [STATUS]", "valid values: Completed|Running|Error. will only look for containers with the given status. default: Running", String) do |status|
            options[:status] = status
          end

          opts.on("-n [NAMESPACE]", "--namespace [NAMESPACE]", "sets the kubernetes namespace to look for containers in. default: connect", String) do |status|
            options[:status] = status
          end


          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end


        end.parse!

        options
      end
    end
  end
end