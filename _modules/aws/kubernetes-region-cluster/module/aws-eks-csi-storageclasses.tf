resource "kubectl_manifest" "storageclasses" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter,
    kubectl_manifest.ebs,
    kubectl_manifest.efs
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: aws-storage-csi
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: raw
          version: "2.0.0"
          sourceRef:
            kind: HelmRepository
            name: bedag
          interval: 5m
      releaseName: aws-storage-csi
      targetNamespace: kube-system
      install:
        createNamespace: false
        remediation:
          retries: 3
      upgrade:
        remediation:
          retries: 3
      test:
        enable: false
      driftDetection:
        mode: warn
      dependsOn:
        - name: aws-ebs
        - name: aws-efs
      values:
        resources:
          - apiVersion: storage.k8s.io/v1
            kind: StorageClass
            metadata:
              name: cluster-block-base-ext4
              annotations:
                storageclass.kubernetes.io/is-default-class: "true"
            parameters:
              fsType: ext4
              type: gp3
            provisioner: ebs.csi.aws.com
            reclaimPolicy: Delete
            allowVolumeExpansion: true
            volumeBindingMode: WaitForFirstConsumer
  YAML
}
