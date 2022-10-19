#!/usr/bin/env bash

get_chapter_list() {
	curl -k -s "https://readberserk.com/" \
	| grep "btn btn-sm btn-primary mr-2" \
	| cut -d '"' -f2
}

get_image_list() {
	curl -k -s "$chapter_url" \
		| grep "class=\"pages__img\"" \
		| cut -d '"' -f4
}

echo "Downloading chapter list..."
chapter_list="$(get_chapter_list)"
while IFS= read -r chapter_url_raw; do
	chapter_url="${chapter_url_raw//[$'\t\r\n ']}"
	chapter_id=$(echo "$chapter_url" | cut -d "/" -f5);
	echo "Downloading $chapter_id..."

	rm -rf "./output/$chapter_id";
	mkdir -p "./output/$chapter_id";

	image_list="$(get_image_list "$chapter_id")"
	count=1;
	while IFS= read -r image_url_raw; do
		image_url="${image_url_raw//[$'\t\r\n ']}"
		filename="$(echo "$image_url" | sed 's|.*/||g' | sed 's/[^a-zA-Z].*$//g')"
		extension="${filename##*.}"
		echo "Fetching $image_url"
		curl -LSks "$image_url" > "./output/$chapter_id/$count.$extension"
		((count+=1))
	done <<< "$image_list"
done <<< "$chapter_list"

echo "Downloads done :)"
