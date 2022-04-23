# Deploy - Local
### Deploy Prerequisites
- `docker`, `docker-compose`
- docker login with aws credentials

### Deploy
- `docker-compose up`
- pull latest image from docker hub : uncomment `pull_policy: always` in `docker-compose.yaml`
### Destroy
- `docker-compose down`

### Install docker-desktop
- [Link](https://docs.docker.com/desktop/)

### docker login with aws credentials
- AWS Access Token 필요
- `aws ecr get-login-password | docker login --username AWS --password-stdin 075730933478.dkr.ecr.ap-northeast-2.amazonaws.com`

### api-generator
- `docker-compose up` 할 시 `./dist` 폴더에 swagger spec에 맞는 typescript stub 생성
  
### TODO
- 디비 readiness 후 스프링 시작 : 스프링 서버에서 reconnect 하다 fail ( 현재는 수동으로 재시작 )
![diagram](./local_infra.drawio.png)
