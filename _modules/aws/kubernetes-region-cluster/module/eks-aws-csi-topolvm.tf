resource "kubectl_manifest" "topolvm" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: topolvm
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: topolvm
          version: "13.0.1"
          sourceRef:
            kind: HelmRepository
            name: topolvm
          interval: 5m
      releaseName: topolvm
      targetNamespace: kube-system
      install:
        remediation:
          retries: 3
      upgrade:
        remediation:
          retries: 3
      test:
        enable: false
      driftDetection:
        mode: enabled
        ignore:
          - paths: ["/spec/replicas"]
            target:
              kind: Deployment
      dependsOn:
        - name: cert-manager
      values:
        cert-manager:
          enabled: false
        scheduler:
          enabled: false
          type: Deployment
          service:
            type: ClusterIP
          updateStrategy:
            rollingUpdate:
              maxUnavailable: 1
            type: RollingUpdate
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                      - key: app.kubernetes.io/name
                        operator: In
                        values:
                          - topolvm
                      - key: app.kubernetes.io/component
                        operator: In
                        values:
                          - scheduler
                  topologyKey: kubernetes.io/hostname
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                  - matchExpressions:
                      - key: kubernetes.io/os
                        operator: In
                        values:
                          - linux
              preferredDuringSchedulingIgnoredDuringExecution:
                - weight: 100
                  preference:
                    matchExpressions:
                      - key: role
                        operator: NotIn
                        values:
                          - system
                - weight: 100
                  preference:
                    matchExpressions:
                      - key: kubernetes.io/arch
                        operator: In
                        values:
                          - arm64

          topologySpreadConstraints:
            - maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: topolvm
                  app.kubernetes.io/component: scheduler
              matchLabelKeys:
                - pod-template-hash
          priorityClassName: "system-cluster-critical"
        lvmd:
          managed: false
          deviceClasses:
            - name: default
              volume-group: default
              default: true
              spare-gb: 10
        node:
          lvmdEmbedded: true
          priorityClassName: system-node-critical
          initContainers:
            - name: pvinit
              securityContext:
                privileged: true
              image: ghcr.io/lvm-init-for-k8s/containers/lvm-init-for-k8s:1.2.0
              args:
                - aws
              imagePullPolicy: IfNotPresent
              env:
                - name: VG_NAME
                  value: default
                - name: MY_NODE_NAME
                  valueFrom:
                    fieldRef:
                      fieldPath: spec.nodeName
          tolerations:
            - operator: Exists
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                  - matchExpressions:
                      - key: kubernetes.io/os
                        operator: In
                        values:
                          - linux
                      - key: karpenter.k8s.aws/instance-local-nvme
                        operator: Exists
        controller:
          updateStrategy:
            rollingUpdate:
              maxUnavailable: 1
            type: RollingUpdate
          affinity: |
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                      - key: app.kubernetes.io/name
                        operator: In
                        values:
                          - topolvm
                      - key: app.kubernetes.io/component
                        operator: In
                        values:
                          - controller
                  topologyKey: kubernetes.io/hostname
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                  - matchExpressions:
                      - key: kubernetes.io/os
                        operator: In
                        values:
                          - linux
              preferredDuringSchedulingIgnoredDuringExecution:
                - weight: 100
                  preference:
                    matchExpressions:
                      - key: role
                        operator: NotIn
                        values:
                          - system
                - weight: 100
                  preference:
                    matchExpressions:
                      - key: kubernetes.io/arch
                        operator: In
                        values:
                          - arm64

          topologySpreadConstraints:
            - maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: topolvm
                  app.kubernetes.io/component: controller
              matchLabelKeys:
                - pod-template-hash
          priorityClassName: "system-cluster-critical"
        storageClasses:
          - name: instancestore-xfs
            storageClass:
              # Supported filesystems are: ext4, xfs, and btrfs.
              fsType: xfs
              # reclaimPolicy
              reclaimPolicy: Delete
              # Additional annotations
              annotations: {}
              # Default storage class for dynamic volume provisioning
              # ref: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning
              isDefaultClass: false
              # volumeBindingMode can be either WaitForFirstConsumer or Immediate. WaitForFirstConsumer is recommended because TopoLVM cannot schedule pods wisely if volumeBindingMode is Immediate.
              volumeBindingMode: WaitForFirstConsumer
              # enables CSI drivers to expand volumes. This feature is available for Kubernetes 1.16 and later releases.
              allowVolumeExpansion: true
              additionalParameters:
                "topolvm.io/device-class": "default"
              # mount options
              mountOptions: []
              allowedTopologies:
                - matchLabelExpressions:
                    - key: karpenter.k8s.aws/instance-local-nvme
                      operator: Exists
  YAML
}
