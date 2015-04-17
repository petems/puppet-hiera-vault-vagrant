# profile to deploy a puppet vault_message

class profile::vault_message {

  $vault_notify = lookup({"name" => "vault_notify", "value_type" => String, "default_value" => "No Vault Secret Found", "merge" => "first"})
  notify { "testing vault ${vault_notify}":}

}
