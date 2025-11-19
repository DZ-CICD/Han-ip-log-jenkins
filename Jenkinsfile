pipeline {
    agent any

    environment {
        HARBOR_REGISTRY = '192.168.0.183'
        IMAGE_NAME = 'jenkins/han-ip-log'
        HARBOR_CREDENTIALS_ID = 'harbor-creds'
        
        // [필수] Jenkins에 등록한 깃허브 토큰 ID (ID: git-token-id 로 만드셔야 합니다)
        GIT_CREDENTIALS_ID = 'git-token-id' 
        
        // [필수] 본인의 깃허브 리포지토리 주소 (.git 포함)
        GIT_REPO_URL = 'https://github.com/DZ-CICD/Han-ip-log-jenkins.git'
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
                    
                    // 도커 이미지 빌드
                    def customImage = docker.build("${HARBOR_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}")

                    // Harbor 로그인 및 푸시
                    docker.withRegistry("http://${HARBOR_REGISTRY}", "${HARBOR_CREDENTIALS_ID}") {
                        echo "Pushing Image to Harbor..."
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }

        // ▼▼▼▼▼ [추가된 단계: 깃허브 Manifest 파일 수정 및 Push] ▼▼▼▼▼
        stage('Update Manifest') {
            steps {
                // 깃허브 인증 정보를 변수로 불러옵니다.
                withCredentials([usernamePassword(credentialsId: GIT_CREDENTIALS_ID, passwordVariable: 'GIT_TOKEN', usernameVariable: 'GIT_USER')]) {
                    script {
                        echo "Updating deployment.yaml..."
                        
                        // 1. 깃허브 커밋을 위한 유저 정보 설정 (본인 이메일/아이디로 수정 가능)
                        sh "git config user.email 'rlaehgns745@gmail.com'"
                        sh "git config user.name 'kdh5018'"
                        
                        // 2. sed 명령어로 deployment.yaml 안의 image 태그 숫자 변경
                        // deployment.yaml 파일이 'jenkins' 폴더 안에 있다고 가정했습니다.
                        sh "sed -i 's|image: .*|image: ${HARBOR_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}|' jenkins/deployment.yaml"
                        
                        // 3. 잘 바뀌었는지 로그로 확인
                        sh "cat jenkins/deployment.yaml"
                        
                        // 4. 변경 사항을 깃허브에 Push
                        // [skip ci] 메시지는 필수입니다 (무한 빌드 루프 방지)
                        sh "git add jenkins/deployment.yaml"
                        sh "git commit -m 'Update image tag to ${env.BUILD_NUMBER} [skip ci]'"
                        
                        // 토큰을 사용하여 인증 후 Push
                        sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/DZ-CICD/Han-ip-log-jenkins.git HEAD:main"
                    }
                }
            }
        }
        // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                echo 'ArgoCD will detect the change in Git and sync automatically.'
            }
        }
    }

    post {
        success {
            echo 'Build, Push, and Manifest Update Successful!'
        }
        failure {
            echo 'Pipeline Failed.'
        }
    }
}
