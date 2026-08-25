pipeline {

    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-21-openjdk-amd64'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Checking out source code ==='
                checkout scm
                sh 'git log --oneline -5'
            }
        }

        stage('Maven Build') {
            steps {
                echo '=== Building Backend with Maven ==='

                dir('backend') {
                    sh '''
                        mvn clean package -DskipTests -B \
                            --no-transfer-progress \
                            -Dmaven.compiler.source=17 \
                            -Dmaven.compiler.target=17
                    '''

                    sh 'ls -lh target/*.jar'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                echo '=== Running Unit Tests ==='

                dir('backend') {
                    sh 'mvn test -B --no-transfer-progress'
                }
            }

            post {
                always {
                    junit(
                        testResults: 'backend/target/surefire-reports/*.xml',
                        allowEmptyResults: true
                    )
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo '=== Building Docker Images ==='

                sh '''
                    docker build -t emp-backend:${IMAGE_TAG} ./backend
                    docker build -t emp-frontend:${IMAGE_TAG} ./frontend

                    docker tag emp-backend:${IMAGE_TAG} emp-backend:latest
                    docker tag emp-frontend:${IMAGE_TAG} emp-frontend:latest

                    docker images | grep emp-
                '''
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                echo '=== Deploying 3-Tier Application ==='

                sh '''
                    IMAGE_TAG=${IMAGE_TAG} docker-compose down --remove-orphans || true

                    IMAGE_TAG=${IMAGE_TAG} docker-compose up -d --build

                    echo "=== Running Containers ==="
                    docker ps
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                echo '=== Testing Application ==='

                sh '''
                    sleep 30

                    echo "Testing Frontend..."
                    curl -f http://localhost/ || exit 1

                    echo "Testing Backend..."
                    curl -f http://localhost:8080/api/employees/health || exit 1

                    echo "=== Smoke Test Passed ==="
                '''
            }
        }
    }

    post {

        success {
            echo """
            ==========================================
              CI/CD PIPELINE SUCCESSFUL
              Build #${BUILD_NUMBER}

              Frontend: http://EC2-PUBLIC-IP
              Backend:  http://EC2-PUBLIC-IP:8080
            ==========================================
            """
        }

        failure {
            echo """
            ==========================================
              CI/CD PIPELINE FAILED
              Build #${BUILD_NUMBER}
              Check the logs above.
            ==========================================
            """
        }

        always {
            sh 'docker image prune -f || true'
        }
    }
}
