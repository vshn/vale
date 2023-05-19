#!/usr/bin/env bash
set -e -u -o pipefail

vale_version="$(awk -F '=' '/VALE_VERSION=/{print $2}' Dockerfile)"
ms_style_version="$(awk -F '=' '/MS_STYLE_VERSION=/{print $2}' Dockerfile)"
openly_style_version="$(awk -F '=' '/OPENLY_STYLE_VERSION=/{print $2}' Dockerfile)"

tag="$vale_version"
msg="Release $tag

- vale: $helm_version
- Microsoft style: $ms_style_version
- Openly style: $openly_style_version
"

git tag -s "$tag" -m "$msg"
