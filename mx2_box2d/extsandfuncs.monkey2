Namespace box2dxt.extsandfuncs

#Import "<std>"
#Import "<mojo>"
#Import "<box2d>"
'#Import "<box2dxt>"

Using std..



'camera

'Matrix reverse trans

'-------------------------------------------
'
'   vec2d angle ext
'
'-------------------------------------

Alias Vec2d:Vec2<Double>

Struct Vec2<T> Extension
	
	'- Pi to Pi
	Method SignedAngleWith:Double(v:Vec2<T>)
		If (Self.Length=0) Or (v.Length=0)
			#If __DEBUG__
				Print"ERROR: null Vec2<T> for angle, returning zero"
			#End
			Return 0
		End
		
		Local dot := Self.x*v.x + Self.y*v.y    '  # dot product between [x1, y1] and [x2, y2]
		Local det := Self.x*v.y - Self.y*v.x     ' # determinant
		Return ATan2(det, dot) ' # atan2(y, x) or atan2(sin, cos)
	End
	
	'0 to 2Pi
	Method PositiveAngleWith:Double(v:Vec2<T>)
		If (Self.Length=0) Or (v.Length=0)
			#If __DEBUG__
				Print"ERROR: null Vec2<T> for angle, returning zero"
			#End
			Return 0
		End
		
		Local dot := Self.x*v.x + Self.y*v.y    '  # dot product between [x1, y1] and [x2, y2]
		Local det := Self.x*v.y - Self.y*v.x     ' # determinant
		Local a:= ATan2(det, dot) ' # atan2(y, x) or atan2(sin, cos)
		If a<0 Then a=2*Pi+a
		Return a
	End
	
	
	Method Cross:Double(v:Vec2<T>)
		Return x * v.y - y * v.x
	End
		
End


'--------------------------------------
'
'  Stack ext shuffle
'
'--------------------------------------

Class Stack<T> Extension
	Method Shuffle()
		For Local i:=0 Until Self.Length
			Self.Swap(i,Int(Rnd(0,Self.Length-0.00000001)))
		Next
	End

End

'---------------------------------------
'
'    Structs with points/vects/Line  (geoms)
'
'---------------------------------------

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
	
	Method IsOkToIntersect:Bool(line:Line2D)

		Local divisor:Double=1.0*(1.0*line.d.y*Self.d.x*1.0)-1.0*(1.0*Self.d.y*1.0*line.d.x)
		
		If divisor<1.0e-35 And divisor>-1.0e-35
			Return False

		End
		
		Return True

		
	End
	
	Method Intersection:Vec2<Double>(line:Line2D)

		Local divisor:Double=1.0*(1.0*line.d.y*Self.d.x*1.0)-1.0*(1.0*Self.d.y*1.0*line.d.x)

		If divisor=0.0
			#If __DEBUG__
				Print"Error: divisor=0 returning Vec2 Null(0,0)! You should use Line2D.Parallel before calling Line2D.intersection!"
			#End
			Return Null
		End
		
		Local multiplor:Double=(Self.d.x*Self.o.y)+Self.d.y*(line.o.x-Self.o.x)-Self.d.x*line.o.y
		Local tline:=multiplor/divisor
		Local intersectPoint:=line.o+(line.d*tline)
		
		Return intersectPoint

	End
	
	'donne false pour ligne égales même si en vrai elles on infinité d'intersections et false si touche le bord
	Method SegmentIntersectsLimitsExcluded:Bool(line:Line2D)
		
		If Not Self.IsOkToIntersect(line) Then Return False
		
		Local inter:=Self.Intersection(line)
		Local intx:=inter.x
		Local inty:=inter.y
		Local o2:=o+d
		Local selfMinx:=Min(o.x,o2.x)
		Local selfMaxx:=Max(o.x,o2.x)
		Local selfMiny:=Min(o.y,o2.y)
		Local selfMaxy:=Max(o.y,o2.y)
		
		Local insideSelf:=False
		
		If ((selfMinx<inter.x) And (inter.x<selfMaxx)) Or ((selfMinx=selfMaxx) And (selfMinx=inter.x))
			If ((selfMiny<inter.y) And (inter.y<selfMaxy)) Or ((selfMiny=selfMaxy) And (selfMiny=inter.y))
				insideSelf=True
			Else
				Return False 'pour zapper y
			End
		End
	
		Local lineo2:=line.o+line.d
		Local lineMinx:=Min(line.o.x,lineo2.x)
		Local lineMaxx:=Max(line.o.x,lineo2.x)
		Local lineMiny:=Min(line.o.y,lineo2.y)
		Local lineMaxy:=Max(line.o.y,lineo2.y)
		Local insideLine:=False
		If ((lineMinx<inter.x) And (inter.x<lineMaxx)) Or ((lineMinx=lineMaxx) And (lineMinx=inter.x))
			If ((lineMiny<inter.y) And (inter.y<lineMaxy)) Or ((lineMiny=lineMaxy) And (lineMiny=inter.y))
				insideLine=True
			End
		End
		
		If insideSelf And insideLine Then Return True
		
		Return False
		
	End
	
	Method IsCollinearPointInside:Bool(p:Vec2d)
		
			Local inter:=p
			
			Local o2:=o+d
			
			Local selfMinx:=Min(o.x,o2.x)
			Local selfMaxx:=Max(o.x,o2.x)
			Local selfMiny:=Min(o.y,o2.y)
			Local selfMaxy:=Max(o.y,o2.y)
			
			Local insideSelf:=False
			
			If ((selfMinx<=inter.x) And (inter.x<=selfMaxx)) Or ((selfMinx=selfMaxx) And (selfMinx=inter.x))
				If ((selfMiny<=inter.y) And (inter.y<=selfMaxy)) Or ((selfMiny=selfMaxy) And (selfMiny=inter.y))
					Return True
				Else
					Return False
				End
			End
			
			Return False
			
	End
	
	Method SegmentIntersectsPAB:PointAndBool(line:Line2D)
			
			If Not Self.IsOkToIntersect(line)
				Return New PointAndBool(New Vec2d(0,0),False)
			End
			
			Local inter:=Self.Intersection(line)
			'Local intx:=inter.x
			'Local inty:=inter.y
			Local o2:=o+d
			Local selfMinx:=Min(o.x,o2.x)
			Local selfMaxx:=Max(o.x,o2.x)
			Local selfMiny:=Min(o.y,o2.y)
			Local selfMaxy:=Max(o.y,o2.y)
			
			Local insideSelf:=False
			
			If ((selfMinx<=inter.x) And (inter.x<=selfMaxx)) Or ((selfMinx=selfMaxx) And (selfMinx=inter.x))
				If ((selfMiny<=inter.y) And (inter.y<=selfMaxy)) Or ((selfMiny=selfMaxy) And (selfMiny=inter.y))
					insideSelf=True
				Else
					New PointAndBool(inter,False)
				End
			End
		
			Local lineo2:=line.o+line.d
			Local lineMinx:=Min(line.o.x,lineo2.x)
			Local lineMaxx:=Max(line.o.x,lineo2.x)
			Local lineMiny:=Min(line.o.y,lineo2.y)
			Local lineMaxy:=Max(line.o.y,lineo2.y)
			Local insideLine:=False
			If ((lineMinx<=inter.x) And (inter.x<=lineMaxx)) Or ((lineMinx=lineMaxx) And (lineMinx=inter.x))
				If ((lineMiny<=inter.y) And (inter.y<=lineMaxy)) Or ((lineMiny=lineMaxy) And (lineMiny=inter.y))
					insideLine=True
				End
			End
			
			If insideSelf And insideLine
				Return New PointAndBool(inter,True)
			End
			
			Return New PointAndBool(inter,False)
			
		End
		
		Method IsCollinear:Bool(l:Line2D) 
			
			If Self.IsParallel(l)
				Local p2:=Self.o+Self.d
				If ((l.o.y - p2.y) * (p2.x - Self.o.x) = (p2.y - Self.o.y) * (l.o.x - p2.x))
					Return True
				End
			End
			
			Return False
			
		End

End

Struct PointAndBool
	
	Field p:Vec2d
	Field b:Bool
	
	Method New(point:Vec2d,bol:Bool)
		p=point
		b=bol
	End
End

Struct PointAndInt
	
	Field p:Vec2d
	Field i:Int
	
	Method New(point:Vec2d,in:Int)
		p=point
		i=in
	End
End

Struct SegmentPWI
	
	Field pp1:PointsPair
	Field pp2:PointsPair
	Field hasIntersection:Bool
	Field intersection:Vec2d
	
	Method New(paa:Vec2d,pab:Vec2d,pba:Vec2d,pbb:Vec2d)
		pp1=New PointsPair(paa,pab)
		pp2=New PointsPair(pba,pbb)
		
		Local line1:=pp1.ToLine2D()
		Local line2:=pp2.ToLine2D()
		
		Local pabool:PointAndBool=line1.SegmentIntersectsPAB(line2)
		
		hasIntersection=pabool.b
		intersection=pabool.p
				
	End
	
	Method Contains:Bool(pp:PointsPair)
		
		If pp1=pp Or pp2=pp Then Return True
		
		Return False
	
	End
	
	Operator =:Bool(s:SegmentPWI)
	
		If pp1=s.pp1 And pp2=s.pp2 Then Return True
		If pp1=s.pp2 And pp2=s.pp1 Then Return True 
		Return False
	End
	
End

Struct PointsPair
	
	Field p1:Vec2d
	Field p2:Vec2d
	
	Method New(pa:Vec2d,pb:Vec2d)
		p1=pa
		p2=pb
		End
	
	Method Contains:Bool(p:Vec2d)
		
		If p1=p Or p2=p Then Return True
		
		Return False
	
	End
	
	Method ToLine2D:Line2D()
		Return New Line2D(p1,p2-p1)
	End
	
	Operator =:Bool(pp:PointsPair)
	
		If p1=pp.p1 And p2=pp.p2 Then Return True
		If p1=pp.p2 And p2=pp.p1 Then Return True 
		Return False
	End
	
End


'-----------------------------------------
'
'    Small Funcs
'
'---------------------------------------

Function ArrayToStack<T>:Stack<T>(arr:T[])
	Local retStack:=New Stack<T>
	If arr.Length>0
		For Local i:=arr.Length-1 To 0 Step -1
			retStack.Add(arr[i])
		Next
	End
	Return retStack
End

Function b2Vec2ArrayToVec2dArray:Vec2d[](inArr:b2Vec2[])
	Local retArr:=New Vec2d[inArr.Length]
	For Local i:=0 Until inArr.Length
		retArr[i]=inArr[i]
	Next
	Return retArr
End

Function Vec2dArrayTob2Vec2Array:b2Vec2[](inArr:Vec2d[])
	Local retArr:=New b2Vec2[inArr.Length]
	For Local i:=0 Until inArr.Length
		retArr[i]=inArr[i]
	Next
	Return retArr
End