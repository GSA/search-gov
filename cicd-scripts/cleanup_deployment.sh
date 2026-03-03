#!/bin/bash
set -x

echo "Starting ApplicationStop cleanup"
echo "whoami: $(whoami)"

# Clean up Capistrano repo directory if it exists to prevent conflicts with CodeDeploy
if [ -d "/home/search/searchgov/repo" ]; then
    echo "Found existing /home/search/searchgov/repo directory from previous Capistrano deployment"
    echo "Removing to prevent CodeDeploy conflict..."
    rm -rf /home/search/searchgov/repo
    echo "Cleanup completed successfully"
else
    echo "No existing repo directory found - nothing to clean up"
fi

# Also clean up any stale locks or temp files that might cause issues
if [ -d "/home/search/searchgov/.git" ]; then
    echo "Cleaning up any stale git locks..."
    rm -f /home/search/searchgov/.git/index.lock
fi

echo "ApplicationStop cleanup completed"
exit 0
