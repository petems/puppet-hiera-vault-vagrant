Vagrant.configure(2) do |config|

  config.vm.define "puppet", primary: true do |puppet|
    puppet.vm.hostname = "puppet"
    puppet.vm.box = "geerlingguy/centos7"
    puppet.vm.box_version = "1.2.6"
    puppet.vm.network "private_network", ip: "10.13.37.2"
    puppet.vm.network :forwarded_port, guest: 8080, host: 8080, id: "puppetdb"
    puppet.vm.network :forwarded_port, guest: 8200, host: 8200, id: "vault"

    puppet.vm.synced_folder "code", "/etc/puppetlabs/code"

    puppet.vm.provider :virtualbox do |vb|
      vb.memory = "3072"
    end

    puppet.vm.provision "shell", path: "puppetupgrade.sh"

$script = <<-SCRIPT
puppet apply -e 'include ::role::master' --modulepath=/etc/puppetlabs/code/environments/production/modules/:/etc/puppetlabs/code/environments/production/site/ --environment=puppetserver_vault_bootstrap
SCRIPT

    puppet.vm.provision "shell", inline: $script

    puppet.vm.provision "puppet" do |puppetapply|
      puppetapply.environment = "production"
      puppetapply.environment_path = ["vm", "/etc/puppetlabs/code/environments"]
    end
  end

  config.vm.define "node1", primary: true do |node1|
    node1.vm.hostname = "node1"
    node1.vm.box = "geerlingguy/centos7"
    node1.vm.box_version = "1.0.2"
    node1.vm.network "private_network", ip: "10.13.37.3"

    node1.vm.provision "shell", path: "puppetupgrade.sh"
    node1.vm.provision "shell", inline: "/bin/systemctl start puppet.service"

    # Run an agent run to check Puppetserver master is running ok
    node1.vm.provision "puppet_server" do |puppet_server|
      puppet_server.puppet_server = "puppet"
      puppet_server.options = "--test"
    end
  end

end
