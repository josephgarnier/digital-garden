# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

declare DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi
source "${DIR}/global.sh"
source "${DIR}/yaml.sh"
source "${DIR}/two_dim_assoc_array.sh"

#######################################
# PRIVATE
#######################################

#######################################
# Extract meta data in frontmatter in YAML of a markdown file.
# Globals:
#   None.
# Arguments:
#   <file_path>: path to a markdown file.
# Outputs:
#   Write the metadata to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
__extract_metadata()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 1 )); then
		echo -error "ERROR: usage: __extract_metadata <file_path>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r file_path="${1}"
	
	local -r delimiter="-{3}"
	local -r frontmatter=$(sed -n -r "/"${delimiter}"/{:loop n; /"${delimiter}"/q; p; b loop}" "${file_path}") # see https://stackoverflow.com/questions/20943025/how-can-i-get-sed-to-quit-after-the-first-matching-address-range
	echo "${frontmatter}"
}

#######################################
# Extract meta data in frontmatter in YAML of a markdown file, then fill an array with them.
# Globals:
#   None.
# Arguments:
#   <file_path>: path to a markdown file.
#   <ref:result_file_info>: reference to the associative array that will be filled by the function.
# Outputs:
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
__fill_file_info()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 2 )); then
		echo -error "ERROR: usage: __fill_file_info <file_path> <ref:result_file_info>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r file_path="${1}"
	local -n result_file_info="${2}"

	local -r frontmatter=$(__extract_metadata ${file_path})
	local -r prefix="file_"
	local -r yaml_string=$(parse_yaml "${frontmatter}" "${prefix}")
	unset_variables "${yaml_string[@]}"
	eval "${yaml_string}"

	eval "result_file_info[id]=\"\${${prefix}id}\""
	eval "result_file_info[access]=\"\${${prefix}access}\""
	result_file_info[path]="${file_path}"

	unset_variables "${yaml_string[@]}"
}

#######################################
# Explore the directory of post and fill an array with all files information like "id", "path", "access", etc.
# Globals:
#   PROJECT_POSTS_DIR.
# Arguments:
#   <ref:post_file_info_found>: reference to the associative array that will be filled by the function.
# Outputs:
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
__scan_post_directory()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 1 )); then
		echo -error "ERROR: usage: __scan_post_directory <ref:post_file_info_found>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -n post_file_info_found="${1}"

	for file in $(find "${PROJECT_POSTS_DIR}" -name "*.md"); do
		local -A file_info=()
		__fill_file_info "${file}" "file_info"
		#todo make path relative
		file_info[path]=$(realpath --relative-to="${PROJECT_POSTS_DIR}" "${file_info[path]}")
		local id=${file_info[id]}
		if [[ ! -z "${id}" ]]; then
			2d_assoc_array.append "post_file_info_found" "${id}" "file_info"
		fi
		unset file_info
		unset id
	done
}

#######################################
# Substitute all linked id in the body of the file by their file path.
# Globals:
#   None.
# Arguments:
#   <ref:file_info_to_substitute>: reference to the associative array of the file that will be edited by the function.
#   <ref:all_file_info>: reference to the associative array of all files.
#   <file_path>: path to the file to edit.
# Outputs:
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#   -1: if the file to edit doesn't exists.
#######################################
__substitute_ids_by_links()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: __substitute_ids_by_links <ref:file_info_to_substitute> <ref:all_file_info> <file_path>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -i FILE_NOT_FOUND=-1
	local -n -r file_info_to_substitute="${1}"
	local -n -r all_file_info="${2}"
	local -r file_path="${3}"

	if [[ ! -f "${file_path}" ]]; then
		echo -error "ERROR: file \"${file_path}\" doesn't exists"
		exit ${FILE_NOT_FOUND}
	fi
	
	local -r ID_PATTERN="[[:digit:]]{14}"
	local -a linked_ids_to_replace=( \
		$(grep --extended-regexp --only-matching "\[\["${ID_PATTERN}"\]\]" "${file_path}" | \
			sort | \
			uniq | \
			grep --extended-regexp --only-matching "${ID_PATTERN}" \
		) \
	)

	local -a sed_command=(sed --regexp-extended --in-place)
	for linked_id in "${linked_ids_to_replace[@]}"; do
		if [[ -v "all_file_info[${linked_id}]" ]] ; then
			local -n linked_file_info=$(2d_assoc_array.get_ref_value "all_file_info" "${linked_id}")
			assert_eq "${linked_file_info[id]}" "${linked_id}" "Ids are differents"
			sed_command+=(--expression "s,\[\["${linked_file_info[id]}"\]\],[["${linked_file_info[path]}"]],g")
		fi
	done
	sed_command+=("${file_path}")
	"${sed_command[@]}"
}

#######################################
# PUBLIC
#######################################

#######################################
# The Main function.
# Globals:
#   PROJECT_DIR.
#   PROJECT_ASSETS_DIR.
#   PROJECT_EXPORT_DIR.
#   PROJECT_POSTS_DIR.
#   PROJECT_RESOURCES_DIR.
#   PROJECT_SCRIPTS_DIR.
#   PROJECT_EXPORT_POST_DIR.
# Arguments:
#   None.
# Outputs:
#   Write messages to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   -1: if a project folder is missing or if they are too many folder.
#######################################
main() {
	echo -e "============================================="
	echo -e "               Exporting Tool                "
	echo -e "============================================="

	# General variables declaration.
	echo -e "Initialize general variables."
	local -r -a PROJECT_DIRS=( \
		"${PROJECT_ASSETS_DIR}" \
		"${PROJECT_EXPORT_DIR}" \
		"${PROJECT_POSTS_DIR}" \
		"${PROJECT_RESOURCES_DIR}" \
		"${PROJECT_SCRIPTS_DIR}" \
	)

	# Check project structure.
	echo -e "Check project structure."
	for directory in "${PROJECT_DIRS[@]}"; do
		if [[ ! -d "${directory}" ]]; then
			echo -error "ERROR: missing folder \"$(basename "${directory}")/\"!"
			exit -1
		fi
	done

	if [[ $(find "${PROJECT_DIR}" -mindepth 1 -maxdepth 1 -type d -not -path "*/\.*" | wc -l) != "${#PROJECT_DIRS[@]}" ]]; then
		echo -error "ERROR: too many folders!"
		exit -1
	fi

	# Exporting.
	echo -e "Clean export destination before exporting..."
	shopt -s extglob
	eval "rm -r -f -v "${PROJECT_EXPORT_DIR}"/{*!(.),*.*,.!(|.|git|gitignore)}" # remove in export directory what match with : {directory, files with extension, but ignore `.` and `..` and `.git` and `.gitignore`}
	shopt -u extglob
	echo "Export destination is clean!"

	echo -ne "Exporting \"README\"..."
	local error=$(cp --preserve=all "${PROJECT_README_FILE}" "${PROJECT_EXPORT_DIR}/" 2>&1 1>/dev/null) # It preserve mode, ownership and timestamps.
	echo -status "${?}" "${error}"
	
	echo -ne "Exporting \"SUMMARY\"..."
	local error=$(cp --preserve=all "${PROJECT_SUMMARY_FILE}" "${PROJECT_EXPORT_DIR}/" 2>&1 1>/dev/null) # It preserve mode, ownership and timestamps.
	echo -status "${?}" "${error}"
	
	echo -ne "Exporting \"assets\"..."
	error=$(cp -a "${PROJECT_ASSETS_DIR}" "${PROJECT_EXPORT_DIR}/" 2>&1 1>/dev/null) # -a is same as -dR --preserve=all. It preserve mode, ownership and timestamps.
	echo -status "${?}" "${error}"
	
	echo -ne "Exporting \"resources\"..."
	error=$(cp -a "${PROJECT_RESOURCES_DIR}" "${PROJECT_EXPORT_DIR}/" 2>&1 1>/dev/null) # -a is same as -dR --preserve=all. It preserve mode, ownership and timestamps.
	echo -status "${?}" "${error}"
	
	echo -e "Exporting public \"post\"..."
	mkdir "${PROJECT_EXPORT_POST_DIR}"
	
	local -A all_post_file_info=()
	echo -e "  scan the \"post\" directory..."
	__scan_post_directory "all_post_file_info"
	echo -e "  ${#all_post_file_info[@]} files found with an ID, but only public files will be exported."
	
	# export only public posts
	for post_id in "${!all_post_file_info[@]}"; do
		local -n file_info=$(2d_assoc_array.get_ref_value "all_post_file_info" "${post_id}")
		if [[ ${file_info[access]} == "public" ]]; then
			echo -ne "  exporting \"${file_info[path]}\"..."
			cp --no-target-directory --preserve=all "${PROJECT_POSTS_DIR}/${file_info[path]}" "${PROJECT_EXPORT_POST_DIR}/${file_info[path]}" # It preserve mode, ownership and timestamps.
			
			error=$(__substitute_ids_by_links "file_info" "all_post_file_info" "${PROJECT_EXPORT_POST_DIR}/${file_info[path]}")
			echo -status "${?}" "${error}"
		fi
	done

	echo -e "Done!"
}

main "$@"
exit ${?}
