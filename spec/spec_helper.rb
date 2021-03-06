$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'fluent/test'
require 'fluent/test/driver/output'
require 'fluent/plugin/out_rtail'

# Disable Test::Unit
module Test::Unit::RunCount; def run(*); end; end
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

RSpec.configure do |config|
  config.before(:all) do
    Fluent::Test.setup
  end
end
