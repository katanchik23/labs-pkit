#!groovy

pipeline {

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  name: image-builder
  labels:
    robot: builder
spec:
  serviceAccount: jenkins-agent
  containers:
  - name: jnlp
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.18.0-debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/
        readOnly: true
  - name: kubectl
    image: bitnami/kubectl
    tty: true
    command:
    - cat
    securityContext:
      runAsUser: 1000
  - name: golang
    image: golang:1.21.3
    tty: true
    command:
    - cat
  volumes:
    - name: docker-config
      secret:
        secretName: credentials
        optional: false
"""
        }
    }

    environment {
        // Поміняйте APP_NAME на ваше імʼя та прізвище.
        // Поміняйте DOCKER_IMAGE_NAME по формату ваше імʼя аккаунту в Docker та імʼя образу
        APP_NAME = 'Maria_Povoroznik'
        DOCKER_IMAGE_NAME = 'katanchik/lab'
    }

    stages {
        stage('Clone Repository') {
            steps {
                container(name: 'jnlp', shell: '/bin/bash') {
                    echo 'Pulling new changes'
                    // Крок клонування репозиторію
                    git(
                        url: 'https://github.com/katanchik23/k8s-simple-task',
                        branch: "main",
                    )
                }
            }
        }
        stage('Compile') {
            steps {
                container(name: 'golang', shell: '/bin/bash') {
                    // Компіляція проекту на мові Go. Всі ці флаги необхідні для запуску на пустій файловій системі образу scratch :)
                    sh "CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GOFLAGS=-buildvcs=false go build -a -ldflags '-w -s -extldflags \"-static\"' -o ${APP_NAME} ."
                }
            }
        }

        stage('Unit Testing') {
            steps {
                container(name: 'golang', shell: '/bin/bash') {
                    echo 'Testing the application'
                    // Виконання юніт-тестів.
                    sh 'go test'
                }
            }
        }

        stage('Build image') {
            // Не потрібно змінювати. Цей код працюватиме, якщо у вас правильний Dockerfile.
            environment {
                PATH = "/busybox:/kaniko:$PATH"
            }
            steps {
                container(name: 'kaniko', shell: '/busybox/sh') {
                    sh '''#!/busybox/sh
                    /kaniko/executor --dockerfile="$(pwd)/Dockerfile" --context="dir:///$(pwd)" --build-arg "APP_NAME=${APP_NAME}" --destination ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                container(name: 'kubectl', shell: '/bin/bash') {
                    echo 'Deploying to Kubernetes'
                    sh "sed -Ei 's#image: lab#image: ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}#' ./k8s/deployment.yaml && kubectl apply -f k8s/"
                    archiveArtifacts artifacts: "k8s/deployment.yaml", onlyIfSuccessful: true
                }
            }
        }
        stage('Test deployment') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
metadata:
  name: tester
  labels:
    robot: tester
spec:
  serviceAccount: jenkins-agent
  containers:
  - name: jnlp
  - name: ubuntu
    image: ubuntu:22.04
    tty: true
    command:
    - cat
"""
                }
            }
            steps {
                    echo 'Testing the deployment with curl'
                    sh 'curl http://labfive:80'      
            }
        }
    }
}
