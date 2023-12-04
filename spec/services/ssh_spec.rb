# frozen_string_literal: true

require 'spec_helper'

describe port(22) do
  it { should be_listening }
end

describe 'Cluster Nodes' do
  describe command('serf members | grep -c "alive"') do 
    it 'There are at least 3 alive nodes' do
      n_nodes = subject.stdout.to_i
      expect(n_nodes).to be > 2
    end
  end
end

describe 'Reachable nodes' do
  describe command('serf members | awk \'{split($2, a, ":"); print a[1]}\'') do
    its(:exit_status) { should eq 0 }

    it 'Main host can reach every node' do
      target_ips = subject.stdout.chomp.split("\n")
      target_ips.each do |target_ip|
        expect(host(target_ip)).to be_reachable.with(:port => 22) # Cambia el puerto según el servicio que quieras comprobar
      end
    end
  end
end
