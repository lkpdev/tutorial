pipeline {
  agent any
  environment {
    TF_IN_AUTOMATION = 'true'
//     AWS_SHARED_CREDENTIALS_FILE='/root/.aws/credentials'
  }

  stages {
    stage('Vulnerability Scan - Docker Trivy') {
           steps {
             withCredentials([string(credentialsId: 'trivy_github_token', variable: 'TOKEN')]) {
      sh "sed -i 's#token_github#${TOKEN}#g' trivy-image-scan.sh"
      sh "sudo bash trivy-image-scan.sh"
            }
           }
         }
    stage('Vault') {
      steps {
        script {
          withVault(configuration: [disableChildPoliciesOverride: false, skipSslVerification: true, timeout: 60, vaultCredentialId: 'terraform-role', vaultUrl: 'http://3.90.216.202:8200'],vaultSecrets: [[path: 'terraform/aws/awsaccesskey', secretValues: [[vaultKey: 'access_key']]],[path: 'terraform/aws/awssecretkey', secretValues: [[vaultKey: 'secret_key']]],[path: 'terraform/aws/sshkey', secretValues: [[vaultKey: 'public_key']]]]) {
            sh 'echo access_key=$access_key'
            sh 'echo secret_key=$secret_key'
            sh 'echo public_key=$public_key'
//                 sh 'terraform init && terraform apply -var "access_key=$access_key" -var "secret_key=$secret_key" -var "public_key=$public_key" --auto-approve'
          }
        }
      }
    }
    stage('Install Checkov') {
      steps {
        script {
          sh "pip install checkov --break-system-packages"
          def checkovPath = sh(script: 'pip show checkov | grep "Location" | cut -d " " -f 2', returnStdout: true).trim()
          env.PATH = "${checkovPath}:${env.PATH}"
        }
      }
    }
    stage('Init TF') {
      steps {
        sh '''
          ls -al
          cat main.tf
          terraform init
              echo 'TF INIT complete'
        '''
        logstashSend failBuild: true, maxLines: 1000
      }
    }

    stage('checkov scan ') {
      steps {
        catchError(buildResult: 'SUCCESS') {
          script {
            try {
              sh 'mkdir -p reports'
              sh 'checkov -d . --output junitxml > reports/checkov-report.xml'
              junit skipPublishingChecks: true, testResults: 'reports/checkov-report.xml'
            } catch (err) {
                junit skipPublishingChecks: true, testResults: 'reports/checkov-report.xml'
                throw err
            }
          }
        }
      }
    }

    stage('Plan TF') {
      steps {
        sh '''
          terraform plan
        '''
        logstashSend failBuild: true, maxLines: 1000
      }
    }

        stage('Validate TF') {
          input {
            message "Do you want to apply this Plan?"
            ok "Apply Plan"
          }
          steps {
            echo 'Plan Accepted'
          }
        }

    stage('Apply TF') {
      steps {
        sh '''
          terraform apply -auto-approve
        '''
        logstashSend failBuild: true, maxLines: 1000
      }
    }

    stage('Print Inventory') {
      steps {
        sh '''
          echo $(terraform output -json ec2_public_ip) | awk -F'"' '{print $2}' > aws_hosts
          cat aws_hosts
        '''
        logstashSend failBuild: true, maxLines: 1000
      }
    }

    stage('Wait EC2') {
      steps {
        sh '''
          aws ec2 wait instance-status-ok --region us-east-1 --instance-ids `$(terraform output -json ec2_id_test) | awk -F'"' '{print $2}'`
        '''
        logstashSend failBuild: true, maxLines: 1000
      }
    }

    stage('Validate Ansible') {
      input {
        message "Do you want to run Ansible Playbook?"
        ok "Run Ansible"
      }
      steps {
        echo "Ansible Accepted"
      }
    }

    stage('Run Ansible') {
      steps {
        ansiblePlaybook(credentialsId: 'ec2.ssh.key	', inventory: 'aws_hosts', playbook: 'ansible/docker.yml')
        logstashSend failBuild: true, maxLines: 1000
      }
    }

    stage('Validate Destroy') {
      input {
        message "Do you want to destroy Terraform Infra?"
        ok "Destroy"
      }
      steps {
        echo "Destroy Accepted"
      }
    }

    stage('Destroy TF') {
      steps {
        sh '''
          terraform destroy -auto-approve
        '''
      logstashSend failBuild: true, maxLines: 1000
      }
    }
  }
}