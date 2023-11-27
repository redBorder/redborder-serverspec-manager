require "spec_helper"
describe service("redborder-monitor") do
  it { should be_running }
end

describe file("/etc/redborder-monitor/config.json") do
  it { should exist }
  # Puedes añadir más verificaciones para el archivo de configuración aquí
end

describe service("kafka") do
  it { should be_running }
end

describe service("logstash") do
  it { should be_running }
end

describe command("rb_get_topics | grep monitor") do
  its(:stdout) { should match /rb_monitor/ }
  its(:stdout) { should match /rb_monitor_post/ }
  # Añade aquí más matches para otros topics específicos que necesites verificar
end

describe file("/etc/logstash/pipelines/monitor/00_input.conf") do
  it { should exist }
end

describe file("/etc/logstash/pipelines/monitor/01_monitor.conf") do
  it { should exist }
end

describe file("/etc/logstash/pipelines/monitor/99_output.conf") do
  it { should exist }
end

describe file("/etc/logstash/pipelines.yml") do
  it { should contain "pipeline.id: monitor-pipeline" }
  it { should contain 'path.config: "/etc/logstash/pipelines/monitor"' }
end

describe file("/etc/druid/realtime/rb_realtime.spec") do
  it { should exist }
  # Añade aquí verificaciones específicas para el contenido del archivo
end

describe command("ls /tmp/realtime/rb_monitor") do
  its(:exit_status) { should eq 0 }
end

# Nota: Ejecutar estos comandos puede ser más complejo y depende del entorno
describe command("timeout 3 rb_consumer.sh -t rb_monitor_post") do
  its(:stdout) { should match(/"organization_uuid":"\*"/) }
  its(:stdout) { should match(/"timestamp":\d+/) }
  its(:stdout) { should match(/"monitor":"organization_received_bytes"/) }
  its(:stdout) { should match(/"unit":"bytes"/) }
  its(:stdout) { should match(/"value":\d+/) }
end
