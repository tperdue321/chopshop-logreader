module Chopshop
  module Logreader
    class Error < StandardError; end
  end
end

require "chopshop/logreader/version"
require "chopshop/logreader/parser"
require "chopshop/logreader/executor"
