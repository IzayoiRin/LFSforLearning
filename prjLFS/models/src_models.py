import copy
import json

import numpy as np
import pandas as pd

SRC_JSON_ARRAY = "C:\izayoi\prjs\LFSforLearning\prjLFS\models\src.json"

with open(SRC_JSON_ARRAY, "r") as f:
    SRC_ARR = json.loads(f.read())  # type: list
    SRC_NOTES = ["ttc", "bss"]


class SrcJSON(object):

    def __init__(self, src_js_name, attrs):
        self.src_js_name = src_js_name
        self.__fields = list(attrs.keys())
        for k, v in attrs.items():
            setattr(self, k, v)

    @property
    def fields(self):
        return self.__fields

    def __repr__(self):
        return "SrcJs-{name}-with-{fields}-fields".\
            format(name=self.src_js_name, fields=len(self.fields))


class SrcJsonMeta(type):

    src_key = "src"
    filter_key = "filter_fields"

    def __new__(mcs, name, base, attrs):
        if attrs.get(mcs.src_key):
            attrs[mcs.src_key] = SRC_ARR[SRC_NOTES.index(attrs[mcs.src_key])] \
                if isinstance(attrs[mcs.src_key], str) else attrs[mcs.src_key]
            attrs[mcs.src_key] = mcs.src_dict2obj(attrs[mcs.src_key], attrs.get(mcs.filter_key, list()))
        return super().__new__(mcs, name, base, attrs)

    @staticmethod
    def src_dict2obj(src, filter_fields):
        new_dict = dict()
        for k, v in src.items():
            attrs = copy.deepcopy(v)
            for fk in filter_fields:
                if attrs.get(fk, None) is None:
                    continue
                del attrs[fk]
            new_dict[int(k)] = SrcJSON("src%s" % k, attrs)
            del attrs
        return new_dict


class SrcJsonModelBase(object, metaclass=SrcJsonMeta):

    src = None
    filter_fields = list()

    _retrieve_type = {"np.arr": np.array, "pd.df": pd.DataFrame}

    def __init__(self):
        self.__len = len(self.src)
        self.__ori = 0

    def is_empty(self):
        return self.__len == 0

    def retrieve(self, fields=None, indices=None, rtype=None):
        """
        retrieve fields from src model guide by indices.
        :param fields: list
        :param indices: list or None
        :param rtype: whether return other data structure, support {"np.arr": np.array, "pd.df": pd.DataFrame}
        :return: [[src1.fd1, src1.fd2], [src2.fd1, src2.fd2], ... ,]
        """
        if indices == list() or self.is_empty():
            return self._retrieve_type[rtype](indices) \
                if rtype is None or self._retrieve_type.get(rtype) else indices
        indices = indices or range(len(self))
        fields = fields or self[0].fields
        if max(indices) >= self.__len:
            raise IndexError("Index Overflow! [%s, max:%s]" % (max(indices), self.__len-1))
        ret = [[getattr(self[i], fk, None) for fk in fields] for i in indices]
        return self._retrieve_type[rtype](ret) \
            if rtype or self._retrieve_type.get(rtype) else ret

    def and_select(self, fields, conds, rtype=None):
        """
        and op: select src from model guide by field's cond
        :param fields:
        :param conds:
        :param rtype: {"ins": src_obj, None: idx}
        :return: [idx0 or scr_obj0, idx1 or scr_obj1, ..., ]
        """
        rec = list()
        if self.is_empty():
            return rec

        for idx, obj in enumerate(self):
            expr = " and ".join([cond % getattr(obj, fk) for fk, cond in zip(fields, conds)])
            if eval(expr):
                rec.append(obj if rtype == "ins" else idx)
        return rec

    def __iter__(self):
        return self

    def __next__(self):
        if self.__ori < self.__len:
            ret = self[self.__ori]
            self.__ori += 1
            return ret
        else:
            raise StopIteration("Iteration at Max point!")

    def __getitem__(self, idx):
        if idx > self.__len - 1:
            raise IndexError("Index Overflow! [%s, max:%s]" % (idx, self.__len-1))
        return self.src.get(idx)

    def __len__(self):
        return self.__len


class TTCSrcJsonModel(SrcJsonModelBase):

    src = "ttc"
    filter_fields = ["host"]


class BSSSrcJsonModel(SrcJsonModelBase):

    src = "bss"
    filter_fields = ["host"]


def main_example():
    obj = TTCSrcJsonModel()
    #  step & sbu
    ifileds = input("select fields (spilt by <&>, pass by <Enter>):\n ")
    fds = [i.strip() for i in ifileds.split("&")] if ifileds else []
    # <4 & <1.5
    iconds = input("filter conditions (spilt by <&>, pass by <Enter>): \n")
    cds = ["%s {}".format(i.strip()) for i in iconds.split("&")] if iconds else []
    if len(ifileds) != len(iconds):
        return
    try:
        fds.index("core")
    except ValueError:
        fds.append("core")
        cds.append('%s == 0')
    else:
        cds[fds.index("core")] = '%s == 0'

    sli = obj.and_select(fds, cds, rtype=None)
    rdf = obj.retrieve(fields=None, indices=sli, rtype="pd.df")  # type: pd.DataFrame
    rdf = rdf.rename(columns=dict(zip(list(rdf.columns), obj[0].fields)), index=dict(zip(list(rdf.index), sli)))
    print(rdf)

    # 2, 8, 9
    outters = input("select uninstall pack's No. (spilt by <,>, pass by <Enter>):\n ")
    unload = [int(i.strip()) for i in outters.split(",")] if outters else []
    load_idx = np.setdiff1d(np.arange(len(obj)), unload).tolist()
    rdf = obj.retrieve(fields=None, indices=load_idx, rtype="pd.df")  # type: pd.DataFrame
    rdf = rdf.rename(columns=dict(zip(list(rdf.columns), obj[0].fields)), index=dict(zip(list(rdf.index), load_idx)))
    print(rdf)


if __name__ == '__main__':
    main_example()
