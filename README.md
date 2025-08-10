# Ansible RC Playbooks

Ansible roles and playbooks to install different distros and configure `.rc`.

## Prerequisite

- [Ansible][ansible]
- [`sshpass`][sshpass] **required** for `--ask-pass`
- [`git-crypt`][git-crypt] **optional** for keeping encrypted configurations.

[sshpass]: https://man.freebsd.org/cgi/man.cgi?query=sshpass
[ansible]: https://docs.ansible.com/ansible/latest/index.html
[git-crypt]: https://github.com/AGWA/git-crypt

If you are using `git-crypt`, setup your key, and override the encrypted files (`host_vars/*.yml`)
with your own version.

If you are not using `git-crypt`, delete the `.gitattributes` file and override the encrypted files
with your own version.
Ex. `rm .gitattributes && cp host_vars/ubuntuiso.local.yml.example host_vars/ubuntuiso.local.yml`

## Boot distro live image

## Playbook: distro-install

- Follow the pre-install guides for desired distro in "Boot distro live image"
- Install ansible required dependencies
- Run the playbook

```bash
ansible-galaxy install -r requirements.yml

ansible-playbook site.yml --ask-pass
```

## Special Thanks to

- [Jeff Geerling](https://www.jeffgeerling.com/), who I learned a **LOT** from his open-source work.
