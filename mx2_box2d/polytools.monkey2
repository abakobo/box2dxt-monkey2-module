Namespace polytools

#Import "<box2d>"
#Import "akofw.monkey2"

Using box2d..
Using akofw..

' Copyright 2000 softSurfer, 2012 Dan Sunday
' This code may be freely used and modified for any purpose
' providing that this copyright notice is included with it.
' SoftSurfer makes no warranty for this code, and cannot be held
' liable for any real or imagined damage resulting from its use.
' Users of this code must verify correctness for their application.


Function IsLeft:Int( P0:b2Vec2, P1:b2Vec2, P2:b2Vec2 )

    return ( (P1.x - P0.x) * (P2.y - P0.y) - (P2.x -  P0.x) * (P1.y - P0.y) )
End

Function wn_PnPoly:Int( P:b2Vec2, V:b2Vec2[] )
	
	'Print V.size
	If V[0]<>V[V.Length-1]
		V=V.Resize(V.Length+1)
		V[V.Length-1]=V[0]	
	End
	'Print V.size

    Local wn := 0    ' the  winding number counter

    ' loop through all edges of the polygon
    For Local i:=0 To V.Length-2   ' edge from V[i] to  V[i+1]
        If V[i].y <= P.y          ' start y <= P.y
            If V[i+1].y  > P.y      ' an upward crossing
                 If IsLeft( V[i], V[i+1], P) > 0  ' P left of  edge
                     wn+=1          ' have  a valid up intersect
                 End
        	End
        Else                         ' start y > P.y (no test needed)
            If V[i+1].y <= P.y    ' a downward crossing
                 If IsLeft( V[i], V[i+1], P) < 0  ' P right of  edge
                     wn-=1         ' have  a valid down intersect
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

	'copie array>Stack avec point le +à gauche en premier
		'checher point+àGauche
	Local maxLeftPoint:=New b2Vec2(3.40282002e+38,0) 'maxfloat
	Local maxLeftPointIndex:=-1
	For Local i:=0 Until vertices.Length
		If vertices[i].x<maxLeftPoint.x
			maxLeftPoint=vertices[i]
			maxLeftPointIndex=i
		End
	Next
	

	'faire stack avec plus à gauche premier
	For Local i:=maxLeftPointIndex Until vertices.Length
		tCopy.Add(vertices[i])
	Next
	If maxLeftPointIndex>0
		For Local i:=0 Until maxLeftPointIndex
			tCopy.Add(vertices[i])
		Next
	End
	Print "Step1"
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
		Print "Step2"+CleanIntersectionPass1Stack.Length
	If CleanIntersectionPass1Stack.Top=CleanIntersectionPass1Stack[0] Then CleanIntersectionPass1Stack.Pop() 
		Print "Step3"
	If CleanIntersectionPass1Stack.Length<3
		#If __DEBUG__
			Print "ERROR less than 3 different vertices for CreatePolygonShapes After cleanup. "
		#End
		Return Null
	End
	
	'cherchage d'intersections par segmentline-segent-line et ajout au stackPass2
	Local CleanIntersectionPass2Stack:=New Stack<b2Vec2>
	
	CleanIntersectionPass1Stack.Add(CleanIntersectionPass1Stack[0])'pour pas devoir cycler hors boucle
		Print "Step4"
	For Local i:=0 Until CleanIntersectionPass1Stack.Length-1
		CleanIntersectionPass2Stack.Add(CleanIntersectionPass1Stack[i])
		Local intersectStack:=SegmentPolyIntersection(CleanIntersectionPass1Stack[i],CleanIntersectionPass1Stack[i+1],CleanIntersectionPass1Stack.ToArray())
		CleanIntersectionPass2Stack.AddAll(intersectStack)
	Next
	
	Return CleanIntersectionPass2Stack.ToArray()

	'Return Null
End

Function SegmentPolyIntersection:Stack<b2Vec2>(p0:b2Vec2,p1:b2Vec2,vertices:b2Vec2[])
	
	If vertices[0]<>vertices[vertices.Length-1]
		vertices=vertices.Resize(vertices.Length+1)
		vertices[vertices.Length-1]=vertices[0]
	End
	
	Local retStack:=New Stack<b2Vec2>
	Local l:=New Line2D(p0,p1-p0) 'car line2d c'est o,d et pas p1,p2
	
	For Local i:=0 Until vertices.Length-1
		Local tl:=New Line2D(vertices[i],vertices[i+1]-vertices[i]) 'car line2d c'est o,d et pas p1,p2
		If tl.SegmentIntersects(l)
			retStack.Add(tl.Intersection(l))
			Print "adding: "+tl.Intersection(l)+"  i: "+i
		End
	Next

	
	'trier dans le sens du segment
	If Abs(p1.x-p0.x)>Abs(p1.y-p0.y) 'choisir si on trie en x ou en y en prennant le+grand écart
		If p0.x<p1.x
			retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2) 
							Return  a.x - b.x
						End )
		Elseif p0.x>p1.x
					retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2) 
									Return  b.x - a.x
								End )
		End
	Else				'ça pourrait quand même merder? peut être choisir le +Grand écart 
		
		If p0.y<p1.y
			retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2) 
							Return  a.y - b.y
						End )
		Elseif p0.y>p1.y
					retStack.Sort(Lambda:Int(a:b2Vec2,b:b2Vec2) 
									Return  b.y - a.y
								End )
		End
		
	End
	Print "retsize: "+retStack.Length
	Return retStack
	
End	

