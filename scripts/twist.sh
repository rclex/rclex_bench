#!/bin/bash

### Configuration part.
# The number of communication (publication) for each measurement.
NUM_COMM=5
# Time to sleep after running sub_main before running pub_main.
SUB_PUB_INTERVAL=0.2

# Maximum number of nodes
#MAX_NUM_NODES=100
MAX_NUM_NODES=40
# Initial number of nodes, that will be increased by 20
INI_NUM_NODES=20

if [ "$1" == string_topic ]; then
  VERSION=string_topic
  TARGET=rclex051
  MODULE=StringTopic
elif [ "$1" == string_topic_cm ]; then
  VERSION=string_topic_cm
  TARGET=rclexcm
  MODULE=StringTopicCm
elif [ "$1" == twist_topic_cm ]; then
  VERSION=twist_topic_cm
  TARGET=rclexcm
  MODULE=TwistTopicCm
else
  echo "Usage: ./twist.sh [ string_topic | string_topic_cm | twist_topic_cm ]"
  exit 1
fi

# Re-compile benchmark.
# rm -rf _build/ deps
MIX_TARGET=${TARGET} mix deps.get
MIX_TARGET=${TARGET} mix compile
if [ $? -ne 0 ]; then
  echo "Error: mix compile failed"
  exit 1
fi

# Pub1 : Sub1 test.
  NUM_PUB=1
  NUM_SUB=1

  FILEPATH="./results/p1s1/${VERSION}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  FILE_TIM="${FILEPATH}/time.csv"
  mkdir -p ${FILEPATH}

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.${MODULE}.sub_main(\"${FILE_SUB}\", ${NUM_SUB})'"
  eval ${CMD} &
  PID_SUB=$!

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.${MODULE}.pub_main(\"${FILE_PUB}\", ${NUM_PUB}, ${NUM_COMM})'"
  eval ${CMD} &
  PID_PUB=$!

  wait $PID_SUB $PID_PUB

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.Utils.aggregation_csv(\"${FILE_PUB}\", \"${FILE_SUB}\", \"${FILE_TIM}\")'"
  eval ${CMD} ;


# PubN : Sub1 test.
  NUM_PUB=${INI_NUM_NODES}
  NUM_SUB=1
while [ ${NUM_PUB} -le ${MAX_NUM_NODES} ]; do
  FILEPATH="./results/pNs1/${VERSION}/${NUM_PUB}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  FILE_TIM="${FILEPATH}/time.csv"
  mkdir -p ${FILEPATH}
  
  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.${MODULE}.sub_main(\"${FILE_SUB}\", ${NUM_SUB})'"
  eval ${CMD} &
  PID_SUB=$!

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.${MODULE}.pub_main(\"${FILE_PUB}\", ${NUM_PUB}, ${NUM_COMM})'"
  eval ${CMD} &
  PID_PUB=$!

  wait $PID_SUB $PID_PUB

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.Utils.aggregation_csv(\"${FILE_PUB}\", \"${FILE_SUB}\", \"${FILE_TIM}\")'"
  eval ${CMD} ;

  NUM_PUB=$((${NUM_PUB} + 20))
done


# Pub1 : SubN test.
  NUM_PUB=1
  NUM_SUB=${INI_NUM_NODES}
while [ ${NUM_SUB} -le ${MAX_NUM_NODES} ]; do
  FILEPATH="./results/p1sN/${VERSION}/${NUM_SUB}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  FILE_TIM="${FILEPATH}/time.csv"
  mkdir -p ${FILEPATH}
  
  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.${MODULE}.sub_main(\"${FILE_SUB}\", ${NUM_SUB})'"
  eval ${CMD} &
  PID_SUB=$!

  # Wait a while.
  sleep ${SUB_PUB_INTERVAL}

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.${MODULE}.pub_main(\"${FILE_PUB}\", ${NUM_PUB}, ${NUM_COMM})'"
  eval ${CMD} &
  PID_PUB=$!

  wait $PID_SUB $PID_PUB

  CMD="MIX_TARGET=${TARGET} mix run -e 'RclexBench.Utils.aggregation_csv(\"${FILE_PUB}\", \"${FILE_SUB}\", \"${FILE_TIM}\")'"
  eval ${CMD} ;

  NUM_SUB=$((${NUM_SUB} + 20))
done
