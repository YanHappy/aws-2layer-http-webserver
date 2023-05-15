output "lb_security_group" {
  value = module.lb_security_group.security_group_name
}
output "app_security_group" {
  value = module.app_security_group.security_group_name
}