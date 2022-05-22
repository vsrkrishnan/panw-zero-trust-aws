
function install_prerequisites() {
    sudo yum install -y jq
    sudo yum install -y wget
}

# Function to check if Terraform is installed already, if not, then download and installed the version of Terraform as required.
function install_terraform() {
    # Sticking to Terraform v1.1.7 as it was used for the development of this code-base
    TERRAFORM_VERSION="1.1.7"

    # Check if terraform is already installed and display the version of terraform as installed
    [[ -f ${HOME}/bin/terraform ]] && echo "`${HOME}/bin/terraform version` already installed at ${HOME}/bin/terraform" && return 0

    TERRAFORM_DOWNLOAD_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep 'linux.*amd64' | egrep "${TERRAFORM_VERSION}" | egrep -v 'rc|beta|alpha')
    TERRAFORM_DOWNLOAD_FILE=$(basename $TERRAFORM_DOWNLOAD_URL)

    echo "Downloading Terraform v$TERRAFORM_VERSION from '$TERRAFORM_DOWNLOAD_URL'"

    # Download and install Terraform v1.1.7 as that is the version used for the development of this code-base.
    # TODO: Once Base and Ceiling versions have been validated, the code here will be modified to download the Ceiling version of terraform as required by the scripts in this code-base.
    mkdir ${HOME}/bin/ && cd ${HOME}/bin/ && wget $TERRAFORM_DOWNLOAD_URL && unzip $TERRAFORM_DOWNLOAD_FILE && rm $TERRAFORM_DOWNLOAD_FILE

    # Display an confirmation of the successful installation of Terraform.
    echo "Installed: `${HOME}/bin/terraform version`"
}

function install_kubectl() {
    KUBECTL_VERSION="1.23.0"
    KUBECTL_DOWNLOAD_URL="https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl"
    cd ${HOME}/bin/ && curl -LO $KUBECTL_DOWNLOAD_URL && chmod +x kubectl
}

function install_aws_iam_authenticator() {
    AWS_IAM_AUTH_VERSION="1.21.2"
    AWS_IAM_AUTH_DOWNLOAD_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/$AWS_IAM_AUTH_VERSION/2021-07-05/bin/linux/amd64/aws-iam-authenticator"
    cd ${HOME}/bin/ && curl -o aws-iam-authenticator $AWS_IAM_AUTH_DOWNLOAD_URL && chmod +x aws-iam-authenticator
}

function deploy_vmseries_lab() {
    # Assuming that this setup script is being run from the cloned github repo, changing the current working directory to one from where Terraform will deploy the lab resources.
    cd "${HOME}/panw-zero-trust-aws/terraform/vmseries01/zero-trust-lab"

    # Initialize terraform
    echo "Initializing directory for lab resource deployment"
    terraform init

    # Deploy resources
    echo "Deploying Resources required for Palo Alto Networks Reference Architecture for Zero Trust on AWS"
    terraform apply -auto-approve

    if [ $? -eq 0 ]; then
        echo "AWS Zero Trust Reference Architecture Lab Deployment Completed successfully!"
    else
        echo "AWS Zero Trust Reference Architecture Lab Deployment Failed!"
    fi
}

install_prerequisites
install_terraform
install_kubectl
install_aws_iam_authenticator

deploy_vmseries_lab