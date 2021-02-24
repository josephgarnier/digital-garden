# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

if [[ ! -v EXPORT_TOOL_GLOBAL ]]; then
	readonly EXPORT_TOOL_GLOBAL=true

	# see https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself.
	readonly PROJECT_DIR=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")
	readonly PROJECT_ASSETS_DIR="${PROJECT_DIR}/assets"
	readonly PROJECT_EXPORT_DIR="${PROJECT_DIR}/export"
	readonly PROJECT_POSTS_DIR="${PROJECT_DIR}/posts"
	readonly PROJECT_RESOURCES_DIR="${PROJECT_DIR}/resources"
	readonly PROJECT_SCRIPTS_DIR="${PROJECT_DIR}/scripts"
	
	readonly PROJECT_README_FILE="${PROJECT_DIR}/README.md"
	readonly PROJECT_SUMMARY_FILE="${PROJECT_DIR}/SUMMARY.md"
	readonly PROJECT_EXPORT_POST_DIR="${PROJECT_EXPORT_DIR}/$(basename "${PROJECT_POSTS_DIR}")"
fi