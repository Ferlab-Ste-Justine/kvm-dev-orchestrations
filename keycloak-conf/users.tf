data "etcd_key" "ferlab_users" {
    key        = "/test-users/users.yml"
    must_exist = false
}

resource "time_rotating" "now" {
  rotation_minutes = 1
}

module "download_users" {
  count = data.etcd_key.ferlab_users.found ? 1 : 0
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-ferlab-users.git//download?ref=v0.5.0"
  etcd_key = "/test-users/users.yml"
  execution_time = time_rotating.now.rfc3339
  compute = {
    users_by_username = true
    users_by_role = true
    usernames_by_role = true
    users_by_environment = true
    usernames_by_environment = true
    users_by_environment_role = true
    usernames_by_environment_role = true
  }
}

data "keycloak_realm" "master" {
  realm = "master"
}

//test realm users
module "test_realm_user_roles" {
  source = "./terraform-keycloak/staff-user-role-ids"
  realm_name = keycloak_realm.test.realm
  master_realm_user = false
  management_roles = [
    "view-realm",
    "view-users",
    "view-events",
    "view-identity-providers",
    "view-authorization",
    "query-clients",
  ]
  account_roles = [
    "view-profile",
  ]
}

module "test_realm_users" {
  for_each = length(module.download_users) > 0 ? {for key, val in module.download_users[0].users_by_username: key => val.username} : {}

  source = "./terraform-keycloak/staff-user"
  realm_id = keycloak_realm.test.id
  role_ids = module.test_realm_user_roles.role_ids
  username = "${each.key}@test.test"
  password = "testtest"
  email = "${each.key}@test.test"
  first_name = "test"
  last_name = "test"
}

//master realm users
module "master_realm_user_master_roles" {
  source = "./terraform-keycloak/staff-user-role-ids"
  realm_name = data.keycloak_realm.master.realm
  master_realm_user = true
  management_roles = [
    "view-realm",
    "view-users",
    "view-events",
    "view-identity-providers",
    "view-authorization",
    "query-clients",
  ]
  account_roles = [
    "view-profile",
  ]
}

module "master_realm_user_test_roles" {
  source = "./terraform-keycloak/staff-user-role-ids"
  realm_name = keycloak_realm.test.realm
  master_realm_user = true
  management_roles = [
    "view-realm",
    "view-users",
    "view-events",
    "view-identity-providers",
    "view-authorization",
    "query-clients",
  ]
}

module "master_realm_users" {
  for_each = length(module.download_users) > 0 ? {for key, val in module.download_users[0].users_by_username: key => val.username} : {}

  source = "./terraform-keycloak/staff-user"
  realm_id = data.keycloak_realm.master.id
  role_ids = concat(module.master_realm_user_master_roles.role_ids, module.master_realm_user_test_roles.role_ids)
  username = "${each.key}@master.master"
  password = "mastermaster"
  email = "${each.key}@master.master"
  first_name = "master"
  last_name = "master"
}