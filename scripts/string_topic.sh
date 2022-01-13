#!/bin/bash

### Configuration part.
# Time to sleep after running sub_main before running pub_main.
SUB_PUB_INTERVAL=0.1
# Maximum length of string a.k.a size of message.
MAX_STR_LENGTH=8192
# Current length, that will be increased by a factor of two.
CUR_STR_LENGTH=16

if [ $# != 1 ]; then
  echo "Usage: ./string_topic.sh <version>"
  exit 1
fi

VERSION=$1

# Re-compile benchmark.
rm -rf _build/ deps
mix deps.get
mix compile
if [ $? -ne 0 ]; then
  echo "Error: mix compile failed"
  exit 1
fi

# Pub1 : Sub1 test.
NUM_SUB=1
NUM_PUB=1

while [ ${CUR_STR_LENGTH} -le ${MAX_STR_LENGTH} ]; do
  FILEPATH="./results/p1s1/${VERSION}/${CUR_SIZE}"
  FILE_PUB="${FILEPATH}/pub.txt"
  FILE_SUB="${FILEPATH}/sub.txt"
  mkdir -p ${FILEPATH}
  
  CMD="mix run -e 'RclexBench.StringTopic.sub_main(\"${FILE_PUB}\", ${NUM_SUB})'"
  eval ${CMD} &

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="mix run -e 'RclexBench.StringTopic.pub_main(\"${FILE_SUB}\", ${NUM_PUB}, ${CUR_SIZE})'"
  eval ${CMD}

  CUR_STR_LENGTH=$((${CUR_STR_LENGTH} * 2))
done