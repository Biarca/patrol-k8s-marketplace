output "roles" {
  value = "${google_project_iam_member.grantrole.*.role}"
}
