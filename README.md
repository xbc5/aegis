
## Installation

#### Dom0 changes

You may wish to use a `DispVM` setup (I do). This project is designed with that idea in mind:

```sh
# DispVM template (calling it tun-t)
qvm-create tun-t \
  --label purple \
  --property template_for_dispvms=True

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
# enable the service: this starts the tunnel at boot
qvm-service -e tun aegis

# allow the aegis script to run (not seting this means that it won't)
qvm-features tun vm-config.aegis--vmtype 'tunvm'

# [OPTIONAL] When the service boots, it selects a random config. Use this RegExp pattern to limit selection.
# This "filter" also applies to the -r flag, which selects a config at random.
# Leave it UNSET if unsure; when unset, it does not limit choices.
qvm-features tun vm-config.aegis--conf-pattern '.*'  # .* is the default
```


#### In the tun template (tun-t)

```sh
git clone https://www.github.com/xbc5/aegis
```

Use the `build` script that's inside of the repo:
```
./build -h
./build install
```

#### In your TemplateVM

Copy the repo to your `TemplateVM`, and run:
```
./build install
```

#### What this script does

It will `install` the approproate files and dependencies to that qube:
- `TemplateVM`: system deps, and service;
- `tun-t`: the script, firewall rules, and it will create the config directory;

The config directory is `/usr/local/etc/aegis`, and Wireguard configs live under the `confs` directory. You can install your into there. For now there's no enforced directory structure, but that may change in the future: one idea being that Wireguard confs live under `wg`, and eventually (when I get around to supporting it), OpenVPN configs will live under `ovpn`:
- `/usr/local/etc/aegis/confs/wg/...`
- `/usr/local/etc/aegis/confs/ovpn/...`

 One piece of advice, use a directory structure to distinguish different classes of config -- this will make fuzzy finding (`-c`) over them much easier, for example:
- `/usr/local/etc/aegis/confs/wg/proton/secure-core/,,,.conf`
- `/usr/local/etc/aegis/confs/wg/proton/servers/,,,.conf`
- `/usr/local/etc/aegis/confs/wg/ivpn/servers/,,,.conf`
