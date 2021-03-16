extends Node2D

class Line:
	var Start : Vector3
	var End : Vector3
	var LineColor : Color
	var Time : float
	var Text : String
	var TextPos : String
	var FontColor : Color

	var label_ref : Label
	
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
	func _init(Start : Vector3, End : Vector3, LineColor : Color, Time : float, Text : String = "", TextPos : String = "end", FontColor : Color = Color(1,1,1,1)):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.Time = Time
		self.Text = Text
		self.TextPos = TextPos
		self.FontColor = FontColor

var Lines = []
var RemovedLine := false

func _process(delta):
	if len(Lines) > 0:
		for i in range(len(Lines)):
			Lines[i].Time -= delta
	
	if(len(Lines) > 0 || RemovedLine):
		update() #Calls _draw
		RemovedLine = false

func _draw():
	var Cam := get_viewport().get_camera()
	for i in range(len(Lines)):
		if (Lines[i].Time >= 0):
			var ScreenPointStart : Vector2 = Cam.unproject_position(Lines[i].Start)
			var ScreenPointEnd : Vector2 = Cam.unproject_position(Lines[i].End)
			
			#Dont draw line if either start or end is considered behind the camera
			#this causes the line to not be drawn sometimes but avoids a bug where the
			#line is drawn incorrectly
			if(Cam.is_position_behind(Lines[i].Start) ||
				Cam.is_position_behind(Lines[i].End)):
				continue
			
			draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor, 3.0, true)
			
			if (Lines[i].Text != ""):
				if Lines[i].TextPos == "end":
					Lines[i].label_ref = Label.new()
					add_child(Lines[i].label_ref)
					#Lines[i].label_ref.set("custom_colors/default_color", Color(244.0 / 256.0, 246.0 / 256.0, 10.0 / 256.0))
					Lines[i].label_ref.add_color_override("font_color", Lines[i].FontColor)
					Lines[i].label_ref.text = Lines[i].Text
					Lines[i].label_ref.rect_position = ScreenPointEnd
				elif Lines[i].TextPos == "center":
					Lines[i].label_ref = Label.new()
					add_child(Lines[i].label_ref)
					#Lines[i].label_ref.set("custom_colors/default_color", Color(244.0 / 256.0, 246.0 / 256.0, 10.0 / 256.0))
					Lines[i].label_ref.add_color_override("font_color", Lines[i].FontColor)
					Lines[i].label_ref.text = Lines[i].Text
					var pos : Vector2 = ScreenPointStart + Vector2( (ScreenPointEnd.x - ScreenPointStart.x) / 2, (ScreenPointEnd.y - ScreenPointStart.y) / 2 )
					Lines[i].label_ref.rect_position = pos
					
	#Remove lines that have timed out
	var i = Lines.size() - 1
	while (i >= 0):
		if(Lines[i].Time < 0.0):
			if (is_instance_valid(Lines[i].label_ref)):
				Lines[i].label_ref.queue_free()
			Lines.remove(i)
			RemovedLine = true
		i -= 1

func DrawLine(Start : Vector3, End : Vector3, LineColor : Color, Time : float = 0.0, Text : String = "", TextPos : String = "end", FontColor : Color = Color(1,1,1,1)) -> void:
	Lines.append(Line.new(Start, End, LineColor, Time, Text, TextPos, FontColor))

func DrawRay(Start : Vector3, Ray : Vector3, LineColor : Color, Time : float = 0.0, Text : String = "", TextPos : String = "end", FontColor : Color = Color(1,1,1,1)) -> void:
	Lines.append(Line.new(Start, Start + Ray, LineColor, Time, Text, TextPos, FontColor))

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
	pass
	#Draw top square
	var color := Color(244.0 / 256.0, 246.0 / 256.0, 10.0 / 256.0)
	var LinePointStart := Start + Vector3(0, End.y - Start.y, 0)
	var LinePointEnd := LinePointStart + Vector3(End.x - Start.x, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "X", "center", color);
	LinePointStart = LinePointEnd
	LinePointEnd = End
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "Z", "center", color);
	LinePointStart = LinePointEnd
	LinePointEnd = Start + Vector3(0, End.y - Start.y, End.z - Start.z)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "X", "center", color);
	LinePointStart = LinePointEnd
	LinePointEnd = Start + Vector3(0, End.y - Start.y, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "Z", "center", color);
	
	#Draw bottom square
	LinePointStart = Start
	LinePointEnd = LinePointStart + Vector3(End.x - Start.x, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "X", "center", color);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, End.z - Start.z)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "Z", "center", color);
	LinePointStart = LinePointEnd
	LinePointEnd = Start + Vector3(0, 0, End.z - Start.z)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "X", "center", color);
	LinePointStart = LinePointEnd
	LinePointEnd = Start
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time, "Z", "center", color);
	
	#Draw vertical lines
	LinePointStart = Start
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time, "Y", "center", color)
	LinePointStart = Start + Vector3(End.x - Start.x, 0, 0)
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time, "Y", "center", color)
	LinePointStart = Start + Vector3(End.x - Start.x, 0, End.z - Start.z)
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time, "Y", "center", color)
	LinePointStart = Start + Vector3(0, 0, End.z - Start.z)
	DrawRay(LinePointStart, Vector3(0, End.y - Start.y, 0), LineColor, Time, "Y", "center", color)

func DrawCartesianAxis(Origin : Vector3, LineLength : float, Time : float = 0.0) -> void:
	var xAxisColor := Color(1, 0, 0, 1)
	var yAxisColor := Color(0, 1, 0, 1)
	var zAxisColor := Color(0, 0, 1, 1)
	DrawRay(Origin, Vector3(LineLength, 0, 0), xAxisColor, Time, "X", "end")
	DrawRay(Origin, Vector3(0, LineLength, 0), yAxisColor, Time, "Y", "end")
	DrawRay(Origin, Vector3(0, 0, LineLength), zAxisColor, Time, "Z", "end")
