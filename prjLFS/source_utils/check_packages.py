# check packages whether correct.

import os
import conf as c

packList = os.path.join(c.SOURCES, c.PACKAGES_URL)


def create(pack):
    with open(os.path.join(c.SYS_SOURCES, pack), "w") as f:
        f.write("")


def main():
    lacks = list()
    sumall = 0

    def check(pac):
        pac = os.path.join(c.SYS_SOURCES, pac)
        if not os.path.exists(pac):
            lacks.append(pack)

    with open(packList, "r") as f:
        line = f.readline()
        while line:
            sumall += 1
            pack = os.path.split(line)[-1].strip()
            # create(pack)
            check(pack)
            line = f.readline()
    msg = "Lack: %s / Total: %s" % (len(lacks), sumall)
    print(msg)
    if len(lacks):
        with open(os.path.join(c.LOGS, "check_lack_pac.log"), "w") as f:
            f.write("\n".join(lacks))
        for i in lacks:
            print("--| %s" % i)


if __name__ == '__main__':
    main()
