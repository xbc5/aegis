#!/usr/bin/env sh

# Credit for thos code goes to hkbakke: https://github.com/hkbakke/qubes-wireguard/blob/f8a0822d86a90e2860ae510c77abfca273e23b1d/bin/firewall#L1-L22

nft -f - << EOF
flush chain ip qubes custom-forward
flush chain ip6 qubes custom-forward
table ip qubes {
    chain custom-forward {
        ct state related,established counter accept
        oifname "wg*" tcp flags syn tcp option maxseg size set rt mtu counter
        iifname "vif*" oifname "wg*" counter accept
        counter reject
    }
}
table ip6 qubes {
    chain custom-forward {
        ct state related,established counter accept
        oifname "wg*" tcp flags syn tcp option maxseg size set rt mtu counter
        iifname "vif*" oifname "wg*" counter accept
        counter reject
    }
}
EOF
