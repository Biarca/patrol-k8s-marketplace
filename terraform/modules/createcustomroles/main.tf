# Installer Project

resource "google_project_iam_custom_role" "patrol-operations-custom-role" {
  project     = var.project_id
  role_id     = var.ops_id
  permissions = var.ops_perm
  title       = "Patrol Operations Role"
  description = "A Custom Role for Patrol Operations"
}

resource "google_project_iam_custom_role" "patrol-enforcer-installer-custom-role" {
  project     = var.project_id
  role_id     = var.enforcer_installer_id
  permissions = var.enforcer_installer_permissions
  title       = "Patrol Installer Enforcer Role"
  description = "A Custom Role for Patrol Enforcer on Installer Project"
}

# Monitoring Project

resource "google_project_iam_custom_role" "patrol-scanner-custom-role" {
  project     = var.fs_project_id
  role_id     = var.scan_id
  permissions = var.scan_perm
  title       = "Patrol Scanner Role"
  description = "A Custom Role for Patrol's Scanner"
}

resource "google_project_iam_custom_role" "enforcer-custom-role-mon" {
  project     = var.fs_project_id
  role_id     = var.enforce_id
  permissions = var.enforce_perm
  title       = "Patrol Monitor Enforcer Role"
  description = "A custom role for Patrol Enforcer on Monitoring Project"
}
