# unifi

Ubiquiti Network's Unifi Controller

**This chart is not maintained by the [upstream project](https://github.com/jacobalberty/unifi-docker) and any issues with the chart should be raised [here](https://github.com/mkilchhofer/unifi-chart/issues/new)**

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

Read through the [values.yaml] file. It has several commented out suggested values.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

```console
helm install unifi \
  --set env.TZ="America/New York" \
  oci://ghcr.io/mkilchhofer/unifi-chart/unifi
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart.

```console
helm install unifi oci://ghcr.io/mkilchhofer/unifi-chart/unifi -f values.yaml
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

An example entry in `values.yaml` to achieve this using the [Ingress-Nginx Controller] is as follows:

```yaml
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
| affinity | object | `{}` | Assign custom [affinity] rules to the deployment |
| bindPrivilegedPorts | bool | `true` | Allow listening on privileged ports. Required when `controllerService.port` or `guiService.port` is less than 1024. |
| captivePortalService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| captivePortalService.enabled | bool | `true` | Enable service for the captive portal webpage |
| captivePortalService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| captivePortalService.http | int | `8880` | Kubernetes port where the http service is exposed |
| captivePortalService.https | int | `8843` | Kubernetes port where the https service is exposed |
| captivePortalService.ingress.annotations | object | `{}` | Annotations for Ingress resource |
| captivePortalService.ingress.enabled | bool | `false` | Enable Ingress resource |
| captivePortalService.ingress.hosts | list | `["unifi-captive.example.com"]` | Hostname(s) for the Ingress resource |
| captivePortalService.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| captivePortalService.ingress.path | string | `"/"` | Ingress path |
| captivePortalService.ingress.tls | list | `[]` | Ingress TLS configuration |
| captivePortalService.labels | object | `{}` | Labels to add to the captive portal service |
| captivePortalService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| captivePortalService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| captivePortalService.type | string | `"ClusterIP"` | Kubernetes service type |
| controllerService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| controllerService.enabled | bool | `true` | Enable service for the controller |
| controllerService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| controllerService.ingress.annotations | object | `{}` | Annotations for Ingress resource |
| controllerService.ingress.enabled | bool | `false` | Enable Ingress resource |
| controllerService.ingress.hosts | list | `["unifi-controller.example.com"]` | Hostname(s) for the Ingress resource |
| controllerService.ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| controllerService.ingress.path | string | `"/"` | Ingress path |
| controllerService.ingress.tls | list | `[]` | Ingress TLS configuration |
| controllerService.labels | object | `{}` | Labels to add to the controller service |
| controllerService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| controllerService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| controllerService.port | int | `8080` | Kubernetes port where the service is exposed |
| controllerService.type | string | `"NodePort"` | Kubernetes service type |
| customCert.certName | string | `"tls.crt"` | File name of the certificate |
| customCert.certSecret | string | `""` | Load custom certificate from an existing Kubernetes secret. If you want to store certificate and its key as a Kubernetes tls secret you can pass the name of that secret using certSecret variable |
| customCert.enabled | bool | `false` | Enable use of your own custom certificate in <unifi-data>/cert |
| customCert.isChain | bool | `false` | Sets the CERT_IS_CHAIN environment variable. See [Certificate Support](https://github.com/jacobalberty/unifi-docker?tab=readme-ov-file#certificate-support) |
| customCert.keyName | string | `"tls.key"` | File name of the private key for the certificate |
| deploymentAnnotations | object | `{}` | Annotations for UniFi deployment |
| discoveryService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| discoveryService.enabled | bool | `true` | Enable service for the discovery feature |
| discoveryService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| discoveryService.labels | object | `{}` | Labels to add to the discovery service |
| discoveryService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| discoveryService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| discoveryService.port | int | `10001` | Kubernetes port where the service is exposed |
| discoveryService.type | string | `"NodePort"` | Kubernetes service type |
| extraConfigFiles | object | `{}` | Specify additional config files which are mounted to /configmap |
| extraJvmOpts | list | `[]` | Extra java options |
| extraVolumeMounts | list | `[]` | specify additional VolumeMount to be mounted inside unifi container |
| extraVolumes | list | `[]` | specify additional volume to be used by extraVolumeMounts inside unifi container |
| guiService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| guiService.enabled | bool | `true` | Enable service for the main web UI |
| guiService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| guiService.labels | object | `{}` | Labels to add to the GUI service |
| guiService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| guiService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| guiService.nodePort | int | `nil` | Specify the nodePort value for the LoadBalancer and NodePort service types. ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport |
| guiService.port | int | `8443` | Kubernetes port where the service is exposed |
| guiService.type | string | `"ClusterIP"` | Kubernetes service type |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. One of `Always`, `Never`, `IfNotPresent` |
| image.repository | string | `"ghcr.io/jacobalberty/unifi-docker"` | Container image name |
| image.tag | string | `""` (use appVersion in `Chart.yaml`) | Container image tag |
| ingress.annotations | object | `{}` | Annotations for Ingress resource |
| ingress.enabled | bool | `true` | Enable Ingress resource |
| ingress.hosts | list | `["unifi.example.com"]` | Hostname(s) for the Ingress resource |
| ingress.ingressClassName | string | `""` | Defines which ingress controller will implement the resource |
| ingress.path | string | `"/"` | Ingress path |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| jvmInitHeapSize | string | `""` | Java Virtual Machine (JVM) initial, and minimum, heap size. Unset value means there is no lower limit |
| jvmMaxHeapSize | string | `"1024M"` | Java Virtual Machine (JVM) maximum heap size For larger installations a larger value is recommended. For memory constrained system this value can be lowered. |
| livenessProbe.enabled | bool | `true` | Enable liveness [probe] |
| livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded. |
| livenessProbe.initialDelaySeconds | int | `0` | Number of seconds after the container has started before probes are initiated. |
| livenessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe]. |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed. |
| livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out. |
| logging.promtail.enabled | bool | `false` | Enable promtail sidecar |
| logging.promtail.image.pullPolicy | string | `"IfNotPresent"` | Promtail image pull policy. One of `Always`, `Never`, `IfNotPresent` |
| logging.promtail.image.repository | string | `"grafana/promtail"` | Promtail container image name |
| logging.promtail.image.tag | string | `"3.3.2"` | Promtail container image tag |
| logging.promtail.loki.url | string | `"http://loki.logs.svc.cluster.local:3100/loki/api/v1/push"` | Loki backend for promtail sidecar |
| mongodb.databaseName | string | `"unifi"` | Maps to `unifi.db.name` |
| mongodb.dbUri | string | `"mongodb://mongo/unifi"` | Maps to `db.mongo.uri` |
| mongodb.enabled | bool | `false` | Use external mongoDB instead of using the built-in mongodb |
| mongodb.statDbUri | string | `"mongodb://mongo/unifi_stat"` | Maps to `statdb.mongo.uri` |
| nodeSelector | object | `{}` | [Node selector] for pod assignment |
| persistence.accessMode | string | `"ReadWriteOnce"` | Persistence access modes |
| persistence.enabled | bool | `false` | Use persistent volume to store data |
| persistence.existingClaim | string | `""` | Use an existing PVC to persist data |
| persistence.size | string | `"5Gi"` | Size of persistent volume claim |
| persistence.skipuninstall | bool | `true` | Do not delete the PVC upon helm uninstall by adding the `helm.sh/resource-policy: keep` annotation. |
| persistence.storageClass | string | `""` | Storage Class to use for the PVC |
| podAnnotations | object | `{}` | Annotations for UniFi pod |
| podSecurityContext | object | `{}` | Set pod-level security context |
| priorityClassName | string | `""` | [Priority Class Name] for pod |
| readinessProbe.enabled | bool | `true` | Enable readiness [probe] |
| readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded. |
| readinessProbe.initialDelaySeconds | int | `0` | Number of seconds after the container has started before probes are initiated. |
| readinessProbe.periodSeconds | int | `10` | How often (in seconds) to perform the [probe]. |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the [probe] to be considered successful after having failed. |
| readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out. |
| resources | object | `{}` | Set container requests and limits for different resources like CPU or memory |
| runAsRoot | bool | `false` | This is used to determine whether or not the UniFi service runs as a privileged (root) user. The default value is `true` but it is recommended to use `false` instead. |
| securityContext | object | `{}` | Set container-level security context. The parameter `bindPrivilegedPorts=true` will add the `SETFCAP` capability automatically. |
| speedtestService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| speedtestService.enabled | bool | `true` | Enable service for mobile speedtest inside the UniFi Mobile app |
| speedtestService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| speedtestService.labels | object | `{}` | Labels to add to the speedtest service |
| speedtestService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| speedtestService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| speedtestService.port | int | `6789` | Kubernetes port where the service is exposed |
| speedtestService.type | string | `"ClusterIP"` | Kubernetes service type |
| startupProbe.enabled | bool | `true` | Enable startup [probe]. **Set** `livenessProbe.initialDelaySeconds` **to at least `30` if you decide to disable the startupProbe!** Max startup delay is `failureThreshold * periodSeconds`. |
| startupProbe.failureThreshold | int | `60` | Minimum consecutive failures for the [probe] to be considered failed after having succeeded. |
| startupProbe.periodSeconds | int | `5` | How often (in seconds) to perform the [probe]. |
| startupProbe.timeoutSeconds | int | `1` | Number of seconds after which the [probe] times out. |
| strategyType | string | `"Recreate"` | upgrade strategy type (e.g. Recreate or RollingUpdate) |
| stunService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| stunService.enabled | bool | `true` | Enable service the STUN feature |
| stunService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| stunService.labels | object | `{}` | Labels to add to the STUN service |
| stunService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| stunService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| stunService.port | int | `3478` | Kubernetes port where the service is exposed |
| stunService.type | string | `"NodePort"` | Kubernetes service type |
| syslogService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| syslogService.enabled | bool | `true` | Enable service for the syslog server. Used to capture syslog from UniFi devices if the feature is enabled in the site configuration. |
| syslogService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| syslogService.labels | object | `{}` | Labels to add to the syslog service |
| syslogService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| syslogService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| syslogService.port | int | `5514` | Kubernetes port where the service is exposed |
| syslogService.type | string | `"NodePort"` | Kubernetes service type |
| timezone | string | `"UTC"` | Timezone for UniFi controller |
| tolerations | list | `[]` | [Tolerations] for pod assignment |
| unifiedService.annotations | object | `{}` | Provide any additional annotations which may be required. This can be used to set the LoadBalancer service type to internal only. ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer |
| unifiedService.enabled | bool | `false` | Create a unified service instead of dedicated services. If enabled, the controller, discovery, GUI, STUN and syslog services will not be created. |
| unifiedService.externalTrafficPolicy | string | `""` | Set the externalTrafficPolicy in the Service to either `Cluster` or `Local` |
| unifiedService.labels | object | `{}` | Labels to add to the unified service |
| unifiedService.loadBalancerIP | string | `""` | Use loadBalancerIP to request a specific static IP, otherwise leave blank |
| unifiedService.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the load-balancer to the specified client IPs. |
| unifiedService.nodePort | int | `nil` | Specify the nodePort value for the LoadBalancer and NodePort service types. ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport |
| unifiedService.type | string | `"ClusterIP"` | Kubernetes service type |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.9.1](https://github.com/norwoodj/helm-docs/releases/v1.9.1)

[ubnt 3]: https://help.ubnt.com/hc/en-us/articles/204976094-UniFi-What-protocol-does-the-controller-use-to-communicate-with-the-UAP-
[ubnt 4]: https://help.ubnt.com/hc/en-us/articles/115015457668-UniFi-Troubleshooting-STUN-Communication-Errors
[unifi]: https://community.ui.com/questions/Controller-how-to-deactivate-http-to-https/c5e247d8-b5b9-4c84-a3bb-28a90fd65668
[affinity]: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity
[Ingress-Nginx Controller]: https://kubernetes.github.io/ingress-nginx/
[Node selector]: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
[Priority Class Name]: https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass
[probe]: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
[Tolerations]: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
[values.yaml]: values.yaml
