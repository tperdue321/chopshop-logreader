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

        container = nil
        service = ARGV[0]
        puts "looking for valid container"
        while !container
          containers = `kubectl get pods --namespace #{options[:namespace]} | grep #{service}`
          container = containers.split("\n").map {|line| line.split(" ") }.each do |line|
            match_data = REGEX.match(line[4])
            line[5] = TIME_CALCULATOR[match_data.captures[1].downcase] * match_data.captures[0].to_i + TIME_CALCULATOR[match_data.captures[3].downcase] * match_data.captures[2].to_i
          end.select{|line| line[2] == options[:status] }.sort_by {|line| line[5] }.first

          if container
            exec "kubectl logs --follow=#{options[:follow]} --tail=#{options[:lines]} --namespace connect #{container[0]}"
          end


          print "."
          sleep 1
        end
      end
    end
  end
end
