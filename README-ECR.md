# ToDoAI — Docker image and Amazon ECR

This folder contains the Docker deployment files for the `macnaer/ToDoAI`
React + TypeScript + Vite application.

## 1. Add the files to the repository

Copy `Dockerfile`, `nginx.conf`, `.dockerignore`, and `ecr-push.sh` into the
root of the cloned `ToDoAI` repository (next to `package.json`).

## 2. Build and test locally

```bash
docker build -t todoai:latest .
docker run --rm -d --name todoai-test -p 8080:80 todoai:latest
```

Open `http://localhost:8080`. Check the container and then stop it:

```bash
docker ps
docker logs todoai-test
docker stop todoai-test
```

## 3. Create and push the image to Amazon ECR

Requirements: AWS CLI configured with credentials that can manage ECR,
Docker installed and running, and permission to create/push to an ECR repository.

Find the AWS account ID:

```bash
aws sts get-caller-identity
```

Choose the region where the ECR repository should live (for example
`eu-central-1`), then run from the repository root:

```bash
chmod +x ecr-push.sh
AWS_REGION=eu-central-1 AWS_ACCOUNT_ID=YOUR_12_DIGIT_ACCOUNT_ID ./ecr-push.sh
```

The script creates the ECR repository if it does not exist, authenticates
Docker to ECR, builds the image, tags it with the account/region registry
address, and pushes it.

## 4. Verify the result

```bash
aws ecr describe-images --repository-name todoai --region eu-central-1
```

The pushed image URI has this form:

```text
YOUR_12_DIGIT_ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/todoai:latest
```

Replace the example region/account ID with your actual values. Do not commit
AWS access keys, `.env` files, or other credentials to Git.
