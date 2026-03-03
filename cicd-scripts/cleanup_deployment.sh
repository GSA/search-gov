#!/bin/bash
set -x

echo "Starting ApplicationStop cleanup"
echo "whoami: $(whoami)"

# Clean up Capistrano repo directory's Git state to prevent ref locking issues
if [ -d "/home/search/searchgov/repo" ]; then
    echo "Found existing /home/search/searchgov/repo directory from previous Capistrano deployment"
    
    # Clean up Git locks and packed-refs that can cause ref locking issues
    if [ -d "/home/search/searchgov/repo/.git" ]; then
        echo "Cleaning up Git state to prevent ref conflicts..."
        cd /home/search/searchgov/repo
        
        # Remove any lock files
        find .git -name "*.lock" -type f -delete 2>/dev/null || true
        
        # Clean up packed refs that might be stale
        rm -f .git/packed-refs 2>/dev/null || true
        
        # Reset any partial fetches or operations
        git reset --hard HEAD 2>/dev/null || true
        git clean -fdx 2>/dev/null || true
        
        # Prune any stale remote tracking branches
        git remote prune origin 2>/dev/null || true
        
        echo "Git state cleanup completed"
    fi
    
    echo "Cleanup completed successfully"
else
    echo "No existing repo directory found - nothing to clean up"
fi

echo "ApplicationStop cleanup completed"
exit 0
