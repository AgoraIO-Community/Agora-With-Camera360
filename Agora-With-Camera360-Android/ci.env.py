#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import shutil


def main():
    with open("./app/src/main/res/values/strings.xml", 'r+',
              encoding='utf-8') as file:

        lines = []
        for line in file.readlines():
            if "agora_app_id" in line:
                line = re.sub(r'>.+<', '><#YOUR_APP_ID#><', line)

            if "camera_360_licence" in line:
                line = re.sub(r'>.+<', '><#LICENCE#><', line)

            lines.append(line)

        file.seek(0)
        file.truncate()
        file.writelines(lines)
        file.flush()


if __name__ == "__main__":
    main()
    print("Done..")
