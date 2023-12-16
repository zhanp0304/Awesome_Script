# GitLab Multi-Project Merge Request Script

## Overview

This Bash script simplifies the process of creating merge requests across multiple GitLab projects simultaneously. 
It addresses the repetitive nature of such tasks, especially in scenarios where \
you need to submit merge requests to multiple repositories with different target branches.

## Features

- **Interactive Selection:**
    - Choose multiple projects and target branches interactively.
    - Conveniently set the source branch for the merge request.

- **Dynamic Assignee:**
    - Specify an assignee for the merge request.
    - Supports assigning multiple merge requests to different assignees.

- **GitLab API Integration:**
    - Utilizes GitLab API to fetch project and user information.
    - Creates merge requests programmatically.

- **Debug Mode:**
    - Enable debug mode to view detailed execution steps.
    - Useful for troubleshooting and understanding the script's behavior.

## Usage

```bash
./multi_merge_request.sh [debug_flag] [gitlab_host] [access_token] [default_assignee]
