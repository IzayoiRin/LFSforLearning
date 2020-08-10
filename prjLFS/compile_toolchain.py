import os
import tarfile
import conf as c


class ToolchainPack(object):

    SYS_SOURCES = None

    def __init__(self, pac):
        self.sys_sources = self.SYS_SOURCES or c.SYS_SOURCES
        self.pac = pac

