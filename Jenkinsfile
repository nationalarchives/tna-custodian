library("tdr-jenkinslib")

pipeline {
    agent {
        label "master"
    }
    parameters {
        choice(name: "STAGE", choices: ["intg", "staging", "prod"], description: "AWS account being configured")
    }
    stages {
        stage('Run Terraform build') {
            agent {
                ecs {
                    inheritFrom 'terraform'
                    taskrole "arn:aws:iam::${env.MANAGEMENT_ACCOUNT}:role/TDRTerraformAssumeRole${params.STAGE.capitalize()}"
                }
            }
            environment {
                TF_VAR_tdr_account_number = tdr.getAccountNumberFromStage(params.STAGE)
                //no-color option set for Terraform commands as Jenkins console unable to output the colour
                //making output difficult to read
                TF_CLI_ARGS = "-no-color"
            }
            stages {
                stage('Set up Terraform workspace') {
                    steps {
                        dir("terraform") {
                            echo 'Initializing Terraform...'
                            sshagent(['github-jenkins']) {
                                sh("git clone git@github.com:nationalarchives/tdr-configurations.git")
                            }
                            sh 'terraform init'
                            //If Terraform workspace exists continue
                            sh "terraform workspace new ${params.STAGE} || true"
                            sh "terraform workspace select ${params.STAGE}"
                            sh 'terraform workspace list'
                        }
                    }
                }
                stage('Run Terraform plan') {
                    steps {
                        dir("terraform") {
                            echo 'Running Terraform plan...'
                            sh 'terraform plan'
                            slackSend(
                                    color: 'good',
                                    message: "Terraform plan complete for ${params.STAGE.capitalize()} TDR environment. View here for plan: https://jenkins.tdr-management.nationalarchives.gov.uk/job/${JOB_NAME}/${BUILD_NUMBER}/console",
                                    channel: '#tdr-releases'
                            )
                        }
                    }
                }
                stage('Approve Terraform plan') {
                    steps {
                        dir("terraform") {
                            echo 'Sending request for approval of Terraform plan...'
                            slackSend(
                                    color: 'good',
                                    message: "Do you approve Terraform deployment for ${params.STAGE.capitalize()} TDR environment? jenkins.tdr-management.nationalarchives.gov.uk/job/${JOB_NAME}/${BUILD_NUMBER}/input/",
                                    channel: '#tdr-releases')
                            input "Do you approve deployment to ${params.STAGE.capitalize()}?"
                        }
                    }
                }
                stage('Apply Terraform changes') {
                    steps {
                        dir("terraform") {
                            echo 'Applying Terraform changes...'
                            sh 'echo "yes" | terraform apply'
                            echo 'Changes applied'
                            slackSend(
                                    color: 'good',
                                    message: "Deployment complete for ${params.STAGE.capitalize()} TDR environment",
                                    channel: '#tdr-releases'
                            )
                        }
                    }
                }
            }
        }
        stage("Custodian") {
            agent {
                ecs {
                    inheritFrom "aws"
                    taskrole "arn:aws:iam::${env.MANAGEMENT_ACCOUNT}:role/TDRCustodianAssumeRole${params.STAGE.capitalize()}"
                }
            }
            steps {
                script {
                    dir("accounts") {
                        sh "../custodian/scripts/deploy-custodian-jenkins.sh ${params.STAGE} TDR tdr-secops@nationalarchives.gov.uk ${env.MANAGEMENT_ACCOUNT} arn:aws:iam::${getAccountNumberFromStage(params.STAGE)}:role/TDRCustodianDeployRole${params.STAGE.capitalize()}"
                    }
                    slackSend(
                            color: "good",
                            message: "Cloud Custodian deployed to ${params.STAGE.capitalize()} AWS account",
                            channel: "#tdr-releases"
                    )
                }
            }
        }
    }
    post {
        always {
            echo 'Deleting Jenkins workspace...'
            deleteDir()
        }
    }
}
