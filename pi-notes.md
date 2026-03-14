

# github access

Create ssh key:
	ssh-keygen -t ed25519 -C "rafael5@pi5"
Add key to Github
	cat ~/.ssh/id_ed25519.pub
	Copy output to GitHub: 
	Settings → SSH and GPG keys → New SSH key.
Test connection: 
	ssh -T git@github.com
Change repo to use SSH
	git remote set-url origin git@github.com:rafael5/[REPO].git
Push normally
	git push
