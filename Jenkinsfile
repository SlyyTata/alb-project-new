pipeline {
    agent any

    tools {
        terraform 'Terraform' // Assuming 'Terraform' is the name of the Terraform installation configured in Jenkins
    }

    environment {
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform...'
                // Add Terraform init steps here
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                echo 'Planning Terraform...'
                // Add Terraform plan steps here
                sh 'terraform plan -input=false tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                echo 'Applying Terraform...'
                // Add Terraform apply steps here
                sh 'terraform apply -input=false tfplan'
            }
        }
    }
}