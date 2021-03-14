extends Node2D

class Line:
	var Start : Vector3
	var End : Vector3
	var LineColor : Color
	var Time : float
	
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
	func _init(Start : Vector3, End : Vector3, LineColor : Color, Time : float):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.Time = Time

var Lines = []
var RemovedLine := false

func _process(delta):
	for i in range(len(Lines)):
		Lines[i].Time -= delta
	
	if(len(Lines) > 0 || RemovedLine):
		update() #Calls _draw
		RemovedLine = false

func _draw():
	var Cam := get_viewport().get_camera()
	for i in range(len(Lines)):
		var ScreenPointStart : Vector2 = Cam.unproject_position(Lines[i].Start)
		var ScreenPointEnd : Vector2 = Cam.unproject_position(Lines[i].End)
		
		#Dont draw line if either start or end is considered behind the camera
		#this causes the line to not be drawn sometimes but avoids a bug where the
		#line is drawn incorrectly
		if(Cam.is_position_behind(Lines[i].Start) ||
			Cam.is_position_behind(Lines[i].End)):
			continue
		
		draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor)
	
	#Remove lines that have timed out
	var i = Lines.size() - 1
	while (i >= 0):
		if(Lines[i].Time < 0.0):
			Lines.remove(i)
			RemovedLine = true
		i -= 1

func DrawLine(Start : Vector3, End : Vector3, LineColor : Color, Time : float = 0.0) -> void:
	Lines.append(Line.new(Start, End, LineColor, Time))

func DrawRay(Start : Vector3, Ray : Vector3, LineColor : Color, Time : float = 0.0) -> void:
	Lines.append(Line.new(Start, Start + Ray, LineColor, Time))

func DrawCube(Center : Vector3, HalfExtents : float, LineColor : Color, Time : float = 0.0) -> void:
	#Start at the 'top left'
	var LinePointStart := Center
	LinePointStart.x -= HalfExtents
	LinePointStart.y += HalfExtents
	LinePointStart.z -= HalfExtents
	
	#Draw top square
	var LinePointEnd := LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw bottom square
	LinePointStart = LinePointEnd + Vector3(0, -HalfExtents * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw vertical lines
	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(0, 0, HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(HalfExtents * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(0, 0, -HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)

func DrawParallelepiped(Start : Vector3, End : Vector3, LineColor : Color, Time : float = 0.0) -> void:
	#Draw top square
	var LinePointStart := Start + Vector3(0, End.y - Start.y, 0)
	var LinePointEnd := LinePointStart + Vector3(End.x - Start.x, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = End
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = Start + Vector3(0, End.y - Start.y, End.z - Start.z)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = Start + Vector3(0, End.y - Start.y, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw bottom square
	LinePointStart = Start
	LinePointEnd = LinePointStart + Vector3(End.x - Start.x, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, End.z - Start.z)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = Start + Vector3(0, 0, End.z - Start.z)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = Start
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw vertical lines
	LinePointStart = Start
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time)
	LinePointStart = Start + Vector3(End.x - Start.x, 0, 0)
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time)
	LinePointStart = Start + Vector3(End.x - Start.x, 0, End.z - Start.z)
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time)
	LinePointStart = Start + Vector3(0, 0, End.z - Start.z)
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time)
