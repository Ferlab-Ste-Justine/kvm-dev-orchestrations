output "roles" {
  description = "List of roles."
  value       = module.download_users.roles
}

output "environments" {
  description = "List of environments."
  value       = module.download_users.environments
}

output "users" {
  description = "List of users."
  value       = module.download_users.users
}

output "users_by_username" {
  description = "List of users by username."
  value       = module.download_users.users_by_username
}

output "users_by_role" {
  description = "Map of filtered users lists with the roles as key."
  value       = module.download_users.users_by_role
}

output "usernames_by_role" {
  description = "Map of filtered users lists with the roles as key."
  value       = module.download_users.usernames_by_role
}

output "users_by_environment" {
  description = "Map of filtered users lists with the environments as key."
  value       = module.download_users.users_by_environment
}

output "usernames_by_environment" {
  description = "Map of filtered usernames lists with the environments as key."
  value       = module.download_users.usernames_by_environment
}

output "users_by_environment_role" {
  description = "Nested maps of filtered users lists with the environments and the role as keys."
  value       = module.download_users.users_by_environment_role
}

output "usernames_by_environment_role" {
  description = "Nested maps of filtered usernames lists with the environments and the role as keys."
  value       = module.download_users.usernames_by_environment_role
}