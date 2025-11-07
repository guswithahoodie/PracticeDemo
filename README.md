# 🐍 Django + Terraform + AWS Demo Project

This is a small end-to-end demo I built to practice deploying a Django app with Terraform and AWS.  
It automatically sets up the whole stack — network, EC2 instance, Docker, PostgreSQL, and the Django backend — all running together in the cloud.

---

## 🚀 What it does
- Uses **Terraform** to spin up an **EC2 instance**.  
- The instance automatically installs **Docker** and **AWS CLI** through a startup script.  
- On boot, it pulls the latest **Docker image** for the Django app from **Amazon ECR**.  
- It also runs a **PostgreSQL** container and links it to the Django container.  
- Django runs on **port 8000**, accessible through the instance’s public IP.  

Basically: one `terraform apply` → boom, app is live.

---

## ⚙️ Tech used
- **Terraform** – for infrastructure as code  
- **AWS EC2 + ECR + SSM** – compute, container registry, remote access  
- **Docker** – app and DB containers  
- **PostgreSQL** – database  
- **Django (Gunicorn)** – backend web app  

---

## 🧩 Routes
When deployed, you’ll see a 404 at the root (`/`) since only these paths exist:
/admin/
/api/

That means everything’s working — just no homepage route yet.

---

## 🧠 Notes
- EC2 builds are x86_64, so the Docker image must be built for `linux/amd64`.  
- SSM is used instead of SSH for secure access.  
- The Django and Postgres containers start automatically via `user_data`.  

---

## 🪄 To deploy
```bash
terraform init
terraform apply -auto-approve
```
Then check:

http://your-instance-public-ip:8000

Keeping it simple. It’s not a big app — just a solid, automated setup that proves everything’s working together nicely.
