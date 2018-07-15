#! /usr/bin/env python

import json
POSTS = json.load(open("./derepo.json", "r", encoding="utf-8"))


def print_missing():
    id_list = list(map(lambda p: p["id"], POSTS))
    min_id = 1
    max_id = max(id_list)
    for i in range(min_id, max_id):
        if not i in id_list:
            print(i)


def print_contradiction():
    from datetime import datetime
    from functools import reduce

    time_format = "%m-%d %H:%M"
    year = 2018

    def to_time(post):
        return datetime.strptime(post["post_time"], time_format).replace(year=year)

    def ooooo(a, b):
        (a_time, b_time) = (to_time(a), to_time(b))
        if a_time > b_time:
            print(a["id"], b["id"], a_time, b_time, a_time - b_time, sep="\t")
            return a
        else:
            return b

    #time_list = [to_time(p) for p in POSTS[::-1]]
    reduce(ooooo, POSTS[::-1])


print_missing()
#print_contradiction()
