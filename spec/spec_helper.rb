# frozen_string_literal: true

require 'serverspec'
require 'net/ssh'
require 'tempfile'
require 'highline/import'

set :backend, :ssh
set :disable_sudo, true

# ssh setup
host = ENV['TARGET_HOST'] || '10.1.209.20'
options = Net::SSH::Config.for(host)
set :host, options[:host_name] || host
options[:user] ||= ENV['LOGIN_USERNAME'] || 'root'

options[:password] = if ENV['ASK_LOGIN_PASSWORD']
                       ask("\nEnter login password: ") { |q| q.echo = false }
                     else
                       ENV['LOGIN_PASSWORD'] || 'redborder'
                     end

set :ssh_options, options
