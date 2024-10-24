pipeline {
    agent any

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
    }

    environment {
        AWS_ACCOUNT_ID = '739313151559'
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'simple-html-web-app'
        ECR_REPO_URI = '739313151559.dkr.ecr.us-east-1.amazonaws.com/simple-html-web-app'
        REGISTRY_CREDENTIAL = 'aws-credentials-id' // Ensure this matches the credentials ID in Jenkins
        IMAGE_TAG = "latest-${env.BUILD_NUMBER}" // Unique tag for each build
        ECS_CLUSTER = 'simple-html-web-app-cluster'
        ECS_SERVICE = 'ecs-demo-srv'
        TASK_DEFINITION_FAMILY = 'ecs-task-def'
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

        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Build and tag Docker image with specified tag
                    sh "docker build -t ${ECR_REPO_URI}:${params.IMAGE_TAG} ."
                    
                    // Login to AWS ECR
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URI}
                        """
                    }
                    
                    // Push Docker image to ECR
                    sh "docker push ${ECR_REPO_URI}:${params.IMAGE_TAG}"
                }
            }
        }

        stage('Update ECS Task Definition') {
            steps {
                script {
                    // Load and update task definition JSON
                    def taskDefinition = readFile 'taskdef.json'
                    taskDefinition = taskDefinition.replace("REPLACE_WITH_IMAGE_TAG", "${ECR_REPO_URI}:${params.IMAGE_TAG}")
                    
                    // Write updated task definition to file
                    writeFile file: 'taskdef.json', text: taskDefinition
                    
                    // Register updated task definition
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh "aws ecs register-task-definition --cli-input-json file://taskdef.json"
                    }
                }
            }
        }

        stage('Deploy ECS Service') {
            steps {
                script {
                    // Update ECS service with new task definition revision
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${REGISTRY_CREDENTIAL}"]]) {
                        sh "aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${TASK_DEFINITION_FAMILY}"
                    }
                }
            }
        }
    }
}
