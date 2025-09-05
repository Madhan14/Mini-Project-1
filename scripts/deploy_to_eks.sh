#!/usr/bin/env bash
set -euo pipefail

REGION=${REGION:-ap-south-1}
CLUSTER=${CLUSTER:-brain-eks}

echo "[deploy] Updating kubeconfig for cluster $CLUSTER in $REGION"
aws eks update-kubeconfig --name "$CLUSTER" --region "$REGION"

echo "[deploy] Applying manifests"
kubectl apply -f /opt/brain/app/artifact/k8s/

echo "[deploy] Waiting for rollout"
kubectl rollout status deployment/brain-tasks -n brain --timeout=120s || (
  echo "[deploy] Rollout failed, showing events:"; 
  kubectl get events -n brain --sort-by=.metadata.creationTimestamp | tail -n 50; 
  exit 1
)

echo "[deploy] Service details:"
kubectl get svc brain-tasks-svc -n brain -o wide

DNS=$(kubectl get svc brain-tasks-svc -n brain -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "EXTERNAL URL: http://$DNS"

# Save a small report for pipeline artifacts/logs
mkdir -p /opt/brain/app/deploy-out
echo "$DNS" > /opt/brain/app/deploy-out/external_dns.txt
