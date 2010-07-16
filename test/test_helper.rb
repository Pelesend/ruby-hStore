begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:default, :test)

db = Mongo::Connection.new.db('hStore-test')

db.drop_collection('records')

Mongoid.configure do |config|
  config.master = db
end

require 'test/unit'

# Set up the models
Dir[File.dirname(__FILE__) + '/../lib/models/*.rb'].each {|file| require file }

# Load the web request handlers, order is significant
require 'lib/controllers/document'
require 'lib/controllers/root'
require 'lib/controllers/section'
require 'lib/controllers/hstore'

class HDataTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = HStore::Application
    app.set :environment, :test
    app.set :root, File.join(File.dirname(__FILE__), '..')
    app
  end
  
  def test_truth
    assert true
  end
end
