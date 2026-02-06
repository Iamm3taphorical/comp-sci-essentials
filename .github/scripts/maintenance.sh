#!/bin/bash

# Configuration
START_DATE="2026-01-07"
VAULT_BRANCH="content-vault"

# Calculate current day
TODAY=$(date -u +%Y-%m-%d)
DAYS=$(( ($(date -d "$TODAY" +%s) - $(date -d "$START_DATE" +%s)) / 86400 + 1 ))

# Check if past 30-day window (Self-Destruct)
if [ $DAYS -gt 30 ]; then
    echo "Mission Accomplished. Initiating self-destruct..."

    # Configure Git
    git config user.name "Mahir Dyan"
    git config user.email "mahirdyan@users.noreply.github.com"

    # 1. Remove the workflow file from main
    if [ -f ".github/workflows/ci.yml" ]; then
        git rm .github/workflows/ci.yml
        git commit -m "🔥 Post-deployment cleanup: Removing CI configuration"
        git push origin HEAD:main
    fi

    # 2. Delete the vault branch (remote)
    # Note: Requires repo token permissions. If it fails, branch stays but workflow is gone.
    git push origin --delete content-vault || echo "Vault deletion skipped (permissions)"
    
    exit 0
fi

# Check if within 30-day window
if [ $DAYS -le 30 ] && [ $DAYS -ge 1 ]; then
    DAY_STR=$(printf '%02d' $DAYS)
    
    # Fetch specific day folder from vault
    git checkout origin/$VAULT_BRANCH -- scheduled-uploads/day-$DAY_STR
    
    if [ -d "scheduled-uploads/day-$DAY_STR" ]; then
        # Move files to root
        cp -r scheduled-uploads/day-$DAY_STR/* . 2>/dev/null || true
        rm -rf scheduled-uploads
        
        # Determine random delay (0-30 mins)
        DELAY=$((RANDOM % 1800))
        sleep $DELAY
        
        # Configure Git
        git config user.name "Mahir Dyan"
        git config user.email "mahirdyan@users.noreply.github.com"
        
        git add .
        
        # Select random message
        MESSAGES=(
            "📚 Added new learning resources"
            "✨ Updated study materials"
            "📖 New notes and guides"
            "🚀 Added more interview prep content"
            "📝 Updated documentation"
            "💡 Added helpful resources"
            "🎯 New problem sets added"
            "📊 Updated CS fundamentals"
        )
        MSG=${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}
        
        # Commit and push
        git commit -m "$MSG"
        git push origin HEAD:main
    fi
fi
