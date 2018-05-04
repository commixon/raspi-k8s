## Initial Raspisetup

- Raspbian
- run raspi-config (expand filesystem)
- Set hostnames (master, worker01, worker02)
- Set static ips
    - Could use the hostname.sh script
    - `sh hostname.sh master 192.168.1.100 192.168.1.1 8.8.8.8 wlan0`


## Install docker / kubeadm

Docker:
```
curl -sSL get.docker.com | sh && \
  sudo usermod pi -aG docker
```

Disable swap:
```
sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall && \
  sudo update-rc.d dphys-swapfile remove
```

Setup cgroups:
```
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_enable=memory"

echo $orig | sudo tee /boot/cmdline.txt
```

Install kubeadm:
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubeadm
```

And then:
```
reboot
```

```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

This `--pod-network-cidr=10.244.0.0/16` is specific for flannel

Also consider using `advertise-ip-addr`

You can now cp the generated kube-config:

```
mkdir ~/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

## Init flannel

IMPORTANT:
You have to init flannel now before any nodes join the cluster:

```
curl -sSL https://rawgit.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml | sed "s/amd64/arm/g" | kubectl create -f -
```

## Start workers

With the command given at the end of master installation