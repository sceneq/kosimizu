#! /usr/bin/sh

## go get github.com/ericchiang/pup
## https://github.com/rg3/youtube-dl

IMAGE_DIR=./img
VIDEO_DIR=./vid
MDPATH=~/memo/im/kosimizu.md

VIDEO_OUTPUT="./$VIDEO_DIR/%(title)s-%(id)s.%(ext)s"
DL="./youtube-dl.exe -i --min-sleep-interval 1 --max-sleep-interval 6"

function image(){
	mkdir -p $IMAGE_DIR
	pandoc $MDPATH > a.html
	python -m http.server &
	wget \
		-N \
		-nd -r -l 1 -P $IMAGE_DIR -A jpeg,jpg,bmp,gif,png,apng -H -e robots=off http://localhost:8000/a.html
}

function video(){
	mkdir -p $VIDEO_DIR
	VIDLINKS=$(pandoc $MDPATH | pup 'a[href*="youtube.com/watch"], a[href*="/video/1"] attr{href}')
	$DL $VIDLINKS -o $VIDEO_OUTPUT 2>error

	VIDLINKS=$(pandoc $MDPATH | pup 'a[href*="nicovideo.jp/watch/"] attr{href}')
	for VIDLINK in $VIDLINKS ; do
		$DL $VIDLINK -o $VIDEO_OUTPUT 2>>error
	done
}

function derepo_image(){
	DEREOP_IMG_DIR="$IMAGE_DIR/derepo"
	mkdir -p $DEREOP_IMG_DIR
	
	# TODO: タイムスタンプを返してくれないので、毎回ダウンロードしてしまう
	# stat
	wget -N -nd -P $DEREOP_IMG_DIR $(./derepo/get_img_path.sh)
}

#image
#video
#derepo_image
