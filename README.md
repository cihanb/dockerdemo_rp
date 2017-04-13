# Simple Automated Deployment for Redis Enterprise Pack (Redis<sup>e</sup> Pack) on Docker 

Simple automated cluster deployment for a Redis Enterprise Pack (Redis<sup>e</sup> Pack) deployment on Docker. Ideal for build up and teardown of test environments or functional tests. Works with Redis<sup>e</sup> Pack v4.4 or later. 

## Getting Started
- Modify ```settings.sh``` to change default cluster settings
  - FQDN (full qualified domain name) ```rp_fqdn```, 
  - Cluster admin account and password ```rp_admin_account_name``` and ```rp_admin_account_password```
- Run ```initialize.sh``` to set up a cluster
- Create a Redis database by visiting ```https://locahost:8443``` 
- Connect to your database using ```redis-cli``` 
```
docker  exec -it rp1 bash
```
```
sudo /opt/redislabs/bin/redis-cli -p 12000
127.0.0.1:16653> set key1 123
OK
127.0.0.1:16653> get key1
“123”
```