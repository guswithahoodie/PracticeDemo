## Demo: gus-demo-project

Architecture:
- Django REST API (task manager) containerized and built on EC2
- SQLite local DB (demo only)
- Terraform-based infra (VPC, Subnet, EC2, Security Groups)
- Manual deploy via GitHub Actions (workflow_dispatch)
- Deploy target: EC2 instance public IP (port 80)

Quick deploy (locally):
```bash
cd infra/envs/dev
../../scripts/deploy.sh

cd infra/envs/dev
../../scripts/destroy.sh


---

# 11) Important operational notes / next steps (you must read)
1. **Secrets**: Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub repo secrets (for the Actions deploy job). Use least-privilege keys (allow tf create/destroy, ec2, iam, etc.). You can also use Terraform Cloud if you prefer remote state and run triggers there.

2. **Branch protection**: Enforce PR approvals on `main` (Settings → Branches) so deployments require a PR and approval.

3. **User data branch**: `infra/envs/dev/variables.tf` default `git_branch = "infra-cleanup"`. If you want the EC2 to pull `dev` branch instead, set that variable or update the workflow to pass `TF_VAR_git_branch`.

4. **Instance public IP**: After `terraform apply`, the output will show the instance public IP. Visit `http://<EC2_IP>/tasks/` (or root) to use DRF browsable API. Because Gunicorn binds to port 80, hitting `http://<ip>/` should work.

5. **Access**: SSH port 22 is restricted to your IP only, but we mostly use SSM. If SSH is required later, you can enable it temporarily.

6. **Cost**: Running the t3.micro EC2 will incur small cost when running; destroy with `destroy.sh` when not using.

7. **Troubleshooting**: If the container does not start, view instance system logs via AWS Console → EC2 → Instance → System Log, or connect via SSM and run `docker ps` and `docker logs`.

---

# 12) How to proceed now (exact steps for you)

1. Add the files above into your `infra-cleanup` branch in the matching paths.
   - `infra/modules/...` files
   - `infra/envs/dev/...` files
   - `infra/scripts/deploy.sh` & `destroy.sh`
   - replace `backend/Dockerfile` content with the provided Dockerfile.
   - add the GitHub Actions workflow under `.github/workflows/aws-deploy.yml`

2. Commit & push `infra-cleanup` branch and open a PR to `main`. Make sure branch protection requires approval; then approve and merge the PR.

3. Add GitHub secrets: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

4. In GitHub → Actions → open `CI & Manual Deploy` workflow and click **Run workflow** → choose `deploy`. Wait for Terraform apply to finish.

5. After deployment completes, check Actions logs for the `terraform output instance_public_ip` and open `http://<ip>/tasks/` in browser. Login to admin at `/admin/` (you’ll need to create an admin user — see note below).

---

# 13) Creating Django admin user (two ways)

- Local: create superuser locally and include in repo? (not safe)
- Recommended: After instance is up, connect via SSM and run:
```bash
# via AWS Session Manager (console) or use SSM send-command
# Example command
sudo docker exec -it gus-demo-project-container python manage.py createsuperuser
