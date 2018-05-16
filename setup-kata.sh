#!/bin/bash

#First - check to see if we are using CRI-O or containerd



## Configure CRIO to use Kata:
echo "Set manage_network_ns_lifecycle to true"
network_ns_flag="manage_network_ns_lifecycle"

# Check if flag is already defined in the CRI-O config file.
# If it is already defined, then just change the value to true,
# else, add the flag with the value.
if grep "$network_ns_flag" "$crio_config_file"; then
	sudo sed -i "s/^$network_ns_flag.*/$network_ns_flag = true/" "$crio_config_file"
else
	sudo sed -i "/\[crio.runtime\]/a$network_ns_flag = true" "$crio_config_file"
fi


### Configure CRIO to use Kata:
## Uncomment next line if you'd like to have default trust level for the cluster be "untrusted":
#sudo sed -i 's/default_workload_trust = "trusted"/default_workload_trust = "untrusted"/' "$crio_config_file"

echo "Set Kata containers as default runtime in CRI-O for untrusted workloads"
sudo sed -i 's/runtime_untrusted_workload = ""/runtime_untrusted_workload = "\/opt\/kata\/bin\/kata-runtime"/' "$crio_config_file"

## Not sure the following is really needed:
service_path="/etc/systemd/system"
crio_service_file="${cidir}/data/crio.service"
echo "Install crio service (${crio_service_file})"
sudo install -m0444 "${crio_service_file}" "${service_path}"
echo "Reload systemd services"
sudo systemctl daemon-reload

### Restart CRIO:



## Configure CRI-Containerd to use Kata: