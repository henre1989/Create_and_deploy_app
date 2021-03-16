pipeline {
    agent any
    stages {
        stage ('aws configure') {
        steps {
            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                credentialsId: 'aws-credentials',
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
            sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
            sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
            sh 'aws configure set default.region us-east-2'
                }
            }
        }
        stage ('git clone') {
            steps {
                script {
                    git 'https://github.com/henre1989/Create_and_deploy_app.git'
                }
            }
        }
        stage('TF create instances') {
            steps {
                  sh 'terraform init'
                  sh 'terraform apply -auto-approve'
                    script{
                    env.build_server_ip = sh (
                        script: 'terraform output -raw instance_ips_build',
                        returnStdout: true
                        ).trim()
                    env.run_app_server_ip = sh (
                        script: 'terraform output -raw instance_ips_run',
                        returnStdout: true
                        ).trim()
                    }
                }
        }
        stage('Ansible build and deploy app') {
            steps {
                ansiblePlaybook credentialsId: 'anible-connect',
                disableHostKeyChecking: true,
                extras: '--extra-vars \'{"host_run_app":"${run_app_server_ip}","host_build":"${build_server_ip}"}\'',
                installation: 'ansible',
                playbook: 'build_app.yaml',
                vaultCredentialsId: 'vault'
                }
        }
    }
    }
