import os
import re

from conf import TTC_SHELL_TEMPLATES, TTC_SHELL
from models.src_models import TTCSrcJsonModel


class Render(object):
    """
    Examples:
        render_func[for]
        @for:i:step1:: bash ${RUNSH}/manage.sh {{i.package}} {{i.name}} {{i.params}} ::
        @for:j:step2:: bash ${RUNSH}/manage.sh {{j.package}} {{j.name}} {{j.params}} ::

        render_from_ins:
        bash ${RUNSH}/manage.sh {{i.package}} {{i.name}} {{i.params}}

    src = TTCSrcJsonModel()
    s1idx = src.and_select(fields=["step", ], conds=["%s==1", ])
    s2idx = src.and_select(fields=["step", ], conds=["%s==2", ])
    s3idx = src.and_select(fields=["step", ], conds=["%s==3", ])

    ret = r.render_function(
        target,
        step1=[src[i] for i in s1idx],
        step2=[src[i] for i in s2idx],
        step3=[src[i] for i in s3idx]
    )
    print(ret)

    ret2 = r.render_from_ins(target, "i", src[0])
    print(ret2)
    """

    ins_pattern = r"\{\{%s\.[a-zA-Z0-9_]+\}\}"
    ins_pattern_ = re.compile(r"\{\{[a-zA-Z0-9_]+\.([a-zA-Z0-9_]+)\}\}")
    func_pattern = re.compile(r"@(for):([a-zA-Z0-9_]+):([a-zA-Z0-9_]+)::(.*)::")

    def render_from_ins(self, handler, *ins):
        """
        render template content from orm instance
        :param handler: text content going to be processed
        :param ins: orm instance: (ins_name, instance)
        :return: rendered handler
        """
        for ret in re.findall(self.ins_pattern % ins[0], handler):
            handler = re.sub(
                ret,
                str(getattr(ins[1], re.search(self.ins_pattern_, ret).group(1))),
                handler
            )
        return handler

    def render_from_ins_arr(self, handler, **iterins):
        for k, v in iterins.items():
            handler = self.render_from_ins(handler, k, v)
        return handler

    def _func_for(self, var_name, arr_name, handler, **iterins):
        ret = "\n".join(
            [self.render_from_ins(handler.strip(), var_name, ins) for ins in iterins.get(arr_name)]
        )
        return ret

    def render_function(self, context, **kwargs):
        func_list = re.findall(self.func_pattern, context)
        blocks = list()
        for func, var1, var2, handler in func_list:
            blocks.append(
                [r"@%s:%s:%s::.*::" % (func, var1, var2),
                 getattr(self, "_func_%s" % func)(var1, var2, handler, **kwargs)]
            )
        for b, t in blocks:
            context = re.sub(b, t, context)
        return context


class GenericShRender(object):
    src = None
    sh_temp = None
    default_render = Render()

    def __init__(self, *ldid):
        self.ldid = ldid

    def find_temp(self, name: str):
        ls = os.listdir(self.sh_temp)
        pattern = "^run{name}.*\.sh$".format(name=name.rsplit("-")[0])
        pattern = re.compile(pattern)
        for sh in ls:
            if re.match(pattern, sh):
                break
        else:
            raise FileNotFoundError("No such file")
        return os.path.join(TTC_SHELL_TEMPLATES, sh), os.path.join(TTC_SHELL, sh)

    def render(self, ins, name=None):
        name = name or ins.name
        temp, sh = self.find_temp(name)
        with open(temp, "r") as f:
            text = f.read()
        if isinstance(ins, dict):
            sub_text = self.default_render.render_from_ins_arr(text, **ins)
        else:
            sub_text = self.default_render.render_from_ins(text, "ins", ins)
        with open(sh, "w") as f:
            f.write(sub_text)
        print("Done")

    def __call__(self):
        link = dict()
        for i in self.ldid:
            ins = self.src[i]
            if getattr(ins, "link", None) is not None:
                if link.get(ins.link, None) is None:
                    link[ins.link] = list()
                link[ins.link].append(ins)
                continue
            # self.render(ins)
        for i in link.values():
            keys = [chr(i) for i in range(97, 97+len(i))]
            kwins = dict(zip(keys, i))
            self.render(kwins, name=i[0].name)


class TTCShRender(GenericShRender):

    src = TTCSrcJsonModel()
    sh_temp = TTC_SHELL_TEMPLATES


if __name__ == '__main__':
    sr = TTCShRender(*range(0, 10))
    sr()
