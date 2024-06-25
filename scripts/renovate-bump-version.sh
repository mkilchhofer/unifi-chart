#!/bin/bash
chartName="${1}"
if [ -z "${chartName}" ]; then
  echo "Missing argument 'chartName'" >&2
  exit 1
fi

parentDir="charts/${chartName}"

# Bump the chart version by one patch version
version=$(grep '^version:' "${parentDir}/Chart.yaml" | awk '{print $2}')
major=$(echo "${version}" | cut -d. -f1)
minor=$(echo "${version}" | cut -d. -f2)
patch=$(echo "${version}" | cut -d. -f3)
patch=$((patch + 1))
sed -i "s/^version:.*/version: ${major}.${minor}.${patch}/g" "${parentDir}/Chart.yaml"
