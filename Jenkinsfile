pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '739313151559.dkr.ecr.us-east-1.amazonaws.com/simple-html-web-app'
        ECS_CLUSTER = 'simple-html-web-app-cluster'
        ECS_SERVICE = 'ecs-demo-srv'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-repo/simple-html-web-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPO}:${env.BUILD_ID}")
                }
            }
        }
        stage('Login to Amazon ECR') {
            steps {
                script {
                    withAWS(credentials: 'aws-credentials-id', region: "${AWS_REGION}") {
                        sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.image("${ECR_REPO}:${env.BUILD_ID}").push()
                }
            }
        }
        stage('Deploy to ECS') {
            steps {
                script {
                    withAWS(credentials: 'aws-credentials-id', region: "${AWS_REGION}") {
                        sh """
                        aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment
                        """
                    }
                }
            }
        }
    }
}
