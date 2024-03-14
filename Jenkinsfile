pipeline {
    agent {
        dockerfile true
    }
    stages {
        stage('check out dependent repos') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'master']], extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: '../platform_widgets']], userRemoteConfigs: [[credentialsId: '0fb2d178-8ce7-4e0d-8612-54a7b0cb7195', url: 'https://github.com/Rocky-Mountain-Devs/platform_widgets.git']]])
            }
        }
        stage('clean') {
            steps {
                sh 'flutter clean'
            }
        }
        stage('build') {
            steps {
                sh 'flutter pub get'
                sh 'flutter pub run build_runner build --delete-conflicting-outputs'
                sh 'flutter build aar'
            }
        }
        stage('flutter-doctor') {
            steps {
                sh 'flutter doctor -v'
            }
        }
        stage('test') {
            steps {
                sh 'flutter test --machine --coverage | tojunit -o junit-test-report.xml'
                sh "cat junit-test-report.xml | tr -d '\033' | tr -d '&#' > final-test-report.xml"
                junit 'final-test-report.xml'
            }
        }
        stage('post-clean') {
            steps {
                sh 'flutter clean'
            }
        }
    }
}