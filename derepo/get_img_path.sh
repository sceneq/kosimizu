#! /usr/bin/sh
cd `dirname $0`

HOST="https://apis.game.starlight-stage.jp"
EXT="png"

images=$(
	cat ./derepo.json | \
	jq -r ". | map(. | .img_path ) | join(\" \")"
)
	#jq -r ". | map(select(.chara_name == \"$CHARACTER_NAME\") | .img_path ) | join(\" \")"

r=()
for image_name in ${images[@]}; do
	PATH="image/derepo/$image_name.$EXT"
	r+=("$HOST/$PATH")
done
echo ${r[@]}
