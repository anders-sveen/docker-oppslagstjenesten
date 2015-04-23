#!/bin/bash
set -e
set -u

DIR=$( cd $( dirname $0 ) && pwd )
STARTDIR="$DIR/.."
ETCDIR="$STARTDIR/etc"
ENVFILE="$ETCDIR/startup-env.sh"

if [[ -f "$ENVFILE" ]]; then
  source $ENVFILE
fi

JAVA_OPTS=${JAVA_OPTS:-""}
JAVA_TRUST_STORE=${JAVA_TRUST_STORE:-""}
JAVA_MIN_MEMORY=${JAVA_MIN_MEMORY:-"256m"}
JAVA_MAX_MEMORY=${JAVA_MAX_MEMORY:-"512m"}

SCRIPTDIR=$( cd $( dirname $0 ) && pwd )
LOG_APP_NAME=`basename "$( cd "$SCRIPTDIR/../.." && pwd && cd "$SCRIPTDIR" )"`

# Detekter om tilgjengelig java er minst version 1.7.
JAVA_HOME=${JAVA_HOME:-""}

if [[ -n "$JAVA_HOME" ]]; then
   JAVA_CMD="$JAVA_HOME/bin/java"
else
   REQUIRED_VERSION=`echo 1.7 | sed -e 's;\.;0;g'`
   java -version 2> tmp.ver
    VERSION=`cat tmp.ver | grep "java version" | awk '{ print substr($3, 2, length($3)-7); }' | sed -e 's;\.;0;g'`
    rm tmp.ver
    if [[ "$VERSION" -lt "$REQUIRED_VERSION" ]]; then
      echo "JAVA 1.7 is required, please set environment variabel JAVA_HOME or make java 1.7 the default java"
      exit -1
    else
       JAVA_CMD="java"
    fi
fi

TEMP_JAVA_OPTS=${JAVA_OPTS:-""}
if [[ -n "$JAVA_TRUST_STORE" ]]; then
  TEMP_JAVA_OPTS="$TEMP_JAVA_OPTS -Djavax.net.ssl.trustStore=$JAVA_TRUST_STORE"
fi

TEMP_JAVA_OPTS="-Xms$JAVA_MIN_MEMORY -Xmx$JAVA_MAX_MEMORY $TEMP_JAVA_OPTS -DLOG_APP_NAME=$LOG_APP_NAME"

export JAVA_OPTS="$TEMP_JAVA_OPTS"

echo " "
echo "$(date)"
echo "Starter registry-server i $DIR med JAVA_OPTS=$JAVA_OPTS"

exec $JAVA_CMD -cp "$DIR/../repo/*" $JAVA_OPTS ske.registry.server.RegistryServer $PORT_BASE
