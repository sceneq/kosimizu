#! /usr/bin/sh
cd `dirname $0`

CHARACTER_ID=150
CHARACTER_NAME=$1
if [ "$CHARACTER_NAME" = "" ]; then
	CHARACTER_NAME="輿水幸子"
fi

HOST="https://apis.game.starlight-stage.jp"
EXT="png"

images=$(
	cat ./derepo.json | \
	jq -r ". | map(select(.chara_name == \"$CHARACTER_NAME\") | .img_path ) | join(\" \")"
)

r=()
for image_name in $images; do
	PATH="/image/derepo/$image_name.$EXT"
	r+=("$HOST$PATH")
done
echo ${r[@]}
