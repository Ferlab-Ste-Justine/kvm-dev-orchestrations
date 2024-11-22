locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))

  fe_leader_node = {
    ip   = netaddr_address_ipv4.fe_nodes.0.address
    fqdn = "starrocks-server-fe-1.ferlab.lan"
  }
  fe_follower_nodes = [
    for index, fe_node in netaddr_address_ipv4.fe_nodes : {
      ip   = fe_node.address
      fqdn = "starrocks-server-fe-${index + 1}.ferlab.lan"
    } if index > 0
  ]
  be_nodes = [
    for index, be_node in netaddr_address_ipv4.be_nodes : {
      ip   = be_node.address
      fqdn = "starrocks-server-be-${index + 1}.ferlab.lan"
    }
  ]
}
