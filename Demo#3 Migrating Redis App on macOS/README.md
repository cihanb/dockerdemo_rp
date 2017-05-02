# DEMO
## Step#1 - Run Redis App against Redis Container
Steps to get a running Redis app on Windows ported over to Redis Enterprise. 

### 1.a Run Redis Open Source Container
```
docker run --name redis-oss -d -p 6379:6379 redis
```
### 1.b Run the sample Redis App
```
python3 redis_driver.py -p 6379
```
Matrix should fill your screen!
![Image](https://raw.githubusercontent.com/cihanb/dockerdemo_rp/master/Demo%233%20Migrating%20Redis%20App%20on%20macOS/Media/app_output.jpeg)

## Step#2 - Run the same Redis App against Enterprise Pack Container
### 1.a Create a network
```
docker network create --ip-range 10.0.0.0/16 --subnet=10.0.0.0/16 redis_net
```

### 1.b Run Redis Enterprise Containers
```
docker run -d --cap-add sys_resource --network redis_net --name redis1 -p 8443:8443 -p 9443:9443 -p 12000:12000 redislabs/redis:latest
docker run -d --cap-add sys_resource --network redis_net --name redis2 -p 8444:8443 -p 9444:9443 -p 12001:12000 redislabs/redis:latest
docker run -d --cap-add sys_resource --network redis_net --name redis3 -p 8445:8443 -p 9445:9443 -p 12002:12000 redislabs/redis:latest
```

### 1.b Create cluster
```
docker exec -d --privileged redis1 "/opt/redislabs/bin/rladmin" cluster create name cluster.local username cihan@redislabs.com password redislabs123 flash_enabled
docker exec -d --privileged redis2 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.0.2 flash_enabled
docker exec -d --privileged redis3 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.0.2 flash_enabled
```

### 1.c Create database
```
curl -k -u "cihan@redislabs.com:redislabs123" --request POST --url "https://localhost:9443/v1/bdbs" --header 'content-type: application/json' --data '{"name":"sample-db","type":"redis","memory_size":1073741824,"port":12000}'
```

### 1.d Run the sample Redis App
```
python3 redis_driver.py -p 12000
```

Matrix should fill your screen!
![Image](https://raw.githubusercontent.com/cihanb/dockerdemo_rp/master/Demo%233%20Migrating%20Redis%20App%20on%20macOS/Media/app_output.jpeg)


# Cleanup
docker rm -f redis-oss
docker rm -f redis1
docker rm -f redis2
docker rm -f redis3
docker network remove redis_net
