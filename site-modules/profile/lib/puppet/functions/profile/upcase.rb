# frozen_string_literal: true

# Use functions if you need to manipulate data or communicate with third-party services during catalog compilation.
# If the built-in functions, or functions from Forge modules, aren’t sufficient, you can write custom functions for Puppet.
#
# Converts a string to uppercase.
#
# @see https://docs.openvoxproject.org/openvox/latest/functions_ruby_overview.html
Puppet::Functions.create_function(:'profile::upcase') do
  dispatch :up do
    param 'String', :some_string
  end

  def up(some_string)
    some_string.upcase
  end
end
