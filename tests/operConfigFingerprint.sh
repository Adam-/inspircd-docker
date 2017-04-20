#!/bin/sh
echo "
         ######################################
         ###        Oper config test         ##
         ###          (Fingerprint)          ##
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Generate some random ports for testing
CLIENT_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=10000 -v r=19999 '{printf "%i\n", f + r * $1 / 65536}')
TLS_CLIENT_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=20000 -v r=29999 '{printf "%i\n", f + r * $1 / 65536}')
SERVER_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=30000 -v r=39999 '{printf "%i\n", f + r * $1 / 65536}')
TLS_SERVER_PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=40000 -v r=49999 '{printf "%i\n", f + r * $1 / 65536}')


# Make sure the ports are not already in use. In case they are rerun the script to get new ports.
[ $(netstat -an | grep LISTEN | grep :$CLIENT_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -an | grep LISTEN | grep :$TLS_CLIENT_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -an | grep LISTEN | grep :$SERVER_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }
[ $(netstat -an | grep LISTEN | grep :$TLS_SERVER_PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }

TESTFILE=$(mktemp /tmp/operConfigFingerprint.XXXXXX)

OPERNAME=Alice
OPERFINGERPRINT=bob
OPERAUTOLOGIN=no

mkdir -p "$(dirname $TESTFILE)"

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d -p 127.0.0.1:${CLIENT_PORT}:6667 -p 127.0.0.1:${TLS_CLIENT_PORT}:6697 -e "INSP_OPER_NAME=$OPERNAME" -e "INSP_OPER_FINGERPRINT=$OPERFINGERPRINT" -e "INSP_OPER_AUTOLOGIN=$OPERAUTOLOGIN" inspircd:testing)

sleep 10

docker exec ${DOCKERCONTAINER} /bin/sh /inspircd/conf/opers.sh >"$TESTFILE"

grep "name=\"operName\" value=\"$OPERNAME\"" "$TESTFILE"
grep "name=\"operFingerprint\" value=\"$OPERFINGERPRINT\"" "$TESTFILE"
grep "fingerprint=\"&operFingerprint;\"" "$TESTFILE"

# Clean up
rm "$TESTFILE"
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER}
