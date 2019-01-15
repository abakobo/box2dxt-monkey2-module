Namespace akofw

#Import "<std>"
'#Import "<mojo>"
'#Import "<box2d>"
'#Import "<box2dxt>"

Using std..

'Alias Line2Df:Line2D<Float>
'Alias LineSegment2Df:LineSegment2D<Float>

#Rem
Class LineSegment2DDouble
	
	Private 
	
	Field p1:Vec2Double
	Field p2:Vec2Double
	Field l:Line2DDouble
	
	Public
	
	Method New(point1:Vec2Double,point2:Vec2Double)
		p1=point1
		p2=point2
		Local tp:T=point2-point1
		l=New Line2D(point1, tp)
	
	End
	
	Method IsParallel:Bool(s:LineSegment2DDouble)
		Return False
	End
	
	Method Intersects:Bool(s:LineSegment2DDouble)
		
		If Self.IsParallel(s)
			Return False
		Else
		
		End
		
	End
	
	Method Intersection:Vec2Double(s:LineSegment2DDouble)
		Return Null
	End
	
End
#end

Struct Line2D
	
	Field o:Vec2<Double>
	Field d:Vec2<Double>
	
	Method New(origin:Vec2<Double>,directionSegment:Vec2<Double>)
		o=origin
		d=directionSegment
	End
	
	Method IsParallel:Bool(line:Line2D)
		If Self.d.Normalize()<>line.d.Normalize() And Self.d.Normalize()<>-line.d.Normalize()
			Return False
		Else
			Return True
		End
	End
	
	Method Intersection:Vec2<Double>(line:Line2D)

		'Print "parall: "+Self.IsParallel(line)

		Local divisor:Double=(line.d.y*Self.d.x)-(Self.d.y*line.d.x)
		If divisor=0
			Print "Error: divisor=0 returning Vec2 Null(0,0)! You should use Line2D.IsParallel before calling Line2D.intersection!"
			Return Null
		End
		
		'Print "div: "+divisor
		Local multiplor:Double=(Self.d.x*Self.o.y)+Self.d.y*(line.o.x-Self.o.x)-Self.d.x*line.o.y
		
		Local tline:=multiplor/divisor
		'Print tline
		Local intersectPoint:=line.o+(line.d*tline)
		
		Return intersectPoint

	End
	
	'donne false pour ligne égales même si en vrai elles on infinité d'intersections et false si touche le bord
	Method SegmentIntersects:Bool(line:Line2D)
		If Self.IsParallel(line) Then Return False
		Local inter:=Self.Intersection(line)
		Local o2:=o+d
		Local selfMinx:=Min(o.x,o2.x)
		Local selfMaxx:=Max(o.x,o2.x)
		Local selfMiny:=Min(o.y,o2.y)
		Local selfMaxy:=Max(o.y,o2.y)
		
		Local insideSelf:=False
		If selfMinx<inter.x And inter.x<selfMaxx
			If selfMiny<inter.y And inter.y<selfMaxy
				insideSelf=True
			End
		End
	
		Local lineo2:=line.o+line.d
		Local lineMinx:=Min(line.o.x,lineo2.x)
		Local lineMaxx:=Max(line.o.x,lineo2.x)
		Local lineMiny:=Min(line.o.y,lineo2.y)
		Local lineMaxy:=Max(line.o.y,lineo2.y)
		
		Local insideLine:=False
		If lineMinx<inter.x And inter.x<lineMaxx
			If lineMiny<inter.y And inter.y<lineMaxy
				insideLine=True
			End
		End
		
		If insideSelf And insideLine Then Return True
		
		Return False
		
	End
	
End

#rem
Function Main()

	
	Local o1:=New Vec2f(1,1)
	Local d1:=New Vec2f(-2,1)
	Local o2:=New Vec2f(3,2)
	Local d2:=New Vec2f(-1,0)
	
	Local l1:=New Line2D(o1,d1)
	Local l2:=New Line2D(o2,d2)
	
	Print l1.Intersection(l2)

End
#end