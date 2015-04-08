require 'rubygems'
require File.join(File.dirname(__FILE__), 'lib/server.rb')

run BookmarkManager

require 'data_mapper'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'

DataMapper.finalize

DataMapper.auto_upgrade!
