#!/bin/bash

#  ██████  ██ ████████ ██  ██████  ███    ██  ██████  ██████  ███████
# ██       ██    ██    ██ ██       ████   ██ ██    ██ ██   ██ ██
# ██   ███ ██    ██    ██ ██   ███ ██ ██  ██ ██    ██ ██████  █████
# ██    ██ ██    ██    ██ ██    ██ ██  ██ ██ ██    ██ ██   ██ ██
#  ██████  ██    ██    ██  ██████  ██   ████  ██████  ██   ██ ███████

# Adds personal entries to gitignore.

set -euo pipefail
IFS=$'\n\t'

grep --quiet "# Lobo" ~/.gitignore || { echo -e "# Lobo
*credentials*
__scratch__/
.idea/
sub/
.venv/

$(cat ~/.gitignore)" > ~/.gitignore; }
