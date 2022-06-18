import sys
import json
stdout = sys.stdout
from builder import buildHtml

def processLine(line):
	try:
		decoded = json.loads(line)
	except Exception as e: stdout.write(json.dumps({'err': str(e)}))
	else:
		func = decoded.get('f')
		nonce = decoded.get('o')
		data = decoded.get('d')

		# execute function
		if not func:
			result = buildHtml(data.get("from"),data.get("to"))
		elif func == "kill": sys.exit()

		# elif func == "setRateLimit":
		# 	result = setRateLimit(data)

		# write return data
		if not result: result = False
		returnData = {'o': nonce}
		if type(result) == str and result.startswith("ERR:"):
			returnData['e'] = result
		else: returnData['d'] = result
		stdout.write(json.dumps(returnData))
		stdout.write("\n")
		stdout.flush()
