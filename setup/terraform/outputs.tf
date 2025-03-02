output "humanitec_app" {
  description = "The ID of the Humanitec application"
  value       = humanitec_application.demo.id
}

output "humanitec_environment" {
  description = "The ID of the Humanitec environment"
  value       = humanitec_environment.demo.id
}
