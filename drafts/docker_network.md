### External Network Standard Mode
```
docker network create -d bridge --attachable=true -o com.docker.network.bridge.name=proxy0 \
-o com.docker.network.bridge.host_binding_ipv4=0.0.0.0 --subnet 172.18.10.0/24 proxy
```

### External Network Swarm Mode
```
docker network create -d overlay --attachable=true -o com.docker.network.bridge.name=proxy0 proxy
```