Namespace box2dxt.polytools

#Import "<std>"
#Import "extsandfuncs.monkey2"
#Import "concavepoly.monkey2"

Using std..
Using box2d..
Using box2dxt..

Public

Function FullPartition:Stack<Stack<b2Vec2>>(poly:Stack<b2Vec2>)
	
	Local polyStack:=SimplePartition(b2StackToV2dStack(poly))
	If polyStack=Null Then Return Null
	If polyStack.Length=0 Then Return Null
	
	Local convexPolys:=New Stack<Stack<Vec2d>>
	
	For Local i:=0 Until polyStack.Length
		MakeCCW(polyStack[i])	
		Local tconvPolys:=ConvexPartition(polyStack[i])
		convexPolys.AddAll(tconvPolys)
	Next

	
	Return V2dStastackTob2Stastack(convexPolys)
	
End

Function FullPartition:Stack<Stack<Vec2d>>(poly:Stack<Vec2d>)
	
	Local polyStack:=SimplePartition(poly)
	If polyStack=Null Then Return Null
	If polyStack.Length=0 Then Return Null
	
	Local convexPolys:=New Stack<Stack<Vec2d>>
	
	For Local i:=0 Until polyStack.Length
		MakeCCW(polyStack[i])	
		Local tconvPolys:=ConvexPartition(polyStack[i])
		convexPolys.AddAll(tconvPolys)
	Next
	
	Return convexPolys
	
End

Function SimplePartition:Stack<Stack<b2Vec2>>(poly:Stack<b2Vec2>)
	Return V2dStastackTob2Stastack(SimplePartition(b2StackToV2dStack(poly)))
End

Function SimplePartition:Stack<Stack <Vec2d>>(vertices:Stack<Vec2d>)

	If vertices.Length<3
		#If __DEBUG__
			Print"ERROR less than 3 vertices for CreatePolygonShapes . "
		#End
		Return Null
	End

	Local tCopy:=New Stack<Vec2d>
	For Local i:=0 Until vertices.Length
		tCopy.Add(vertices[i])
	Next
	
	Local CleanIntersectionPass1Stack:=cleanDuples(tCopy)
	If CleanIntersectionPass1Stack.Top<>CleanIntersectionPass1Stack[0] Then CleanIntersectionPass1Stack.Add(CleanIntersectionPass1Stack[0])
	
	If CleanIntersectionPass1Stack.Length<4
		#If __DEBUG__
			Print"ERROR less than 3 different vertices for CreatePolygonShapes After cleanup. "
		#End
		Return Null
	End
	
	If CleanIntersectionPass1Stack.Top<>CleanIntersectionPass1Stack[0] Then CleanIntersectionPass1Stack.Add(CleanIntersectionPass1Stack[0])
	Local pABInts:=CreatePABIntersectionArray(CleanIntersectionPass1Stack)

	Local CleanIntersectionPass2Stack:=New Stack<Vec2d>
	For Local i:=0 Until CleanIntersectionPass1Stack.Length-1
		CleanIntersectionPass2Stack.Add(CleanIntersectionPass1Stack[i])
		Local intersectStack:=CreateInterStack(CleanIntersectionPass1Stack[i],CleanIntersectionPass1Stack[i+1],i,pABInts)
		
		CleanIntersectionPass2Stack.AddAll(intersectStack)
	Next

	CleanIntersectionPass2Stack=cleanDuples(CleanIntersectionPass2Stack)
	If CleanIntersectionPass2Stack.Top=CleanIntersectionPass2Stack[0] Then CleanIntersectionPass2Stack.Pop()

	tCopy=New Stack<Vec2d>
	
	Local maxLeftPoint:=CleanIntersectionPass2Stack[0]
	Local maxLeftPointIndex:=0
	For Local i:=0 Until CleanIntersectionPass2Stack.Length
		If CleanIntersectionPass2Stack[i].x<maxLeftPoint.x
			maxLeftPoint=CleanIntersectionPass2Stack[i]
			maxLeftPointIndex=i
		End
	Next

	For Local i:=maxLeftPointIndex Until CleanIntersectionPass2Stack.Length
		tCopy.Add(CleanIntersectionPass2Stack[i])
	Next
	If maxLeftPointIndex>0
		For Local i:=0 Until maxLeftPointIndex
			tCopy.Add(CleanIntersectionPass2Stack[i])
		Next
	End

	Local polyAddForCompare:Double=0.0
	Local polySignForCompare:=1
	
	Local vBegin:Vec2d=tCopy[1]-tCopy[0]
	vBegin=vBegin.Normalize() '! normalize de Vec2d return Float et pas vect nomalisé
	Local vEndin:Vec2d=tCopy[tCopy.Length-1]-tCopy[0]
	vEndin=vEndin.Normalize()
	
	If vBegin.y=vEndin.y
		#If __DEBUG__
			Print "ERROR: exterior zero-angle: extreme left vertices are parallel and have same direction (in cleanPoly) returning NULL"
		#End
		Return Null
	End
	If vBegin.y>vEndin.y
		polyAddForCompare=2*Pi
		polySignForCompare=-1
	End
	
	tCopy.Add(tCopy[0])
	

	Local cleanPoly:=New Stack<Vec2d>
	
	cleanPoly.Add(tCopy[0])
	cleanPoly.Add(tCopy[1])
	
	
	Local detectedZeroAngle:=False
	Repeat
		Local adjPoints:=GetAdjacentPointsInPoly(cleanPoly.Top,tCopy)
		Local minAngle:Double=7.0
		Local minAnglePoint:Vec2d
		Local vCurrent:=cleanPoly.Top-cleanPoly[cleanPoly.Length-2] 'inversion du Vect pour faire angle "intuitivement visible"
		Local cleanTopX:=cleanPoly.Top.x
		Local cleanTopY:=cleanPoly.Top.y
		For Local adjP:=Eachin adjPoints
			Local vTest:=cleanPoly.Top-adjP
			If vTest=vCurrent Then Continue
			If adjP=cleanPoly.Top Then Continue
			If vTest=New Vec2d(0,0) Or vCurrent=New Vec2d(0,0)
				#If __DEBUG__
					Print "ERROR: internal CleanPoly() error coed:'Nulos vect'. Returning NULL"
				#End
				Return Null
			End

			Local ta:=vCurrent.PositiveAngleWith(vTest)
			Local a:=polyAddForCompare+polySignForCompare*ta
			If a<minAngle
				minAngle=a
				minAnglePoint=adjP
				If minAngle=0
					#If __DEBUG__
						Print "ERROR: exterior zero-angle! Returning Null"
					#End
					Return Null
				End
			End
		Next
		
		cleanPoly.Add(minAnglePoint)
		If cleanPoly.Length>3*vertices.Length
			#If __DEBUG__
				Print "ERROR: CleanPoly adjacent infiniteLoop! Returning Null"
			#End
			Return Null
		End
	Until cleanPoly.Top=tCopy[0]
	cleanPoly.Pop()
	
	Local retStack:=New Stack<Stack<Vec2d>>
	
	Local antiBugCount:=0
	Repeat
		If cleanPoly.Top=cleanPoly[0] Then cleanPoly.Pop()
		Local interArr:=New Bool[cleanPoly.Length]
		For Local i:=0 Until cleanPoly.Length
			For Local j:=0 Until cleanPoly.Length
				If i<>j And cleanPoly[i]=cleanPoly[j]
					interArr[i]=True
				End
			Next
		Next
		Local simpleLoopStack:=New Stack <Vec2i>
		Local interStack:=New IntStack
		For Local i:=0 Until interArr.Length
			If interArr[i]=True
				interStack.Add(i)	
			End
		Next
		If interStack.Length=0
			If IsPolyCollinearOrLessThan3(cleanPoly)=False
				retStack.Add(cleanPoly)
			End
			Return retStack
		End
		For Local i:=0 Until interStack.Length-1
			If cleanPoly[interStack[i]]=cleanPoly[interStack[i+1]]
				simpleLoopStack.Add(New Vec2i(interStack[i],interStack[i+1]))
			End
		Next
		If interStack.Length>1
			If cleanPoly[interStack[interStack.Length-1]]=cleanPoly[interStack[0]]
				simpleLoopStack.Add(New Vec2i(interStack[interStack.Length-1],interStack[0]))
			End
		End
		
		Local tCleanPoly:=New Stack<Vec2d>
	
		For Local lopIndex:=0 Until simpleLoopStack.Length
			If simpleLoopStack[lopIndex].x<simpleLoopStack[lopIndex].y
				
				Local littleLoopStack:=New Stack<Vec2d>
				For Local i:=simpleLoopStack[lopIndex].x Until simpleLoopStack[lopIndex].y
					littleLoopStack.Add(cleanPoly[i])
				Next
				If IsPolyCollinearOrLessThan3(littleLoopStack)=False
					retStack.Add(littleLoopStack)
				End
				
				If lopIndex=simpleLoopStack.Length-1
					
					For Local i:=simpleLoopStack[lopIndex].y To (cleanPoly.Length-1)
						tCleanPoly.Add(cleanPoly[i])
					Next
					
					For Local i:=0 To simpleLoopStack[0].x
						tCleanPoly.Add(cleanPoly[i])
					Next
				Else
					For Local i:=simpleLoopStack[lopIndex].y To simpleLoopStack[lopIndex+1].x
						tCleanPoly.Add(cleanPoly[i])
					Next
				End
	
			Else 
				
				Local littleLoopStack:=New Stack<Vec2d>
				For Local i:=simpleLoopStack[lopIndex].x Until cleanPoly.Length
					littleLoopStack.Add(cleanPoly[i])
				Next
				For Local i:=0 Until simpleLoopStack[lopIndex].y
					littleLoopStack.Add(cleanPoly[i])
				Next
				If IsPolyCollinearOrLessThan3(littleLoopStack)=False
					retStack.Add(littleLoopStack)
				End
				
				For Local i:=simpleLoopStack[lopIndex].y To simpleLoopStack[0].x
					tCleanPoly.Add(cleanPoly[i])
				Next
				
			End
					
		Next
		
		
		tCleanPoly=cleanDuples(tCleanPoly)

		If tCleanPoly.Length>0
			If tCleanPoly.Top<>tCleanPoly[0] Then tCleanPoly.Add(tCleanPoly[0])
		Else
			Return retStack
		End		
		If tCleanPoly.Length<4
			Return retStack
		Else
			If IsPolyCollinearOrLessThan3(tCleanPoly)=True Then Return retStack
		End
		If HasPolyZeroAngleOrLessThan3(tCleanPoly)=True
			#If __DEBUG__
				Print "ERROR: encoutered zero-Angle in complex polygon partitionning!"
			#End
			Return Null
		End
		cleanPoly=tCleanPoly
		antiBugCount+=1
	Until antiBugCount>10+(vertices.Length/2)
	
	Return retStack
End

Private

Function HasPolyZeroAngleOrLessThan3:Bool(p:Stack<Vec2d>)
	
		If p.Length>2
			If p.Top<>p[0] Then p.Add(p[0])
		End
		
		If p.Length>3
			For Local i:=0 Until p.Length-2
				Local d1:=p[i+1]-p[i]
				Local d2:=p[i+1]-p[i+2]
				If d1.SignedAngleWith(d2)=0
					Return True
				End
			Next
		Else
			Return True
		End
		
		Return False
		
End
#rem
Function IsPolyCollinearOrLessThan3:Bool(p:Stack<Vec2d>)
	
	If p.Length>2
		If p.Top<>p[0] Then p.Add(p[0])
	End
	
	If p.Length>3
		
		For Local i:=0 Until p.Length-2
		
			Local line1:=New Line2D(p[i],p[i+1]-p[i])
			Local line2:=New Line2D(p[i+1],p[i+2]-p[i+1])
		
			If line1.IsCollinear(line2)=False Then Return False
					
		Next
		
	End
	
	Return True
	
End
#end

Function GetAdjacentPointsInPoly:Stack<Vec2d>(point:Vec2d,poly:Stack<Vec2d>)
	
	Local retStack:=New Stack <Vec2d>
	
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

Function CreateInterStack:Stack<Vec2d>(p0:Vec2d,p1:Vec2d,index:Int,pABI:PointAndBool[,])
	
	Local retStack:=New Stack<Vec2d>
	
	For Local i:=0 Until pABI.GetSize(0)-1
		
		If pABI[index,i].b=True
			retStack.Add(pABI[index,i].p)
		End
		
	Next
	
	If Abs(p1.x-p0.x)>Abs(p1.y-p0.y) 
		If p0.x<p1.x
			retStack.Sort(Lambda:Int(a:Vec2d,b:Vec2d)
							Return	a.x <=> b.x
						End )
		Elseif p0.x>p1.x
					retStack.Sort(Lambda:Int(a:Vec2d,b:Vec2d)
									Return	b.x <=> a.x
								End )
		End
	Else				
		
		If p0.y<p1.y
			retStack.Sort(Lambda:Int(a:Vec2d,b:Vec2d)
							Return	a.y <=> b.y
						End )
		Elseif p0.y>p1.y
					retStack.Sort(Lambda:Int(a:Vec2d,b:Vec2d)
									Return	b.y <=> a.y
								End )
		End
		
	End

	Return retStack
	
End

	
Function CreatePABIntersectionArray:PointAndBool[,](verts:Stack<Vec2d>)
	
	If verts.Top<>verts[0] Then verts.Add(verts[0])
	
	Local retArr:=New PointAndBool[verts.Length,verts.Length]
 
	For Local i:=0 Until verts.Length-1
		For Local j:=i Until verts.Length-1
			
			If i<>j
				
				Local line1:=New Line2D(verts[i],verts[i+1]-verts[i])
				Local line2:=New Line2D(verts[j],verts[j+1]-verts[j])
				
				Local pabool:PointAndBool=line1.SegmentIntersectsPAB(line2)
				
				retArr[i,j]=pabool
				retArr[j,i]=pabool
			Else 
				retArr[i,j]=New PointAndBool(New Vec2d(0,0),False)
				retArr[j,i]=New PointAndBool(New Vec2d(0,0),False)
			End
			
		Next
	Next

	Return retArr
	
End


Function cleanDuples:Stack<Vec2d>(tCopy:Stack<Vec2d>)
	
		Local CleanIntersectionPass1Stack:=New Stack<Vec2d>
		
		If tCopy.Top=tCopy[0] Then tCopy.Pop()
		
		While tCopy.Length>0
			
			If CleanIntersectionPass1Stack.Length=0 'premier point est pris d'office
			
				CleanIntersectionPass1Stack.Add(tCopy.Pop())
		
			Elseif CleanIntersectionPass1Stack.Length=1 'deuxiemme point a une seule condition (<>précédent)
	
				If Not (tCopy.Top=CleanIntersectionPass1Stack.Top)
					
					CleanIntersectionPass1Stack.Add(tCopy.Pop())

				Else
					tCopy.Pop()
				End
				
			Elseif CleanIntersectionPass1Stack.Length>1 'troisièmme+ a deux conditions (<>précédent et <>antéprécédent)
				
				If (Not (tCopy.Top=CleanIntersectionPass1Stack.Top)) And (Not (tCopy.Top=CleanIntersectionPass1Stack[CleanIntersectionPass1Stack.Length-2])) '1 avant .Top
	
					CleanIntersectionPass1Stack.Add(tCopy.Pop())
					 					
				Else
					tCopy.Pop()
				End
	
			End
			
		Wend
				
		Return CleanIntersectionPass1Stack
		
End


