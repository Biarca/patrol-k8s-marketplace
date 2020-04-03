resource "google_project_iam_member" "grantrole" {
  count  = "${var.resource_type == "project" ? length(var.roles) : 0}"
  role   = "${element(var.roles, count.index)}"
  member = "serviceAccount:${var.email}"
  project = "${var.project_id}"
}
