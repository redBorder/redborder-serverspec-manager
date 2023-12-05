# frozen_string_literal: true

require_relative '../spec_helper'

set :os, family: 'redhat', release: '9', arch: 'x86_64'

def get_mode_services
  discovery_host = command('hostname').stdout.split('.')[0]
  filter = '.override.redborder.mode'

  mode_output = command("knife node show #{discovery_host} -l -F json | jq '#{filter}'").stdout.strip
  mode = mode_output.chomp.gsub('"', '')

  mode_tasks = {
    'full' => ['chef', 'kafka', 'redborder_monitor', 'druid_realtime'],
    'core' => ['Executing tasks for "core" mode...'],
    'chef' => ['Executing tasks for "chef" mode...'],
    # ... more modes
  }

  if mode_tasks.key?(mode)
    puts "MODE: #{mode}"
    return mode_tasks[mode]
  else
    raise "Unknown mode '#{mode}'. No specific tasks to execute."
  end
rescue => e
  raise "Error: #{e.message}"
end
