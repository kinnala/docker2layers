#!/bin/bash
old_image=${1:-None}
if [ "$old_image" = "None" ]
then
    echo "Create rsync patch from directory to another."
    echo "Usage: ./create_patch.sh OLD NEW PATCH"
    exit 1
fi
new_image=${2:-None}
if [ "$new_image" = "None" ]
then
    echo "Missing new image file! See ./create_patch.sh for instructions."
    exit 1
fi
patch=${3:-None}
if [ "$patch" = "None" ]
then
    echo "Missing patch filename! See ./create_patch.sh for instructions."
    exit 1
fi

echo "Creating patch from '$old_image' to '$new_image' ..."
rsync -arvz --only-write-batch=$patch $new_image/ $old_image/
