$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'map_reduce'

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
