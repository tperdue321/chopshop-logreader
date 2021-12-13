require "chopshop/logreader/parser"

module Chopshop
  module Logreader
    class Executor
      attr_reader :parser

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

      def execute!
        options = @parser.parse 
        profile = options.profile || ENV["AWS_PROFILE"] || ENV["PROFILE"]
        tenant = options.tenant || ENV["DEFAULT_TENANT"]
        region = options.region || ENV["AWS_REGION"] || "us-east-1"
        container = options.container

        service = nil
        service_name = ARGV[0]
        `rally-kubectl -a #{region} -e #{profile} -t #{tenant}`
        puts "looking for valid service container"
        while !service
          services = `kubectl get pods --namespace #{options.namespace} | grep #{service_name}`
          service = services.split("\n").map {|line| line.split(" ") }.each do |line|
            match_data = REGEX.match(line[4])
            line[5] = TIME_CALCULATOR[match_data.captures[1].downcase] * match_data.captures[0].to_i + TIME_CALCULATOR[match_data.captures[3].downcase] * match_data.captures[2].to_i
          end.select{|line| line[2] == options.status }.sort_by {|line| line[5] }.first

          if service
            if container
              exec "kubectl logs --follow=#{options.follow} --tail=#{options.lines} --namespace connect --container=#{container} #{service[0]}"
            else
              exec "kubectl logs --follow=#{options.follow} --tail=#{options.lines} --namespace connect #{service[0]}"
            end
          end

          print "."
          sleep 1
        end
      end
    end
  end
end
