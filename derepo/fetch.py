#! /usr/bin/python
import json
from urllib import parse
import httplib2

# [POST] /derepo/timeline
# {
#     viewer_id: int
#     paging_time: str
#     sign: str
# } => {
#     has_next_page :bool,
#     list : [post],
#     paging_time: str,
# }

# /image/derepo/{icon_path}
# /image/derepo/{img_path}

# favorite_statusはいらない
# signがわかないので手抜き
#DEREPO_URL = "https://apis.game.starlight-stage.jp/derepo/index?viewer_id={}&time={}&sign={}"

DEREPO_API_HOST = "https://apis.game.starlight-stage.jp"
DEREPO_API_PORT = 443
OUTPUT_JSON_PATH = "./derepo.json"
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3492.1 Safari/537.36"
PAGING_TIME = "2038-01-19 03:14:07"

a = parse.parse_qs(parse.urlparse(DEREPO_URL).query)
SIGN = a["sign"][0]
VIEWER_ID = a["viewer_id"][0]

HEADERS = {
    "accept": "application/json",
    "accept-language": "ja,en-US;q=0.9,en;q=0.8",
    "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
    "origin": DEREPO_API_HOST,
    "referer": DEREPO_URL,
    "user-agent": UA,
}

h = httplib2.Http(".cache")


def get_derepo_json(paging_time):
    body_dic = {
        "viewer_id": VIEWER_ID,
        "sign": SIGN,
        "paging_time": paging_time
    }
    body = bytes(parse.urlencode(body_dic), "ascii")
    (resp, content) = h.request(
        '{}:{}/derepo/timeline'.format(DEREPO_API_HOST, DEREPO_API_PORT),
        "POST",
        headers=HEADERS,
        body=body
    )
    return content


def get_until_break(paging_time, break_id):
    new_posts = []
    while True:
        print(paging_time)
        derepo_json = json.loads(get_derepo_json(paging_time))
        print(len(derepo_json["list"]))
        new_posts.extend(derepo_json["list"])
        paging_time = derepo_json["paging_time"]

        if derepo_json["has_next_page"] == False:
            print("break: has_next_page=False")
            break

        min_id = min(map(lambda p: p["id"], derepo_json["list"]))
        if break_id is not None and min_id < break_id:
            print("break: {} <= {}".format(min_id, break_id))
            break
    return new_posts


def merge(last_posts, new_posts):
    tmpdic = {}
    for post in new_posts + last_posts:
        post_id = post["id"]
        if not post_id in tmpdic:
            tmpdic[post_id] = post
    return list(tmpdic.values())


POSTS_PER_RESPONSE = 53
try:
    last_posts = json.load(open(OUTPUT_JSON_PATH, "r"))
    break_id = max(map(lambda p: p["id"], last_posts))
    # idもgroup_idも時系列順ではなく、post_timeには年がないので
    # 1ページ分余分に問い合わせる(favorite_countの更新もできる)
    break_id -= (POSTS_PER_RESPONSE*2) 
except FileNotFoundError:
    last_posts = []
    break_id = None

new_posts = get_until_break(PAGING_TIME, break_id)
output = merge(last_posts, new_posts)
output.sort(key=lambda p: p["id"], reverse=True)

open(OUTPUT_JSON_PATH,
     "w").write(json.dumps(output, indent=2, ensure_ascii=False))
