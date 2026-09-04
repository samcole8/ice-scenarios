cat <<'EOF' | kubectl apply -f - --kubeconfig /etc/rancher/k3s/k3s.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: microservice-clusterrole
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: microservice-clusterrolebinding
subjects:
  - kind: ServiceAccount
    name: microservice-sa
    namespace: demo
roleRef:
  kind: ClusterRole
  name: microservice-clusterrole
  apiGroup: rbac.authorization.k8s.io
EOF