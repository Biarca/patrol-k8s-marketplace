resource "local_file" "save_conent_to_file" {
  sensitive_content = base64decode(var.content)
  filename          = var.path
}
