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
            defaultValue: '13.61.5.224',
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
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PSWD', usernameVariable: 'UNAME')]) {
                    sh 'docker build -t $UNAME/observability-app:latest .'
                    sh 'echo $PSWD | docker login -u $UNAME --password-stdin'
                    sh 'docker push $UNAME/observability-app:latest'
                }
            }
        }

        

        stage('Deploy to EC2 (SSH)') {
            when { expression { return params.DEPLOY_SSH == 'true' } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PSWD', usernameVariable: 'UNAME')]) {
                    sshagent(['EC2-SSH-KEY']) {
                        def ip = params.EC2_PUBLIC_IP.trim()
                        def image = env.UNAME + '/observability-app:latest'
                        echo "Deploying to EC2 (${ip}): copy compose + config, pull images, run containers"
                        sh """
                            set -e
                            ssh -o StrictHostKeyChecking=no ubuntu@${ip} 'mkdir -p /opt/observability-app'
                            scp -o StrictHostKeyChecking=no docker-compose.deploy.yml ubuntu@${ip}:/opt/observability-app/docker-compose.yml
                            scp -o StrictHostKeyChecking=no -r monitoring ubuntu@${ip}:/opt/observability-app/
                            ssh -o StrictHostKeyChecking=no ubuntu@${ip} 'echo DOCKER_IMAGE_APP=${image} > /opt/observability-app/.env'
                            ssh -o StrictHostKeyChecking=no ubuntu@${ip} 'cd /opt/observability-app && docker compose pull && docker compose up -d'
                        """
                    }
                }
            }
            post {
                success {
                    echo "Deployed to EC2 (${params.EC2_PUBLIC_IP}). Grafana: http://${params.EC2_PUBLIC_IP}:3000 Prometheus: http://${params.EC2_PUBLIC_IP}:9090"
                }
                failure {
                    echo 'SSH deploy failed. Check EC2_PUBLIC_IP and EC2-SSH-KEY.'
                }
            }
        }
    }
}
