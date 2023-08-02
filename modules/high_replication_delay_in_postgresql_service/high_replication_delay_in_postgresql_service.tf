resource "shoreline_notebook" "high_replication_delay_in_postgresql_service" {
  name       = "high_replication_delay_in_postgresql_service"
  data       = file("${path.module}/data/high_replication_delay_in_postgresql_service.json")
  depends_on = [shoreline_action.invoke_stop_remove_start_standby_server,shoreline_action.invoke_wal_sync]
}

resource "shoreline_file" "stop_remove_start_standby_server" {
  name             = "stop_remove_start_standby_server"
  input_file       = "${path.module}/data/stop_remove_start_standby_server.sh"
  md5              = filemd5("${path.module}/data/stop_remove_start_standby_server.sh")
  description      = "Restart the replication process by resetting the standby server to the latest checkpoint on the primary server. This can be done by stopping the standby server, removing all files in the PostgreSQL data directory, and starting the server again."
  destination_path = "/agent/scripts/stop_remove_start_standby_server.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "wal_sync" {
  name             = "wal_sync"
  input_file       = "${path.module}/data/wal_sync.sh"
  md5              = filemd5("${path.module}/data/wal_sync.sh")
  description      = "Verify that the standby server is up to date with the primary server by checking the WAL files on the standby server. If there are any discrepancies, restore the missing files from the primary server."
  destination_path = "/agent/scripts/wal_sync.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_stop_remove_start_standby_server" {
  name        = "invoke_stop_remove_start_standby_server"
  description = "Restart the replication process by resetting the standby server to the latest checkpoint on the primary server. This can be done by stopping the standby server, removing all files in the PostgreSQL data directory, and starting the server again."
  command     = "`/agent/scripts/stop_remove_start_standby_server.sh`"
  params      = ["STANDBY_SERVER"]
  file_deps   = ["stop_remove_start_standby_server"]
  enabled     = true
  depends_on  = [shoreline_file.stop_remove_start_standby_server]
}

resource "shoreline_action" "invoke_wal_sync" {
  name        = "invoke_wal_sync"
  description = "Verify that the standby server is up to date with the primary server by checking the WAL files on the standby server. If there are any discrepancies, restore the missing files from the primary server."
  command     = "`/agent/scripts/wal_sync.sh`"
  params      = []
  file_deps   = ["wal_sync"]
  enabled     = true
  depends_on  = [shoreline_file.wal_sync]
}

