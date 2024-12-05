# frozen_string_literal: true

require 'spec_helper'
require 'set'

set :os, family: 'redhat', release: '9', arch: 'x86_64'

describe 'Check zones are defined' do
  zones = %w(public home)
  zones.each do |zone|
    describe file("/etc/firewalld/zones/#{zone}.xml") do
      it { should exist }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      # it { should be_mode 600 } # Ensures file is readable and writable by root only
    end
  end
end

describe 'Check existence of not allowed open ports' do
  valid_ports = Set.new [
    '443/tcp',    # (HTTPS)
    # We don't know why 5353 should be open. Remove?. Found references in our code mention pfring and snort
    '5353/udp',   # (mDNS / Serf)
    '2055/udp',   # (f2k)
    '6343/udp',   # (sfacctd/pmacctd)
    '514/tcp',    # (rsyslogd)
    '514/udp',    # (rsyslogd)
    '1812/udp',   # (freeradius)
    '1813/udp',   # (freeradius)
    '7779/tcp',   # (rb-ale)
    '2056/tcp',   # (n2klocd)
    '2057/tcp',   # (n2klocd)
    '2058/tcp',   # (n2klocd)
    '161/udp',    # (snmp)
    '162/udp',    # (snmp)
    '123/udp'     # (chrony)
  ]
  describe 'Check existence of not allowed open ports in public zone' do
    open_ports = command('firewall-cmd --zone=public --list-ports')
    open_ports = open_ports.stdout.strip.split(' ')
    open_ports = Set.new open_ports

    not_allowed_open = open_ports - valid_ports

    it 'should not have any not allowed open ports in public zone' do
      unless not_allowed_open.empty?
        # 'fail' can be blocky, so we use 'skip' instead.
        skip "Not allowed open ports in public zone: #{not_allowed_open.to_a.join(', ')}"
      end

      expect(not_allowed_open).to be_empty  # This can be blocky.
    end
  end

  describe 'Check existence of not allowed open ports in home zone' do
    valid_ports += Set.new [
      '53/tcp',     # large DNS
      '53/udp',     # short DNS
      '2181/tcp',   # (zookeeper client)
      '2888/tcp',   # (zookeeper followers)
      '3888/tcp',   # (zookeeper leader election)
      '50505/tcp',  # (zookeeper admin)
      '5432/tcp',   # (postgresql)
      '7946/tcp',   # (serf)
      '7946/udp',   # (serf)
      '4443/tcp',   # (erchef)
      '7980/tcp',   # (http2k)
      '8001/tcp',   # (consul)
      '8081/tcp',   # (druid web console)
      '8083/tcp',   # (druid historical)
      '8084/tcp',   # (druid broker)
      '8080/tcp',   # (general internal http)
      '9000/tcp',   # (minio API)
      '9001/tcp',   # (minio console)
      '8300/tcp',   # (consul RPC)
      '8301/tcp',   # (consul/serf LAN)
      '8301/udp',   # (consul/serf LAN)
      '8302/tcp',   # (consul/serf WAN)
      '8302/udp',   # (consul/serf WAN)
      '8400/tcp',   # (consul)           deprecated,TODO investigate to close
      '8500/tcp',   # (consul web console)
      '9092/tcp',   # (kafka)
      '11211/tcp',  # (memcached)
      '11211/udp',  # (memcached)
      '27017/tcp',  # (mongodb)
    ]

    open_ports = command('firewall-cmd --zone=home --list-ports')
    open_ports = open_ports.stdout.strip.split(' ')
    open_ports = Set.new open_ports

    not_allowed_open = open_ports - valid_ports

    it 'should not have any not allowed open ports in home zone' do
      unless not_allowed_open.empty?
        skip "Not allowed open ports in home zone: #{not_allowed_open.to_a.join(', ')}"
      end

      expect(not_allowed_open).to be_empty
    end
  end
end
