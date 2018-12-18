Vagrant.configure(2) do |config|

  config.vm.define "puppet", primary: true do |puppet|
    puppet.vm.hostname = "puppet.vm"
    puppet.vm.box = "geerlingguy/centos7"
    puppet.vm.box_version = "1.2.12"
    puppet.vm.network "private_network", ip: "10.13.37.2"
    puppet.vm.network :forwarded_port, guest: 8080, host: 8080, id: "puppetdb"
    puppet.vm.network :forwarded_port, guest: 8200, host: 8200, id: "vault"

    puppet.vm.synced_folder "code", "/etc/puppetlabs/code"

    puppet.vm.provider :virtualbox do |vb|
      vb.memory = "3072"
    end

    puppet.vm.provision "shell", path: "install_puppet.sh"

$puppet_boostrap = <<-SCRIPT
puppet apply -e 'include ::role::master' --modulepath=/etc/puppetlabs/code/environments/production/modules/:/etc/puppetlabs/code/environments/production/site/ --environment=puppetserver_vault_bootstrap
SCRIPT

$vault_init_unseal = <<-SCRIPT
export VAULT_ADDR=http://localhost:8200
/usr/local/bin/vault operator init -key-shares=1 -key-threshold=1 | tee vault.keys
VAULT_TOKEN=$(grep '^Initial' vault.keys | awk '{print $4}')
VAULT_KEY=$(grep '^Unseal Key 1:' vault.keys | awk '{print $4}')
export VAULT_TOKEN
/usr/local/bin/vault operator unseal "$VAULT_KEY"
echo $VAULT_TOKEN > /etc/vault_token.txt
SCRIPT

    puppet.vm.provision "shell", inline: $puppet_boostrap
    puppet.vm.provision "shell", inline: $vault_init_unseal

    puppet.vm.provision "puppet_server" do |puppet_server|
      puppet_server.puppet_server = "puppet.vm"
      puppet_server.options = "--test"
    end
  end

  config.vm.define "node1", primary: true do |node1|
    node1.vm.hostname = "node1.vm"
    node1.vm.box = "geerlingguy/centos7"
    node1.vm.box_version = "1.2.12"
    node1.vm.network "private_network", ip: "10.13.37.3"

    node1.vm.provision "shell", path: "install_puppet.sh"

    # Run an agent run to check Puppetserver master is running ok
    node1.vm.provision "puppet_server" do |puppet_server|
      puppet_server.puppet_server = "puppet.vm"
      puppet_server.options = "--test"
    end
  end

end
