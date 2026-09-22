# GitHub Actions Demo

This repository is a hands-on example of using GitHub Actions to automate a .NET application lifecycle. The sample app is a lightweight ASP.NET Core API, but the primary focus is demonstrating CI/CD pipelines, testing, Docker publishing, and self-hosted GitHub runner automation.

## Why this project exists

The main goal of this project is to showcase how GitHub Actions can be used to:

- validate pull requests automatically
- run unit tests on every code change
- build and package a .NET application
- publish Docker images to Docker Hub
- run workflows on a self-hosted GitHub runner

The order-calculation API is simply the application used to exercise those workflows.

## Overview

This project includes a small ASP.NET Core API that calculates order totals, including:

- subtotal
- discount amount
- tax
- final total

It is intentionally simple so the focus remains on the automation around it.

## Features

- GitHub Actions workflows for CI and Docker publishing
- .NET 10 ASP.NET Core API demo app
- Automated unit tests with xUnit
- Docker image build and push automation
- Self-hosted runner setup scripts
- Minimal example of DevOps automation in a real project flow

## Project Structure

```text
GitHubActionsDemo/
├── .github/
│   ├── selfhosted-github-runner-setup/
│   │   ├── .env.template
│   │   ├── Dockerfile
│   │   ├── build-and-run.sh
│   │   └── setup-runner.sh
│   │
│   └── workflows/
│       ├── pr-request.yml
│       └── push-docker-image-publish.yml
│
├── src/
│   ├── Services/
│   │   └── OrderService.cs
│   │
│   ├── Program.cs
│   ├── GitHubActionsDemo.csproj
│   └── appsettings*.json
│
├── tests/
│   ├── GitHubActionsDemo.Tests.csproj
│   └── UnitTest1.cs
│
├── Dockerfile
├── .gitignore
└── README.md
```

## Technology Stack

- GitHub Actions
- .NET 10
- ASP.NET Core Minimal API
- xUnit
- Docker
- Docker Hub

## Prerequisites

Before running the project, make sure you have:

- .NET SDK 10.0 or later
- Docker installed and running
- A GitHub repository configured for Actions
- Docker Hub account and credentials if you want to publish images

## Getting Started

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd GitHubActionsDemo
```

### 2. Restore dependencies

```bash
dotnet restore
```

### 3. Run the application locally

```bash
dotnet run --project src/GitHubActionsDemo.csproj
```

The sample API is configured to run on port 8080:

```text
http://localhost:8080
```

and

```text
https://localhost:8080
```

### 4. Test the sample API

#### Root endpoint

```bash
curl http://localhost:8080/
```

Response:

```text
GitHub Actions Demo API
```

#### Order calculation endpoint

```bash
curl "http://localhost:8080/api/order/total?price=100&quantity=2&discountPercent=10"
```

Example response:

```json
{
  "subtotal": 200,
  "discount": 20,
  "tax": 32.4,
  "total": 212.4
}
```

## Business Logic

The order service applies the following rules:

- Price cannot be negative
- Quantity must be greater than zero
- Discount must be between 0 and 100 percent
- Tax rate is 18%
- Discount is applied before tax is calculated

## Running Tests

```bash
dotnet test tests/GitHubActionsDemo.Tests.csproj
```

The test suite validates:

- normal order totals
- discounted totals
- invalid quantity handling
- invalid price handling
- invalid discount handling

## Docker

### Build image

```bash
docker build -t githubactionsdemo .
```

### Run container locally

```bash
docker run -p 8080:8080 githubactionsdemo
```

Then open:

```text
http://localhost:8080/
```

### Pull the published Docker image from Docker Hub

After the GitHub Actions workflow has published the image, you can run it directly from Docker Hub with:

```bash
docker pull ayushisar110/githubactionsdemo:latest
docker run -p 8080:8080 ayushisar110/githubactionsdemo:latest
```

Then open:

```text
http://localhost:8080/
```

## GitHub Actions Workflows

This project is built to demonstrate the workflow automation itself. The repository includes two key pipelines:

### 1. PR validation

File: .github/workflows/pr-request.yml

This workflow runs on pull requests and demonstrates how GitHub Actions can be used to enforce quality gates before merge. It performs:

- repository checkout
- .NET 10 environment setup
- dependency restore
- unit test execution
- application build validation

### 2. Docker image publish

File: .github/workflows/push-docker-image-publish.yml

This workflow shows how a successful build can be turned into a deployment artifact. It:

- runs tests and build checks
- publishes a Docker image to Docker Hub
- tags the image with the latest version and commit SHA
- only pushes on the main branch

Required GitHub secrets:

- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN

### How to generate and store these secrets

1. Log in to Docker Hub and create a Docker account if needed.
2. Generate a Docker Hub access token:
   - Open Docker Hub
   - Go to Account Settings -> Security
   - Click New Access Token
   - Give it a name such as GitHubActionsDemo
   - Copy the generated token
3. In GitHub, open your repository.
4. Go to Settings -> Secrets and variables -> Actions.
5. Click New repository secret.
6. Add the following values:
   - Name: `DOCKERHUB_USERNAME`  Value: your Docker Hub username
   - Name: `DOCKERHUB_TOKEN`  Value: the generated Docker Hub access token

Store these secrets at the repository level (or organization level if you manage shared secrets). They are used by the workflow in `.github/workflows/push-docker-image-publish.yml` to authenticate and push the Docker image.

This is the core demonstration of the repository: GitHub Actions as the automation layer for a .NET app.

## Self-Hosted GitHub Runner Setup

The project includes a self-hosted runner configuration under:

- .github/selfhosted-github-runner-setup/

Files included:

- .env.template
- setup-runner.sh
- build-and-run.sh
- Dockerfile

### Configure environment

Copy the template file and update values:

```bash
cp .github/selfhosted-github-runner-setup/.env.template .github/selfhosted-github-runner-setup/.env
```

Then edit the .env file with your GitHub repository URL, runner token, labels, and runner version.

### Start runner

```bash
cd .github/selfhosted-github-runner-setup
chmod +x setup-runner.sh build-and-run.sh
./setup-runner.sh
```

This sets up the GitHub self-hosted runner and starts it in the configured work folder.

## Example API Calls

```bash
curl "http://localhost:8080/api/order/total?price=250&quantity=3&discountPercent=5"

curl "http://localhost:8080/api/order/total-with-tax?price=100&quantity=2&discountPercent=10&taxPercent=18"
```

## Notes

This repository is intentionally designed as a GitHub Actions showcase. The app is simple, but the automation patterns are the real value:

- CI on pull requests
- automatic test execution
- build verification
- Docker image publishing
- self-hosted runner setup for custom GitHub-hosted workflows

It is a practical example for learning DevOps automation in a small but realistic setup.

## License

This project does not currently include a license file. If you plan to share it publicly, consider adding an appropriate open-source license such as MIT.
