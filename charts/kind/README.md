# Using K8s to deploy KeyHarbour

## With Kind (for local test)

Create cluster
```
kind create cluster --name keyharbour-cluster --config kind-config.yml
```

Load secret engine
```
kubectl apply -f keyharbour-secret.yml
```

Load and start cluster
```
kubectl apply -f keyharbour.yml
```

Activate port forwarding
```
kubectl port-forward service/web 3000:3000
```