# unifi

Ubiquiti Network's Unifi Controller

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/k8s-at-home/charts/issues/new/choose)**

## Source Code

* <https://github.com/jacobalberty/unifi-docker>

## Requirements

- Helm: 3.8+ (due to OCI registry support)
- Kubernetes: `>=1.18-0`

## Installing the Chart

To install the chart with the release name `unifi`

```console
helm install unifi oci://ghcr.io/mkilchhofer/unifi-chart/unifi
```

## Uninstalling the Chart

To uninstall the `unifi` deployment

```console
helm uninstall unifi
```

The command removes all the Kubernetes components associated with the chart **including persistent volumes** and deletes the release.

## Configuration

Read through the [values.yaml](./values.yaml) file. It has several commented out suggested values.
Other values may be used from the [values.yaml](../common/values.yaml) from the [common library](../common).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

```console
helm install unifi \
  --set env.TZ="America/New York" \
    k8s-at-home/unifi
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart.

```console
helm install unifi k8s-at-home/unifi -f values.yaml
```

## Custom configuration

### Regarding the services

- `guiService`: Represents the main web UI and is what one would normally point
  the ingress to.
- `captivePortalService`: This service is used to allow the captive portal webpage
  to be accessible. It needs to be reachable by the clients connecting to your guest
  network.
- `controllerService`: This is needed in order for the unifi devices to talk to
  the controller and must be otherwise exposed to the network where the unifi
  devices run. If you run this as a `NodePort` (the default setting), make sure
  that there is an external load balancer that is directing traffic from port
  8080 to the `NodePort` for this service.
- `discoveryService`: This needs to be reachable by the unifi devices on the
  network similar to the controller `Service` but only during the discovery
  phase. This is a UDP service.
- `stunService`: Also used periodically by the unifi devices to communicate
  with the controller using UDP. See [this article][ubnt 3] and [this other
  article][ubnt 4] for more information.
- `syslogService`: Used to capture syslog from Unifi devices if the feature is
  enabled in the site configuration. This needs to be reachable by Unifi devices
  on port 5514/UDP.
- `speedtestService`: Used for mobile speedtest inside the UniFi Mobile app.
  This needs to be reachable by clients connecting to port 6789/TCP.

### Ingress and HTTPS

Unifi does [not support HTTP][unifi] so if you wish to use the guiService, you
need to ensure that you use a backend transport of HTTPS.

An example entry in `values.yaml` to achieve this is as follows:

```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| GID | int | `999` | These GID (group id) the UniFi service runs as when `runAsRoot` is set to false |
| UID | int | `999` | Set the UID (user id) the UniFi service runs as when `runAsRoot` is set to false |
| affinity | object | `{}` | Affinity for pod assignment |
| captivePortalService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| captivePortalService.enabled | bool | `false` | Enable service for the captive portal webpage |
| captivePortalService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| captivePortalService.http | int | `8880` | Kubernetes port where the http service is exposed |
| captivePortalService.https | int | `8843` | Kubernetes port where the https service is exposed |
| captivePortalService.ingress.annotations | object | `{}` | Annotations for Ingress resource |
| captivePortalService.ingress.enabled | bool | `false` | Enable Ingress resource |
| captivePortalService.ingress.hosts | list | `["chart-example.local"]` | Hostname(s) for the Ingress resource |
| captivePortalService.ingress.path | string | `"/"` | Ingress path |
| captivePortalService.ingress.tls | list | `[]` | Ingress TLS configuration |
| captivePortalService.labels | object | `{}` | Labels to add to the captive portal service |
| captivePortalService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| captivePortalService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| captivePortalService.type | string | `"ClusterIP"` | Kubernetes service type |
| controllerService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| controllerService.enabled | bool | `false` | Enable service for the controller |
| controllerService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| controllerService.ingress.annotations | object | `{}` | Annotations for Ingress resource |
| controllerService.ingress.enabled | bool | `false` | Enable Ingress resource |
| controllerService.ingress.hosts | list | `["chart-example.local"]` | Hostname(s) for the Ingress resource |
| controllerService.ingress.path | string | `"/"` | Ingress path |
| controllerService.ingress.tls | list | `[]` | Ingress TLS configuration |
| controllerService.labels | object | `{}` | Labels to add to the controller service |
| controllerService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| controllerService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| controllerService.port | int | `8080` | Kubernetes port where the service is exposed |
| controllerService.type | string | `"NodePort"` | Kubernetes service type |
| customCert.certName | string | `"tls.crt"` | File name of the certificate |
| customCert.certSecret | string | `""` | Load custom certificate from an existing Kubernetes secret. If you want to store certificate and its key as a Kubernetes tls secret you can pass the name of that secret using certSecret variable |
| customCert.enabled | bool | `false` | Enable use of your own custom certificate in <unifi-data>/cert |
| customCert.isChain | bool | `false` | Sets the CERT_IS_CHAIN environment variable. See [Certificate Support](https://github.com/jacobalberty/unifi-docker?tab=readme-ov-file#certificate-support) |
| customCert.keyName | string | `"tls.key"` | File name of the private key for the certificate |
| deploymentAnnotations | object | `{}` | Annotations for UniFi deployment |
| discoveryService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| discoveryService.enabled | bool | `false` | Enable service for the discovery feature |
| discoveryService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| discoveryService.ingress.annotations | object | `{}` | Annotations for Ingress resource |
| discoveryService.ingress.enabled | bool | `false` | Enable Ingress resource |
| discoveryService.ingress.hosts | list | `["chart-example.local"]` | Hostname(s) for the Ingress resource |
| discoveryService.ingress.path | string | `"/"` | Ingress path |
| discoveryService.ingress.tls | list | `[]` | Ingress TLS configuration |
| discoveryService.labels | object | `{}` | Labels to add to the discovery service |
| discoveryService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| discoveryService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| discoveryService.port | int | `10001` | Kubernetes port where the service is exposed |
| discoveryService.type | string | `"NodePort"` | Kubernetes service type |
| extraConfigFiles | object | `{}` | Specify additional config files which are mounted to /configmap |
| extraJvmOpts | list | `[]` | Extra java options |
| extraVolumeMounts | list | `[]` | specify additional VolumeMount to be mounted inside unifi container |
| extraVolumes | list | `[]` | specify additional volume to be used by extraVolumeMounts inside unifi container |
| guiService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| guiService.enabled | bool | `false` | Enable service for the main web UI |
| guiService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| guiService.labels | object | `{}` | Labels to add to the GUI service |
| guiService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| guiService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| guiService.nodePort | int | `nil` | Specify the nodePort value for the LoadBalancer and NodePort service types. ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport |
| guiService.port | int | `8443` | Kubernetes port where the service is exposed |
| guiService.type | string | `"ClusterIP"` | Kubernetes service type |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. One of `Always`, `Never`, `IfNotPresent` |
| image.repository | string | `"jacobalberty/unifi"` | Container image name |
| image.tag | string | `""` (use appVersion in `Chart.yaml`) | Container image tag |
| ingress.annotations | object | `{}` | Annotations for Ingress resource |
| ingress.enabled | bool | `false` | Enable Ingress resource |
| ingress.hosts | list | `["chart-example.local"]` | Hostname(s) for the Ingress resource |
| ingress.path | string | `"/"` | Ingress path |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| jvmInitHeapSize | string | `nil` | Java Virtual Machine (JVM) initial, and minimum, heap size Unset value means there is no lower limit |
| jvmMaxHeapSize | string | `"1024M"` | Java Virtual Machine (JVM) maximum heap size For larger installations a larger value is recommended. For memory constrained system this value can be lowered. |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the probe to be considered failed after having succeeded. |
| livenessProbe.initialDelaySeconds | int | `30` | Number of seconds after the container has started before probes are initiated. |
| livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the probe. |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed. |
| livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| logging.promtail.enabled | bool | `false` | Enable promtail sidecar |
| logging.promtail.image.pullPolicy | string | `"IfNotPresent"` | Promtail image pull policy. One of `Always`, `Never`, `IfNotPresent` |
| logging.promtail.image.repository | string | `"grafana/promtail"` | Promtail container image name |
| logging.promtail.image.tag | string | `"1.6.0"` | Promtail container image tag |
| logging.promtail.loki.url | string | `"http://loki.logs.svc.cluster.local:3100/loki/api/v1/push"` | Loki backend for promtail sidecar |
| mongodb.databaseName | string | `"unifi"` | Maps to `unifi.db.name` |
| mongodb.dbUri | string | `"mongodb://mongo/unifi"` | Maps to `db.mongo.uri` |
| mongodb.enabled | bool | `false` | Use external mongoDB instead of using the built-in mongodb |
| mongodb.statDbUri | string | `"mongodb://mongo/unifi_stat"` | Maps to `statdb.mongo.uri` |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| persistence.accessMode | string | `"ReadWriteOnce"` | Persistence access modes |
| persistence.enabled | bool | `false` | Use persistent volume to store data |
| persistence.existingClaim | string | `nil` | Use an existing PVC to persist data |
| persistence.size | string | `"5Gi"` | Size of persistent volume claim |
| persistence.skipuninstall | bool | `false` | Do not delete the pvc upon helm uninstall |
| persistence.storageClass | string | `nil` | Type of persistent volume claim |
| podAnnotations | object | `{}` | Annotations for UniFi pod |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the probe to be considered failed after having succeeded. |
| readinessProbe.initialDelaySeconds | int | `15` | Number of seconds after the container has started before probes are initiated. |
| readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the probe. |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed. |
| readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| resources | object | `{}` | Set container requests and limits for different resources like CPU or memory |
| runAsRoot | bool | `false` | This is used to determine whether or not the UniFi service runs as a privileged (root) user. The default value is `true` but it is recommended to use `false` instead. |
| speedtestService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| speedtestService.enabled | bool | `false` | Enable service for mobile speedtest inside the UniFi Mobile app |
| speedtestService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| speedtestService.labels | object | `{}` | Labels to add to the speedtest service |
| speedtestService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| speedtestService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| speedtestService.port | int | `6789` | Kubernetes port where the service is exposed |
| speedtestService.type | string | `"ClusterIP"` | Kubernetes service type |
| strategyType | string | `"Recreate"` | upgrade strategy type (e.g. Recreate or RollingUpdate) |
| stunService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| stunService.enabled | bool | `false` | Enable service the STUN feature |
| stunService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| stunService.labels | object | `{}` | Labels to add to the STUN service |
| stunService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| stunService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| stunService.port | int | `3478` | Kubernetes port where the service is exposed |
| stunService.type | string | `"NodePort"` | Kubernetes service type |
| syslogService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| syslogService.enabled | bool | `false` | Enable service for the syslog server. Used to capture syslog from Unifi devices if the feature is enabled in the site configuration. |
| syslogService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| syslogService.labels | object | `{}` | Labels to add to the syslog service |
| syslogService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| syslogService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| syslogService.port | int | `5514` | Kubernetes port where the service is exposed |
| syslogService.type | string | `"NodePort"` | Kubernetes service type |
| timezone | string | `"UTC"` | Timezone for UniFi controller |
| tolerations | list | `[]` | Tolerations for pod assignment |
| unifiedService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| unifiedService.enabled | bool | `false` | Create a unified service instead of dedicated services. If enabled, the controller, discovery, GUI, STUN and syslog services will not be created. |
| unifiedService.externalTrafficPolicy | string | `nil` | Set the externalTrafficPolicy in the Service to either Cluster or Local |
| unifiedService.labels | object | `{}` | Labels to add to the unified service |
| unifiedService.loadBalancerIP | string | `nil` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| unifiedService.loadBalancerSourceRanges | list | `nil` | loadBalancerSourceRanges |
| unifiedService.nodePort | int | `nil` | Specify the nodePort value for the LoadBalancer and NodePort service types. ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport |
| unifiedService.type | string | `"ClusterIP"` | Kubernetes service type |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.9.1](https://github.com/norwoodj/helm-docs/releases/v1.9.1)
