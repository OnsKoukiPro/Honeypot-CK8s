<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/banner-dark.svg?v=r1"><img src="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/banner-light.svg?v=r1" alt="Honeypot-CK8s: a honeynet inside a vCluster, with every attacker interaction shipped to OpenSearch" width="100%"></picture>

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/stats-dark.svg?v=r1"><img src="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/stats-light.svg?v=r1" alt="3 honeypots, 10 protocols exposed, 4 attack tools, 1 vCluster sandbox" width="100%"></picture>

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/s1-dark.svg?v=r1"><img src="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/s1-light.svg?v=r1" alt="01 / Attack path: bait, catch, and watch it live" width="100%"></picture>

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/flow-dark.svg?v=r1"><img src="https://raw.githubusercontent.com/OnsKoukiPro/Honeypot-CK8s/main/.github/assets/flow-light.svg?v=r1" alt="Attacker job hits Cowrie, Dionaea and Conpot inside a vCluster; Fluentd ships container logs to OpenSearch, viewed in OpenSearch Dashboards and Grafana" width="100%"></picture>

Three honeypots run inside an isolated **vCluster**. A Fluentd DaemonSet tails their container logs, OpenSearch ingest pipelines parse logins and scans into fields, and dashboards show the attacks as they happen. A custom attacker image replays SSH/FTP/MySQL brute force, Modbus and SNMP probing and HTTP scans, so the whole chain can be tested end to end.

<details>
<summary><b>Components</b></summary>

| Component | What it does | Manifests |
|---|---|---|
| vCluster | isolates the honeypots from the host cluster's control plane | `vcluster-honeypot/vcluster-values.yaml`, `namespace.yaml` |
| Cowrie | SSH/Telnet honeypot (NodePort) | `vcluster-honeypot/cowrie-deployment.yaml` |
| Dionaea | FTP, SMB, RPC, MySQL, HTTP honeypot | `vcluster-honeypot/dionea-deployment.yaml` |
| Conpot | ICS/SCADA honeypot: Modbus, S7comm, SNMP, EtherNet/IP | `vcluster-honeypot/conpot-deployment.yaml` |
| Fluentd | DaemonSet with Kubernetes metadata enrichment, ships to OpenSearch | `fluentd-*.yaml` |
| OpenSearch + Dashboards | storage, search, dashboards | `opensearch*.yaml`, `Dashboards/`, `Panels/` |
| Ingest pipelines | parse Cowrie login attempts and Nikto scans into fields | `Pipelines/` |
| Grafana | alternative dashboards via the OpenSearch datasource | `grafana*.yaml` |
| Attacker | Debian image with hydra, nikto, mbpoll, snmpwalk | `Attacks/`, `multi-attack-job.yaml`, `hydra-job.yaml` |

Original design diagram: [`arch.png`](arch.png)

</details>

<details>
<summary><b>Run it</b></summary>

Prerequisites: a Kubernetes cluster (Docker Desktop or kubeadm), `kubectl`, the [vCluster CLI](https://www.vcluster.com/docs/get-started), Docker.

```bash
# 1. monitoring stack
kubectl apply -f monitoring-ns.yaml
kubectl apply -f opensearch.yaml -f opensearch-service.yaml -f opensearch-dashboards.yaml
kubectl apply -f fluentd-rbac.yaml -f fluentd-configmap.yaml -f fluentd-daemonset.yaml
kubectl apply -f grafana.yaml -f grafana-datasource.yaml        # optional

# 2. honeynet inside a vCluster
vcluster create honeypot-cluster --namespace honeynet-vcluster -f vcluster-honeypot/vcluster-values.yaml
kubectl apply -f vcluster-honeypot/cowrie-deployment.yaml \
              -f vcluster-honeypot/conpot-deployment.yaml \
              -f vcluster-honeypot/dionea-deployment.yaml
vcluster disconnect

# 3. generate attacks
docker build -t honeypot-attacker:latest Attacks/
kubectl create configmap attack-passwords --from-file=Attacks/passwords.txt
kubectl apply -f multi-attack-job.yaml                          # set TARGET_IP in the manifest
```

Load the ingest pipelines from `Pipelines/` (OpenSearch Dev Tools), import `Dashboards/Dashboard.json`, then:

```bash
kubectl port-forward svc/opensearch-dashboards -n monitoring 5601:5601   # http://localhost:5601
```

| Symptom | Fix |
|---|---|
| `opensearch-0` Pending | `kubectl describe pod/opensearch-0 -n monitoring`. Usually memory: raise the Docker Desktop limits. |
| No logs in OpenSearch | `kubectl logs -n monitoring -l app=fluentd`. Reapply `fluentd-rbac.yaml`. |
| Grafana datasource error | use `grafana-opensearch-datasource` plugin 2.7.0 |

Cleanup: `vcluster delete honeypot-cluster --namespace honeynet-vcluster && kubectl delete ns monitoring`

</details>

Ons Kouki · Ahmed Houcine. For research and education only: run the attacker job only against infrastructure you own.
