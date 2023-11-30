# frozen_string_literal: true

require 'spec_helper'

databases = %w[bifrost druid monitors oc_id opscode_chef postgres radius redborder template0
               template1]

# PostgreSQL Tests
describe 'PostgreSQL Tests' do
  # Test if PostgreSQL package is installed
  describe package('postgresql') do
    it { should be_installed }
  end

  # Test if the PostgreSQL service is enabled and running
  describe service('postgresql') do
    it { should be_enabled }
    it { should be_running }
  end

  # Test if PostgreSQL is listening on the default port (5432)
  describe port(5432) do
    it { should be_listening }
  end

  # Test database connection
  describe command('psql -U redborder -d redborder -h localhost -c "\\l"') do
    databases.each do |db|
      its('stdout') { should match(/#{db}/) }
    end
    its('exit_status') { should eq 0 }
  end
end

# PostgreSQL Configuration File Tests
describe 'PostgreSQL Configuration Files' do
  # Check if postgresql.conf exists and has correct permissions
  describe file('/var/lib/pgsql/data/postgresql.conf') do
    it { should exist }
    it { should be_owned_by 'postgres' }
  end

  # Check if pg_hba.conf exists and has correct permissions
  describe file('/var/lib/pgsql/data/pg_hba.conf') do
    it { should exist }
    it { should be_owned_by 'postgres' }
  end
end
