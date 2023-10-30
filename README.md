# Synthetic PoP
Synthetic PoP runs as a set of kubernetes pods in the kubernetes cluster, and use helm chart to deploy. Before installation, please ensure kubernetes and helm are installed on your environment.

For more information about deploying Synthetic PoP, please refer to [Synthetic PoP Deployment](https://www.ibm.com/docs/en/instana-observability/current?topic=monitoring-pop-deployment)

# Support KEDA（https://keda.sh/）

KEDA is a Kubernetes-based Event Driven Autoscaler. If customer want to use KEDA to auto scale the playback engines pods, please ensure that the following prerequisites are met:

1. **KEDA Installed**: Ensure that the KEDA is installed and running in your Kubernetes cluster.

2. **KEDA Enabled in Values.yaml**: By default, KEDA is disabled in the configuration. To enable KEDA, you need to set the `keda.enabled` parameter to `true` and input the `keda.namespace` (the namespace is specified when installing keda) in the values.yaml in the `values.yaml` file.

