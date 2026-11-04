#!/usr/bin/env bash
# Passwordless SSH to localhost -- required by Hadoop's start-dfs.sh /
# start-yarn.sh, which ssh into every host listed in etc/hadoop/workers.
#
# Uses a DEDICATED key (id_rsa_hadoop) so an existing default identity is
# never touched, and refuses to overwrite a key that is already there.
set -euo pipefail

KEY="${HOME}/.ssh/id_rsa_hadoop"
mkdir -p "${HOME}/.ssh"; chmod 700 "${HOME}/.ssh"

if [ -f "${KEY}" ]; then
  echo "${KEY} already exists; reusing it (not overwriting)."
else
  # Empty passphrase: Hadoop's sbin scripts cannot answer a prompt. The key is
  # authorised for localhost only. No secret is stored in this repo.
  ssh-keygen -t rsa -b 4096 -N "" -C "hadoop-pseudo-localhost" -f "${KEY}" -q
  echo "created ${KEY}"
fi

touch "${HOME}/.ssh/authorized_keys"
if ! grep -qF "$(cut -d' ' -f2 "${KEY}.pub")" "${HOME}/.ssh/authorized_keys"; then
  cat "${KEY}.pub" >> "${HOME}/.ssh/authorized_keys"
  echo "authorised for localhost"
fi
chmod 600 "${HOME}/.ssh/authorized_keys"

# Route localhost at the dedicated key; keep host-key prompts out of the way.
# The short hostname is included because sbin/start-dfs.sh rewrites a
# 0.0.0.0 secondary-namenode address to $(hostname) and ssh's there.
if ! grep -q 'IdentityFile ~/.ssh/id_rsa_hadoop' "${HOME}/.ssh/config" 2>/dev/null; then
  cat >> "${HOME}/.ssh/config" <<CFG

Host localhost 0.0.0.0 127.0.0.1 $(hostname)
    HostName 127.0.0.1
    IdentityFile ~/.ssh/id_rsa_hadoop
    StrictHostKeyChecking no
    UserKnownHostsFile ~/.ssh/known_hosts_hadoop
    LogLevel ERROR
CFG
  echo "appended localhost block to ~/.ssh/config"
fi
chmod 600 "${HOME}/.ssh/config"

echo "--- test ---"
ssh -o BatchMode=yes localhost 'echo "ssh localhost OK  ($(hostname))"'
ssh -o BatchMode=yes 0.0.0.0  'echo "ssh 0.0.0.0   OK"'
ssh -o BatchMode=yes "$(hostname)" 'echo "ssh $(hostname) OK"'
