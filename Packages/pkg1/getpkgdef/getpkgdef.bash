#!/bin/bash
function getpkgdef() {
	 local DEFINE_PKG_NAMES=( "$@" )
	local pids=()
for DEFINE_PKG_NAME in ${DEFINE_PKG_NAMES[@]}
do
echo "${DEFINE_PKG_NAME}"
(nix eval --raw "nixpkgs#""${DEFINE_PKG_NAME}".meta.position | cut -d: -f1 2>&1 | tee "${DEFINE_PKG_NAME}".def) &

pids+=("$!")
		done
wait "${pids[@]}"
}
getpkgdef "$@"
