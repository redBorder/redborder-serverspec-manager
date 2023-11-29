# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'

interfaces = command('ip link show | grep "^[0-9]" | cut -d" " -f2 | sed "s/:$//"').stdout.split("\n")

describe 'All interfaces: ' do
  interfaces.each do |interface|
    describe interface(interface) do
      it { should exist }
      # it { should be_up }
    end
  end
end

# Management network
puts 'Configuration'

ip = ENV['TARGET_HOST']
puts "HOST: #{ip}"

describe 'Management network' do
  it 'The Management network should contain an IP' do
    expect(ip).to match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
  end
end

# Sync network
describe 'Sync network' do
  sync = command('ip addr show').stdout
  it 'Have a network sync' do
    interfaces_with_ip = sync.scan(/inet\s+(\d+\.\d+\.\d+\.\d+)/).flatten
    expect(interfaces_with_ip.length).to be >= 3
    puts "OUTPUT: #{interfaces_with_ip}"
  end
end

# DNS
describe 'DNS' do
  resolv_content = command('cat /etc/resolv.conf').stdout
  it 'It should have a nameserver' do
    expect(resolv_content).to match(/nameserver/)
  end
end

# Passwords
describe 'Password' do
  user_root = command('sudo passwd -S root').stdout
  it 'User root have a password' do
    expect(user_root).to include('P')
  end
end

# Date and time
current_time = Time.now.utc

describe 'Date time' do
  date_time = command('date -u "+%a %b %e %H:%M %Z %Y"').stdout
  it 'Current date and time in utc' do
    expect(date_time).to include(current_time.strftime('%a %b %e %H:%M %Z %Y').to_s)
    puts "OUTPUT: #{date_time}"
  end
end

# Hostname
describe 'Hostname' do
  hostname = command('hostname').stdout
  it 'Hostname is set' do
    expect(hostname).not_to be_empty
    puts "OUTPUT: #{hostname}"
  end
end

# IPMI
describe 'IPMI' do
  ipmi_status = command('rpm -qa | grep ipmi').stdout
  it 'Status IPMI' do
    expect(ipmi_status).to include('ipmi')
  end
end
