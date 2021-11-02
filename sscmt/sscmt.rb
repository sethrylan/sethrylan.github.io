#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'open-uri'
require 'open3'
require 'fileutils'

# downloaded scripts are stored to this directory
SCRIPT_DIR = '/opt/sscmt/scripts/'
APT_CMD = 'DEBIAN_FRONTEND=noninteractive apt-get'
# global variable for parsed options
$options = {}

######################################
##       Helper Functions
######################################

# Downloads a file at a URI to the scripts directory.
# @param   [String] uri to download
# @return  [String] the file path of the downloaded file
def fetch(uri)
  puts "Fetching #{uri}..." if $options[:verbose]
  FileUtils.mkdir_p SCRIPT_DIR
  file = SCRIPT_DIR + uri.split('/').last
  File.write file, URI.parse(uri).open
  file
end

def run(cmd)
  stdout, stderr, status = Open3.capture3(cmd)
  puts stderr.chomp.red unless stderr.empty?
  puts stdout.chomp if $options[:verbose]

  exit(status.exitstatus) unless status == 0
end

# Colorization for the string class
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def match?(regex)
    !!self.match(regex)
  end
end

######################################
##       CLI Options
######################################
OptionParser.new do |opts|
  opts.banner = 'Usage: sscmt [-h/--help] [-v/--verbose] -c CONFIGFILE'
  opts.on('-v', '--verbose', 'Run verbosely')
  opts.on('-c', '--config CONFIGFILE', 'The configuration file in YAML format')
  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    puts 'SSCMT reads a configuration files to idempotently configure the running linux server.'
    exit
  end
end.parse!(into: $options)

puts 'Must specify a config file (-c file.yaml).' unless $options.key?(:config)

######################################
##     init work
######################################

config_source = if $options[:config] =~ URI::DEFAULT_PARSER.make_regexp
                  fetch($options[:config])
                else
                  $options[:config]
                end

conf = YAML.load_file(config_source)
run("#{APT_CMD} update")

######################################
##     packages
######################################
conf['packages'].each do |package|
  if package.key?('action') && package['action'] == 'remove'
    puts "Removing #{package['name']}..." if $options[:verbose]
    run("#{APT_CMD} remove -y #{package['name']}")
  else
    puts "Installing #{package['name']}..." if $options[:verbose]
    if package.key?('version')
      run("#{APT_CMD} install -y #{package['name']}=#{package['version']}")
    else
      run("#{APT_CMD} install -y #{package['name']}")
    end
  end
end

######################################
##     files
######################################
conf['files'].each do |file|
  puts "Processing file #{file}..." if $options[:verbose]

  source = if file['source'] =~ URI::DEFAULT_PARSER.make_regexp
             fetch(file['source'])
           else
             file['source']
           end

  FileUtils.mkdir_p File.dirname(file['path'])

  File.open(source, 'rb') do |source_stream|
    File.open(file['path'], 'wb') do |dest_stream|
      IO.copy_stream(source_stream, dest_stream)
    end
  end

  File.chmod(file['permissions'], file['path'])
  FileUtils.chown file['owner'], file['group'], file['path']

  if file.key?('after')
    if file['after'] =~ URI::DEFAULT_PARSER.make_regexp
      run("sh ${fetch(conf['after'])}")
    else
      run(file['after'])
    end
  end
end

######################################
##     after.validate
######################################
if conf.key?('after')
  puts 'Validating after the fact...' if $options[:verbose]

  if conf['after'] =~ URI::DEFAULT_PARSER.make_regexp
    run("sh ${fetch(conf['after'])}")
  else
    run(conf['after'])
  end
end
