pipeline {
    agent any

    environment {
        // Harbor 레지스트리 주소 및 이미지 이름 설정
        HARBOR_REGISTRY = '192.168.0.183'
        IMAGE_NAME = 'han-ip-log'
        // 젠킨스에 등록한 Credential ID
        HARBOR_CREDENTIALS_ID = 'harbor-creds' 
    }

    stages {
        stage('Checkout') {
            steps {
                // 깃허브 코드 가져오기
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // 도커 이미지 빌드 (태그는 빌드 번호 사용)
                    // 예: 192.168.0.183/library/han-ip-log:15
                    echo "Building Docker Image..."
                    def customImage = docker.build("${HARBOR_REGISTRY}/library/${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    
                    // Harbor 로그인 및 푸시
                    docker.withRegistry("http://${HARBOR_REGISTRY}", "${HARBOR_CREDENTIALS_ID}") {
                        echo "Pushing Image to Harbor..."
                        customImage.push()
                        customImage.push('latest') // latest 태그도 함께 푸시
                    }
                }
            }
        }
        
        // (선택) 기존 컨테이너 제거 및 새 컨테이너 실행 (배포 단계)
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // 여기에 kubectl 명령어나 docker run 명령어를 추가할 수 있습니다.
            }
        }
    }
    
    // 빌드 후 처리 (성공/실패 알림 등)
    post {
        success {
            echo 'Build and Push Successful!'
        }
        failure {
            echo 'Build Failed.'
        }
    }
}
