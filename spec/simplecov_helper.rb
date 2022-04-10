require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/lib/'
  add_filter '/vendor/'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Services', 'app/services'
  add_group 'Serializers', 'app/serializers'
  add_group 'Workers', 'app/workers'
  add_group 'Policies', 'app/policies'
  add_group 'Exceptions', 'app/exceptions'
end if ENV["COVERAGE_ANALYSIS"]

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
