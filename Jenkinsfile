pipeline {
    agent any

    environment {
        // Harbor 설정
        HARBOR_REGISTRY = '192.168.0.183'
        IMAGE_NAME = 'jenkins/han-ip-log'
        HARBOR_CREDENTIALS_ID = 'harbor-creds'

        // Git 설정
        GIT_CREDENTIALS_ID = 'git-token-id'
        GIT_REPO_URL = 'https://github.com/DZ-CICD/Han-ip-log-jenkins.git'

        // SonarCloud 설정
        SONAR_CREDENTIALS_ID = 'sonar-token'
    }

    stages {
        // 1. 소스 코드 가져오기
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // 2. SonarCloud 코드 품질 검사 (최종 수정됨)
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Jenkins 관리 > Tools에서 설정한 이름 ('sonar-scanner')
                    def scannerHome = tool 'sonar-scanner'

                    // [수정 포인트 1] withCredentials 삭제 (보안 경고 해결)
                    // [수정 포인트 2] withSonarQubeEnv가 토큰을 자동으로 주입해줌
                    withSonarQubeEnv('sonar-server') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.organization=dz-cicd \
                        -Dsonar.projectKey=DZ-CICD_Han-ip-log-jenkins \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=https://sonarcloud.io
                        """
                        // [수정 포인트 3] -Dsonar.branch.name=main 삭제 (첫 분석 충돌 방지)
                        // [수정 포인트 4] -Dsonar.organization=dz-cicd (소문자 유지)
                    }
                }
            }
        }

        // 3. Docker 이미지 빌드 및 Harbor 푸시
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image..."
                    // 이미지 빌드
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

        // 4. Kubernetes 배포 파일(Manifest) 버전 업데이트
        stage('Update Manifest') {
            steps {
                withCredentials([usernamePassword(credentialsId: GIT_CREDENTIALS_ID, passwordVariable: 'GIT_TOKEN', usernameVariable: 'GIT_USER')]) {
                    script {
                        echo "Updating deployment.yaml..."

                        // Git 유저 설정
                        sh "git config user.email 'rlaehgns745@gmail.com'"
                        sh "git config user.name 'kdh5018'"

                        // deployment.yaml 파일의 이미지 태그 수정
                        sh "sed -i 's|image: .*|image: ${HARBOR_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}|' jenkins/deployment.yaml"

                        // 변경 확인
                        sh "cat jenkins/deployment.yaml"

                        // Git Push
                        sh "git add jenkins/deployment.yaml"
                        sh "git commit -m 'Update image tag to ${env.BUILD_NUMBER} [skip ci]'"
                        sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/DZ-CICD/Han-ip-log-jenkins.git HEAD:main"
                    }
                }
            }
        }

        // 5. 배포 알림
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                echo 'ArgoCD will detect the change in Git and sync automatically.'
            }
        }
    }

    post {
        success {
            echo 'Build, Analysis, Push, and Manifest Update Successful!'
        }
        failure {
            echo 'Pipeline Failed.'
        }
    }
}
