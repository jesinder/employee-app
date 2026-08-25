// ─────────────────────────────────────────────────────────────────
//  Employee Management System — CI/CD Pipeline
//  Team: Jesinder (DevOps) & Menaka (Java)
//  Stack: Maven → Docker → AWS EC2
// ─────────────────────────────────────────────────────────────────

pipeline {

    agent any

    // ── Environment variables ────────────────────────────────────
    environment {
        APP_NAME          = 'employee-management'
        DOCKER_HUB_USER   = credentials('DOCKER_HUB_USERNAME')   // Jenkins credential
        DOCKER_HUB_PASS   = credentials('DOCKER_HUB_PASSWORD')   // Jenkins credential
        IMAGE_BACKEND     = "${DOCKER_HUB_USER}/emp-backend"
        IMAGE_FRONTEND    = "${DOCKER_HUB_USER}/emp-frontend"
        IMAGE_TAG         = "${env.BUILD_NUMBER}"
        EC2_HOST          = credentials('EC2_HOST')               // e.g. 54.x.x.x
        EC2_USER          = 'ubuntu'
        EC2_KEY           = credentials('EC2_SSH_KEY')            // SSH private key
        JAVA_HOME         = '/usr/lib/jvm/java-17-openjdk-amd64'
    }

    // ── Global options ───────────────────────────────────────────
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
    }

    // ── Pipeline stages ──────────────────────────────────────────
    stages {

        // ── Stage 1: Checkout ────────────────────────────────────
        stage('📥 Checkout') {
            steps {
                echo '=== Checking out source code ==='
                checkout scm
                sh 'git log --oneline -5'
            }
        }

        // ── Stage 2: Build Backend with Maven ────────────────────
        stage('🔨 Maven Build') {
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

        // ── Stage 3: Run Unit Tests ───────────────────────────────
        stage('🧪 Unit Tests') {
            steps {
                echo '=== Running Unit Tests ==='
                dir('backend') {
                    sh 'mvn test -B --no-transfer-progress'
                }
            }
            post {
                always {
                    // Publish JUnit results
                    junit(
                        testResults: 'backend/target/surefire-reports/*.xml',
                        allowEmptyResults: true
                    )
                }
            }
        }

        // ── Stage 4: Build Docker Images ─────────────────────────
        stage('🐳 Docker Build') {
            steps {
                echo '=== Building Docker images ==='
                sh """
                    # Build backend image
                    docker build -t ${IMAGE_BACKEND}:${IMAGE_TAG} \
                                 -t ${IMAGE_BACKEND}:latest \
                                 ./backend

                    # Build frontend image
                    docker build -t ${IMAGE_FRONTEND}:${IMAGE_TAG} \
                                 -t ${IMAGE_FRONTEND}:latest \
                                 ./frontend

                    # List built images
                    docker images | grep emp-
                """
            }
        }

        // ── Stage 5: Push to Docker Hub ───────────────────────────
        stage('📤 Push to Docker Hub') {
            steps {
                echo '=== Pushing images to Docker Hub ==='
                sh """
                    echo \${DOCKER_HUB_PASS} | docker login -u \${DOCKER_HUB_USER} --password-stdin

                    docker push ${IMAGE_BACKEND}:${IMAGE_TAG}
                    docker push ${IMAGE_BACKEND}:latest

                    docker push ${IMAGE_FRONTEND}:${IMAGE_TAG}
                    docker push ${IMAGE_FRONTEND}:latest

                    docker logout
                """
            }
        }

        // ── Stage 6: Deploy to AWS EC2 ────────────────────────────
        stage('🚀 Deploy to EC2') {
            steps {
                echo '=== Deploying to AWS EC2 ==='
                // Write docker-compose to EC2 and restart
                sshagent(credentials: ['EC2_SSH_KEY']) {
                    sh """
                        # Copy docker-compose file to EC2
                        scp -o StrictHostKeyChecking=no \
                            docker-compose.yml \
                            ${EC2_USER}@${EC2_HOST}:/home/${EC2_USER}/employee-management/

                        # Copy .env.example as .env if not exists
                        scp -o StrictHostKeyChecking=no \
                            .env.example \
                            ${EC2_USER}@${EC2_HOST}:/home/${EC2_USER}/employee-management/.env.example

                        # SSH into EC2 and deploy
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            cd /home/${EC2_USER}/employee-management

                            # Pull latest images
                            docker pull ${IMAGE_BACKEND}:${IMAGE_TAG}
                            docker pull ${IMAGE_FRONTEND}:${IMAGE_TAG}

                            # Update IMAGE_TAG in environment
                            export IMAGE_TAG=${IMAGE_TAG}
                            export DOCKER_HUB_USERNAME=${DOCKER_HUB_USER}

                            # Stop existing containers
                            docker-compose down --remove-orphans || true

                            # Start all services
                            IMAGE_TAG=${IMAGE_TAG} docker-compose up -d

                            # Wait for health
                            sleep 30

                            # Show running containers
                            docker ps

                            echo "=== Deployment Complete ==="
                        '
                    """
                }
            }
        }

        // ── Stage 7: Smoke Test ───────────────────────────────────
        stage('✅ Smoke Test') {
            steps {
                echo '=== Running post-deployment smoke test ==='
                sh """
                    sleep 15

                    # Test frontend
                    FRONTEND_STATUS=\$(curl -s -o /dev/null -w "%{http_code}" http://${EC2_HOST}/)
                    echo "Frontend HTTP status: \$FRONTEND_STATUS"

                    # Test backend health endpoint
                    BACKEND_STATUS=\$(curl -s -o /dev/null -w "%{http_code}" http://${EC2_HOST}:8080/api/employees/health)
                    echo "Backend HTTP status: \$BACKEND_STATUS"

                    # Test employees API
                    API_RESPONSE=\$(curl -s http://${EC2_HOST}:8080/api/employees)
                    echo "API response: \$API_RESPONSE"

                    if [ "\$FRONTEND_STATUS" = "200" ] && [ "\$BACKEND_STATUS" = "200" ]; then
                        echo "✅ All smoke tests PASSED!"
                    else
                        echo "❌ Smoke tests FAILED — Frontend: \$FRONTEND_STATUS, Backend: \$BACKEND_STATUS"
                        exit 1
                    fi
                """
            }
        }

    } // end stages

    // ── Post-pipeline actions ────────────────────────────────────
    post {

        success {
            echo """
            ╔══════════════════════════════════════════╗
            ║   ✅ DEPLOYMENT SUCCESSFUL               ║
            ║   Build #${env.BUILD_NUMBER}             ║
            ║   Frontend:  http://\${EC2_HOST}         ║
            ║   Backend:   http://\${EC2_HOST}:8080    ║
            ╚══════════════════════════════════════════╝
            """
        }

        failure {
            echo """
            ╔══════════════════════════════════════════╗
            ║   ❌ PIPELINE FAILED — Build #${env.BUILD_NUMBER}
            ║   Check logs above for details           ║
            ╚══════════════════════════════════════════╝
            """
        }

        always {
            // Clean workspace after build
            cleanWs()

            // Remove dangling Docker images on Jenkins agent
            sh 'docker image prune -f || true'
        }
    }

} // end pipeline
