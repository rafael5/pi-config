### SSH TO UBUNTU FROM MAC
ssh ubuntu@192.168.9.114
ubuntu / ubuntu#1


### INSTALL - SIMPLE
https://linuxhint.com/install_ubuntu_ssh_headless_raspberry_pi_4/
https://medium.com/@aayushjn11/installing-ubuntu-server-20-04-on-raspberry-pi-4-451504988d61


#### INSTALL - ADVANCED
https://mutschler.eu/linux/install-guides/raspi-btrfs/
https://mutschler.eu/linux/install-guides/raspi-post-install/



#### LOGIN
initial: ubuntu / ubuntu
changed: ubuntu / ubuntu#1



### WIFI: netplan + cloud-init
```text
https://linuxconfig.org/ubuntu-20-04-connect-to-wifi-from-command-line
https://cloudinit.readthedocs.io/
https://netplan.io/examples/


> ls /sys/class/net
> cd /etc/netplan
> sudoedit 50-cloud-init.yaml
---------------------------
network:
    version: 2
    wifis:
        wlan0:
            optional: true
            access-points: 
                "indro-home":
                    password: "indro#1@home"
            dhcp4: true
---------------------------
- each layer is 4 spaces (no tabs)
- colon + space after each directive.
- colon after "indro-home": 


sudo netplan apply
ping google.com

Changes to this will not persist across instance reboot.
To disable cloud-init's netwrok configuraiton cpabilities write a file: 
/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg    with the following
network: {config: disabled}

```



### SSH
```text
https://pimylifeup.com/ubuntu-server-raspberry-pi/

sudo apt install openssh-server
sudo /etc/init.d/ssh start


# IP ADDRESS
sudo apt install net-tools
ifconfig

wlan0: flags=...
    inet 192.168.9.114 ...  <== ip address

# SSH TO UBUNTU FROM MAC
ssh ubuntu@192.168.9.114
ubuntu / ubuntu#1
```



### POST-INSTALLATION
https://mutschler.eu/linux/install-guides/raspi-post-install/

```text
# UPDATE
sudo apt update && sudo apt upgrade -y
sudo apt autoremove
sudo snap refresh
sudo reboot now

# DOWNLOADS DIR
mkdir downloads
```


### GIT: cache personal access token
https://www.edgoad.com/2021/02/using-personal-access-tokens-with-git-and-github.html
```text
git config -l
git config --global user.name "rafael5"
git config --global user.email "rmrich5@gmail.com"
git config --global credential.helper store
```




# zshell bashscripts
sudo ./aaLinux-base.sh
sudo ./go-install.sh 
sudo ./rust-install.sh
sudo ./ydb-install.sh
```




### PROFILE
```text

# ALIASES
source ~/zshell/aliases/aliases-bash.sh

# YottaDB and Rust 
source $(pkg-config --variable=prefix yottadb)/ydb_env_set
source "$HOME/.cargo/env"

```



### ADD SUPERUSER  (does not create user directory)
* https://www.digitalocean.com/community/tutorials/* how-to-create-a-new-sudo-enabled-user-on-ubuntu-20-04-quickstart
```text
sudo adduser rafael
sudo usermode -aG sudo rafael
su rafael
```

