#!/usr/bin/env ruby
require 'optparse'
require 'open3'
options = {}
options_parser = OptionParser.new do |opts|
  opts.on("-r role", "--role=role") do |role|
    options[:role] = role
  end

  opts.on("-e env_name", "--environment=name") do |env|
    options[:environment]  = env
  end

  opts.on("--install-packages=", Array) do |packages|
    options[:packages] = packages
  end
end

options_parser.parse!
puts options.inspect
options[:packages] ||= []
options[:packages] << 'epel-release'

#install default packages.
options[:packages].each do |pack|
  if !system("yum install -y #{pack}")
    STDERR.puts "Could not install #{pack} package. Aborting"
    exit 1
  end
end
#install chef
#FIXME: Mention chef version to be installed. Very important.
output, error, status = Open3.capture3("curl -L https://omnitruck.chef.io/install.sh | bash")
if status == 0
  puts output
  puts "Chef Installed"
  o,e,s = Open3.capture3('chef-client')
  if s == 0
    puts o
    puts "Client connected and registered with chef server."
  else
    STDERR.puts e
  end
else
  STDERR.puts "Chef Installation failed:"
  STDERR.puts error
end
