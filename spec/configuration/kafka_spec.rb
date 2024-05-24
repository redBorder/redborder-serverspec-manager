# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'
pipelines = %w[
  rb_event rb_event_post
  rb_monitor rb_monitor_post
  rb_loc rb_locne rb_loc_post rb_loc_post_discard rb_location
  rb_mobile
  rb_radius
  rb_nmsp
  rb_metrics
  rb_state rb_state_post
  rb_vault rb_vault_post
  rb_http2k_sync
  sflow
]

describe 'Check logstash config' do
  describe file('/etc/kafka/topics_definitions.yml') do
    it { should exist }
    it { should be_file }
    it { should be_readable }
    it { should be_writable.by_user('kafka') }
    it { should_not be_writable.by('others') }
    it { should_not be_executable }
    pipelines.each do |pipeline|
        it { should contain pipeline }
    end
  end
end
