# Ansible Role: configure

This role configures the bootstrapped distro installation basic networking functionality

## Dependencies

- Role: `bootstarp`

## Role Variables

- `configure_playbooks_path` the root directory of the distro-configure playbooks
- `partiton_root` dictionary with the required  `mount_path`
- `hostname` the hostname variable defined in bootstrap role

## Internals

- Install ansible on live environment
- Copy `ansible-distro-configure` playbook (via archive because it's waaaay faster)
- Update the `ansible-distro-configure` inventory to configure chroot (`partition_root.mount_path`)
- Run the `ansible-distro-configure` playbook for desired `hostname`
