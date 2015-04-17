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

The local port 8100 gets forwarded to the Vagrant VM to port 8100.

# Security

This repository is meant as a non-production sandbox setup.
It is not a guide on how to setup a secure Puppet and Vault environment.

In particular this means:

* Auto signing is enabled, every node that connects to the puppetserver is automatically signed.
* Passwords or PSKs are not randomized and easily guessable.
* Vault should be on it's own dedicated node rather than the same server as the puppet master

For a non publicly reachable playground this should be acceptable.
