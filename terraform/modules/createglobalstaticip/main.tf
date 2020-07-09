resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "google_compute_global_address" "create_global_static_ip" {
  depends_on = [time_sleep.wait_60_seconds]
  name = "${var.name}"
}