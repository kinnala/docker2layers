#!/bin/bash
config_file=${1:-None}
if [ "$config_file" = "None" ]
then
    echo "Load Docker image from extracted layer blobs using image config file."
    echo "Usage: ./loader.sh CONFIG DIRECTORY"
    exit 1
fi
layers_cache_dir=${2:-None}
if [ "$layers_cache_dir" = "None" ]
then
    echo "Missing layer cache directory! See ./loader.sh for instructions."
    exit 1
fi
tmp_dir=$(mktemp -d -t image-XXXXXXXXXX)

echo "Copying layer blobs to '$tmp_dir' ..."
cat $config_file \
    | sed -e 's/.*"diff_ids":\[\(.*\)\]}}/\1/' \
          -e 's/"sha256:\([a-z0-9]*\)"/\1\n/g' \
          -e 's/,//g' \
    | nl -nln \
    | awk -v layers="$layers_cache_dir" \
          -v tmp="$tmp_dir" \
          '{ a="mkdir "tmp"/"$1" && cp "layers"/"$2" "tmp"/"$1"/layer.tar"; print a}' \
    | xargs -I {} sh -c '{}'

echo "Copying image config to '$tmp_dir' ..."
cp $config_file $tmp_dir/config.json

echo "Creating manifest.json ..."
echo "[{\"Config\":\"config.json\",\"RepoTags\":null,\"Layers\":[" >> $tmp_dir/manifest.json
ls -1v $tmp_dir \
    | grep -v json \
    | awk '{print "\""$1"\""}' \
    | paste -sd "," >> $tmp_dir/manifest.json
echo "]}]" >> $tmp_dir/manifest.json

echo "Creating and loading image.tar ..."
cd $tmp_dir
tar -cf /tmp/image.tar *
docker load -i /tmp/image.tar
cd -

echo "Removing temporary files ..."
rm -r /tmp/image*
