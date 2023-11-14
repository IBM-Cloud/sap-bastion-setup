data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}


resource "ibm_resource_instance" "activity_tracker" {
  count = var.ATR_PROVISION ? 1 : 0

  name              = var.ATR_NAME
  resource_group_id = data.ibm_resource_group.group.id
  service           = "logdnaat"
  plan              = var.ATR_PLAN 
  location          = var.REGION
  tags              = (var.ATR_TAGS != null ? var.ATR_TAGS : null)

    //User can increase timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}


data "ibm_resource_instance" "activity_tracker" {
  depends_on = [ ibm_resource_instance.activity_tracker ]

  name              = var.ATR_NAME
  location          = var.REGION
  service           = "logdnaat"
}