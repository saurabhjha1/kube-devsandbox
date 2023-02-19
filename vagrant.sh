#!/bin/bash
sudo apt install -y vagrant virtualbox ansible

vagrant up

vagrant plugin install landrush
vagrant plugin install vagrant-vboxmanager
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-libvirt

nodes=$(vagrant global-status | grep k8s | awk '{ print $2 }')
for node in $nodes; do
    vagrant ssh $node -c "sudo  sysctl -w vm.max_map_count=262144"
    vagrant ssh $node -c "echo 'sysctl vm.max_map_count=262144' | sudo tee -a /etc/rc.local"
    vagrant ssh $node -c "echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf"
done

