# Kubernetes Honeypot Monitoring Stack

A complete observability stack for monitoring SSH honeypot activity using Fluentd, OpenSearch, and Grafana.

## Components
- **Fluentd**: Log collection from honeypot pods
- **OpenSearch**: Log storage and indexing
- **Grafana**: Metrics visualization
- **SSH Honeypot**: Docker-based SSH server
- **Hydra**: Traffic generation tool

## Prerequisites
- Docker Desktop with Kubernetes enabled
- `kubectl` configured
- 8GB+ RAM allocated to Docker
- 4+ CPU cores allocated to Docker

## Quick Start

### 1. Clone Repository
git clone https://github.com/https://github.com/OnsKoukiPro/Honeypot-CK8s.git
cd k8s-docker-desktop

### 2. Deploy Components
**Create monitoring namespace**
kubectl apply -f monitoring-ns.yaml

**Deploy OpenSearch**
kubectl apply -f opensearch.yaml

**Set up Fluentd**
kubectl apply -f fluentd-rbac.yaml
kubectl apply -f fluentd-configmap.yaml
kubectl apply -f fluentd-daemonset.yaml

**Install Grafana**
kubectl apply -f grafana-datasource.yaml
kubectl apply -f grafana.yaml

**Deploy Honeypot**
kubectl apply -f honeypot-deployment.yaml

**Generate traffic (optional)**
kubectl apply -f hydra-job.yaml //not applicable

### 3. Verification

**Check Pod Statuses**
kubectl get pods -n monitoring -w

**Access Services**
**OpenSearch**
kubectl port-forward svc/opensearch -n monitoring 9200:9200

**Grafana**
kubectl port-forward svc/grafana -n monitoring 3000:3000
//creds are admin admin

**Check OpenSearch-Fluentd connection in**
http://localhost:9200/_cat/indices?v

**Activate Honeypot**
kubectl port-forward svc/ssh-honeypot 2222:22
**Check Pod Statuses**

### 3. Vcluster Setup
# Download vCluster CLI
curl -s -L "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" -o vcluster

# Make it executable
chmod +x vcluster

# Move to a system path (requires sudo)
sudo mv vcluster /usr/local/bin

# Verify installation
vcluster --version

# Install vluster with Helm
helm repo add loft https://charts.loft.sh
helm repo update
helm upgrade --install honeypot-cluster loft/vcluster \
  --version 0.15.0 \
  --namespace honeynet-vcluster \
  -f vcluster-values.yaml

### Common Issues
**OpenSearch Pod Pending**

kubectl describe pod/opensearch-0 -n monitoring
# Check for resource constraints in Docker Desktop settings

**Fluentd Permission Errors**
```bash
kubectl logs -n monitoring -l app=fluentd
# Reapply fluentd-rbac.yaml if permissions mismatch

**Grafana Plugin Errors**
```bash
kubectl exec -n monitoring deployment/grafana -- \
  cat /var/lib/grafana/plugins/grafana-opensearch-datasource/plugin.json
# Verify version matches 2.7.0

### Cleanup
```bash
kubectl delete -f ./
kubectl delete ns monitoring
