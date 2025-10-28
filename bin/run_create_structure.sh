#!/usr/bin/env bash
set -euo pipefail

# --- Configuration (edit as needed) ---
REPO_URL="https://github.com/kolelan/create_structure.git"
RAW_SCRIPT_URL="https://raw.githubusercontent.com/kolelan/create_structure/refs/heads/main/create_structure.py"
SCRIPT_PATH="$(pwd)/create_structure.py"
STRUCTURE_TXT="$(pwd)/structure.txt"
MIN_PY_MAJOR=3
MIN_PY_MINOR=8
# --------------------------------------

err() { echo "${1}" >&2; }

get_python() {
	if command -v python >/dev/null 2>&1; then
		echo "python"
		return 0
	fi
	if command -v python3 >/dev/null 2>&1; then
		echo "python3"
		return 0
	fi
	err "Python not found. Please install Python 3.8+ and ensure it is on PATH."
	exit 1
}

check_python_version() {
	local pycmd="$1"
	local ver
	ver="$(${pycmd} --version 2>&1 | sed -E 's/^Python[[:space:]]+//')"
	if [[ -z "${ver}" ]]; then
		err "Unable to determine Python version."
		exit 1
	fi
	local maj min
	IFS='.' read -r maj min _ <<< "${ver}"
	if [[ -z "${maj}" || -z "${min}" ]]; then
		err "Unexpected Python version string: ${ver}"
		exit 1
	fi
	if (( maj < MIN_PY_MAJOR || (maj == MIN_PY_MAJOR && min < MIN_PY_MINOR) )); then
		err "Python ${MIN_PY_MAJOR}.${MIN_PY_MINOR}+ required. Detected: ${ver}"
		exit 1
	fi
	echo "Using Python ${ver}"
}

ensure_script() {
	if [[ -f "${SCRIPT_PATH}" ]]; then
		return
	fi
	echo "create_structure.py not found. Downloading from repository..."
	# Try curl or wget
	if command -v curl >/dev/null 2>&1; then
		if ! curl -fsSL "${RAW_SCRIPT_URL}" -o "${SCRIPT_PATH}"; then
			echo "Direct download failed, trying git clone as fallback..."
		else
			echo "Downloaded create_structure.py from raw URL."
			return
		fi
	elif command -v wget >/dev/null 2>&1; then
		if ! wget -q "${RAW_SCRIPT_URL}" -O "${SCRIPT_PATH}"; then
			echo "Direct download failed, trying git clone as fallback..."
		else
			echo "Downloaded create_structure.py from raw URL."
			return
		fi
	else
		echo "Neither curl nor wget found, trying git clone as fallback..."
	fi

	if command -v git >/dev/null 2>&1; then
		tmp_dir="$(mktemp -d)"
		git clone --depth 1 "${REPO_URL}" "${tmp_dir}" >/dev/null 2>&1
		if [[ ! -f "${tmp_dir}/create_structure.py" ]]; then
			rm -rf "${tmp_dir}"
			err "create_structure.py not found in cloned repo"
			exit 1
		fi
		cp "${tmp_dir}/create_structure.py" "${SCRIPT_PATH}"
		rm -rf "${tmp_dir}"
		echo "Copied create_structure.py from cloned repository."
	else
		err "Failed to retrieve create_structure.py. Install curl/wget or git."
		exit 1
	fi
}

check_structure_txt() {
	if [[ ! -f "${STRUCTURE_TXT}" ]]; then
		err "Required file not found: ${STRUCTURE_TXT}"
		exit 1
	fi
	local count
	count=$(grep -cve '^[[:space:]]*$' "${STRUCTURE_TXT}" || true)
	if [[ "${count}" -eq 0 ]]; then
		err "No entries found in ${STRUCTURE_TXT}. Add at least one non-empty line."
		exit 1
	fi
	echo "Found ${count} entries in structure.txt"
}

main() {
	pycmd="$(get_python)"
	check_python_version "${pycmd}"
	check_structure_txt
	ensure_script
	echo "Running create_structure.py..."
	"${pycmd}" "${SCRIPT_PATH}"
}

main "$@"
