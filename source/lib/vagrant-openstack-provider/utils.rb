module VagrantPlugins
  module Openstack
    class Utils
      def initialize
        @logger = Log4r::Logger.new('vagrant_openstack::action::config_resolver')
      end

      def get_ip_address(env)
        addresses = env[:openstack_client].nova.get_server_details(env, env[:machine].id)['addresses']
        addresses.each do |_, network|
          network.each do |network_detail|
            return network_detail['addr'] if network_detail['OS-EXT-IPS:type'] == 'floating'
          end
        end
        fail Errors::UnableToResolveIP if addresses.size == 0
        if addresses.size == 1
          net_addresses = addresses.first[1]
        elsif !env[:machine].provider_config.networks.nil?
          net_addresses = addresses[env[:machine].provider_config.networks[0]]
        end
        if net_addresses.nil? || net_addresses.empty?
          net_addresses = addresses.shift[1]
        end
        fail Errors::UnableToResolveIP if net_addresses.size == 0
        net_addresses[0]['addr']
      end
    end
  end
end
