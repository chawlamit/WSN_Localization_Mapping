import flask
from collections import deque
from flask import Flask,request ,render_template
import os
import datetime
import time

dataPoints=deque()

def time_min(sec):
	return datetime.datetime.fromtimestamp(sec).strftime('%Y-%m-%d %H:%M:%S')

app=Flask(__name__)

@app.route("/", methods=['GET','POST'])
def main():
	if request.method=='GET':
		return render_template('display.html',dataPoints=dataPoints)
		
@app.route("/data", methods=['GET','POST'])
def data():	
	if request.method=='GET':

		gID=request.args.get('groupID')
		print gID
		nID = float(request.args.get('nodeID'))
		print nID
		rNO = float(request.args.get('roomNO'))
		print rNO
		time = int(request.args.get('time'))
		time = time_min(time)
		print time
		quadNO = float(request.args.get('quadNO'))
		print quadNO
	
		if (gID and nID and rNO and time and quadNO):
			dataPoints.append((id_bus,lati,longi,time))
			print dataPoints

		return ("recieved data")
		
port = int(os.getenv('VCAP_APP_PORT', 8080))
if __name__=='__main__':
	app.run(host='0.0.0.0', port=port, debug=True)
