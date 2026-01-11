# BeaglePlay

[@zfogg](https://github.com/zfogg)'s BeaglePlay setup.

## Initial config

To start, we write the latest BeaglePlay Debian Flasher image to an SDXC 
card and flash it to the BeaglePlay eMMC. Get it from 
https://www.beagleboard.org/distros .

Next, let's configure files from `root/`, run scripts from `scripts/`, and use the assets from `assets/`.

Run `ssh debian@192.168.7.2 'bash -s' < scripts/install-debian-packages.sh` to 
install all the packages. Auth tailscale.

Set up your local computer's ssh config. There's an example in assets/ssh_config.

Read and execute `./docs/homeassistant-and-diyhue-setup-README.md`.

Now your BeaglePlay is ready to go.

## Storage

We have `root/etc/fstab` with the proper setup for the 256gb SDXC card I 
bought, which we previously used to flash Debian onto the eMMC. We wipe that 
and reconfigure it for device storage.

`/home`, `/opt`, docker data (`/var/lib/docker`), and `/var/log` are all stored on the sdcard and mounted on boot.
