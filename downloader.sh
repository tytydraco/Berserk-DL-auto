#!/bin/bash

git config --global user.email "Berserk-DL-auto@github-action.com"
git config --global user.name "Berserk-DL-auto"

echo "Starting the download of berserk chapters from https://readberserk.com/"
curl -k -s https://readberserk.com/ | grep "btn btn-sm btn-primary mr-2" | cut -d '"' -f2 > ./output/chaplist.txt;
for f in $(cat ./output/chaplist.txt); do
	chap=$(echo $f | cut -d "/" -f5);
	echo "Downloading $chap"
	rm -rf ./output/$chap;
	mkdir -p ./output/$chap;
	curl -k -s $f | grep "class=\"pages__img\"" | cut -d '"' -f4 > ./output/$chap/imglist.txt;
	
	count=1;
	for x in $(cat ./output/$chap/imglist.txt); do
		case $x in
			*".jpg")
				curl -k -s $x > ./output/$chap/$count.jpg;
				;;
			*".jpeg")
				curl -k -s $x > ./output/$chap/$count.jpeg;
				;;
			*".png")
				curl -k -s $x > ./output/$chap/$count.png;
				;;
		esac
		let "count=count+1";
	done
	
  	git add .
  	git commit -sam "Updated chapter: $chap"
  	git push
done
echo "Downloads done :)"
rm -f ./output/*.txt
rm -f ./output/*/*.txt
echo "Files available in ./output/"
