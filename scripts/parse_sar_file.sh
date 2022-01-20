#!/bin/bash

### Configuration part.
# The number of communication (publication) for each measurement.
NUM_COMM=5
# Time to sleep after running sub_main before running pub_main.
SUB_PUB_INTERVAL=0.1

# Maximum length of string a.k.a size of message.
#MAX_STR_LENGTH=8192
MAX_STR_LENGTH=256
# Initial value of length, that will be increased by a factor of two.
INI_STR_LENGTH=128
# Maximum number of nodes
#MAX_NUM_NODES=100
MAX_NUM_NODES=100
# Initial number of nodes, that will be increased by 20
INI_NUM_NODES=20

if [ $# != 1 ]; then
  echo "Usage: ./string_topic.sh <version>"
  exit 1
fi

VERSION=$1

# Re-compile benchmark.
if [ $? -ne 0 ]; then
  echo "Error: mix compile failed"
  exit 1
fi

# Pub1 : Sub1 test.
CUR_STR_LENGTH=${INI_STR_LENGTH}

while [ ${CUR_STR_LENGTH} -le ${MAX_STR_LENGTH} ]; do
  NUM_PUB=1
  NUM_SUB=1

  FILEPATH="./results/string/p1s1/${VERSION}/${CUR_STR_LENGTH}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  FILE_TIM="${FILEPATH}/time.csv"
  mkdir -p ${FILEPATH}

  sar -u -f ${FILEPATH}/before_usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_before_cpu_usage_${CUR_STR_LENGTH}_strings.log
  sar -r -f ${FILEPATH}/before_usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_before_memory_usage_${CUR_STR_LENGTH}_strings.log
  sar -u -f ${FILEPATH}/usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_cpu_usage_${CUR_STR_LENGTH}_strings.log
  sar -r -f ${FILEPATH}/usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_memory_usage_${CUR_STR_LENGTH}_strings.log

  CUR_STR_LENGTH=$((${CUR_STR_LENGTH} * 2))
done


# PubN : Sub1 test.
CUR_STR_LENGTH=${INI_STR_LENGTH}

while [ ${CUR_STR_LENGTH} -le ${MAX_STR_LENGTH} ]; do
  NUM_PUB=${INI_NUM_NODES}
  NUM_SUB=1
  while [ ${NUM_PUB} -le ${MAX_NUM_NODES} ]; do
  FILEPATH="./results/string/pNs1/${VERSION}/${CUR_STR_LENGTH}/${NUM_PUB}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  FILE_TIM="${FILEPATH}/time.csv"
  mkdir -p ${FILEPATH}

  sar -u -f ${FILEPATH}/before_usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_before_cpu_usage_${CUR_STR_LENGTH}_strings.log
  sar -r -f ${FILEPATH}/before_usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_before_memory_usage_${CUR_STR_LENGTH}_strings.log
  sar -u -f ${FILEPATH}/usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_cpu_usage_${CUR_STR_LENGTH}_strings.log
  sar -r -f ${FILEPATH}/usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_memory_usage_${CUR_STR_LENGTH}_strings.log

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
  FILEPATH="./results/string/p1sN/${VERSION}/${CUR_STR_LENGTH}/${NUM_SUB}"
  FILE_PUB="${FILEPATH}/pub.csv"
  FILE_SUB="${FILEPATH}/sub.csv"
  FILE_TIM="${FILEPATH}/time.csv"
  mkdir -p ${FILEPATH}
  
  sar -u -f ${FILEPATH}/before_usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_before_cpu_usage_${CUR_STR_LENGTH}_strings.log
  sar -r -f ${FILEPATH}/before_usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_before_memory_usage_${CUR_STR_LENGTH}_strings.log
  sar -u -f ${FILEPATH}/usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_cpu_usage_${CUR_STR_LENGTH}_strings.log
  sar -r -f ${FILEPATH}/usage_${CUR_STR_LENGTH}_strings.log > ${FILEPATH}/parsed_memory_usage_${CUR_STR_LENGTH}_strings.log

  NUM_SUB=$((${NUM_SUB} + 20))
  done
  CUR_STR_LENGTH=$((${CUR_STR_LENGTH} * 2))
done