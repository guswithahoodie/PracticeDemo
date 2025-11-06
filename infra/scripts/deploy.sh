#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../envs/dev"
terraform init -input=false
terraform apply -auto-approve
