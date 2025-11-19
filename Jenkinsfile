pipeline {
    agent any

    environment {
        HARBOR_REGISTRY = '192.168.0.183'
        // IMAGE_NAME 자체에 프로젝트 명을 포함시키는 것이 관리하기 편합니다.
        // 예: '프로젝트명/이미지명' -> 'jenkins/han-ip-log'
        IMAGE_NAME = 'jenkins/han-ip-log' 
        HARBOR_CREDENTIALS_ID = 'harbor-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image..."
                    
                    // [중요 변경] '/library/' 부분을 제거했습니다.
                    // 결과적으로 192.168.0.183/jenkins/han-ip-log:6 형태로 빌드됩니다.
                    def customImage = docker.build("${HARBOR_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}")

                    docker.withRegistry("http://${HARBOR_REGISTRY}", "${HARBOR_CREDENTIALS_ID}") {
                        echo "Pushing Image to Harbor..."
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }

    post {
        success {
            echo 'Build and Push Successful!'
        }
        failure {
            echo 'Build Failed.'
        }
    }
}
