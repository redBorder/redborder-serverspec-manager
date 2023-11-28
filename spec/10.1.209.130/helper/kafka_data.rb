#!/usr/bin/env ruby
class KafkaData
    def self.generate_mac
        6.times.map { '%02x' % rand(0..255) }.join(':')
    end

    def self.get_time
        Time.now.to_i
    end

    def self.get_mac_address
        @mac_address ||= generate_mac
    end

    def self.sample_data
        {
        "type":"netflowv10",
        "flow_sequence":"36741",
        "ip_protocol_version":4,
        "l4_proto":6,"input_vrf":0,
        "flow_end_reason":"idle timeout",
        "biflow_direction":"reverse initiator",
        "application_id_name":"13:453",
        "engine_id_name":"13",
        "output_vrf":0,
        "direction":"upstream",
        "lan_interface":1,
        "lan_interface_name":"1",
        "lan_interface_description":"1",
        "wan_interface":12,
        "wan_interface_name":"12",
        "wan_interface_description":"12",
        "client_mac": get_mac_address,
        "wan_ip":"10.1.30.17",
        "lan_ip":"20.54.36.229",
        "wan_l4_port":49320,
        "lan_l4_port":443,
        "index_partitions":5,
        "index_replicas":1,
        "sensor_ip":"10.1.50.20",
        "sensor_name":"ISR",
        "sensor_uuid":"94f865e1-c51f-4bfd-9434-a50c490f98d9",
        "bytes":215,
        "pkts":1,
        "timestamp": get_time
        }
    end

    def self.get_sample_data
        sample_data.to_json
    end
end
