resource "kubernetes_storage_class" "gp2-ext4" {
  metadata {
    name = "aws-ebs-gp2-ext4"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  parameters = {
    fsType = "ext4"
    type   = "gp2"
  }

}

resource "kubernetes_storage_class" "gp3-ext4" {
  metadata {
    name = "aws-ebs-gp3-ext4"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  parameters = {
    fsType = "ext4"
    type   = "gp3"
  }
}
