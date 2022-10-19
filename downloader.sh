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

git config --global user.email "Berserk-DL-auto@github-action.com"
git config --global user.name "Berserk-DL-auto"

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
		filename="$(echo "$image_url" | sed 's|.*/||g' | sed 's/?.*$//g')"
		extension="${filename##*.}"
		pretty_count="$(printf "%03d" "$count")"
		echo "Fetching $image_url"
		curl -LSks "$image_url" > "./output/$chapter_id/$pretty_count.$extension"
		((count+=1))
	done <<< "$image_list"

	git add .
  	git commit -sam "Updated chapter: $chapter_id" && git push
done <<< "$chapter_list"

echo "Downloads done :)"
