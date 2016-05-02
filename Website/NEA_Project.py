import flask
from collections import deque
from flask import Flask,request ,render_template
import os
import datetime
import time

MaxNodesPerGroup = 5
MaxGroups = 3

MaxRooms=3
MaxQuadrants=4

# dataToDisplay=[[''] * MaxQuadrants] * MaxRooms # rNO,quadNO indexed
# inputList=[[''] * MaxNodesPerGroup] * MaxGroups # gID,nID indexed
inputList = [['' for x in range(MaxNodesPerGroup)] for y in range(MaxGroups)] 
dataToDisplay = [['' for x in range(MaxQuadrants)] for y in range(MaxRooms)]

print inputList

def time_min(sec):
	return datetime.datetime.fromtimestamp(sec).strftime('%Y-%m-%d %H:%M:%S')

app=Flask(__name__)

@app.route("/", methods=['GET','POST'])
def main():
	if request.method=='GET':
		return render_template('display.html',dataToDisplay=dataToDisplay)
		
@app.route("/data", methods=['GET','POST'])
def data(): 
	if request.method=='GET':

		gID=int(request.args.get('groupID'))
		# print gID
		nID = int(request.args.get('nodeID'))
		# print nID
		rNO = int(request.args.get('roomID'))
		# rNO=rNO-1
		# print rNO
		time = int(request.args.get('time'))
		time = time_min(time+19800)
		# print time
		quadNO = int(request.args.get('quadNO'))
		quadNO=quadNO-1
		# print quadNO
		global dataToDisplay
		dataToDisplay = [['' for x in range(MaxQuadrants)] for y in range(MaxRooms)]
		if (gID and nID and rNO and time and quadNO):
			inputList[gID-1][nID]=(rNO,quadNO,time)
			# print inputList
			
			for i in range(len(inputList)):
				for j in range(len(inputList[i])):
					strToDisplay=''	
					if inputList[i][j]:
						# print(inputList[i][j])
						print "i:" +str(i)+ "j:" + str(j)
						dataToDisplay[inputList[i][j][0] - 1][inputList[i][j][1]] += "<li>" + " Group ID:" + str(i+1) + " Node ID:" +str(j) + " Timestamp:" + str(inputList[i][j][2]) + "</li>"
			# print dataToDisplay

			# dataToDisplay[rNO-1][quadNO-1]=(gID,nID,time)
		return ("recieved data")
		
port = int(os.getenv('VCAP_APP_PORT', 8080))
if __name__=='__main__':
	app.run(host='0.0.0.0', port=port, debug=True)


# /data?groupID=1&nodeID=2&roomID=1&quadNO=3&time=1462164476