import logging
import logging.config

from pygluu.containerlib import get_manager
from pygluu.containerlib import wait_for

from settings import LOGGING_CONFIG

logging.config.dictConfig(LOGGING_CONFIG)
logger = logging.getLogger("wait")


def main():
    manager = get_manager()
    deps = ["config", "secret"]
    wait_for(manager, deps)


if __name__ == "__main__":
    main()
