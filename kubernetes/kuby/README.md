# kuby - Kubernetes Utility Script

## Introduction

This script provides a set of utility functions to interact with Kubernetes (K8s) clusters. It facilitates the monitoring and troubleshooting of pods within a specified namespace using kubectl commands.

## Default Configuration

- By default, the kubeconfig file is assumed to be located at `${HOME}/Documents/script/your-kubeconfig.yml`.
- The default namespace is set to "o2".

## Functions

1. **my_echo_white(), my_echo_green(), my_echo_red():**
    - Custom echo functions to print text in white, green, or red for better visibility and differentiation.

2. **find_pod():**
    - Searches for a running pod within the specified namespace based on a provided search string.
    - If multiple matching pods are found, the user is prompted to choose one.
    - Returns the name of the selected pod.

3. **watch_pod():**
    - Monitors the logs of a specified pod continuously, starting from the last 1 minute.

4. **exec_command():**
    - Executes a specified command inside a pod. Specifically designed for running 'arthas-boot.jar' for debugging.

5. **main():**
    - The main function that interprets command-line arguments and triggers the corresponding actions.
    - Supports two commands: 'watch' to monitor pod logs and 'arthas' to execute arthas-boot.jar inside a pod.

## Usage

```bash
./kuby [watch|arthas] [short_pod_name]
# Example 1: ./kuby watch my-pod
# Example 2: ./kuby arthas another-pod
