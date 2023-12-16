#!/bin/bash

function my_echo_green() {
  local echo_content=$1
  echo -e "\033[32m${echo_content}\033[0m" >&2
}

# echo function for preventing its output polluting the result of core function
function my_echo_red() {
  local echo_content=$1
  echo -e "\033[31m${echo_content}\033[0m" >&2
}

# Function to create a Kafka topic
create_topic() {
  # Get the list of Kafka brokers from the environment variables
  KAFY_KAFKA_BROKERS=$KAFY_KAFKA_BROKERS
  # Get the topic name from the first parameter
  TOPIC_NAMES="$@"

  # Loop through the topic names and construct the Kafka topic describe command
  for TOPIC_NAME in $TOPIC_NAMES; do
    # Construct the Kafka topic create command
    KAFKA_CREATE_CMD="bin/kafka-topics.sh --zookeeper $KAFY_KAFKA_BROKERS -create -replication-factor 3 --partitions 3 --topic $TOPIC_NAME"

    # Execute the Kafka topic create command
    my_echo_green "Creating Kafka topic: $TOPIC_NAME"
    my_echo_green "Executing command: $KAFKA_CREATE_CMD"
    eval $KAFKA_CREATE_CMD
  done
}

# Function to describe a Kafka topic
describe_topic() {
  # Get the list of Kafka brokers from the environment variables
  KAFY_KAFKA_BROKERS=$KAFY_KAFKA_BROKERS
  # Get the topic names from the parameters
  TOPIC_NAMES="$@"

  # Loop through the topic names and construct the Kafka topic describe command
  for TOPIC_NAME in $TOPIC_NAMES; do
    KAFKA_DESCRIBE_CMD="bin/kafka-topics.sh --zookeeper $KAFY_KAFKA_BROKERS --describe --topic $TOPIC_NAME"
    # Execute the Kafka topic describe command
    my_echo_green "Describing Kafka topic: $TOPIC_NAME"
    my_echo_green "Executing command: $KAFKA_DESCRIBE_CMD"
    eval $KAFKA_DESCRIBE_CMD
  done
}

# Main program

# Set the Kafka brokers environment variable
export KAFY_KAFKA_BROKERS="<your_kafka_broker_host_1>:2181,<your_kafka_broker_host_2>:2181,<your_kafka_broker_host_3>:2181"

cd /Users/zhanpeng/Documents/script/ || exit

# Get the command and topic names from the user input
COMMAND=$1
shift
TOPIC_NAMES="$@"

# Check the command and call the appropriate function
case $COMMAND in
"create")
  create_topic $TOPIC_NAMES
  ;;
"describe")
  describe_topic $TOPIC_NAMES
  ;;
*)
  my_echo_red "Invalid command: $COMMAND"
  my_echo_red "Usage: kafy [create|describe] topic1 [topic2 ...]"
  exit 1
  ;;
esac
