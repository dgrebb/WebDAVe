resource "aws_efs_file_system" "webdav" {
  encrypted = true
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = var.DASHED_SUBDOMAIN
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.webdav.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "mount" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.webdav.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.security_group_id]
}
