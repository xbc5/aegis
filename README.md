
## Installation

#### Dom0 changes

You may wish to use a `DispVM` setup (I do). This project is designed with that idea in mind:

```sh
# DispVM template (calling it tun-t)
qvm-create tun-t \
  --label red \
  --property template_for_dispvms True
qvm-prefs --set tun-t default_dispvm tun-t

# The usable tunnel VM (calling it tun)
qvm-create tun \
  --label black \
  --class DispVM \
  --property template=tun-t \
  --property default_dispvm=tun-t \
  --property provides_network=True
```

From there you will use `tun` as your `netvm`, or perhaps you will connect a firewall to it and use the firewall as the netvm.

You need to run this against `tun`:
```sh
qvm-service -e tun aegis                            # enables the service
qvm-features tun vm-config.aegis--vmtype 'tunvm'    # prevent the aegis script from running in other VMs

# [OPTIONAL] When the service boots, it selects a random config. Use this RegExp pattern to limit selection.
# This "filter" also applies to the -r flag, which selects a config at random.
# Leave it UNSET if unsure; when unset, it does not limit choices.
qvm-features tun vm-config.aegis--conf-pattern '.*'  # .* is the default
```


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

