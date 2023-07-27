#!/bin/bash

#  ██████  ██ ████████      ██████  ██████  ███    ███ ███    ███ ██ ████████     ███    ███ ███████ ███████ ███████  █████   ██████  ███████ 
# ██       ██    ██        ██      ██    ██ ████  ████ ████  ████ ██    ██        ████  ████ ██      ██      ██      ██   ██ ██       ██      
# ██   ███ ██    ██        ██      ██    ██ ██ ████ ██ ██ ████ ██ ██    ██        ██ ████ ██ █████   ███████ ███████ ███████ ██   ███ █████   
# ██    ██ ██    ██        ██      ██    ██ ██  ██  ██ ██  ██  ██ ██    ██        ██  ██  ██ ██           ██      ██ ██   ██ ██    ██ ██      
#  ██████  ██    ██         ██████  ██████  ██      ██ ██      ██ ██    ██        ██      ██ ███████ ███████ ███████ ██   ██  ██████  ███████ 
                                                                                                                                            
# Creates template for git commit message.

set -euo pipefail
IFS=$'\n\t'

cat <<- "EOF" | tee ~/.gitcommitmessage.txt
type(optional_scope): short_summary_in_present_tense

#(optional body: explains motivation for the change)

#(optional footer: note BREAKING CHANGES here, and issues to be closed)

# feat: A new feature.
# fix: A bug fix.
# docs: Documentation changes.
# style: Changes that do not affect the meaning of the code (white-space, formatting, missing semicolons, etc).
# refactor: A code change that neither fixes a bug nor adds a feature.
# perf: A code change that improves performance.
# test: Changes to the test framework.
# build: Changes to the build process or tools.
# chore: Housekeeping changes.
EOF
