resource "null_resource" "install-prereq" {

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.IP
    private_key = var.private_ssh_key
  }

  provisioner "file" {
    source      = "modules/install-prereq/verify_rhel_repo.sh"
    destination = "/tmp/verify_rhel_repo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/verify_rhel_repo.sh",
      "/tmp/verify_rhel_repo.sh",

    ]
  }

  provisioner "file" {
    source      = "modules/install-prereq/prereq.sh"
    destination = "/tmp/prereq.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/prereq.sh",
      "/tmp/prereq.sh args",
    ]
  }

}