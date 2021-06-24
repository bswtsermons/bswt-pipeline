#!/usr/bin/env bash
# we assume an ssh key is set up between the two systems

# test connection to linode
ssh root@$1 echo > /dev/null 2>&1
if ! [[ "$?" -eq 0 ]]; then
    echo "faildz"
fi

# see if docker exists
ssh root@$1 docker ps > /dev/null 2>&1
if ! [[ "$?" -eq 0 ]]; then
    # intall docker as root
ssh root@$1 <<EOF
# following https://docs.docker.com/engine/install/debian/
export DEBIAN_FRONTEND=noninteractive
echo \$DEBIAN_FRONTEND
ssh root@$1 apt update
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | 
   gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
EOF
    
fi

# see if bswt user exists
ssh root@$1 id -u bswt > /dev/null 2>&1
if ! [[ "$?" -eq 0 ]]; then
    # create bswt user
    ssh root@$1 useradd -m bswt
fi

# see if bswt user exists
    # create bswt user

