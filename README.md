# 🏢 Employee Management System — CI/CD Pipeline

**Team:** Jesinder (DevOps Engineer) & Menaka (Java Developer)  
**Stack:** Spring Boot · MySQL · Nginx · Docker · Jenkins · AWS EC2 · Maven · Git

---

## 📐 Architecture Overview

```
Browser
  │
  ▼
┌─────────────────────┐   Port 80
│  Frontend (Nginx)   │  ◄──────── User
│  index.html         │
└─────────┬───────────┘
          │ /api/* proxy
          ▼
┌─────────────────────┐   Port 8080
│  Backend (Spring)   │  ◄──────── API Calls
│  REST API (Java 17) │
└─────────┬───────────┘
          │ JDBC
          ▼
┌─────────────────────┐   Port 3306
│  Database (MySQL)   │
│  empdb              │
└─────────────────────┘
```

---

## 📁 Repository Structure

```
employee-management/
├── backend/                        ← Spring Boot (Java/Maven)
│   ├── src/main/java/com/emp/
│   │   ├── EmployeeManagementApplication.java
│   │   ├── controller/EmployeeController.java
│   │   ├── model/Employee.java
│   │   ├── repository/EmployeeRepository.java
│   │   └── service/EmployeeService.java
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── pom.xml
│   └── Dockerfile
├── frontend/                       ← Nginx + HTML/JS
│   ├── index.html
│   ├── nginx.conf
│   └── Dockerfile
├── database/
│   └── init.sql                    ← Seed data (Jesinder & Menaka)
├── jenkins/
│   ├── ec2-setup.sh                ← One-time EC2 setup script
│   └── jenkins-setup-guide.md
├── Jenkinsfile                     ← Full CI/CD pipeline
├── docker-compose.yml              ← Local + production deploy
├── .env.example                    ← Template for secrets
├── .gitignore
└── README.md
```

---

## 🚀 STEP-BY-STEP SETUP GUIDE

---

### STEP 1 — Push Code to GitHub

```bash
# On your local machine
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Copy all project files into repo
# (paste the entire employee-management folder contents here)

git add .
git commit -m "feat: Initial Employee Management App - Jesinder & Menaka"
git push origin main
```

---

### STEP 2 — Set Up EC2 Instance

#### 2a. Launch EC2 on AWS Console
- AMI: **Ubuntu 22.04 LTS**
- Instance type: **t2.medium** (or t3.medium)
- Storage: **20 GB**
- Key pair: Create/download your `.pem` file

#### 2b. Configure Security Group — Open these inbound ports:

| Port | Purpose         |
|------|-----------------|
| 22   | SSH             |
| 80   | Frontend (HTTP) |
| 8080 | Backend API     |
| 8081 | Jenkins UI      |
| 3306 | MySQL (optional)|

#### 2c. SSH into EC2 and Run Setup Script

```bash
# From your local machine
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# On the EC2 instance
sudo apt-get update -y
sudo apt-get install -y git

# Clone your repo (or copy ec2-setup.sh manually)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/jenkins

# Run the setup script
chmod +x ec2-setup.sh
sudo ./ec2-setup.sh
```

This installs: **Java 17, Maven, Git, Docker, Docker Compose, Jenkins**

---

### STEP 3 — Configure Jenkins

#### 3a. Access Jenkins
Open in browser: `http://YOUR_EC2_IP:8081`

#### 3b. Unlock Jenkins
```bash
# On EC2
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Paste the password → Install suggested plugins → Create admin user

#### 3c. Install Extra Plugins
Go to **Manage Jenkins → Plugins → Available** and install:
- SSH Agent Plugin
- Docker Pipeline
- Pipeline: Stage View

#### 3d. Add Jenkins Credentials
Go to **Manage Jenkins → Credentials → Global → Add Credential**

| ID                    | Type             | Value                     |
|-----------------------|------------------|---------------------------|
| `DOCKER_HUB_USERNAME` | Secret text      | your dockerhub username   |
| `DOCKER_HUB_PASSWORD` | Secret text      | your dockerhub password   |
| `EC2_HOST`            | Secret text      | 54.x.x.x (your EC2 IP)   |
| `EC2_SSH_KEY`         | SSH Username+key | ubuntu + .pem file content|

---

### STEP 4 — Create Pipeline Job in Jenkins

1. **New Item** → Enter name: `employee-management-pipeline`
2. Select **Pipeline** → Click OK
3. Under **Pipeline** section:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/YOUR_USERNAME/YOUR_REPO.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
4. Click **Save**

---

### STEP 5 — Run the Pipeline

Click **Build Now** in Jenkins.

The pipeline runs these stages automatically:

```
📥 Checkout → 🔨 Maven Build → 🧪 Unit Tests →
🐳 Docker Build → 📤 Push to Hub → 🚀 Deploy to EC2 → ✅ Smoke Test
```

---

### STEP 6 — Access the Application

After pipeline succeeds:

| Service  | URL                                          |
|----------|----------------------------------------------|
| 🌐 App   | `http://YOUR_EC2_IP`                         |
| 🔧 API   | `http://YOUR_EC2_IP:8080/api/employees`      |
| ❤️ Health| `http://YOUR_EC2_IP:8080/api/employees/health`|

---

## 🐳 Local Development (Docker Compose)

```bash
# Clone and enter project
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd employee-management

# Copy env file
cp .env.example .env

# Build and start all services
docker-compose up --build -d

# View logs
docker-compose logs -f

# Open app
open http://localhost

# Stop all
docker-compose down
```

---

## 🗄️ Database Details

- **Database:** `empdb`
- **Seed Data:** Jesinder (DevOps) & Menaka (Java) + 4 more employees
- **Auto-migrate:** Spring Boot runs `ddl-auto=update` on startup

---

## 🔌 API Endpoints

| Method | Endpoint                          | Description          |
|--------|-----------------------------------|----------------------|
| GET    | `/api/employees`                  | List all employees   |
| GET    | `/api/employees/{id}`             | Get by ID            |
| POST   | `/api/employees`                  | Create employee      |
| PUT    | `/api/employees/{id}`             | Update employee      |
| DELETE | `/api/employees/{id}`             | Delete employee      |
| GET    | `/api/employees/department/{dept}`| Filter by department |
| GET    | `/api/employees/health`           | Health check         |

---

## 👥 Team

| Name       | Role           | Department |
|------------|----------------|------------|
| Jesinder   | DevOps Engineer| DevOps     |
| Menaka     | Java Developer | Java       |
