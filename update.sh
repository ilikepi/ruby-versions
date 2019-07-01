#!/usr/bin/env bash

set -e

if [[ ! $# -eq 2 ]]; then
	echo "usage: $0 [ruby|mruby|jruby|rubinius] [VERSION]"
	exit -1
fi

ruby="$1"
version="$2"
dest="pkg"

case "$ruby" in
	ruby)
		version_family="${version:0:3}"

		exts=(tar.gz tar.bz2 zip)
		downloads_url="http://cache.ruby-lang.org/pub/ruby/"
		;;
	mruby)
		exts=(tar.gz zip)
		downloads_url="https://github.com/mruby/mruby/archive/"
		;;
	jruby)
		exts=(tar.gz zip)
		downloads_url="https://s3.amazonaws.com/jruby.org/downloads/"
		;;
	rubinius)
		ruby="rbx"
		exts=(tar.bz2)
		downloads_url="http://releases.rubini.us/"
		;;
	*)
		echo "$0: unknown ruby: $ruby" >&2
		exit -1
		;;
esac

mkdir -p "$dest"
pushd "$dest" >/dev/null

for ext in "${exts[@]}"; do
	case "$ruby" in
		ruby)
			archive="ruby-${version}.${ext}"
			url="$downloads_url/$version_family/$archive"
			;;
		mruby)
			archive="mruby-${version}.${ext}"
			url="$downloads_url/$version/$archive"
			;;
		jruby)
			archive="jruby-bin-${version}.${ext}"
			url="$downloads_url/$version/$archive"
			;;
		rubinius)
			archive="rubinius-${version}.${ext}"
			url="$downloads_url/$archive"
			;;
	esac

	curl -f -L -C - -o "$archive" "$url"

	for algorithm in md5 sha1 sha256 sha512; do
                digest=$(openssl dgst -${algorithm} "$archive" | cut -f2 -d' ')
                echo "${digest}  ${archive}" >> "../$ruby/checksums.$algorithm"
	done
done

echo "$version" >> "../$ruby/versions.txt"

popd >/dev/null
