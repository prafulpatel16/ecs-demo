pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '739313151559'
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'simple-html-web-app'
        ECR_REPO_URI = '739313151559.dkr.ecr.us-east-1.amazonaws.com/simple-html-web-app'
        REGISTRY_CREDENTIAL = 'aws-credentials-id' // Ensure this matches the credentials ID in Jenkins
        IMAGE_TAG = 'latest'
        ECS_CLUSTER = 'simple-html-web-app-cluster'
        ECS_SERVICE = 'ecs-demo-srv'
    }
    
    stages {
        stage('Test Credentials') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh 'aws sts get-caller-identity'
                    }
                }
            }
        }
        
        stage('Login to AWS ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh """aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}"""
                    }
                }
            }
        }
        
        stage('Clone Git Repository') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/prafulpatel16/ecs-demo.git']]
                ])
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_REPO}:${IMAGE_TAG}")
                }
            }
        }
        
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh """docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO_URI}:${IMAGE_TAG}"""
                        sh """docker push ${ECR_REPO_URI}:${IMAGE_TAG}"""
                    }
                }
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh """aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment"""
                    }
                }
            }
        }
    }
}
