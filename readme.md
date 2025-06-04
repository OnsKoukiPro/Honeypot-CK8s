# Kubernetes Honeynet Monitoring Stack

A complete observability stack for monitoring honeynet activity in virtual cluster (vCluster) using Fluentd, OpenSearch, and custom multi-vector attacker image.

## Components
- **Fluentd**: Log collection from honeypot pods deployed in vCluster
- **OpenSearch**: Log storage, indexing and visualisation
- **vCluster**: Docker-based SSH server
- **honeypot attacker**: Custom Docker-based multi-protocol attacker image

## Quick Start

### 1. Clone Repository
git clone https://github.com/https://github.com/OnsKoukiPro/Honeypot-CK8s.git
cd k8s-docker-desktop

### 2. Deploy Components
**Create monitoring namespace**
kubectl apply -f monitoring-ns.yaml

**Deploy OpenSearch**
kubectl apply -f opensearch.yaml
kubectl apply -f opensearch-service.yaml

**Deploy OpenSearch Dashboards**
kubectl apply -f opensearch-dashboards.yaml

**Set up Fluentd**
kubectl apply -f fluentd-rbac.yaml
kubectl apply -f fluentd-configmap.yaml
kubectl apply -f fluentd-daemonset.yaml

### 3. Verification

**Check Pod Statuses**
kubectl get pods -n monitoring -w

**Access Services**
**OpenSearch**
kubectl port-forward --address 0.0.0.0 svc/opensearch -n monitoring 9200:9200

**OpenSearch-Dashboard**
kubectl port-forward --address 0.0.0.0 svc/opensearch-dashboards -n monitoring 5601:5601
http://houcine.webhop.me:5601/

**Check OpenSearch-Fluentd connection in**
http://houcine.webhop.me:9200/_cat/indices?v


### 3. Vcluster Setup
# Download vCluster CLI
curl -s -L "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" -o vcluster

# Make it executable
chmod +x vcluster

# Move to a system path (requires sudo)
sudo mv vcluster /usr/local/bin

# Verify installation
vcluster --version

# Create namespace honeynet-vcluster and create vcluster using vcluster cli
vcluster create honeypot-cluster --namespace honeynet-vcluster

# Deploy Cowrie, Conpot, Dionaea Honeypot in vCluster
kubectl apply -f cowrie-deployment.yaml
kubectl apply -f conpot-deployment.yaml
kubectl apply -f dionea-deployment.yaml


# to switch back from vcluster context to default
kubectl config use-context kubernetes-admin@kubernetes

# to switch from default to vcluster context
kubectl config use-context vcluster_honeypot-cluster_honeynet-vcluster_kubernetes-admin@kubernetes

### 4. Attack Generation
# Build custom attacker image
docker build -t honeypot-attacker:latest .
# Create configmap for password file
 kubectl create configmap attack-passwords --from-file=passwords.txt

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
