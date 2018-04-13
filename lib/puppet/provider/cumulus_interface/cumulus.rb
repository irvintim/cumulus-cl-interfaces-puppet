require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'cumulus', 'ifupdown2.rb'))
Puppet::Type.type(:cumulus_interface).provide :cumulus do
  confine operatingsystem: [:cumuluslinux]

  def build_desired_config
    config = Ifupdown2Config.new(resource)
    config.update_speed
    config.update_vrf_table
    config.update_vrf
    config.update_addr_method
    config.update_address
    %w(id raw_device).each do |attr|
      config.update_attr(attr, 'vlan')
    end
    config.update_ip_forward
    config.update_ip6_forward
    %w(vids pvid access arp_nd_suppress learning).each do |attr|
      config.update_attr(attr, 'bridge')
    end
    config.update_alias_name
    config.update_vrr
    config.update_hwaddress
    # attributes with no suffix like bond-, or bridge-
    %w(mstpctl_portnetwork mstpctl_bpduguard mstpctl_portbpdufilter mstpctl_portadminedge vxlan_id vxlan_local_tunnelip clagd_enable clagd_priority clagd_backup_ip clagd_args clagd_sys_mac clagd_peer_ip mtu).each do |attr|
      config.update_attr(attr)
    end
    # copy to instance variable
    @config = config
  end

  def config_changed?
    build_desired_config
    Puppet.debug "desired config #{@config.confighash}"
    Puppet.debug "current config #{@config.currenthash}"
    ! @config.compare_with_current
  end

  def update_config
    @config.write_config
  end
end
