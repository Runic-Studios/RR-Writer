@Library('Jenkins-Shared-Lib') _

pipeline {
    agent {
        kubernetes {
            yaml jenkinsAgent(['agent-base': 'registry.runicrealms.com/jenkins/agent-base:latest'])
        }
    }

    environment {
        IMAGE_NAME = 'rr-writer'
        PROJECT_NAME = 'RR Writer'
        REGISTRY = 'registry.runicrealms.com'
        REGISTRY_PROJECT = 'library'
    }

    stages {
        stage('Send Discord Notification (Build Start)') {
            steps {
                discordNotifyStart(env.PROJECT_NAME, env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT.take(7))
            }
        }
        stage('Determine Environment') {
            steps {
                script {
                    def branchName = env.GIT_BRANCH.replaceAll(/^origin\//, '').replaceAll(/^refs\/heads\//, '')

                    echo "Using normalized branch name: ${branchName}"

                    if (branchName == 'dev') {
                        env.RUN_MAIN_DEPLOY = 'false'
                    } else if (branchName == 'main') {
                        env.RUN_MAIN_DEPLOY = 'true'
                    } else {
                        error "Unsupported branch: ${branchName}"
                    }
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                container('agent-base') {
                    script {
                        sh """
                        zip -r rr-writer.zip .
                        """
                        orasPush(env.ARTIFACT_NAME, env.GIT_COMMIT.take(7), "rr-writer.zip", env.REGISTRY, env.REGISTRY_PROJECT)
                    }
                }
            }
        }
        stage('Update Deployment') {
            steps {
                container('agent-base') {
                    updateManifest('dev', 'Realm-Paper', 'artifact-manifest.yaml', env.ARTIFACT_NAME, env.GIT_COMMIT.take(7), 'artifacts.rr-writer.tag')
                }
            }
        }
        stage('Create PR to Promote Realm-Deployment Dev to Main (Prod Only)') {
            when {
                expression { return env.RUN_MAIN_DEPLOY == 'true' }
            }
            steps {
                container('agent-base') {
                    createPR('RR-Writer', 'Realm-Paper', 'dev', 'main')
                }
            }
        }
    }

    post {
        success {
            discordNotifySuccess(env.PROJECT_NAME, env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT.take(7))
        }
        failure {
            discordNotifyFail(env.PROJECT_NAME, env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT.take(7))
        }
    }
}
