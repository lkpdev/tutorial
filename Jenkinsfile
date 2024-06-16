pipeline {
  agent any
  environment {
    TF_IN_AUTOMATION = 'true'
    AWS_SHARED_CREDENTIALS_FILE='/root/.aws/credentials'
  }

  stages {
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
          sed -i "s|/Users/user/.aws/credentials|/root/.aws/credentials|g" main.tf
          cat main.tf
          terraform init
        '''
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
      }
    }

    stage('Print Inventory') {
      steps {
        sh '''
          echo $(terraform output -json ec2_public_ip) | awk -F'"' '{print $2}' > aws_hosts
          cat aws_hosts
        '''
      }
    }

    stage('Wait EC2') {
      steps {
        sh '''
          aws ec2 wait instance-status-ok --region us-east-1 --instance-ids `$(terraform output -json ec2_id_test) | awk -F'"' '{print $2}'`
        '''
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
      }
    }
  }
}