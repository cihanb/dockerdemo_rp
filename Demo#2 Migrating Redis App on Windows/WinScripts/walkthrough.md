# DEMO
Steps to get a running Redis app on Windows ported over to Redis Enterprise. 

## Step#1 - Run Redis App against Redis Container
### 1.a Run Redis Containers
```
docker run --name redis-oss -d -p 6379:6379 redis
```

### 1.b Run the sample Redis App
```
python3 redis_driver.py -p 6379
```

## Step#2 - Run Redis App against Enterprise Pack Container
### 1.a Run Redis Enterprise Containers 
```
docker run -d --cap-add sys_resource --network redis_net --name redis1 -p 8443:8443 -p 9443:9443 -p 12000:12000 redislabs/redis:latest
```
### 1.b Create cluster

Walk through UI : https://localhost:8443

### 1.c Create database

Make sure DB listens on port 12000

### 1.d Run the sample Redis App
```
python3 redis_driver.py -p 12000
```

Matrix should fill your screen!
![Image](https://raw.githubusercontent.com/cihanb/dockerdemo_rp/master/Demo%232%20Migrating%20Redis%20App%20on%20Windows/WinScripts/app_output.jpeg)

# Cleanup
docker rm -f redis-oss
docker rm -f redis1
docker network remove redis_net
