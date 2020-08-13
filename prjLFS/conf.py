import os

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
SCRIPTS = os.path.join(ROOT_DIR, "scripts")
SOURCES = os.path.join(ROOT_DIR, "sources")
TEMPLATES = os.path.join(ROOT_DIR, "templates")

LOGS = os.path.join(ROOT_DIR, "logs")

SYS_SOURCES = os.path.join(ROOT_DIR, ".SYS_SOURCES")

PACKAGES_URL = os.path.join(SOURCES, "wget_list")

TTC_SHELL = os.path.join(SCRIPTS, "TTC", "toolchain")
TTC_SHELL_TEMPLATES = os.path.join(TEMPLATES, "TTC", "toolchain")