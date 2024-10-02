output "server_cert_crn" {
  value       = ibm_sm_imported_certificate.server.crn
  description = "CRN of the certificate imported to the Secret Manager"
}

output "ca" {
  value       = tls_self_signed_cert.ca_cert.cert_pem
  sensitive   = true
  description = "CA Certificate"
}

output "client_key" {
  value       = tls_private_key.client_key.private_key_pem
  sensitive   = true
  description = "Client Key (private key pem)"
}

output "client_cert" {
  value       = tls_locally_signed_cert.client_cert.cert_pem
  sensitive   = true
  description = "Client Certficate"
}

output "server_cert" {
  value       = tls_locally_signed_cert.server_cert.cert_pem
  sensitive   = true
  description = "Server Certficate"
}

