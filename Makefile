.PHONY: help deploy check common services storage docker ha gpg tailscale

help:
	@echo "BeaglePlay Ansible Deployment"
	@echo ""
	@echo "Usage:"
	@echo "  make deploy       - Deploy full configuration"
	@echo "  make check        - Dry run (check mode)"
	@echo "  make common       - Deploy common packages and setup"
	@echo "  make services     - Disable unnecessary services"
	@echo "  make storage      - Configure storage/fstab"
	@echo "  make docker       - Install Docker"
	@echo "  make ha           - Deploy home automation stack"
	@echo "  make gpg          - Setup GPG forwarding"
	@echo "  make tailscale    - Install Tailscale"
	@echo ""
	@echo "Advanced:"
	@echo "  make syntax       - Check playbook syntax"
	@echo "  make verbose      - Deploy with verbose output"

deploy:
	ansible-playbook playbook.yml

check:
	ansible-playbook playbook.yml --check

syntax:
	ansible-playbook playbook.yml --syntax-check

verbose:
	ansible-playbook playbook.yml -vvv

common:
	ansible-playbook playbook.yml --tags common

services:
	ansible-playbook playbook.yml --tags services

storage:
	ansible-playbook playbook.yml --tags storage

docker:
	ansible-playbook playbook.yml --tags docker

ha:
	ansible-playbook playbook.yml --tags home_automation

gpg:
	ansible-playbook playbook.yml --tags gpg

tailscale:
	ansible-playbook playbook.yml --tags tailscale
