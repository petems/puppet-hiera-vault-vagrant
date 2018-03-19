# puppet-hiera-vault-vagrant

> Note: This is a heavily modified form of https://github.com/roman-mueller/puppet4-sandbox but focused on demo-ing Hiera and Vault

This is a sandbox repository to show how HashiCorp's Vault can be used to interact with Hiera for the storage of secrets in a Puppet environment.

In the Vagrantfile there are 2 VMs defined:

A puppetserver ("puppet") and a puppet node ("node1") both running CentOS 7.0.

Classes get configured via hiera (see `code/environments/production/hieradata/*`).

# Requirements and Setup

* Vagrant 2.X (Works with older but easier to use newer!)
* VirtualBox
* The puppetserver VM is configured to use 3GB of RAM
* The node is using the default (usually 512MB).
* A shell provisioner ("puppetupgrade.sh") which installs the Puppet 5 Yum repos and updates `puppet-agent` before running it for the first time. That way newly spawned Vagrant environments will always use the latest available version.
* There is no DNS server running in the private network, sll nodes have each other in their `/etc/hosts` files.
* Note: I will be fixing this to use https://github.com/oscar-stack/vagrant-hosts in the future

# Usage

After cloning the repository make sure the submodules are also updated:

```
$ git clone https://github.com/roman-mueller/puppet4-sandbox
$ cd puppet4-sandbox
$ git submodule update --init --recursive
```

Whenever you `git pull` this repository you should also update the submodules again.

Now you can simply run `vagrant up puppet` to get a fully set up puppetserver.

The `code/` folder will be a synced folder and gets mounted to `/etc/puppetlabs/code` inside the VM.

If you want to attach a node to the puppetserver simply run `vagrant up node1`.
Once provisioned it is automatically connecting to the puppetserver and it gets automatically signed.

After that puppet will run automatically every 30 minutes on the node and apply your changes.

You can also run it manually:

```
$ vagrant ssh node1
[vagrant@node1 ~]$ sudo /opt/puppetlabs/bin/puppet agent -t
Info: Caching certificate for node1
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for node1
Info: Retrieving pluginfacts
Info: Retrieving plugin
(...)
Notice: Applied catalog in 0.52 seconds
```

# Configuring Vault

Vault gets installed and started by default on the Puppetserver node.

The local port 8200 gets forwarded to the Vagrant VM to port 8200.

After the inital provisioning is done, initialise vault:

```
$ VAULT_ADDR='http://127.0.0.1:8200' vault init

Unseal Key 1: qduQtx3VNgLN/9WP1ZRzCq1ZB709DZ3TS/D52YS6yLzr
Unseal Key 2: YSXO2hST8+FHoBrn1SgI6yn+ApriQpqiDKhrnLXH9ojP
Unseal Key 3: o+Og63B2/cJiX/8VoshTlBIb/dkCoeGrgSv2bPLQzBjE
Unseal Key 4: lfNiq0/B5V1IXyKzivjDRXqetHtcXqaHj8prF9RclL08
Unseal Key 5: DL3Xf4FSxIv6+NEYdZCZaskf0jcJ0bowe34r7Gdl7Y+9
Initial Root Token: 677b88e3-300c-3a5a-ea2f-72ba70be5516

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your vault will remain permanently sealed.
```

Take note of the token. Replace the string `<REPLACE-ME>` in the `hiera.yaml-after-provision` file

Unseal Vault:

```
$ VAULT_ADDR='http://127.0.0.1:8200' vault unseal
Key (will be hidden):
```

Use 3 of the unseal keys from above.

Then add a secret to demonstrate the Vault Hiera backend using the token you were given:


```
$ VAULT_TOKEN=677b88e3-300c-3a5a-ea2f-72ba70be5516 VAULT_ADDR='http://127.0.0.1:8200' vault write secret/puppet/common/vault_notify value=hello_123
Success! Data written to: secret/puppet/common/vault_notify
```

Now, change the name of your hiera file on so it'll be picked up as part of the hierachy:

```
$ mv /vagrant/code/environments/production/hiera.yaml-after_provision /vagrant/code/environments/production/hiera.yaml
```

Now, run an agent run on your node1 node:

```
$ puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Loading facts
Info: Caching catalog for node1.home
Info: Applying configuration version '1521467005'
Notice: testing vault hello_123
Notice: /Stage[main]/Profile::Vault_message/Notify[testing vault hello_123]/message: defined 'message' as 'testing vault hello_123'
Notice: Applied catalog in 0.14 seconds
[root@node1 vagrant]# exit
```

Now change it...

```
$ VAULT_TOKEN=677b88e3-300c-3a5a-ea2f-72ba70be5516 VAULT_ADDR='http://127.0.0.1:8200' vault write secret/puppet/common/vault_notify value=gbye_123
Success! Data written to: secret/puppet/common/vault_notify
```

And see the message change:

```
```
$ puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Retrieving locales
Info: Loading facts
Info: Caching catalog for node1.home
Info: Applying configuration version '1521467005'
Notice: testing vault gbye_123
Notice: /Stage[main]/Profile::Vault_message/Notify[testing vault gbye_123]/message: defined 'message' as 'testing vault gbye_123'
Notice: Applied catalog in 0.14 seconds
[root@node1 vagrant]# exit
```
```

You can also do this from your host:
```
$ vagrant provision node1 --provision-with puppet_server
==> node1: Running provisioner: puppet_server...
==> node1: Running Puppet agent...
==> node1: Info: Using configured environment 'production'
==> node1: Info: Retrieving pluginfacts
==> node1: Info: Retrieving plugin
==> node1: Info: Retrieving locales
==> node1: Info: Loading facts
==> node1: Info: Caching catalog for node1.home
==> node1: Info: Applying configuration version '1521467181'
==> node1: Notice: testing vault hello_123
==> node1: Notice: /Stage[main]/Profile::Vault_message/Notify[testing vault hello_123]/message: defined 'message' as 'testing vault hello_123'
==> node1: Notice: Applied catalog in 0.16 seconds
```



# Security

This repository is meant as a non-production sandbox setup.
It is not a guide on how to setup a secure Puppet and Vault environment.

In particular this means:

* Auto signing is enabled, every node that connects to the puppetserver is automatically signed.
* Passwords or PSKs are not randomized and easily guessable.
* Vault should be on it's own dedicated node rather than the same server as the puppet master

For a non publicly reachable playground this should be acceptable.
