#!/bin/bash

#########################################################
# kuby - Kubernetes Utility Script                      #
#########################################################

# Introduction:
# This script provides a set of utility functions to interact with Kubernetes (K8s) clusters. It facilitates the
# monitoring and troubleshooting of pods within a specified namespace using kubectl commands.
# For more details, refer to kubernetes/kuby/README.md

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

