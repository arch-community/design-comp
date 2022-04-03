#!/usr/bin/env bash

set -e

warn () {
	>&2 cat <<< "$@"
}

if [[ -z "$1" ]]; then
	warn "competition name not given!"
	exit 1
fi

comp_name="$1"

script_dir=$(readlink -f $(dirname "$0"))

comp_dir="$script_dir/$comp_name"
echo "$comp_dir"

gen_mockups () {
	local templates="$1"
	local in_path="$2"
	local out_path="$3"

	local entry_name=$(basename "$in_path")

	echo -n "$entry_name: "

	mkdir -p "$out_path"

	# active icon
	magick convert \
		"$templates/icon-active.png" \
		"$in_path"/icon.*'[0]' -geometry '48x48+12+7' -composite \
		"$templates/icon-active.png" -composite \
		"$out_path/icon-active.png"

	# inactive icon
	magick convert \
		"$templates/icon-inactive.png" \
		"$in_path"/icon.*'[0]' -geometry '48x48+12+7' -composite \
		"$templates/icon-inactive.png" -composite \
		"$out_path/icon-inactive.png"

	# banner
	magick convert \
		"$templates/banner.png" \
		"$in_path/banner.*" -geometry '240x135+9+10' -composite \
		"$templates/banner.png" -composite \
		"$out_path/banner.png"

	# invite background
	magick convert \
		"$templates/invite-bg.png" \
		\( "$in_path/invite-bg.*" -geometry '1024x721^+1+48' \) -composite \
		\( "$in_path/icon.*"      -geometry '64x64+481+205'  \) -composite \
		"$templates/invite-bg.png" -composite \
		"$out_path/invite-bg.png"

	# discovery card
	magick convert \
		"$templates/discovery-card.png" \
		\( "$in_path/cover.*" -geometry '200x112^+15+17' \) -composite \
		\( "$in_path"/icon.*'[0]'  -geometry '40x40+31+103'  \) -composite \
		"$templates/discovery-card.png" -composite \
		"$out_path/discovery-card.png"

	# discovery listing
	magick convert \
		"$templates/discovery.png" \
		\( "$in_path/cover.*" -geometry '240x135^+10+13' \) -composite \
		\( "$in_path/icon.*"  -geometry '32x32+266+13'  \) -composite \
		"$templates/discovery.png" -composite \
		"$out_path/discovery.png"

	# overview
	magick convert \
		-size 1375x480 xc:'#36393E' \
		-gravity northwest \
		\( "$out_path/invite-bg.png"	  -geometry '640x480'  \) -composite \
		\( "$out_path/discovery.png"      -geometry '+654+24'  \) -composite \
		\( "$out_path/discovery-card.png" -geometry '+649+189' \) -composite \
		\( "$out_path/banner.png"		  -geometry '+905+213' \) -composite \
		\( "$out_path/icon-active.png"	  -geometry '+1201+213' \) -composite \
		\( "$out_path/icon-inactive.png"  -geometry '+1201+299' \) -composite \
		"$out_path/overview.png"

	echo 'done.'
}

rm -rf "$comp_dir/mockups"

for entry in "$comp_dir"/entries/*; do
	entry_name=$(basename "$entry")

	gen_mockups "$script_dir/templates" "$entry" "$comp_dir/mockups/$entry_name"

	mkdir -p "$comp_dir/outputs"
	cp "$comp_dir/mockups/$entry_name/overview.png" "$comp_dir/outputs/$entry_name.png"
done
