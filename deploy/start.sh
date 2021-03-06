#!/usr/bin/env bash
set -e
source ./deploy/.env

echo "MY IP LOCAL: ${MY_IP}"
echo "- LOGS_FILE_PATH: ${LOGS_FILE_PATH}"
echo "- KAFKA_BROKERS: ${KAFKA_BROKERS}"

docker run -d \
  --name=zookeeper \
  -p 2181:2181 \
  -e ZOOKEEPER_CLIENT_PORT=2181 \
  confluentinc/cp-zookeeper:5.1.0

docker run -d \
  --name=kafka \
  -p 9092:9092 \
  -e KAFKA_ZOOKEEPER_CONNECT="${MY_IP}":2181 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${MY_IP}":9092 \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  -e TOPIC_AUTO_CREATE=1 \
  confluentinc/cp-kafka:5.1.0

docker run -d \
  --name=kafka-magic \
  -p 9090:80 \
  digitsy/kafka-magic
