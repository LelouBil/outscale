resource "tls_private_key" "priv_key" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

resource "local_file" "priv_key" {
  content = tls_private_key.priv_key.private_key_pem
  filename = "${path.module}/priv_key.pem"
  file_permission = "0600"
}

resource "outscale_keypair" "bastion_keypair" {
  keypair_name = "priv_keypair"
  public_key = tls_private_key.priv_key.public_key_openssh
}
