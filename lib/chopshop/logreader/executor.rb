require "chopshop/logreader/parser"

module Chopshop
  module Logreader
    class Executor
      attr_reader :parser

      def initialize
        @parser = Parser.new

      end

      def self.execute!
        options = @parser.parse 

        container = nil
        service = ARGV[0]
        puts "looking for valid container"
        while !container
          containers = `kubectl get pods --namespace connect | grep #{service}`
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
