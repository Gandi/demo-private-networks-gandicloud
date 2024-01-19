#!/usr/bin/env bash

echo "Please enter your Gandi Personal Access Token:"
read -sr GANDI_PAT
export TF_VAR_gandi_personal_access_token="$GANDI_PAT"
