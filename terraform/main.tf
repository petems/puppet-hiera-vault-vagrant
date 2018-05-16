provider "vault" {
  # Set token via VAULT_TOKEN=<token>
  #
  address = "http://127.0.0.1:8200"
}

resource "vault_policy" "hiera_vault" {
  name = "hiera"

  policy = <<EOT
path "secret/puppet/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_generic_secret" "vault_notify" {
  path = "secret/puppet/common"

  data_json = <<EOT
{
  "vault_notify": "Hello World"
}
EOT
}
