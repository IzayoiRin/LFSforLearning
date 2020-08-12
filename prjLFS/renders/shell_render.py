import os
import re

from conf import TTC_SHELL_TEMPLATES, TTC_SHELL
from models.src_models import TTCSrcJsonModel


class GenericShRender(object):

    src = None
    sh_temp = None

    def __init__(self, *ldid):
        self.ldid = ldid

    def find_temp(self, name: str):
        ls = os.listdir(self.sh_temp)
        # print(ls)
        pattern = "^run{name}.*\.sh$".format(name=name.rsplit("-")[0])
        pattern = re.compile(pattern)
        for sh in ls:
            if re.match(pattern, sh):
                break
        else:
            raise FileNotFoundError("No such file")
        return os.path.join(TTC_SHELL_TEMPLATES, sh), os.path.join(TTC_SHELL, sh)

    def sub_temp(self, text, **kwargs):
        for k, v in kwargs.items():
            pattern = re.compile("\{\{%s\}\}" % k)
            text = re.sub(pattern, str(v), text)
        return text

    def render(self, ins):
        temp, sh = self.find_temp(ins.name)
        with open(temp, "r") as f:
            text = f.read()
            sub_text = self.sub_temp(text, name=ins.name, sbu=ins.sbu, space=ins.space, ver=ins.ver)
        print(sub_text)
        # with open(sh, "w") as f:
        #     f.write(sub_text)
        # print("Done")

    def __call__(self, together=False):
        for i in self.ldid:
            self.render(self.src[i])




class TCCMixin(object):

    def sub_temp(self, text, **kwargs):
        name = kwargs.pop("name")
        text = re.sub(r"\{\{name\}\}", name.rsplit("-")[0], text)
        tail = name.rsplit("-")[-1] if name.rsplit("-")[-1].isdigit() else ""
        for k, v in kwargs.items():
            pattern = re.compile("\{\{%s%s\}\}" % (k, tail))
            if k == "ver":
                pattern = re.compile("\{\{%s\}\}" % k)
            text = re.sub(pattern, str(v), text)
        return text


class TTCShRender(TCCMixin, GenericShRender):

    src = TTCSrcJsonModel()
    sh_temp = TTC_SHELL_TEMPLATES


if __name__ == '__main__':
    sr = TTCShRender(0, 5)
    sr()
