library("tdr-jenkinslib")

pipeline {
    agent {
        label "built-in"
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
                            //Require reinitialization of Terraform after workspace is selected when upgrading from v12 to v13
                            //See this thread for details of the issue: https://discuss.hashicorp.com/t/terraform-v0-13-failed-to-instantiate-provider-for-every-project/16522/9
                            //This step should not be necessary when upgrading from v13 upwards
                            sh 'terraform init'

                            sh 'terraform plan'
                            script {
                                tdr.postToDaTdrSlackChannel(colour: "good",
                                                            message: "Terraform plan complete for ${params.STAGE.capitalize()} TDR environment." +
                                                            "View here for plan: https://jenkins.tdr-management.nationalarchives.gov.uk/job/${JOB_NAME}/${BUILD_NUMBER}/console"
                                )
                            }
                        }
                    }
                }
                stage('Approve Terraform plan') {
                    steps {
                        dir("terraform") {
                            echo 'Sending request for approval of Terraform plan...'
                            script {
                                tdr.postToDaTdrSlackChannel(colour: "good",
                                                            message: "Do you approve Terraform deployment for ${params.STAGE.capitalize()} TDR environment?" +
                                                            "https://jenkins.tdr-management.nationalarchives.gov.uk/job/${JOB_NAME}/${BUILD_NUMBER}/input/"
                                )
                            }
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
                            script {
                                tdr.postToDaTdrSlackChannel(colour: "good",
                                                            message: "Deployment complete for ${params.STAGE.capitalize()} TDR environment"
                                )
                            }
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
                        sh "../custodian/scripts/deploy-custodian-jenkins.sh ${params.STAGE} TDR tdr-secops@nationalarchives.gov.uk ${env.MANAGEMENT_ACCOUNT} arn:aws:iam::${tdr.getAccountNumberFromStage(params.STAGE)}:role/TDRCustodianDeployRole${params.STAGE.capitalize()}"
                    }
                    script {
                        tdr.postToDaTdrSlackChannel(colour: "good",
                                                    message: "Cloud Custodian deployed to ${params.STAGE.capitalize()} AWS account"
                        )
                    }
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
