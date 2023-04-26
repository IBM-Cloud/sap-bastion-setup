data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

resource "ibm_is_volume" "vol1" {
  name           = "${var.HOSTNAME}-vol1"
  zone           = var.ZONE
  resource_group = data.ibm_resource_group.group.id
  profile        = var.VOL_PROFILE
  iops           = var.VOL_IOPS
  capacity       = var.VOL1
}

output "volumes_list" {
  value = [ibm_is_volume.vol1.id]
}
