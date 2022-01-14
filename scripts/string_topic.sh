#!/bin/bash

### Configuration part.
# The number of communication (publication) for each measurement.
NUM_COMM=5
# Time to sleep after running sub_main before running pub_main.
SUB_PUB_INTERVAL=0.1

# Maximum length of string a.k.a size of message.
MAX_STR_LENGTH=8192
# Initial value of length, that will be increased by a factor of two.
INI_STR_LENGTH=16
# Maximum number of nodes
MAX_NUM_NODES=100
# Initial number of nodes, that will be increased by 20
INI_NUM_NODES=20

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
CUR_STR_LENGTH=${INI_STR_LENGTH}

while [ ${CUR_STR_LENGTH} -le ${MAX_STR_LENGTH} ]; do
  NUM_PUB=1
  NUM_SUB=1

  FILEPATH="./results/p1s1/${VERSION}/${CUR_STR_LENGTH}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  mkdir -p ${FILEPATH}

  CMD="mix run -e 'RclexBench.StringTopic.sub_main(\"${FILE_SUB}\", ${NUM_SUB})'"
  eval ${CMD} &
  PID_SUB=$!

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="mix run -e 'RclexBench.StringTopic.pub_main(\"${FILE_PUB}\", ${NUM_PUB}, ${CUR_STR_LENGTH}, ${NUM_COMM})'"
  eval ${CMD} &
  PID_PUB=$!

  wait $PID_SUB $PID_PUB

  CUR_STR_LENGTH=$((${CUR_STR_LENGTH} * 2))
done


# PubN : Sub1 test.
CUR_STR_LENGTH=${INI_STR_LENGTH}

while [ ${CUR_STR_LENGTH} -le ${MAX_STR_LENGTH} ]; do
  NUM_PUB=${INI_NUM_NODES}
  NUM_SUB=1
  while [ ${NUM_PUB} -le ${MAX_NUM_NODES} ]; do
  FILEPATH="./results/pNs1/${VERSION}/${CUR_STR_LENGTH}/${NUM_PUB}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  mkdir -p ${FILEPATH}
  
  CMD="mix run -e 'RclexBench.StringTopic.sub_main(\"${FILE_SUB}\", ${NUM_SUB})'"
  eval ${CMD} &
  PID_SUB=$!

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="mix run -e 'RclexBench.StringTopic.pub_main(\"${FILE_PUB}\", ${NUM_PUB}, ${CUR_STR_LENGTH}, ${NUM_COMM})'"
  eval ${CMD} &
  PID_PUB=$!

  wait $PID_SUB $PID_PUB

  NUM_PUB=$((${NUM_PUB} + 20))
  done
  CUR_STR_LENGTH=$((${CUR_STR_LENGTH} * 2))
done


# Pub1 : SubN test.
CUR_STR_LENGTH=${INI_STR_LENGTH}

while [ ${CUR_STR_LENGTH} -le ${MAX_STR_LENGTH} ]; do
  NUM_PUB=1
  NUM_SUB=${INI_NUM_NODES}
  while [ ${NUM_SUB} -le ${MAX_NUM_NODES} ]; do
  FILEPATH="./results/p1sN/${VERSION}/${CUR_STR_LENGTH}/${NUM_SUB}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  mkdir -p ${FILEPATH}
  
  CMD="mix run -e 'RclexBench.StringTopic.sub_main(\"${FILE_SUB}\", ${NUM_SUB})'"
  eval ${CMD} &
  PID_SUB=$!

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="mix run -e 'RclexBench.StringTopic.pub_main(\"${FILE_PUB}\", ${NUM_PUB}, ${CUR_STR_LENGTH}, ${NUM_COMM})'"
  eval ${CMD} &
  PID_PUB=$!

  wait $PID_SUB $PID_PUB

  NUM_SUB=$((${NUM_SUB} + 20))
  done
  CUR_STR_LENGTH=$((${CUR_STR_LENGTH} * 2))
done