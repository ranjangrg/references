# LXD Containers/Dockers Cheat Sheet

### Remove LXD properly from system
Safety steps to follow:
```bash
$ lxc list
$ lxc delete <whatever came from list>
$ lxc image list
$ lxc image delete <whatever came from list>
$ lxc network list
$ lxc network delete <whatever came from list>
$ echo ‘{“config”: {}}’ | lxc profile edit default
$ lxc storage volume list default
$ lxc storage volume delete default <whatever came from list>
$ lxc storage delete default
```
Effectively listing and the deleting all the objects until everything’s clean.
> source: 'stgraber' 
> link: https://discuss.linuxcontainers.org/t/how-to-remove-lxd-from-my-system/2336/2

### Installing older LXC (lxc-ls instead of lxc ls)
Follow steps from site: 
https://linuxcontainers.org/lxc/getting-started/

### Installing LXD (lxc ls instead of lxc-ls)
Follow steps from site: 
https://linuxcontainers.org/lxd/getting-started-cli/
Commands:
```bash
$ sudo snap install lxd
$ lxd init # to configure (MUST be run ONCE)
```
If you get `Error: Failed to connect to local LXD: .... connect: Permission denied` while running `lxd init`, check if your account is a member of the `lxd` group. If you are already, maybe logging out and logging back in may help. Else if you are not a member of the `lxd` group, add your user/account to the `lxd` group:
```bash
$ sudo usermod --append --groups lxd <username>
```
>source: https://askubuntu.com/questions/1041379/lxd-init-fails-on-ubuntu-16-04-xenial-xerus#targetText=2%20Answers&targetText=Reason%20no%20such%20file%20or,%2Flxd%2Funix.socket%20.

### Create a container (Image is downloaded from network)
```bash
$ lxc launch ubuntu:18.04 container01
$ lxc list # check and confirm the creation of the container
$ lxc exec container01 -- /bin/bash # to get a shell inside new container
```

