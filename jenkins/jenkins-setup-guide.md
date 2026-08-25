# Jenkins Setup Guide — Employee Management System

## Jenkins Credentials to Create
Go to: Jenkins → Manage Jenkins → Credentials → Global → Add Credential

| Credential ID         | Type              | Value                         |
|-----------------------|-------------------|-------------------------------|
| `DOCKER_HUB_USERNAME` | Secret text       | Your Docker Hub username      |
| `DOCKER_HUB_PASSWORD` | Secret text       | Your Docker Hub password/token|
| `EC2_HOST`            | Secret text       | Your EC2 public IP (54.x.x.x)|
| `EC2_SSH_KEY`         | SSH Username+key  | ubuntu / your .pem key content|

## Jenkins Plugins Required
Install via: Manage Jenkins → Plugins → Available

- ✅ Git Plugin
- ✅ Pipeline
- ✅ SSH Agent Plugin
- ✅ Docker Pipeline
- ✅ JUnit Plugin
- ✅ Credentials Binding Plugin

## Create Pipeline Job
1. New Item → Pipeline → Name: `employee-management-pipeline`
2. Pipeline Definition: **Pipeline script from SCM**
3. SCM: **Git**
4. Repository URL: `https://github.com/YOUR_USERNAME/employee-management.git`
5. Branch: `*/main`
6. Script Path: `Jenkinsfile`
7. Save → Build Now
