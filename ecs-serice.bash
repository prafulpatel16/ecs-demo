aws ecs create-service \
  --cluster simple-html-web-app-cluster \
  --service-name simple-html-web-app-service \
  --task-definition simple-html-web-app-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-0eeec273cc27351f3],securityGroups=[sg-02c98c9d512c120de],assignPublicIp=ENABLED}"
