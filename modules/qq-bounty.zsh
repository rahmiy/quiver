#!/usr/bin/env zsh

############################################################# 
# qq-bounty
#############################################################

qq-bounty-help() {
  cat << END

qq-bounty
----------
The bounty namespace provides commands for generating scope files
and other system settings.

Commands
--------
qq-bounty-install: installs dependencies
qq-bounty-scope: generate a scope regex by root word (matches all to the left and right)
qq-bounty-rescope-txt: uses rescope to generate scope from a url
qq-bounty-rescope-burp: uses rescope to generate burp scope (JSON) from a url
qq-bounty-sudoers-easy: removes the requirment for sudo for common commands like nmap
qq-bounty-sudoers-harden: removes sudo exclusions
qq-bounty-sync-data: sync data from a remote server directory, such as your VPS to a local directory using SSHFS

END
}

qq-bounty-install() {
  __pkgs fusermount sshfs rsync
  qq-install-golang
  go get -u github.com/root4loot/rescope
}

qq-bounty-scope() {
  qq-vars-set-project
  local word && read "word?$fg[cyan]WORD:$reset_color "
  print -z "echo \"^.*?${word}\..*\$ \" >> ${__PROJECT}/scope.txt"
}

qq-bounty-rescope-burp() {
  qq-vars-set-project
  local url && read "url?$fg[cyan]URL:$reset_color "
  print -z "rescope --burp -u ${url} -o ${__PROJECT}/burp/scope.json"
}

qq-bounty-rescope-txt() {
  qq-vars-set-project
  local url && read "url?$fg[cyan]URL:$reset_color "
  print -z "rescope --raw -u ${url} -o ${__PROJECT}/scope.txt"
}

qq-bounty-sudoers-easy() {
  __warn "This is dangerous! Remove when done."
  print -z "echo \"$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/nmap, /usr/bin/masscan, /usr/sbin/tcpdump\" | sudo tee /etc/sudoers.d/$USER"
}
alias easymode="qq-bounty-sudoers-easy"

qq-bounty-sudoers-harden() {
  print -z "sudo rm /etc/sudoers.d/$USER"
}
alias hardmode="qq-bounty-sudoers-harden"

qq-bounty-sync-data() {
  __warn "Enter your SSH connection username@remote_host"
  local ssh && read "ssh?$(__cyan SSH: )"
  __warn "Enter the full remote path to the directory your want to copy from"
  local rdir $$ read "rdir?$(__cyan REMOTE DIR: )"
  __warn "Enter the full local path to the directory to use as a mount point"
  local mnt $$ read "mnt?$(__cyan LOCAL MOUNT: )"
  __warn "Enter the full local path to the directory to sync the data to"
  local ldir $$ read "ldir?$(__cyan LOCAL DIR: )"

  __ok "Mounting $rdir to $mnt ..."
  sshfs ${ssh}:${rdir} ${mnt}

  __ok "Syncing data from $mnt to $ldir ..."
  rsync -avuc ${mnt} ${ldir}

  __ok "Unmounting $mnt. ..."
  sudo fusermount -u ${mnt}

  __ok "Sync Completed"
}
