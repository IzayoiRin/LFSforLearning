import json

SRC_JSON_ARRAY = "src.json"

with open(SRC_JSON_ARRAY, "r") as f:
    scr_arr = json.loads(f.read())


class SrcJsonModelBase(object):
    