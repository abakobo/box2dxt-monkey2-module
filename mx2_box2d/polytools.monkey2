Namespace polytools

#Import "<box2d>"

Using box2d..
Using std..

' Copyright 2000 softSurfer, 2012 Dan Sunday
' This code may be freely used and modified for any purpose
' providing that this copyright notice is included with it.
' SoftSurfer makes no warranty for this code, and cannot be held
' liable for any real or imagined damage resulting from its use.
' Users of this code must verify correctness for their application.


Function IsLeft:Int( P0:b2Vec2, P1:b2Vec2, P2:b2Vec2 )

	return ( (P1.x - P0.x) * (P2.y - P0.y) - (P2.x -	P0.x) * (P1.y - P0.y) )
End

Function wn_PnPoly:Int( P:b2Vec2, V:b2Vec2[] )
	
	'Print V.size
	If V[0]<>V[V.Length-1]
		V=V.Resize(V.Length+1)
		V[V.Length-1]=V[0]
	End
	'Print V.size

	Local wn := 0	' the  winding number counter

	' loop through all edges of the polygon
	For Local i:=0 To V.Length-2	' edge from V[i] to  V[i+1]
		If V[i].y <= P.y			' start y <= P.y
			If V[i+1].y	> P.y		' an upward crossing
					If IsLeft( V[i], V[i+1], P) > 0	' P left of  edge
						wn+=1			' have  a valid up intersect
					End
			End
		Else							' start y > P.y (no test needed)
			If V[i+1].y <= P.y	' a downward crossing
					If IsLeft( V[i], V[i+1], P) < 0	' P right of  edge
						wn-=1			' have  a valid down intersect
					End
			End
		End
	Next
	Return wn
End

Function cleanPolygon:b2Vec2[](vertices:b2Vec2[])
	


	
	If vertices.Length<3
		#If __DEBUG__
			Print "ERROR less than 3 vertices for CreatePolygonShapes . "
		#End
		Return Null
	End

	'Check intersections
		'check si même point 	-> si même collés enlever un des deux-> pas intersection
		'						-> si même à une place à côté -> virer le edge et dire que zone sans surface=nul vu que poly, en plus edge dynamique pue -> pas intersection
		'						-> sinon add intersection
		'
		'check si intersection lineSegment-lineSegment (à implémenter, en utilisan geom.line?)
		'
		'.
		'.
		'.
	'M^me points:
	'pas intersection: si mêmes collés, si même à une place à côté

	Local CleanIntersectionPass1Stack:=New Stack<b2Vec2>
	Local tCopy:=New Stack<b2Vec2>

	
	For Local i:=0 Until vertices.Length
		tCopy.Add(vertices[i])
	Next

	'Return tCopy.ToArray() 'orithroihotihgoerihgoeihgoerihgoerihgoerihgoerihgoerihg
	Print "Step1 "
	While tCopy.Length>0
		Print "tCopyLength: "+tCopy.Length
		
		
		If CleanIntersectionPass1Stack.Length=0 'premier point est pris d'office
			
			CleanIntersectionPass1Stack.Add(tCopy.Pop())
			Print "pass1Length=0: "+CleanIntersectionPass1Stack.Length
			
		Elseif CleanIntersectionPass1Stack.Length=1 'deuxiemme point a une seule condition (<>précédent)

			Print Not (tCopy.Top=CleanIntersectionPass1Stack.Top)
			
			If Not (tCopy.Top=CleanIntersectionPass1Stack.Top)
				
				CleanIntersectionPass1Stack.Add(tCopy.Pop())
				Print "pass1Length=1: "+CleanIntersectionPass1Stack.Length
				
			Else
				tCopy.Pop()
				Print "pop1"
			End
			
		Elseif CleanIntersectionPass1Stack.Length>1 'troisièmme+ a deux conditions (<>précédent et <>antéprécédent)
			
			If (Not (tCopy.Top=CleanIntersectionPass1Stack.Top)) And (Not (tCopy.Top=CleanIntersectionPass1Stack[CleanIntersectionPass1Stack.Length-2])) '1 avant .Top

				CleanIntersectionPass1Stack.Add(tCopy.Pop())
				Print "pass1Length>1: "+CleanIntersectionPass1Stack.Length
				
			Else
				tCopy.Pop()
				Print "pop>1"
			End

		End
		
	Wend
		Print "Step2 "+CleanIntersectionPass1Stack.Length
	If CleanIntersectionPass1Stack.Top<>CleanIntersectionPass1Stack[0] Then CleanIntersectionPass1Stack.Add(CleanIntersectionPass1Stack[0])
		Print "Step3 "+CleanIntersectionPass1Stack.Length
	If CleanIntersectionPass1Stack.Length<4
		#If __DEBUG__
			Print "ERROR less than 3 different vertices for CreatePolygonShapes After cleanup. "
		#End
		Return Null
	End
	
	'cherchage d'intersections par segmentline-segent-line et ajout au stackPass2
	Local CleanIntersectionPass2Stack:=New Stack<b2Vec2>
	Local intersectionStack:=New Stack<b2Vec2>
	
	Print "Step4 "
	
	For Local i:=0 Until CleanIntersectionPass1Stack.Length-1
		CleanIntersectionPass2Stack.Add(CleanIntersectionPass1Stack[i])
		Local intersectStack:=SegmentPolyIntersection(CleanIntersectionPass1Stack[i],CleanIntersectionPass1Stack[i+1],CleanIntersectionPass1Stack.ToArray())
		'ajouter au polystck
		CleanIntersectionPass2Stack.AddAll(intersectStack)
		
		For Local p:=Eachin intersectStack
			intersectionStack.Add(p)
		Next
		
	Next
	
	'Return CleanIntersectionPass2Stack.ToArray()
	
	tCopy=New Stack<b2Vec2>
	
	'copie array>Stack avec point le +à gauche en premier
		'checher point+àGauche
	Local maxLeftPoint:=New b2Vec2(3.40282002e+38,0) 'maxfloat
	Local maxLeftPointIndex:=-1
	For Local i:=0 Until CleanIntersectionPass2Stack.Length
		If CleanIntersectionPass2Stack[i].x<maxLeftPoint.x
			maxLeftPoint=CleanIntersectionPass2Stack[i]
			maxLeftPointIndex=i
		End
	Next
	
	'faire stack avec plus à gauche premier
	For Local i:=maxLeftPointIndex Until CleanIntersectionPass2Stack.Length
		tCopy.Add(CleanIntersectionPass2Stack[i])
	Next
	If maxLeftPointIndex>0
		For Local i:=0 Until maxLeftPointIndex
			tCopy.Add(CleanIntersectionPass2Stack[i])
		Next
	End


	
	'Détecter le sens de rotation pour choisir d'applique PositiveAngle ou 2*Pi-Positive angle <
	
	'Chekage du sens de rotation ---> d'abord chopper un pt qui a un y différent
	Local polyAddForCompare:=0
	Local polySignForCompare:=1
	
	Local vBegin:b2Vec2=tCopy[1]-tCopy[0]
	vBegin.Normalize() '! normalize de b2Vec2 return Float et pas vect nomalisé
	Local vEndin:b2Vec2=tCopy[tCopy.Length-1]-tCopy[0]
	vEndin.Normalize()
	
	If vBegin.y=vEndin.y
		#If __DEBUG__
			Print "ERROR: extreme left vertices are parallel (in cleanPoly)"
		#End
		Return Null
	End
	If vBegin.y>vEndin.y
		polyAddForCompare=2*Pi
		polySignForCompare=-1
	End
	'canvas.DrawText( "angle: "+(polyAddForCompare+polySignForCompare*v1.PositiveAngleWith(v2)),10,25 )
	
	
	'on ajoute le premier au dernier
	tCopy.Add(tCopy[0])
	'ajouter map d'intersection par croisement de segment, les intersections de vertices données en deuxiemme passege?
	Local cleanPoly:=New Stack<b2Vec2>
	
	cleanPoly.Add(tCopy[0])
	cleanPoly.Add(tCopy[1])
	
	Repeat
		Local adjPoints:=GetAdjacentPointsInPoly(cleanPoly.Top,tCopy)
		Assert (adjPoints.Length=0, "pas de Points adjcents !!!")
		
		Local minAngle:Double=7.0
		Local minAnglePoint:b2Vec2
		Local vCurrent:=cleanPoly.Top-cleanPoly[cleanPoly.Length-2] 'inversion du Vect pour faire angle "intuitivement visible"
		
		For Local adjP:=Eachin adjPoints
			Local vTest:=cleanPoly.Top-adjP
			Local a:=polyAddForCompare+polySignForCompare*vCurrent.PositiveAngleWith(vTest)
			If a<minAngle
				minAngle=a
				minAnglePoint=adjP
			End
		Next
		
		cleanPoly.Add(minAnglePoint)
		
		
		
	Until cleanPoly.Top=tCopy[0]
	
	
	
	'ajouter au map les intersections par points égaux
	'parcourir et tournant toujours les plus à gauche/droite à chaque intersection
	
	'Return tCopy.ToArray()
	Return cleanPoly.ToArray()
End

Function GetAdjacentPointsInPoly:Stack<b2Vec2>(point:b2Vec2,poly:Stack<b2Vec2>) 'poly[0] doit être = poly.Top
	
	Local retStack:=New Stack <b2Vec2>
	
	If poly[0]=point
		retStack.Add(poly[poly.Length-2])
		retStack.Add(poly[1])
	End
	For Local i:=1 Until poly.Length-1
		
		If poly[i]=point
			retStack.Add(poly[i-1])
			retStack.Add(poly[i+1])
		End
		
	Next
	
	Return retStack
	
End

Function SegmentPolyIntersection:Stack<b2Vec2>(p0:b2Vec2,p1:b2Vec2,vertices:b2Vec2[])
	
	If vertices[0]<>vertices[vertices.Length-1]
		vertices=vertices.Resize(vertices.Length+1)
		vertices[vertices.Length-1]=vertices[0]
	End
	
	Local retStack:=New Stack<b2Vec2>
	Local l:=New Line2D(p0,p1-p0) 'car line2d c'est o,d et pas p1,p2
	
	'Print "---------Segment: "+p0+" "+p1
	For Local i:=0 Until vertices.Length-1
		'Print "i: "+i+" subsegment:"+vertices[i]+" "+vertices[i+1]
		Local tl:=New Line2D(vertices[i],vertices[i+1]-vertices[i]) 'car line2d c'est o,d et pas p1,p2
		If tl.SegmentIntersects(l)
			retStack.Add(tl.Intersection(l))
			'Print "adding: "+tl.Intersection(l)+"  i: "+i
		End
	Next

	
	'trier dans le sens du segment
	If Abs(p1.x-p0.x)>Abs(p1.y-p0.y) 'choisir si on trie en x ou en y en prennant le+grand écart
		If p0.x<p1.x
			retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2)
							Return	a.x - b.x
						End )
		Elseif p0.x>p1.x
					retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2)
									Return	b.x - a.x
								End )
		End
	Else				'ça pourrait quand même merder? peut être choisir le +Grand écart
		
		If p0.y<p1.y
			retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2)
							Return	a.y - b.y
						End )
		Elseif p0.y>p1.y
					retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2)
									Return	b.y - a.y
								End )
		End
		
	End
	Print "retsize: "+retStack.Length
	Return retStack
	
End

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
			Print "parallel"+Self.o+" "+(Self.o+Self.d)+" : "+line.o+" "+(line.o+line.d)
			Return True
		End
	End
	
	Method IsOkToIntersect:Bool(line:Line2D)

		Local divisor:Double=1.0*(1.0*line.d.y*Self.d.x*1.0)-1.0*(1.0*Self.d.y*1.0*line.d.x)
		
		If divisor<1.0e-35 And divisor>-1.0e-35
			
			Print "not ok to intersect"+divisor
			Return False

		End
		
		Return True

		
	End
	
	Method Intersection:Vec2<Double>(line:Line2D)

		'Print "parall: "+Self.IsParallel(line)

		Local divisor:Double=1.0*(1.0*line.d.y*Self.d.x*1.0)-1.0*(1.0*Self.d.y*1.0*line.d.x)
		'Print "div--: "+divisor
		If divisor=0.0
			Print "Error: divisor=0 returning Vec2 Null(0,0)! You should use Line2D.Parallel before calling Line2D.intersection!"
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
		'If Not Self.IsOkToIntersect(line) Then Return False
		
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
				'Print "par x"
				insideSelf=True
			End
		End
	
		Local lineo2:=line.o+line.d
		Local lineMinx:=Min(line.o.x,lineo2.x)
		Local lineMaxx:=Max(line.o.x,lineo2.x)
		Local lineMiny:=Min(line.o.y,lineo2.y)
		Local lineMaxy:=Max(line.o.y,lineo2.y)
'		DebugStop()
		Local insideLine:=False
		If ((lineMinx<inter.x) And (inter.x<lineMaxx)) Or ((lineMinx=lineMaxx) And (lineMinx=inter.x))
			If ((lineMiny<inter.y) And (inter.y<lineMaxy)) Or ((lineMiny=lineMaxy) And (lineMiny=inter.y))
				'Print "par y"
				insideLine=True
			End
		End
		
		If insideSelf And insideLine Then Return True
		
		Return False
		
	End
	
End

Struct b2Vec2 Extension
	
	'returns the angle with no consiredation of angle direction
	Method AngleWith:Float(v:b2Vec2)
		
		If (Self.Length()=0) Or (v.Length()=0)
			Print "ERROR: null b2Vec2 for angle, returning zero"
			Return 0
		End
		Local cosA:=(Self.Dot(v))/(Self.Length()*v.Length())
		
		Return ACos(cosA)
		
	End
	
	'return the angle from ]-Pi to Pi]
	Method SignedAngleWith:Float(v:b2Vec2)
		If (Self.Length()=0) Or (v.Length()=0)
			Print "ERROR: null b2Vec2 for angle, returning zero"
			Return 0
		End
		Local cosA:=(Self.Dot(v))/(Self.Length()*v.Length())
		
		Local sign:Float=Sgn(Self.Cross(v))
		If sign=0 Then sign=1
		
		Return ACos(cosA)*sign
		
	End
	
	'return the angle from 0 to 2*Pi
	Method PositiveAngleWith:Float(v:b2Vec2)
		
		If (Self.Length()=0) Or (v.Length()=0)
			Print "ERROR: null b2Vec2 for angle, returning zero"
			Return 0
		End
		Local cosA:=(Self.Dot(v))/(Self.Length()*v.Length())
		
		Local sign:Float=Sgn(Self.Cross(v))
		If sign=0 Then sign=1
		
		If sign>0
			Return ACos(cosA)
		Else
			Return 2.0*Pi-ACos(cosA)
		End
		
	End
	
	Method Cross:Float(v:b2Vec2)
		Return x * v.y - y * v.x
	End
		
End

