# Writen by qwreey
# on Aub 29th 2021
#
# gole of this code :
# building markdown to html
# with pymarkdown's tabbed,
# emoji, footnode extensions
#
# it will called by lua (lua node)
#
# uses:
# give json array that includes what you want
# to build, the childrens are has 2 values
# first one, has 'from' index, it will be markdown file
# the last, secound one, has 'to' index, it will be target(output) file (html)

import markdown
import sys
import json

async def buildHtml(infile,outfile):
    input_file = open(infile, "r", encoding="utf-8")
    output_file = open(outfile, "w", encoding="utf-8", errors="xmlcharrefreplace")
    output_file.write(
        markdown.markdown(input_file.read(),
            output_format="html5",
            extensions=[
                'pymdownx.tabbed'
            ]
        )
    )

for item in json.loads(sys.argv[1]):
    buildHtml(item["from"],item["to"])
