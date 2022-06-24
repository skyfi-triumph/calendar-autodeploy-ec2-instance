output "vr-gaming-image-id" {
  value = data.aws_ami.vr-gaming.id
}

output "server-IPs" {
  value = aws_eip.eip[*].public_ip
}

output "connection-info" {
  value = !(var.state == "init" && var.ami == "default") ? "" : <<-EOF
  Username: Administrator
  Password: ${var.admin_password}

  After you've setup your box, run:
  TF_VAR_state=snapshot terraform apply --auto-approve

  Later, when you're done gaming, run:
  TF_VAR_state=stop terraform apply --auto-approve

  And when you wanna play again, run:
  TF_VAR_state=start terraform apply --auto-approve
  EOF
}
