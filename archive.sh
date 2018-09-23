#! /usr/bin/sh

## go get github.com/ericchiang/pup
## https://github.com/rg3/youtube-dl

IMAGE_DIR=./img
VIDEO_DIR=./vid
MDPATH=./kosimizu.md

DEREOP_IMG_DIR="$IMAGE_DIR/derepo"
VIDEO_OUTPUT="./$VIDEO_DIR/%(title)s-%(id)s.%(ext)s"
VIDEO_DL="./youtube-dl.exe -i --min-sleep-interval 1 --max-sleep-interval 6"

image(){
	mkdir -p "$IMAGE_DIR"
	IMAGELINKS=($(pandoc "$MDPATH" | pup 'img attr{src}'))
	IMAGENAMES=($(echo "${IMAGELINKS[@]}" | perl -pe 's/https?:\/{2}//g;' -pe 's/\//_/g;'))

	for (( i=0; i<${#IMAGELINKS[@]}; ++i)); do
		wget \
			-A "$UA" \
			--no-verbose \
			--no-directories \
			--no-clobber \
			--span-hosts \
			--execute='robots=off' \
			--output-document="$IMAGE_DIR/${IMAGENAMES[$i]}" \
			"${IMAGELINKS[$i]}"
	done
}

video(){
	mkdir -p "$VIDEO_DIR"
	VIDLINKS=$(pandoc "$MDPATH" | pup 'a[href*="youtube.com/watch"], a[href*="/video/1"] attr{href}')
	#$VIDEO_DL "${VIDLINKS[@]}" -o "$VIDEO_OUTPUT" 2>error
	$VIDEO_DL $VIDLINKS -o "$VIDEO_OUTPUT" 2>error

	#VIDLINKS=$(pandoc $MDPATH | pup 'a[href*="nicovideo.jp/watch/"] attr{href}')
	#for VIDLINK in "${VIDLINKS[@]}" ; do
	#	$VIDEO_DL "$VIDLINK" -o "$VIDEO_OUTPUT" 2>>error
	#done
}

derepo_image(){
	mkdir -p "$DEREOP_IMG_DIR"

	IMAGELINKS=($(./derepo/get_img_path.sh))
	for link in ${IMAGELINKS[@]}; do
		wget \
			-A "$UA" \
			--no-verbose \
			--no-directories \
			--no-clobber \
			--span-hosts \
			--execute='robots=off' \
			--output-document="$DEREOP_IMG_DIR/${link##*/}" \
			"$link"
	done
}

#image
video
#derepo_image
