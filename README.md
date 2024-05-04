
## Installation

#### In the VPN qube

Clone it
```sh
git clone https://www.github.com/xbc5/aegis
```

There is a build script:
```
./build -h  # help
./build i   # install
```

#### In the template

Now copy the repo to your template, and run:
```
./build i
```

#### What it does

The `i` will install what's appropriate into each qube:
- template: system deps, and service;
- proxy vm: script, firewall rules, config directory;

The config directory is `/usr/local/etc/aegis`, and Wireguard configs live under the `confs` directory.

#### Dom0 changes

You need to also (in dom0): `qvm-service -e tun aegis`

You may also wish to use the proxy VM as a disposable VM template (I do); this project is designed with that in mind:
```sh
qvm-create tun-t \
  --label red \
  --property template_for_dispvms True
qvm-prefs --set tun-t default_dispvm tun-t

qvm-create tun \
  --label black \
  --class DispVM \
  --property template=tun-t \
  --property default_dispvm=tun-t \
  --property provides_network=True
```

From there you will use tun as your `netvm`, or perhaps you will connect a firewall to it and use the firewall as the netvm.
