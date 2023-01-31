pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: helm-cli
            image: alpine/helm
            command:
            - cat
            tty: true
          - name: docker
            image: docker:latest
            command:
            - cat
            tty: true
            volumeMounts:
             - mountPath: /var/run/docker.sock
               name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
        '''
    }
  }
  stages {
    stage('Clone') {
      steps {
        container('docker') {
          git branch: 'main', changelog: false, poll: false, url: 'https://github.com/Nb3l77eo/diploma-app.git'
        }
      }
    }
    stage('Login-Docker') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'dockerKey', usernameVariable: 'dockerUser')]) {
            sh 'docker login -u $dockerUser -p $dockerKey'
          }
        }
      }
    }
    stage('Build-Docker-Image') {
      steps {
        container('docker') {
          script {
            if (env.TAG_NAME) {
              sh "docker build -t nb3l77eo/diploma-app:${env.TAG_NAME} ."
            } else {
              sh 'docker build -t nb3l77eo/diploma-app:latest .'
            }
          }
        }
      }
    }
    stage('Push-Docker-Image') {
      steps {
        container('docker') {
          script {
            if (env.TAG_NAME) {
              sh "docker push nb3l77eo/diploma-app:${env.TAG_NAME}"
            } else {
              sh 'docker push nb3l77eo/diploma-app:latest'
            }
          }
        }
      }
    }
    stage('Deploy to env') {
      steps {
        script {
          if (env.TAG_NAME) {
            echo "triggered by the TAG:"
            echo env.TAG_NAME
            container('helm-cli') {
              sh "echo start deployment by tag - ${env.TAG_NAME} -"
              sh "./helm/replaceVer.sh ${env.TAG_NAME}"
              sh "helm upgrade diploma helm/ --install --namespace default"
            }
          } else {
            echo "No deploy"
          }
        }
      }
    }
  }
}