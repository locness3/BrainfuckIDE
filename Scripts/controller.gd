extends Node

export(NodePath) var data_node
export(NodePath) var terminal_node

# the node that manages and displays the array, set in _ready from data_node
var dataManager
var terminal

# the source code that we are running
var source = ""

# instr is an int: 1- 2+ 3< 4> 5. 6, 7[ 8]
var instr = []
var instrToStr = {1: '-', 2: '+', 3: '<', 4: '>', 5: '.', 6: ',', 7: '[', 8: ']'}

# some settings to control appearence
var combineStreak = true

# the index in the source code that we are to run next
# or the length of the source code array if we are done
var instrIndex = 0

# a list of the location of all open brackets that form the stack
var stack = []

# how much longer we are waiting before we can do something new
var delay = 0

# used to speed things up as 
#var lastOp = 0
#var streak = 0
var baseOpTime = 0.4

func _ready():
	dataManager = get_node(data_node)
	terminal = get_node(terminal_node)
	set_process(true)

func addBFSource(sourceIn):
	source += sourceIn
	for i in sourceIn:
		if i == "-":
			instr.append(1)
		elif i == "+":
			instr.append(2)
		elif i == "<":
			instr.append(3)
		elif i == ">":
			instr.append(4)
		elif i == ".":
			instr.append(5)
		elif i == ",":
			instr.append(6)
		elif i == "[":
			instr.append(7)
		elif i == "]":
			instr.append(8)

func _process(delta):
	delay -= delta
	while delay < 0:
		runNextOp()

func runNextOp():
	
		if instrIndex >= instr.size():
			delay = 0
			return
		
		var instrI = instrIndex
		
		var c = instr[instrI]
		
		#if c == lastOp:
		#	streak += 1
		#else:
		#	lastOp = c
		#	streak = 0
		
		var iters = 1
		
		if combineStreak && c >= 1 && c <= 4:
			while instr.size() > instrI+1 && instr[instrI+1] == c:
				instrI += 1
				iters += 1
		
		var time = calcTime()
		
		if c == 1:
			dataManager.addVal(-iters, time)
		elif c == 2:
			dataManager.addVal(iters, time)
		elif c == 3:
			dataManager.movePtr(-iters, time)
		elif c == 4:
			dataManager.movePtr(iters, time)
		elif c == 5:
			terminal.addOutput(dataManager.getValAscii())
		elif c == 6:
			var a = terminal.popInput()
			if a:
				dataManager.setValAscii(a, time)
			else:
				throwError("please enter input")
		elif c == 7:
			if dataManager.getVal() == 0:
				instrI = findCloseBrace(instrI)-1
			else:
				stack.append(instrI)
		elif c == 8:
			if stack.size() == 0:
				throwError("']' without '['")
			else:
				if dataManager.getVal() == 0:
					stack.pop_back()
				else:
					instrI = stack.back()
		else:
			throwError("unrecognised command " + str(c))
		
		dataManager.blinkOp(instrToStr[c], time)
		
		delay += time
		
		instrIndex = instrI + 1

func findCloseBrace(start):
	if source[start] != "[":
		throwError("findCloseBrace called without the starting point being '['")
		return
	
	var count = 1
	var i = start + 1
	
	while count > 0:
		if i > source.length():
			print("could not find matching '['")
			return source.length()
		
		if source[i] == "[":
			count += 1
		elif source[i] == "]":
			count -= 1
		
		i += 1
	
	return i

func calcTime():
	
	return baseOpTime
	
	#if streak<3:
	#	return 0.35
	#elif streak<12:
	#	return 0.2
	#else:
	#	return 0.05
	
	#return (0.3*5) / (streak+5)
	
	#return max(0.4 - streak/20.0, 0)
	
	#if streak<3:
	#	return 0.2
	#else:
	#	return 0

func throwError(msg):
	print("ERROR: " + msg)