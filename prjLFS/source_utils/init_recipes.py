import re
import numpy as np
import pandas as pd
from models.src_models import TTCSrcJsonModel


class Recipes(object):
    src = None

    slice_rtype = None
    retrieve_fields = None
    retries = 3

    load_placeholder = "i"
    unload_placeholder = "!Unload"

    def __init__(self):
        self.fds = None
        self.cds = None
        self.sli = None
        self.uldid = None
        self.ldid = None
        self.whole_fields = self.src[0].fields

    def check_legal(self, raw_input, fields=None, itype=None, fn=None):
        if not raw_input:
            return list()
        for i in raw_input:
            if isinstance(fields, (list, tuple)) and i not in fields:
                raise IOError("Illegal Input: %s" % i)
            if itype and isinstance(i, itype):
                raise IOError("Illegal Input: %s" % i)
            if callable(fn):
                fn(i)

    def locked_field(self, filed, condi):
        if filed is None:
            return
        try:
            i = self.fds.index(filed)
        except ValueError:
            self.fds.append(filed)
            self.cds.append(condi)
        else:
            self.cds[i] = condi

    def check(self, attr):
        self.check_legal(getattr(self, attr))

    def set_fds_from_input(self):
        ifileds = input("select fields (spilt by <&>, pass by <Enter>):\n ")
        self.fds = [i.strip() for i in ifileds.split("&")] if ifileds else []
        self.check("fds")

    def set_cds_from_input(self):
        iconds = input("filter conditions (spilt by <&>, pass by <Enter>): \n")
        self.cds = ["%s {}".format(i.strip()) for i in iconds.split("&")] if iconds else []
        self.check("cds")

    def set_ldid_from_input(self):
        outters = input("select uninstall pack's No. (spilt by <,>, pass by <Enter>):\n ")
        self.uldid = [i.strip() for i in outters.split(",")] if outters else []
        self.check("uldid")

    def packages_from_slice_idx(self):
        self.sli = self.src.and_select(self.fds, self.cds, rtype=self.slice_rtype) \
            if len(self.fds) else list(range(len(self.src)))
        sdf = self.src.retrieve(fields=self.retrieve_fields, indices=self.sli, rtype="pd.df")
        sdf = sdf.rename(columns=dict(zip(list(sdf.columns), self.whole_fields)),
                         index=dict(zip(list(sdf.index), self.sli)))
        print(sdf)

    def packages_from_load_idx(self):
        self.uldid = np.intersect1d(self.uldid, self.sli)
        self.ldid = np.setdiff1d(np.arange(len(self.src)), self.uldid)
        info = [self.load_placeholder for _ in range(len(self.src))]
        for i in self.uldid:
            info[i] = self.unload_placeholder
        info = np.array(info).reshape(-1, 1)
        ldf = self.src.retrieve(fields=None, indices=None, rtype="np.arr")
        ldf = pd.DataFrame(np.hstack([ldf, info]),
                           columns=self.whole_fields + ["info"])
        print(ldf)

    def retries_(self, exec_fn, retries=None):
        retries_ = retries or self.retries
        while retries_ > 0:
            try:
                exec_fn()
            except IOError as e:
                retries_ -= 1
                print("[last: %s]Critical: %s" % (retries_, e))
            else:
                break

    def retries_exec1(self):
        self.set_fds_from_input()
        self.set_cds_from_input()
        if len(self.fds) != len(self.cds):
            raise IOError("Can't match inputs.")

    def retries_exec2(self):
        self.set_ldid_from_input()

    def __call__(self, locked="core", condi="%s == 0", retries=None):
        self.retries_(exec_fn=self.retries_exec1, retries=retries)
        self.locked_field(locked, condi)
        self.packages_from_slice_idx()
        self.retries_(exec_fn=self.retries_exec2, retries=retries)
        self.packages_from_load_idx()


class TTCRecipes(Recipes):
    src = TTCSrcJsonModel()

    def __init__(self):
        super().__init__()
        self.check_dict = {
            "fds": {"fields": self.whole_fields},
            "cds": {"fn": self.check_sign},
            "uldid": {"fn": self.check_numeric}
        }
        self.uldid_i = 0

    def check(self, attr):
        self.check_legal(getattr(self, attr), **self.check_dict[attr])

    def check_sign(self, i):
        p = re.compile(pattern=r"[^><=]+(={2}|[<>]=?)[^><=]+")
        if not re.search(p, i):
            raise IOError("Illegal Input: %s" % i)

    def check_numeric(self, i):
        try:
            self.uldid[self.uldid_i] = int(i)
            self.uldid_i += 1
        except ValueError:
            raise IOError("Illegal Input: %s" % i)


if __name__ == '__main__':
    ttc = TTCRecipes()
    # ttc(locked=None)
    ttc()
    print(ttc.ldid)
