#!/bin/bash
# Update the starsim_ai submodule to the latest remote commit
git submodule update --remote starsim_ai
git add starsim_ai
git commit -m "Update starsim_ai submodule"
