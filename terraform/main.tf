provider "vault" {
  # Set token via VAULT_TOKEN=<token>
  #
  address = "http://127.0.0.1:8200"
}

resource "vault_policy" "hiera_vault" {
  name = "hiera"

  policy = <<EOT
path "puppet/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_generic_secret" "vault_vm_notify" {
  path = "puppet/node1.vm/vault_notify"

  data_json = <<EOT
{
  "value": "Hello World"
}
EOT

  depends_on = [vault_generic_secret.vault_notify]
}
