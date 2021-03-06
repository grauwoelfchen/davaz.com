require 'pathname'

root_dir = Pathname.new(__FILE__).parent.parent.expand_path

src = root_dir.join('src').to_s
$: << src unless $:.include?(src)

test = root_dir.join('test').to_s
$: << test unless $:.include?(test)

require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'watir'
require 'rclconf'
require 'davaz'
require 'util/config'

# debugging
DEBUG    = (ENV['DEBUG'] == 'true' || false)
DEBUGGER = ENV['DEBUGGER'] \
  if ENV.has_key?('DEBUGGER') && !ENV['DEBUGGER'].empty?
TEST_CLIENT_TIMEOUT = 30 # seconds

TEST_SRV_URI = URI.parse(ENV['TEST_SRV_URL'] || 'http://127.0.0.1:11080')
TEST_APP_URI = URI.parse(ENV['TEST_APP_URL'] || 'druby://127.0.0.1:11081')
TEST_YUS_URI = URI.parse(ENV['TEST_YUS_URL'] || 'drbssl://127.0.0.1:10007')

# test data
module DaVaz; module Stub; end; end

Dir[root_dir.join('test/support/**/*.rb')].each { |f| require f }

module DaVaz::TestCase
  include WaitUntil
end

Watir.driver = :webdriver
Watir.load_driver
Watir.default_timeout = TEST_CLIENT_TIMEOUT

DaVaz.config.document_root = root_dir.join('doc').to_s
DaVaz.config.environment   = 'test'
DaVaz.config.autologin     = false
DaVaz.config.server_uri    = TEST_SRV_URI.host
DaVaz.config.yus_uri       = TEST_YUS_URI.host
