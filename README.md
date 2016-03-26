Network Embedded Systems Project 


Objective: The aim of this project is to track the location of a set of people in 3 rooms with data available on a website updated every 5 mins on a GUI.

System-setup: Telosb motes running on tinyOS

Methodology: 
1. Trilateration is used to calculate the position of tracker nodes.
2. RSSI (Recieved Signal Strength Indicator is used to calculate the distance between trackers and beacons).
3. Time slicing is used and each Tracker node is alloted with a Time Slot during which it calculates its location by broadcasting RSSI request messages to the 3 beacon Nodes.
4. Time Synch for TDMA is required, (TDP can be used. Yet to be finalized)
5. Tracker will forward their location to the nearest beacon. THe beacons form a multihop path and forward the position of the nodes towards the base station. 
6. All the nodes will sleep for a period of 5 mins in order to save power. (because location is updated every 5 mins)

