# LXD Containers/Dockers Cheat Sheet

### Remove LXD properly from system
Safety steps to follow:
* lxc list
* lxc delete <whatever came from list>
* lxc image list
* lxc image delete <whatever came from list>
* lxc network list
* lxc network delete <whatever came from list>
* echo ‘{“config”: {}}’ | lxc profile edit default
* lxc storage volume list default
* lxc storage volume delete default <whatever came from list>
* lxc storage delete default
Effectively listing and the deleting all the objects until everything’s clean.
> source: 'stgraber' 
>
> link: https://discuss.linuxcontainers.org/t/how-to-remove-lxd-from-my-system/2336/2

### Installing older lxc (lxc-ls instead of lxc ls)

Follow steps from site: 

https://linuxcontainers.org/lxc/getting-started/