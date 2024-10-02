
resource "null_resource" "get_token" {
  provisioner "local-exec" {
    command = "curl -X POST 'https://iam.cloud.ibm.com/identity/token' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --data-urlencode 'grant_type=urn:ibm:params:oauth:grant-type:apikey' --data-urlencode 'apikey=${var.IBMCLOUD_API_KEY}'| jq -r .access_token > ${path.module}/token.tmpl"
  }
}

resource "null_resource" "folder_create" {
  provisioner "local-exec" {
       command = "[[ -d /tmp ]] && ([[ -d /tmp/.schematics ]] && echo 'Both folders already exist.' || (mkdir /tmp/.schematics && echo 'Folder /tmp/.schematics created.')) || (mkdir -p /tmp /tmp/.schematics && echo 'Both folders created.')"
  }
  depends_on = [null_resource.get_token]
}

resource "null_resource" "sm_create" {
  provisioner "local-exec" {
    command = "ACCESS_TOKEN=$(cat ${path.module}/token.tmpl);curl -X POST https://resource-controller.cloud.ibm.com/v2/resource_instances -H \"Authorization: Bearer $ACCESS_TOKEN\" -H 'Content-Type: application/json' -d '{\"name\":\"${var.sm_name}\",\"target\": \"${var.REGION}\",\"resource_group\": \"${var.RESOURCE_GROUP_ID}\",\"resource_plan_id\": \"${var.SM_PLAN}\"}'| jq -r .guid > /tmp/.schematics/sm_guid.tmpl"
  }
  depends_on = [null_resource.folder_create]
}


