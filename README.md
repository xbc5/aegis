# Aegis

Because I've been waiting aegis for [Qubes-vpn-support](https://github.com/tasket/Qubes-vpn-support/issues/72) for Qubes 4.2; or perhaps because this script took aegis to write.

## Warning

This is alpha.

- [x] I hereby consent that this script has permission to brick my machine.

(heads up: it's also in the [LICENSE](LICENSE) agreement)

## Installation

You **must** set up `dom0` first.

### Using the Installation Script

If you trust the script enough to run in `dom0`, and you don't mind sending files to `dom0`, then you can use this `build` script there. If you *do* mind, then there are manual steps later in this guide.

```sh
# start a DispVM
qvm-run --dispvm=[your-dispvm] xterm

# in the DispVM
wget https://github.com/xbc5/aegis/archive/refs/tags/v0.1-alpha.tar.gz -O /tmp/aegis.tar.gz

# install into dom0
# in the dom0 terminal (keep DispVM terminal open)
cd /tmp
mkdir aegis # important
qvm-run --pass-io [the-dispvm-name] 'cat /tmp/aegis.tar.gz' | tar -xvz -C aegis --strip-components=1
sudo ./aegis/build install

# copy the installer to VMs
qvm-copy-to-vm [your TemplateVM] ./aegis  # primary TemplateVM
qvm-copy-to-vm [tun template] ./aegis  # the created DispVM template, or the tun qube if you didn't create one

# run the installer on VMs
qvm-run --pass-io [your TemplateVM] 'sudo ~/QubesIncoming/dom0/aegis/build install'
qvm-run --pass-io [tun template] 'sudo ~/QubesIncoming/dom0/aegis/build install'

# at this point, inside the DispVM, you will want to put your Wireguard
# configs into /usr/local/etc/aegis/confs/; give them names that allow
# you to fuzzy find over them (e.g. create a semantic directory hierarchy).
# The file extensions must be .conf.

# run the tun
qvm-shutdown [my TemplateVM] [tun template] # <-- you MUST do this..
qvm-start [tun qube] # <-- ..before this
```

Now you can run `aegis -h` in `dom0` 

### What This Script Does

It will `install` the appropriate files and dependencies into that domain:
- `TemplateVM`: system deps, and service;
- `tun-t`: the script, firewall rules, and it will create the config directory;
- `dom0`: create the qubes (if you agree), install the script, and environment variables.

### Info

#### profile.d

In `dom0`, the installer creates the `/etc/profile.d/aegis.sh` file, which contains two variables:
- `TUN_NAME`: the name of the qube that connects the tunnel -- the dom0 script (`aegis`) uses this to target the correct qube;
- `TERM_EXEC`: a command **prefix** to launch the fuzzy finder in a terminal -- e.g. `TERM_EXEC='xterm -e'` (default) or `TERM_EXEC='kitty bash -c'`. The runtime script injects the command like so: `xterm -e '<<command>>'`; so you only need to specify the **prefix**.

**If you do not use the installer**, you must create this file manually:
```sh
TUN_NAME='tun'
TERM_EXEC='xterm -e'
```

#### Wireguard config files

The config directory (in the `tun` qube) is `/usr/local/etc/aegis`, and the Wireguard configs live under the `confs` subdirectory: you can install your own configs into there. For now, there's no enforced directory structure, but that may change in the future: one idea that I have is for Wireguard confs to live under `wg`, and eventually (when I get around to supporting it), OpenVPN configs will live under `ovpn`:
- `/usr/local/etc/aegis/confs/wg/...`
- `/usr/local/etc/aegis/confs/ovpn/...`

 One piece of advice: use a directory structure to distinguish the different classes of your configs -- this will make fuzzy finding (`-c`) over them much easier.. For example:
- `/usr/local/etc/aegis/confs/wg/proton/secure-core/**/*.conf`
- `/usr/local/etc/aegis/confs/wg/proton/servers/**/*.conf`
- `/usr/local/etc/aegis/confs/wg/ivpn/servers/**/*.conf`

### Manual Dom0 Installation (alternative)

You may not trust the script in `dom0`, so follow these instructions instead.

First, create the `profile.d` file (see the `Info` section).

Then create the necessary qubes. Note that you do not *need* to create a `DispVM`, but it's recommended, and it works well:
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

You need to run this against `tun` and/or `tun-t`:

```sh
# enable the service: this starts the tunnel at boot
qvm-service -e tun aegis

# allow the aegis script to run (not setting this means that it won't)
qvm-features tun vm-config.aegis--vmtype 'tunvm'
qvm-features tun-t vm-config.aegis--vmtype 'tunvm'

# [OPTIONAL] When the service boots, it selects a random config.
# Use this RegExp pattern to limit selection. This "filter" also
# applies to the -r flag, which selects a config at random.
#
# Leave it UNSET if unsure; when unset, it does not limit choices.
# You can set it (in dom0) at any time via `aegis -p`.
qvm-features tun vm-config.aegis--conf-pattern '.*'  # .* is the default
```

Unfortunately, you will need to edit the [dom0--aegis](artifacts/dom0--aegis) script by hand (3 lines):
```sh
REMOTE_SCRIPT="<<REMOTE_SCRIPT>>"      # /usr/local/bin
PROFILE_D="<<PROFILE_D_PATH>>"         # /usr/profile.d/aegis.sh
FEAT_SEARCH_PAT="<<FEAT_SEARCH_PAT>>"  # vm-config.aegis--conf-pattern
```

Becomes:
```sh
REMOTE_SCRIPT="/usr/local/bin"
PROFILE_D="/usr/profile.d/aegis.sh"
FEAT_SEARCH_PAT="vm-config.aegis--conf-pattern"
```

Then copy it into `/usr/local/bin/aegis` (`aegis` is the file name, not a directory).


