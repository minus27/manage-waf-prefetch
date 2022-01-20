#!/usr/bin/env bash

exitOnError() { # $1=ErrorMessage $2=PrintUsageFlag
	local TMP="$(echo "$0" | sed -E 's#^.*/##')"
	local REQ_ARGS="$(grep -e "#REQUIRED[=]" $0)"
	local OPT_ARGS="$(grep -e "#OPTIONAL[=]" $0)"
	[ "$1" != "" ] && >&2 echo "ERROR: $1"
	[[ "$1" != "" && "$2" != "" ]] && >&2 echo ""
	[ "$2" != "" ] && {
		>&2 echo -e "USAGE: ${TMP} FASTLY_KEY SERVICE_ID SERVICE_VERSION$([[ "${REQ_ARGS}" != "" ]] && echo " [REQUIRED_ARGUMENTS]")$([[ "${OPT_ARGS}" != "" ]] && echo " [OPTIONAL_ARGUMENTS]")"
		[[ "${REQ_ARGS}" != "" ]] && {
			>&2 echo -e "\nREQUIRED ARGUMENTS:"
			>&2 echo -e "$(echo "${REQ_ARGS}" | sed -E -e 's/\|/ | /' -e 's/^[^-]*/  /g' -e 's/\)//' -e 's/#[^=]*=/: /')"
		}
		[[ "${OPT_ARGS}" != "" ]] && {
			>&2 echo -e "\nOPTIONAL ARGUMENTS:"
			>&2 echo -e "$(echo "${OPT_ARGS}" | sed -E -e 's/\|/ | /' -e 's/^[^-]*/  /g' -e 's/\)//' -e 's/#[^=]*=/: /')"
		}
	}
	exit 1
}

toolCheck() { # $1=TOOL_NAME
	[[ "$1" == "" ]] && exitOnError "Tool Name not specified"
	type -P "$1" >/dev/null 2>&1 || exitOnError "\"$1\" required and not found"
}

getArgs() {
	POSITIONAL=()
	# Set Defaults:
	METHOD="GET"
	#
	while [[ $# -gt 0 ]]
	do
		key="$(echo "[$1]" | tr '[:upper:]' '[:lower:]' | sed -e 's/^\[//' -e 's/\]$//')"
		case "$key" in
			-m|--method) #OPTIONAL=Method (GET|POST|PUT|DELETE)
				[[ "$2" =~ ^(GET|POST|PUT|DELETE)$ ]] || exitOnError "Unexpected METHOD, i.e. not GET, POST, PUT, or DELETE"
				METHOD="$2"
				shift; shift
				;;
			-s|--statement) #OPTIONAL=VCL Conditional Statement (Required if Method = POST or PUT)
				STATEMENT="$2"
				shift; shift
				;;
			-t|--test) #OPTIONAL=Test API call using httpbin.org w/o Fastly Key
				TEST="1"
				shift
				;;
			*)
				[[ "$1" =~ ^- ]] && exitOnError "Unexpected argument - \"$1\"" "1"
				POSITIONAL+=("$1")
				shift
				;;
		esac
	done

	[[ "${#POSITIONAL[@]}" -ne 3 ]] &&  exitOnError "Three positional arguments expected, ${#POSITIONAL[@]} found" "1"

	FASTLY_KEY="${POSITIONAL[0]}"
	SVC_ID="${POSITIONAL[1]}"
	SVC_VER="${POSITIONAL[2]}"

	[[ "$METHOD" =~ ^(POST|PUT)$ && "$STATEMENT" == "" ]] && exitOnError "STATEMENT cannot be zero length"
}
#
#
#
toolCheck "curl"

getArgs "$@"

URL_PATH="/service/${SVC_ID}/version/${SVC_VER}/condition"
OPTS=(-s -H "Accept: application/json")

[[ "$METHOD" =~ ^(POST|PUT)$ ]] && {
	OPTS+=(--data-urlencode "statement=${STATEMENT}")
}
[[ "$METHOD" == "POST" ]] && {
	OPTS+=(-d "name=WAF_Prefetch" -d "type=prefetch")
} || {
	URL_PATH="${URL_PATH}/WAF_Prefetch"
}

[[ "$TEST" == "" ]] && {
	read -rsn1 -p"Hit RETURN to continue or Ctrl-C to exit"
	>&2 echo -e ""
	OPTS+=(-H "Fastly-Key: ${FASTLY_KEY}" -X "$METHOD")
	URL="https://api.fastly.com${URL_PATH}"
} || {
	URL="https://httpbin.org/anything${URL_PATH}"
}
curl "${OPTS[@]}" "${URL}"
