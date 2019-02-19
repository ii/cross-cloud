output "master_ips" { value = "${ join(",", google_compute_instance.cncf.*.network_interface.0.network_ip) }" }
output "public_master_ips" { value = "${ join(",", google_compute_instance.cncf.*.network_interface.0.access_config.0.nat_ip) }" }