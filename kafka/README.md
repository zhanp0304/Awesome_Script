# Kafy - Kafka Topic Management Script

## Overview

`Kafy` is a Bash script designed to simplify the management of Kafka topics. It provides functions to create and describe Kafka topics using the Kafka command-line tools. The script is intended to be used in environments where Kafka is set up with Zookeeper for topic management.

## Features

- **Topic Creation:**
    - Create one or more Kafka topics with specified replication factors and partitions.

- **Topic Description:**
    - Retrieve detailed information about one or more Kafka topics.

- **Color-Coded Output:**
    - Utilizes color-coded output to enhance readability of status messages.

## Prerequisites

- **Kafka Cluster:** Ensure you have a Kafka cluster set up with Zookeeper.
- **Kafka Command-Line Tools:** The script relies on the Kafka command-line tools (`kafka-topics.sh`). Make sure these tools are available in your environment.

## Usage

```bash
./kafy.sh [create|describe] topic1 [topic2 ...]
