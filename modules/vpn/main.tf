
resource "ibm_is_security_group" "sg" {
  name           = format("%s-%s", var.VPN_PREFIX, "sec-group")
  vpc            = data.ibm_is_vpc.vpc_data.id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group_rule" "ingress" {
  group     = ibm_is_security_group.sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "egress" {
  group     = ibm_is_security_group.sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_security_group_rule" "allowVPN" {
  group     = var.resource_group_id_bastion
  direction = "inbound"
  remote = ibm_is_security_group.sg.id
}


resource "null_resource" "wait2" {
  provisioner "local-exec" {
    command = "sleep 150"
  }
  depends_on = [ibm_is_security_group_rule.egress]
}

resource "ibm_is_vpn_server" "vpn_server" {
  depends_on = [null_resource.wait2]
  certificate_crn        = var.certificate_crn
  client_ip_pool         = var.VPN_CLIENT_IP_POOL
  enable_split_tunneling = true
  name                   = var.VPN_PREFIX
  subnets = length(values(data.ibm_is_subnet.subnet_data)) > 1 ? slice([for subnet in values(data.ibm_is_subnet.subnet_data) : subnet.id], 0, 2) : [values(data.ibm_is_subnet.subnet_data)[0].id]
  security_groups        = [ibm_is_security_group.sg.id]
  resource_group         = var.resource_group_id  
  client_authentication {
    method        = "certificate"
    client_ca_crn = var.certificate_crn
  }
}


resource "ibm_is_vpn_server_route" "route" {
  for_each = data.ibm_is_subnet.subnet_data
  name        = format("%s-%s", each.key, "route")
  vpn_server  = ibm_is_vpn_server.vpn_server.id
  destination = each.value.ipv4_cidr_block
  #action      = "deliver"
  action      = "translate"
  depends_on = [ibm_is_vpn_server.vpn_server]
}

