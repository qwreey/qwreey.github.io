import markdown as md
from markdown.extensions import mdExtensions

def buildHtml(infile,outfile):
    with open(infile, "r", encoding="utf-8") as input_file:
        text = input_file.read()
    html = md.markdown(text, extensions=['path.to.module:MyExtClass'])
    with open("some_file.html", "w", encoding="utf-8", errors="xmlcharrefreplace") as output_file:
        output_file.write(html)
