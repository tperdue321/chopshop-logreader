require "optparse"
require 'ostruct'

module Chopshop
  module Logreader
    class Parser
      def parse
        options = OpenStruct.new(
          follow: true, # follow output from log file
          lines: -1, # whole file always,
          status: "Running", # look for a currently running service
          namespace: nil,
          tenant: nil,
          profile: nil,
          region: nil,
          container: nil
        )


        OptionParser.new do |opts|
          opts.banner = "Usage: chopshop-logreader SERVICE [options]"

          opts.on("-f [FOLLOW]", "--follow [FOLLOW]", "boolean true/false on whether to follow output from the file. default: true", TrueClass) do |follow|
            options[:follow] = follow
          end

          opts.on("-l [LINES]", "--lines [LINES]", "number of lines to display from the bottom of logs. default: -1(whole file)", Integer) do |lines|
            options[:lines] = lines
          end

          opts.on("-s [STATUS]", "--status [STATUS]", "valid values: Completed|Running|Error. will only look for services/jobs with the given status. default: Running", String) do |status|
            options[:status] = status
          end

          opts.on("-n [NAMESPACE]", "--namespace [NAMESPACE]", "sets the kubernetes namespace to look for service/job in. default: connect", String) do |namespace|
            options[:namespace] = namespace
          end

          opts.on("-p [PROFILE]", "--profile [PROFILE]", "chooses the cloud profile to use for permissions. default: nil.  You must provide this value or set the ENV VAR AWS_PROFILE' or the ENV VAR 'PROFILE'", String) do |profile|
            options[:profile] = profile
          end

          opts.on("-r [REGION]", "--region [REGION]", "sets the cloud region to look for a tenant within. default: us-east-1.  You may also provide this value via the ENV VAR 'AWS_REGION'", String) do |region|
            options[:region] = region
          end

          opts.on("-c [CONTAINER]", "--container [CONTAINER]", "sets the kubernetes tenant to look for containers in. default: nil. Often not needed", String) do |container|
            options[:container] = container
          end

          opts.on("-t [TENANT]", "--tenant [TENANT]", "sets the kubernetes tenant to look for the service/job in. default: nil.  You must provide this value or set the ENV VAR DEFAULT_TENANT'", String) do |tenant|
            options[:tenant] = tenant
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
