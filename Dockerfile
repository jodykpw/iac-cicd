ARG FROM_IMAGE_NAME
ARG FROM_IMAGE_TAG

FROM ${FROM_IMAGE_NAME}:${FROM_IMAGE_TAG}

# Set version as a build argument
ARG TERRAFORM_VERSION
ARG TERRAFORM_DOCS_VERSION
ARG TERRAGRUNT_VERSION
ARG TFSEC_VERSION
ARG TFLINT_VERSION
ARG GITLEAKS_VERSION

# Create a non-root user and group
RUN groupadd -r cicd && useradd -r -g cicd cicd && \
    id cicd

USER root

# Update package lists and install necessary dependencies
RUN microdnf update -y && \
    microdnf install -y python3 python3-pip wget unzip diffutils tar gzip && \
    microdnf clean all && \
    python3 -m pip install --upgrade pip

# Ensure Python and Pip are in PATH
ENV PATH="/usr/bin/python3:${PATH}"

# Set the working directory to /tmp
WORKDIR /tmp

# Install tools
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    \
    wget https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz && \
    tar -xzvf terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz && \
    mv terraform-docs /usr/bin/terraform-docs && \
    \
    wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt && \
    \
    wget https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 && \
    mv tfsec-linux-amd64 /usr/local/bin/tfsec && \
    chmod +x /usr/local/bin/tfsec && \
    \
    wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip && \
    mv tflint /usr/bin/tflint && \
    \
    wget https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz && \
    tar -xzvf gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz && \
    mv gitleaks /usr/bin/gitleaks

# Copy the requirements.txt file to the container's /app directory
COPY requirements.txt /tmp/requirements.txt

# Install packages listed in requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt

# Remove unnecessary dependencies (but keep dependencies like git and python3)
RUN microdnf remove -y wget unzip diffutils tar gzip python3-pip && \
    microdnf clean all && \
    rm -rf /var/cache/microdnf /tmp/*

# Switch to the non-root user
USER cicd

# Set the default working directory
WORKDIR /app
