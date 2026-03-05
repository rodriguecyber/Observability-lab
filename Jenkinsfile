pipeline {
    agent any
    parameters {
       
        choice(
            name: 'DEPLOY_SSH',
            choices: ['true', 'false'],
            description: 'Deploy to EC2 via SSH: pull latest code/images and run docker compose.'
        )
        string(
            name: 'EC2_PUBLIC_IP',
            defaultValue: '51.21.150.87',
            description: 'EC2 instance public IP for SSH deploy (required when DEPLOY_SSH=true). Get from Terraform output or AWS Console.'
        )
    }
    environment {
        AWS_REGION = 'eu-north-1'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            when { expression { return params.DEPLOY_INFRA != 'true' } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PSWD', usernameVariable: 'UNAME')]) {
                    sh 'docker build -t $UNAME/observability-app:latest .'
                    sh 'echo $PSWD | docker login -u $UNAME --password-stdin'
                    sh 'docker push $UNAME/observability-app:latest'
                }
            }
        }

        

        stage('Deploy to EC2 (SSH)') {
            when {
                allOf {
                    expression { return params.DEPLOY_SSH == 'true' }
                    expression { return params.EC2_PUBLIC_IP?.trim() }
                }
            }
            steps {
                sshagent(['EC2-SSH-KEY']) {
                    sh '''#!/bin/bash
                        set -e
                        EC2_IP="''' + params.EC2_PUBLIC_IP.trim() + '''"
                        ssh -o StrictHostKeyChecking=no ubuntu@$EC2_IP "cd /opt/observability-app && git pull && docker compose pull && docker compose up -d --build"
                    '''
                }
            }
            post {
                success {
                    echo "Deployed to EC2 (${params.EC2_PUBLIC_IP}). Grafana: http://${params.EC2_PUBLIC_IP}:3000 Prometheus: http://${params.EC2_PUBLIC_IP}:9090"
                }
                failure {
                    echo 'SSH deploy failed. Check EC2_PUBLIC_IP and that EC2-SSH-KEY is the key used for the instance.'
                }
            }
        }
    }
}
