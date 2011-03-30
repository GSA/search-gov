require 'rubygems'
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../../../../config/environment', __FILE__)
require 'rails/test_help'

$: << File.dirname(__FILE__) + "/../lib"
require File.dirname(__FILE__) + "/../init"
