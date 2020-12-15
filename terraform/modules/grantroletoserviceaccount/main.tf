resource "google_project_iam_member" "grantrole" {
    count = length(var.roles)
    role    = element(var.roles, count.index)
    member = "serviceAccount:${var.email}"
 }