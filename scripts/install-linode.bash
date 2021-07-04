#!/usr/bin/env bash
# we assume an ssh key is set up between the two systems

HOST=$1

### config 
REMOTE_USER=${REMOTE_USER:-bswt}

### steps
test_connection() {
    # test connection to linode
    ssh root@$HOST echo > /dev/null 2>&1
    if ! [[ "$?" -eq 0 ]]; then
        echo "faildz"
    fi
}

install_docker() {
    # see if docker exists
    ssh root@$HOST docker ps > /dev/null 2>&1
    if ! [[ "$?" -eq 0 ]]; then
        # intall docker as root
ssh root@$HOST <<EOF
# following https://docs.docker.com/engine/install/debian/
export DEBIAN_FRONTEND=noninteractive
echo \$DEBIAN_FRONTEND
ssh root@$HOST apt update
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
}

SSH_DIR=/home/${REMOTE_USER}/.ssh
add_user() {
    # see if bswt user exists
    ssh root@$HOST id -u $REMOTE_USER > /dev/null 2>&1
    if ! [[ "$?" -eq 0 ]]; then
        # create bswt user
        ssh root@$HOST useradd -m $REMOTE_USER
    fi
}


install_user_ssh_key() {
    # install ssh key for created user
    ssh root@$HOST ls -l ${SSH_DIR} > /dev/null 2>&1
    if ! [[ "$?" -eq 0 ]]; then
        # create ssh dir
        ssh root@$HOST mkdir $SSH_DIR
        ssh root@$HOST chmod 700 $SSH_DIR
        ssh root@$HOST chown ${REMOTE_USER}:${REMOTE_USER} $SSH_DIR
    fi

    # key file exists
    key_file=${SSH_DIR}/authorized_keys
    ssh root@$HOST ls -l ${key_file} > /dev/null 2>&1
    if ! [[ "$?" -eq 0 ]]; then
        ssh root@$HOST touch ${key_file}
        ssh root@$HOST chmod 600 ${key_file}
        ssh root@$HOST chown ${REMOTE_USER}:${REMOTE_USER} ${key_file}
    fi

    # make sure authorized key installed
    key=$(cat ~/.ssh/id_rsa.pub)
    ssh root@$HOST "grep \"$key\" ${key_file}" > /dev/null 2>&1
    if [[ "$?" -ne 0 ]]; then
        # apppend existing key to end of file
        echo do it
        ssh root@$HOST "echo \"$key\" >> ${key_file}" 
    fi
}

### mainline
install_user_ssh_key

echo sup