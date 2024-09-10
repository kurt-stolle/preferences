#!/usr/bin/env python

import fitz
import sys

doc = fitz.open(sys.argv[1])
for page in doc:
    for ann in page.annots():
        tpg = ann.get_textpage()
        loc = tpg.rect
        text = ann.get_text()
        msg = ann.info["content"].replace("\r", "")
        msg = "\n> " + "\n> ".join(msg.split("\n"))
        print(ann)
        print(f"Location: {loc}")
        print(f"Message: " + msg)
        print("\n")
