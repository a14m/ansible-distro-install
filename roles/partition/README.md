# Ansible Role: partition

This role partitions the desired host with defined partition map

## Role Variables

- `partition_disk` the `dev/disk` to be partitioned (required)
- `partition_wipe` whether or not to wipe the disk before partitioning (default: false)
- `partition_root` partition map (defined below)
- `partition_boot` partition map (defined below)
- `partition_swap` partition map (defined below)
- `partition_extras` list of partition map (defined below) default: []

### Partition map

This is the `dict` defining the partition properties:

- `num` partition number (required)
- `name` partition name (required)
- `label` partition label (default `gpt`) check `argument_specs` for available labels
- `flags` partition flags (default `[]`) check `argument_specs` for available flags
- `part_start` address to start partition (required, ex: `11G`, `0%`)
- `part_end` address to end partition (required, ex: `250G`, `100%`)
- `fstype` partition file system type (required) check `argument_specs` for available file systems
- `fstype_opts` list of options to be passed to `mkfs` (default: `""`)
- `dev` device mounted path (required, ex: `/dev/nvme0n1p4`, `/dev/sdb4`)
- `mount_path` mount path directory of the partition (required, ex: `/mnt`)
- `fstab_opts` options to add to `fstab` mount (default `"defaults"`)

## Internals

- force erase/wipe partition when configured with `partition_wipe: true`
- ensure swap is unmounted (to avoid failures on multiple consequent runs)
- ensure partitions are unmounted (respecting mount tree), ex. `/mnt/dir/sub` is unmounted before `/mnt/dir`
- partition the partition list provided
- create (force) file system on partitions
- create swap partition (using `mkswap` and `swapon` as ansible parted doesn't support that)
- mount partitions (respecting mount tree), ex. `/mnt` is mounted before `/mnt/dir` before `/mnt/dir/sub`
