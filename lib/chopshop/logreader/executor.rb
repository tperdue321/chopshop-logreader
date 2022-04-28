require "chopshop/logreader/parser"

module Chopshop
  module Logreader
    class Executor
      attr_reader :parser, :options, :profile, :tenant,
        :region, :namespace, :container, :service_name

      # The regex + time calculator takes the human readable output from the kubernetes CLI
      # and calculates how long any given pod has been running. It then selects the most
      # recently pod/shortest living pod
      REGEX = /(?<t1>\d+)(?<v1>[a-z]+)(?<t2>\d*)(?<v2>[a-z]*)/i
      TIME_CALCULATOR = {
        "s" => 1,
        "m" => 60,
        "h" => 60 * 60,
        "d" => 60 * 60 * 24,
        "" => 0 # protect for the scenario where a value isn't present in the capture group.
      }

      def self.execute!
        new.execute!
      end

      def initialize
        @parser = Chopshop::Logreader::Parser.new
      end

      def parse_options
        @options = @parser.parse
        @profile = options.profile || ENV["AWS_PROFILE"] || ENV["PROFILE"]
        @tenant = options.tenant || ENV["DEFAULT_TENANT"]
        @region = options.region || ENV["AWS_REGION"] || "us-east-1"
        @namespace = options.namespace || ENV["K8_NAMESPACE"] || "connect"
        @container = options.container
        @service_name = ARGV[0]
      end

      def execute!
        parse_options
        service = nil

        # log into the EKS cluster, may require 2FA authing here.
        `rally-kubectl -a #{region} -e #{profile} -t #{tenant}`
        puts "looking for valid service container"
        while !service
          services = `kubectl get pods --namespace #{namespace} | grep #{service_name}`
          service = services.split("\n").map {|line| line.split(" ") }.each do |line|
            # get the length of time the pod has been running from the kubernetes CLI output
            match_data = REGEX.match(line[4])
            # calculate the human readable version of time into a single integer for comparison
            line[5] = TIME_CALCULATOR[match_data.captures[1].downcase] * match_data.captures[0].to_i + TIME_CALCULATOR[match_data.captures[3].downcase] * match_data.captures[2].to_i
            # select the most recent/shortest living pod
          end.select{|line| line[2] == options.status }.sort_by {|line| line[5] }.first

          # if we have a pod we want logs from, then get logs and be done
          if service
            if container
              exec "kubectl logs --follow=#{options.follow} --tail=#{options.lines} --namespace #{namespace} --container=#{container} #{service[0]}"
            else
              exec "kubectl logs --follow=#{options.follow} --tail=#{options.lines} --namespace #{namespace} #{service[0]}"
            end
          end

          # no pod with logs, wait 1 second and try again.
          print "."
          sleep 1
        end
      end
    end
  end
end
