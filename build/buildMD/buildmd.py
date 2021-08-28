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
