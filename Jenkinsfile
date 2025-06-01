pipeline {
	agent any

    tools {
		jdk 'AdoptOpenJDK-17' /
        maven 'Maven-3.9.6'
    }
    environment {

        APP_NAME = 'demo'
        DOCKER_IMAGE_NAME = "${APP_NAME}:${env.BUILD_ID}"

        K8S_DEPLOYMENT_NAME = 'demo'
        K8S_SERVICE_NAME = 'demo-service'
    }
    stages {
		stage('Checkout') {
			steps {

                git url: 'https://github.com/VadimDovbiys/my-spring-jenkins-ci', branch: 'main'
            }
        }
        stage('Build') {
			steps {
				sh './mvnw clean compile'
            }
        }
        stage('Test') {
			steps {
				sh './mvnw test'
            }
            post {
				always {
					junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Package') {
			steps {
				sh './mvnw package -DskipTests'
            }
        }
        stage('Archive Artifacts') {
			steps {
				archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
        // НОВІ ЕТАПИ ДЛЯ CD
        stage('Build Docker Image') {
			steps {
				script {
					// Збірка Docker-образу. Jenkins агент повинен мати доступ до Docker.
                    sh "docker build -t ${APP_NAME}:${env.BUILD_ID} ."
                    echo "Docker image ${APP_NAME}:${env.BUILD_ID} built."
                }
            }
        }
        stage('Deploy to Minikube') {
			steps {
				script {

                    sh "sed -i 's|image: ${APP_NAME}:.*|image: ${APP_NAME}:${env.BUILD_ID}|g' k8s/deployment.yaml"


                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'

                    echo "Waiting for deployment rollout to complete..."
                    timeout(time: 5, unit: 'MINUTES') {

                        sh "kubectl rollout status deployment/${K8S_DEPLOYMENT_NAME} --watch=true"
                    }
                    echo "Application deployed to Minikube."
                }
            }
        }
    }
    post {
		success {
			echo 'Pipeline successfully completed! Application deployed to Minikube.'
            echo "To access, run in your terminal: minikube service ${K8S_SERVICE_NAME} --url"
        }
        failure {
			echo 'Pipeline failed.'
        }

        always {
			deleteDir()
        }
    }
}