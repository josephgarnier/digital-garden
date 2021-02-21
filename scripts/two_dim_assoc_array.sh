# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

declare DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi
source "${DIR}/utility.sh"

#######################################
# Append a sub array to a two dimensional associative array. Inspired from https://stackoverflow.com/a/28051297/5929436
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key for the sub array to append.
#   <ref:unique_sub_array>: the sub array with a unique name to append to array.
# Outputs:
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.append_unique()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: 2d_assoc_array.append_unique <ref:array> <key> <ref:unique_sub_array>" 1>&2
		exit ${PARAM_FAILED}
	fi

	local -n two_dim_array="${1}" # use nameref for indirection
	local -r two_dim_array_name="${1}"
	local -r key="${2}"
	local -r sub_array="${3}"

	two_dim_array["${key}"]="${sub_array}"
}

#######################################
# Append by copy a sub array to a two dimensional associative array. Inspired from https://stackoverflow.com/a/28051297/5929436
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key for the sub array to append.
#   <ref:sub_array>: the sub array to append to array.
# Outputs:
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.append()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: 2d_assoc_array.append <ref:array> <key> <ref:sub_array>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -n two_dim_array="${1}" # use nameref for indirection
	local -r two_dim_array_name="${1}"
	local -r key="${2}"
	local -r -n sub_array="${3}"

	local -r sub_array_name="${two_dim_array_name}_${key}" # has to be unique
	declare -g -A "${sub_array_name}=()"
	for sub_array_key in "${!sub_array[@]}"; do
		eval "${sub_array_name}[${sub_array_key}]=\${sub_array[\${sub_array_key}]}"
	done
	two_dim_array["${key}"]="${sub_array_name}"
}

#######################################
# Get the reference value associated to the key. Same command as my_array[key].
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key for the sub array to get.
# Outputs:
#   Write the reference value associated to the key to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.get_ref_value()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 2 )); then
		echo -error "ERROR: usage: 2d_assoc_array.get_ref_value <ref:array> <key>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -n array="${1}"
	local -r key="${2}"
	
	echo "${array[${key}]}"
}

#######################################
# Get the value in the form of array associated to the key.
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key for the sub array to get.
# Outputs:
#   Write the associative sub array associated to the key to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.get_value()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 2 )); then
		echo -error "ERROR: usage: 2d_assoc_array.get_value <ref:array> <key>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -n array="${1}"
	local -r key="${2}"
	
	local -r sub_array_as_string=$(declare -p "${array[${key}]}")
	echo "${sub_array_as_string#*=}"
}

#######################################
# Get the sub keys associate to the key.
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key for the sub array to get.
# Outputs:
#   Write an array containing all sub keys associate to the key to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.get_sub_keys()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 2 )); then
		echo -error "ERROR: usage: 2d_assoc_array.get_sub_keys <ref:array> <key>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -n array="${1}"
	local -r key="${2}"
	
	local -r -n sub_array="${array[${key}]}"
	echo "${!sub_array[@]}"
}

#######################################
# Get the sub values associate to the key.
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key for the sub array to get.
# Outputs:
#   Write an array containing all sub values associate to the key to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.get_sub_values()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 2 )); then
		echo -error "ERROR: usage: 2d_assoc_array.get_sub_values <ref:array> <key>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -n array="${1}"
	local -r key="${2}"
	
	local -r -n sub_array="${array[${key}]}"
	echo "${sub_array[@]}"
}

#######################################
# Get the sub value associate to the sub key.
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
#   <key>: the key of the sub array.
#   <sub_key>: the key for the value to get from the sub array.
# Outputs:
#   Write the sub value associated to the sub key to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.get_sub_value()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: 2d_assoc_array.get_sub_value <ref:array> <key> <sub_key>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -n array="${1}"
	local -r key="${2}"
	local -r sub_key="${3}"
	
	local -r -n sub_array="${array[${key}]}"
	echo "${sub_array[${sub_key}]}"
}

#######################################
# Get a two dimensional associative array and all its sub arrays.
# Globals:
#   None.
# Arguments:
#   <ref:array>: reference to the two dimensional associative array.
# Outputs:
#   Write the referenced array to STDOUT.
#   Write errors to STDERR.
# Returns:
#   None.
# Exits:
#   99: if arguments are missing.
#######################################
2d_assoc_array.print()
{
	local -r -i PARAM_FAILED=99
	if (( $# < 1 )); then
		echo -error "ERROR: usage: 2d_assoc_array.print <ref:array>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -n array="${1}"
	
	for key in "${!array[@]}"; do
		local -n sub_array="${array[${key}]}"
		echo -e "[${key}]=\"${!sub_array}\""
		for sub_key in "${!sub_array[@]}"; do
			echo -e "     |-> [${sub_key}]=\"${sub_array[${sub_key}]}\""
		done
		unset sub_array
	done
}