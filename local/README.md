# Deploy - Local
### Deploy Prerequisites
- `docker`, `docker-compose`
- docker login with aws credentials

### Deploy
- `docker-compose up`

### Destroy
- `docker-compose down`

### Install docker-desktop
- [Link](https://docs.docker.com/desktop/)

### docker login with aws credentials
- AWS Access Token 필요
- `aws ecr get-login-password | docker login --username AWS --password-stdin 075730933478.dkr.ecr.ap-northeast-2.amazonaws.com`

![diagram](./local_infra.drawio.png)
