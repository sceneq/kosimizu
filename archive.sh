#! /usr/bin/sh

## go get github.com/ericchiang/pup
## https://github.com/rg3/youtube-dl

IMAGE_DIR=./img
VIDEO_DIR=./vid
MDPATH=~/memo/im/kosimizu.md

DL="./youtube-dl.exe -i --min-sleep-interval 1 --max-sleep-interval 3"
VIDEO_OUTPUT="./$VIDEO_DIR/%(title)s-%(id)s.%(ext)s"

function dlimage(){
	mkdir -p $IMAGE_DIR

	pandoc $MDPATH > tmp.html
	python -m http.server &
	sleep 4
	wget \
		-N \
		-nd -r -l 1 -P ./img -A jpeg,jpg,bmp,gif,png,apng -H -e robots=off http://localhost:8000/tmp.html
	kill %1
}

function dlvideo(){
	mkdir -p $VIDEO_DIR

	VIDLINKS=$(pandoc $MDPATH | pup 'a[href*="youtube.com/watch"], a[href*="/video/1"] attr{href}')
	$DL $VIDLINKS -o $VIDEO_OUTPUT

	VIDLINKS=$(pandoc $MDPATH | pup 'a[href*="nicovideo.jp/watch/"] attr{href}')
	for VIDLINK in $VIDLINKS ; do
		$DL $VIDLINK -o $VIDEO_OUTPUT
	done
}

#dlimage
#dlvideo
