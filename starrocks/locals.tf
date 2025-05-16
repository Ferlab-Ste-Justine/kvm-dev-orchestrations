locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))

  host_params = fileexists("${path.module}/../shared/host_params.json") ? jsondecode(file("${path.module}/../shared/host_params.json")) : {
    ip = ""
  }

  fe_leader_fqdn    = "starrocks-server-fe-1.ferlab.lan"
  fe_follower_fqdns = [for index, fqdn in netaddr_address_ipv4.fe_nodes : "starrocks-server-fe-${index + 1}.ferlab.lan" if index > 0]
  be_fqdns          = [for index, fqdn in netaddr_address_ipv4.be_nodes : "starrocks-server-be-${index + 1}.ferlab.lan"]
}
