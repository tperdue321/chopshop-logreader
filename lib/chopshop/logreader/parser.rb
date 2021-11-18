require "optparse"

module Chopshop
  module Logreader
    class Parser
      REGEX = /(?<t1>\d+)(?<v1>[a-z]+)(?<t2>\d*)(?<v2>[a-z]*)/i

      TIME_CALCULATOR = {
        "s" => 1,
        "m" => 60,
        "h" => 60 * 60,
        "d" => 60 * 60 * 24,
        "" => 0 # protect for the scenario where a value isn't present in the capture group.
      }

      def parse
        options = {
          follow: true, # follow output from log file
          lines: -1, # whole file always,
          status: "Running", # look for a currently running container
        }

        OptionParser.new do |opts|
          opts.banner = "Usage: ruby log-reader.rb SERVICE [options]"

          opts.on("-f [FOLLOW]", "--follow [FOLLOW]", "boolean true/false on whether to follow output from the file. default: true", TrueClass) do |follow|
            options[:follow] = follow
          end

          opts.on("-l [LINES]", "--lines [LINES]", "number of lines to display from the bottom of logs. default: -1(whole file)", Integer) do |lines|
            options[:lines] = lines
          end

          opts.on("-s [STATUS]", "--status [STATUS]", "valid values: Completed|Running. will only look for containers with the given status. default: Running", String) do |status|
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