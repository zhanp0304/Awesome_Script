#!/bin/bash

#########################################################
# kuby - Kubernetes Utility Script                      #
#########################################################

# Introduction:
# This script provides a set of utility functions to interact with Kubernetes (K8s) clusters. It facilitates the
# monitoring and troubleshooting of pods within a specified namespace using kubectl commands.

# Default Configuration:
# - By default, the kubeconfig file is assumed to be located at ${HOME}/Documents/script/your-kubeconfig.yml.
# - The default namespace is set to "rise".

# Functions:
# 1. my_echo_white(), my_echo_green(), my_echo_red():
#    - Custom echo functions to print text in white, green, or red for better visibility and differentiation.

# 2. find_pod():
#    - Searches for a running pod within the specified namespace based on a provided search string.
#    - If multiple matching pods are found, the user is prompted to choose one.
#    - Returns the name of the selected pod.

# 3. watch_pod():
#    - Monitors the logs of a specified pod continuously, starting from the last 1 minute.

# 4. exec_command():
#    - Executes a specified command inside a pod. Specifically designed for running 'arthas-boot.jar' for debugging.

# 5. main():
#    - The main function that interprets command-line arguments and triggers the corresponding actions.
#    - Supports two commands: 'watch' to monitor pod logs and 'arthas' to execute arthas-boot.jar inside a pod.

# Usage:
# - kuby [watch|arthas] [short_pod_name]
#   - Example 1: ./kuby watch my-pod
#   - Example 2: ./kuby arthas another-pod

# Dependencies:
# - Requires 'kubectl' to be installed and configured with the appropriate kubeconfig file.

# Note:
# - Ensure that 'kubectl' is in your system's PATH.
# - Customize the default values for KUBE_CONFIG_PATH and KUBE_NAMESPACE as needed.

# Author:
# Rise


# Date:
# 2023.03.01

# Set default value of kubeconfig parameter
KUBE_CONFIG_PATH=${KUBE_CONFIG_PATH:-"${HOME}/Documents/script/your-kubeconfig.yml"}

# Set the namespace
KUBE_NAMESPACE=${KUBE_NAMESPACE:-"rise"}

function my_echo_white() {
  local echo_content=$1
  echo -e "\033[37m${echo_content}\033[0m" >&2
}

# echo function for preventing its output polluting the result of core function
function my_echo_green() {
  local echo_content=$1
  echo -e "\033[32m${echo_content}\033[0m" >&2
}

# echo function for preventing its output polluting the result of core function
function my_echo_red() {
  local echo_content=$1
  echo -e "\033[31m${echo_content}\033[0m" >&2
}

# Define a function to find a pod by name
function find_pod() {
  local search=$1
  local match_pods=$(kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE get pods | grep -E "$search.*Running" | head -n 1)

  local pod_name=""
  if [[ -z "$match_pods" ]]; then
    my_echo_red "No pods found matching search string '$search'"
    exit 1
  elif [[ $(kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE get pods -o name | grep "$search" | wc -l) -gt 1 ]]; then
    my_echo_white "Multiple pods found matching search string: ${search}"
    local result=$(kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE get pods --output='custom-columns=NAME:.metadata.name,STATUS:.status.phase' | grep -E "$search.*Running" | awk '{print NR ". " $1 " (" $2 ")"}')
    my_echo_green "${result}"
    read -p $'\033[34mPlease choose a pod number: \033[0m' -r pod_number
    pod_name=$(kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE get pods | grep -E "$search.*Running" | awk -v n=$pod_number 'NR==n {print $1}')
  else
    pod_name=$(kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE get pods | grep -E "$search.*Running" | awk -v n=1 'NR==n {print $1}')
  fi
  echo "$pod_name"
}

# Define a function to watch a pod's logs
function watch_pod() {
  local pod_name=$1
  kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE logs -f $pod_name --since 1m
}

# Define a function to execute a command inside a pod
function exec_command() {
  local pod_name=$1
  kubectl --kubeconfig=$KUBE_CONFIG_PATH -n $KUBE_NAMESPACE exec -it $pod_name -- java -jar arthas-boot.jar 1
}

# Define the main function
function main() {
  if [[ "$1" == "watch" ]]; then
    if [[ -z "$2" ]]; then
      my_echo_red "Invalid command. Usage: kuby [watch|arthas] [short_pod_name]"
      exit 1
    else
      local pod_name=$(find_pod $2)
      if [[ -z "$pod_name" ]]; then
        exit 1
      fi
      watch_pod $pod_name
    fi
  elif [[ "$1" == "arthas" ]]; then
    if [[ -z "$2" ]]; then
      my_echo_red "Invalid command. Usage: kuby [watch|arthas] [short_pod_name]"
      exit 1
    else
      local pod_name=$(find_pod $2)
      if [[ -z "$pod_name" ]]; then
        exit 1
      fi
      exec_command $pod_name
    fi
  else
    my_echo_red "Invalid command. Usage: kuby [watch|arthas] [short_pod_name]"
    exit 1
  fi
}

# Call the main function with command line arguments
main $@

