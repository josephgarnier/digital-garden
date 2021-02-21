# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

readonly -A COLORS=( \
	[GREEN]="\e[32m" \
	[RED]="\e[31m" \
	[WHITE]="\e[37m" \
	[RESET]="\e[0m" \
)

#######################################
# Extends echo command.
# Globals:
#   See echo command.
#   COLORS
# Arguments:
#   See echo command.
#   -error <error_message>: display a message with red color.
#   -status <error_code> <error_message>: display a message either with green color if success or red if fail.
#   -formated <message>: display a message with an header.
# Outputs:
#   Write message to STDOUT.
# Returns:
#   None.
# Exits:
#   None.
#######################################
echo() {
	local -r option="${1}"

	case "${option}" in
		"-error")
			local -r error_message="${2}"
			echo -e "${COLORS[RED]}${error_message}${COLORS[RESET]}" 1>&2
			;;
		"-status")
			local -r error_code="${2}"
			local -r error_message="${3}"
			if [[ "${error_code}" -eq 0 ]]; then
				echo -e " ${COLORS[GREEN]}[success]${COLORS[RESET]}"
			else
				echo -e " ${COLORS[RED]}[fail]: ${error_message}${COLORS[RESET]}" 1>&2
			fi
			;;
		"-formated")
			local -r message="${2}"
			local -r header="$(date +"%Y/%m/%d %H:%M:%S") [$$]"
			echo -e "${header} ${message}"
			;;
		*)
			command echo "${@}"
			;;
	esac
}

#######################################
# Takes two strings and checks whether they are the same based on the character strings. Inspired from https://github.com/torokmark/assert.sh.
# Globals:
#   None.
# Arguments:
#   <expected>: expected string.
#   <actual>: current string that should be the same as expected.
#   <message>: message to display if strings are not equals.
# Outputs:
#   Write <message> to STDERR.
# Returns:
#   0: if strings are equals.
# Exits:
#   99: if arguments are missing.
#   98: if strings are not equals.
#######################################
assert_eq() {
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: assert_eq <expected> <actual> <message>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -i ASSERT_FAILED=98
	local -r expected="${1}"
	local -r actual="${2}"
	local -r message="${3}"

	if [[ "${expected}" == "${actual}" ]]; then
		return 0
	else
		# An error occured, retrieved the line and the name of the script where
		# it happend
		set $(caller)
		echo -error "Assertion failed: \"${expected} == ${actual}\" :: ${message}" 1>&2
		echo -error "File \"${0}\", line ${1}" 1>&2
		exit ${ASSERT_FAILED}
	fi
}

#######################################
# Takes two integer and checks whether the left is less than the right one. Inspired from https://github.com/torokmark/assert.sh.
# Globals:
#   None.
# Arguments:
#   <left>: left integer that should be less than the right one.
#   <right>: right integer.
#   <message>: message to display if the left integer is not less than the right one.
# Outputs:
#   Write <message> to STDERR.
# Returns:
#   0: if the left is less than right.
# Exits:
#   99: if arguments are missing.
#   98: if left is not less than right.
#######################################
assert_lt() {
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: assert_lt <left> <right> <message>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -i ASSERT_FAILED=98
	local -r -i left=${1}
	local -r -i right=${2}
	local -r message="${3}"

	if (( ${left} < ${right} )); then
		return 0
	else
		# An error occured, retrieved the line and the name of the script where
		# it happend
		set $(caller)
		echo -error "Assertion failed: \"${left} < ${right}\" :: ${message}" 1>&2
		echo -error "File \"${0}\", line ${1}" 1>&2
		exit ${ASSERT_FAILED}
	fi
}

#######################################
# Takes two integer and checks whether the left is greater than or equal to the right one. Inspired from https://github.com/torokmark/assert.sh.
# Globals:
#   None.
# Arguments:
#   <left>: left integer that should be greater than or equal to the right one.
#   <right>: right integer.
#   <message>: message to display if the left integer is not greater than or equal to the right one.
# Outputs:
#   Write <message> to STDERR.
# Returns:
#   0: if the left is greater than or equal to the right.
# Exits:
#   99: if arguments are missing.
#   98: if left is not greater than or equal to the right.
#######################################
assert_ge() {
	local -r -i PARAM_FAILED=99
	if (( $# < 3 )); then
		echo -error "ERROR: usage: assert_ge <left> <right> <message>" 1>&2
		exit ${PARAM_FAILED}
	fi
	local -r -i ASSERT_FAILED=98
	local -r -i left=${1}
	local -r -i right=${2}
	local -r message="${3}"

	if (( ${left} >= ${right} )); then
		return 0
	else
		# An error occured, retrieved the line and the name of the script where it happend
		set $(caller)
		echo -error "Assertion failed: \"${left} >= ${right}\" :: ${message}" 1>&2
		echo -error "File \"${0}\", line ${1}" 1>&2
		exit ${ASSERT_FAILED}
	fi
}