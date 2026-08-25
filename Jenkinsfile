pipeline {

    agent {
        node {
            label 'built-in'
            customWorkspace '/home/ubuntu/jenkins-workspace/employee_leave'
        }
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Environment Check') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "       ENVIRONMENT CHECK"
                    echo "=========================================="

                    echo "Current directory:"
                    pwd

                    echo "Java version:"
                    java -version

                    echo "Maven version:"
                    mvn -version

                    echo "Docker version:"
                    docker --version

                    echo "Docker Compose version:"
                    docker-compose version
                '''
            }
        }

        stage('Checkout') {
            steps {
                echo 'Source code is being checked out by Jenkins.'
                sh '''
                    echo "=========================================="
                    echo "       PROJECT FILES"
                    echo "=========================================="
                    ls -la
                    find . -maxdepth 2 -type f | sort
                '''
            }
        }

        stage('Maven Test and Build') {
            steps {
                dir('backend') {
                    sh '''
                        echo "=========================================="
                        echo "       MAVEN TEST AND BUILD"
                        echo "=========================================="

                        mvn clean test package
                    '''
                }
            }
        }

        stage('Verify JAR') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "       VERIFY JAR"
                    echo "=========================================="

                    ls -lh backend/target/

                    test -n "$(find backend/target -name '*.jar' -type f -print -quit)"

                    echo "JAR file created successfully."
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "       BUILD DOCKER IMAGES"
                    echo "=========================================="

                    docker-compose build
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "       DEPLOY APPLICATION"
                    echo "=========================================="

                    docker-compose down --remove-orphans || true

                    docker-compose up -d

                    echo "Waiting for containers to start..."
                    sleep 15

                    echo "Running containers:"
                    docker-compose ps
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "       SMOKE TEST"
                    echo "=========================================="

                    docker-compose ps

                    if docker-compose ps | grep -q "Up"; then
                        echo "Application containers are running."
                    else
                        echo "ERROR: Application containers are not running."
                        docker-compose logs --tail=100
                        exit 1
                    fi
                '''
            }
        }
    }

    post {

        success {
            echo '''
==========================================
       CI/CD PIPELINE SUCCESS
       Application deployed successfully.
==========================================
'''
        }

        failure {
            echo '''
==========================================
       CI/CD PIPELINE FAILED
       Check the logs above.
==========================================
'''
        }

        always {
            sh '''
                echo "Cleaning unused Docker images..."
                docker image prune -f || true
            '''
        }
    }
}
