resource "google_folder_iam_member" "add_folder_roles" {
    count  = "${var.resource_type == "folder" ? length(var.roles) : 0}"
    role    = "${element(var.roles, count.index)}"
    member = "serviceAccount:${var.email}"
    folder  = "folders/${var.folder_id}"
}