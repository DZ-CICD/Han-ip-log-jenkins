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

        // SonarCloud 설정 (credentialsId는 시스템 설정에서 자동 사용되므로 변수만 선언)
        SONAR_CREDENTIALS_ID = 'sonar-token'
    }

    stages {
        // 1. 소스 코드 가져오기
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // 2. SonarCloud 코드 품질 검사 (수정된 부분)
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Jenkins 관리 > Tools에서 설정한 이름 ('sonar-scanner')
                    def scannerHome = tool 'sonar-scanner'
                    
                    // [수정됨] withCredentials와 login 옵션을 제거하여 보안 경고 해결
                    // Jenkins 관리 > System에서 설정한 'sonar-server'가 인증 정보를 자동으로 주입함
                    withSonarQubeEnv('sonar-server') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.organization=dz-cicd \
                        -Dsonar.projectKey=DZ-CICD_Han-ip-log-jenkins \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.branch.name=main
                        """
                        // 위에서 -Dsonar.branch.name=main 을 추가하여 404 에러 방지
                        // -Dsonar.organization=dz-cicd (소문자)로 수정하여 조직 찾기 에러 해결
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
                        
                        // deployment.yaml 파일의 이미지 태그 수정 (jenkins 폴더 안에 있다고 가정)
                        sh "sed -i 's|image: .*|image: ${HARBOR_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}|' jenkins/deployment.yaml"
                        
                        // 변경 확인
                        sh "cat jenkins/deployment.yaml"
                        
                        // Git Push (무한 루프 방지를 위해 [skip ci] 포함)
                        sh "git add jenkins/deployment.yaml"
                        sh "git commit -m 'Update image tag to ${env.BUILD_NUMBER} [skip ci]'"
                        sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/DZ-CICD/Han-ip-log-jenkins.git HEAD:main"
                    }
                }
            }
        }

        // 5. 배포 알림 (ArgoCD 자동 동기화 대기)
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
