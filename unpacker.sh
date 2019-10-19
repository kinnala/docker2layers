#!/bin/bash
tar_file=${1:-None}
if [ "$tar_file" = "None" ]
then
	echo "Extract layers from a saved Docker image into a directory."
	echo "Usage: ./unpacker.sh IMAGE DIRECTORY"
	exit 1
fi
layers_cache_dir=${2:-None}
if [ "$layers_cache_dir" = "None" ]
then
	echo "Missing cache directory! See ./unpacker.sh for instructions."
	exit 1
fi
tmp_dir=$(mktemp -d -t image-XXXXXXXXXX)
echo "Unpacking '$tar_file' to '$tmp_dir' ..."
tar -C $tmp_dir -xf $tar_file
echo "Moving layers to '$layers_cache_dir' ..."
find $tmp_dir \
	| grep layer.tar \
	| xargs -I {} sh -c 'mv {} '$layers_cache_dir'/`sha256sum {} | cut -d " " -f 1`'
