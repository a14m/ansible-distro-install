# Ansible Role: bootstrap

This role bootstraps the installation of a linux distro

## Role Variables

- `hostname` the distro linux network hostname to be used.
- `partition_boot` the boot partition definition for role `partition`, to install bootloader
- `partition_root` the root partition definition for role `partition`, to install distro root

## Dual Booting

The role is configure for allowing dual boot multiple distros.
For example, the following `archiso.local` and `ubuntuiso.local` diff shows how to do that

```diff
+ hostname: "archlinux.local"
+ partition_wipe: true
- hostname: "ubuntuiso.local"
- partition_wipe: false
  partition_disk: "/dev/sda"
  partition_boot:
    num: 1
    name: "boot"
    flags: [boot, esp]
    part_start: "0%"
    part_end: "1.0GiB"
    fstype: "vfat"
    fstype_opts: "-F 32"
    dev: "{{ partition_disk }}1"
    mount_path: "/mnt/boot"
    fstab_opts: "defaults,nodev,nosuid,noexec,umask=0077"
  partition_swap:
    num: 2
    name: "swap"
    flags: [swap]
    part_start: "1.0GiB"
    part_end: "9.0GiB"
    fstype: "ext4"
    dev: "{{ partition_disk }}2"
    mount_path: "none"
  partition_root:
+   num: 3
+   name: "archlinux"
+   part_start: "9.0GiB"
+   part_end: "59.0GiB"
+   fstype: "ext4"
+   dev: "{{ partition_disk }}3"
-   num: 4
-   name: "ubuntu"
-   part_start: "59.0GiB"
-   part_end: "119.0GiB"
-   fstype: "ext4"
-   dev: "{{ partition_disk }}4"
    mount_path: "/mnt"
  partition_extras:
+   - num: 4
+     name: "ubuntu"
+     part_start: "59.0GiB"
+     part_end: "119.0GiB"
+     fstype: "ext4"
+     dev: "{{ partition_disk }}4"
-   - num: 3
-     name: "archlinux"
-     part_start: "9.0GiB"
-     part_end: "59.0GiB"
-     fstype: "ext4"
-     dev: "{{ partition_disk }}3"
    - num: 5
      name: "other_partiton"
      part_start: "119.0GiB"
      part_end: "100%"
      fstype: "ext4"
      dev: "{{ partition_disk }}5"
```

In other words, swap the `partition_root` configuration with the partition that is used for the installation,
and keep the rest of the mapping exactly the same.

It's required that the first system to be installed for dual booting (`archlinux` in the previous example),
sets the `partition_wipe` parameter to `true` in order to wipe the hard drive and partition it correctly,
while the other systems (`ubuntu` in the previous example) sets the `partition_wipe` to `false`.

Otherwise, the hard drive will be wiped and repartitioned again.
