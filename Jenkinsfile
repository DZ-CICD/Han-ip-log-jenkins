pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                // GitHub 코드 가져오기
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                // 도커 이미지 빌드 (Docker가 설치된 환경이어야 함)
                sh 'docker build -t my-app:latest .'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                // 테스트 명령어 추가 (예: npm test)
            }
        }
    }
}
