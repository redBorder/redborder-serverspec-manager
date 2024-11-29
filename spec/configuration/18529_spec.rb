# frozen_string_literal: true

require 'spec_helper'
set :os, family: 'redhat', release: '9', arch: 'x86_64'
virtual_ip = ENV['VIRTUAL_IP'] || '10.1.203.145'
primary_interface = ENV['PRIMARY_INTERFACE'] || 'ens192'
secondary_interface = ENV['SECONDARY_INTERFACE'] || 'ens224'

describe 'Configurar IP virtual' do
  before(:all) do
    # Crear IP virtual (ajustar IP según tu red)
    `ip addr add #{virtual_ip}/24 dev #{primary_interface}`
    # Ensure interface is up
    `ip link set dev #{primary_interface} up`
  end

  # Paso 2: Verificar que la IP virtual está creada
  describe command("ip addr show dev #{primary_interface} | grep \"#{virtual_ip}/24\"") do
    its(:stdout) { should_not be_empty }
  end  
end

# Paso final: Revertir cambios
describe 'Revertir cambios en la máquina' do
  after(:all) do
    # Eliminar la IP virtual creada en primary_interface
    `ip addr del #{virtual_ip}/24 dev #{primary_interface}`

    # Reactivar la interfaz secondary_interface
    `ip link set dev #{secondary_interface} up`
  end

  # Verificar que la IP virtual fue eliminada
  describe command("ip addr show dev #{primary_interface}") do
    its(:stdout) { should_not match /10\.1\.203\.145\/24/ }
  end

  # Verificar que la interfaz secondary_interface está activa nuevamente
  describe command("ip link show dev #{secondary_interface}") do
    its(:stdout) { should match /state UP/ }
  end
end

# Paso 3: Tirar abajo la interfaz secondary_interface
describe 'Deshabilitar interfaz secondary_interface' do
  before(:all) do
    # Apagar la interfaz (reemplazar por el comando necesario si no usas `ip`)
    `ip link set dev #{secondary_interface} down`
  end

  # Paso 4: Verificar que la interfaz secondary_interface está inactiva
  describe command("ip link show dev #{secondary_interface}") do
    its(:stdout) { should match /state DOWN/ }
  end
end

# Paso 5: Verificar que la IP de sincronismo no es la IP virtual
describe 'Verificar IP de sincronismo' do
  it 'La IP de sincronismo no debe coincidir con la IP virtual' do
    sync_ip = `cat /etc/sync_ip`.strip # Reemplaza con el método real para obtener la IP de sincronismo
    expect(sync_ip).not_to eq(virtual_ip)
  end
end