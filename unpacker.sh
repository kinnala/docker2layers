#!/bin/bash
tar_file=${1:-None}
if [ "$tar_file" = "None" ]
then
    echo "Extract layers and, optionally, config from a saved Docker image."
    echo "Usage: ./unpacker.sh IMAGE DIRECTORY [CONFIG]"
    exit 1
fi
layers_cache_dir=${2:-None}
if [ "$layers_cache_dir" = "None" ]
then
    echo "Missing layer cache directory! See ./unpacker.sh for instructions."
    exit 1
fi
config=${3:-None}

tmp_dir=$(mktemp -d -t image-XXXXXXXXXX)

echo "Unpacking '$tar_file' to '$tmp_dir' ..."
tar -C $tmp_dir -xf $tar_file

if [ "$config" = "None" ]
then
    echo "Skipping image config file ..."
else
    mv $tmp_dir/`ls $tmp_dir | grep json | grep -v manifest` $config
fi

echo "Moving layers to '$layers_cache_dir' ..."
find $tmp_dir \
    | grep layer.tar \
    | xargs -I {} sh -c 'mv {} '$layers_cache_dir'/`sha256sum {} | cut -d " " -f 1`'

echo "Removing temporary files ..."
rm -r /tmp/image*
