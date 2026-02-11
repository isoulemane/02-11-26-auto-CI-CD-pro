#!/bin/bash

# -------------------------------
# Variables
# -------------------------------
BRANCH="master"   # Change to 'main' if your GitHub default branch is main
FILES="Dockerfile playbook.yaml README.md config.yml webapp.war"
COMMIT_MESSAGE="Update selected files"

# -------------------------------
# Step 0: Check git status
# -------------------------------
echo "Checking git status..."
git status

# -------------------------------
# Step 1: Stage selected files
# -------------------------------
echo "Adding selected files..."
git add $FILES

# -------------------------------
# Step 2: Check if there are changes to commit
# -------------------------------
if git diff --cached --quiet; then
    echo "No changes detected for the selected files. Nothing to commit."
else
    # -------------------------------
    # Step 3: Commit changes
    # -------------------------------
    echo "Committing changes..."
    git commit -m "$COMMIT_MESSAGE"

    # -------------------------------
    # Step 4: Set branch
    # -------------------------------
    echo "Setting branch to $BRANCH..."
    git branch -M $BRANCH

    # -------------------------------
    # Step 5: Push to GitHub
    # -------------------------------
    echo "Pushing to GitHub..."
    git push -u origin $BRANCH

    echo "✅ Selected files pushed successfully!"
fi

