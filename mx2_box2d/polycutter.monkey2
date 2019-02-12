Namespace box2dxt.polytools

#Import "<std>"
#Import "extsandfuncs.monkey2"

Using std..
Using box2d..
Using box2dxt..

Function PolyCutSided:Stack<Stack<Stack<Vec2d>>>(poly:Stack<Vec2d>,cutEdges:Stack<Vec2d>)
	
	Local polail:=New PolyAIL(poly,True)
	Local LRStack:=PolyCutRecSided(polail,cutEdges)
	
	Local left:=New Stack<Stack<Vec2d>>
	Local right:=New Stack<Stack<Vec2d>>
	Local ret:=New Stack<Stack<Stack<Vec2d>>>
	
	For Local pail:=Eachin LRStack
		If pail.isLeft=True
			left.Add(pail.poly)
		Else
			right.Add(pail.poly)
		End
	Next
	
	ret.Add(left)
	ret.Add(right)
	
	Return ret

End

Private

Function PolyCutRecSided:Stack<PolyAIL>(polygon:PolyAIL,cutEdges:Stack<Vec2d>)
	'poly must be convex
	'poly must be CCW
	'poly may not contain straigths (consecutive parallel edges)
	'knife may not self intersect
	If polygon=Null Then Print "Null poly!!!!!!!!!!!!!!!!!!!"
	Local knife:=New Stack<Vec2d>
	Print "preknif: "+cutEdges.Length
				For Local p:=Eachin cutEdges
					Print p
				Next
	For Local p:=Eachin cutEdges
		If InPolyExclLim(p,polygon.poly) And knife.Length>0
			knife.Add(p)
		Elseif Not InPolyExclLim(p,polygon.poly)
			knife.Add(p)
		End
	End
		
	While knife.Length>1 And InPolyExclLim(knife.Top,polygon.poly)
		knife.Pop()
	End

	Print "knifeé"+knife.Length
	For Local p:=Eachin knife
		Print p
	Next
	
	Local retPolys:=New Stack<PolyAIL>
	If knife.Length<2
		Print "miniknifeInput"
		retPolys.Add(polygon)
		Return retPolys
	End
	
	
	Local poly:=ExtremeLeftise(polygon.poly)
	poly.Add(poly[0])
	Print "preInter:Polylength "+poly.Length
	Local interKnife:=New Stack<PIP>
	Local totInts:=0
	Local tangeantI:=0
	
	Local isEdgeExtreme:=False
	
	
	For Local i:=0 Until knife.Length-1
		Local kline:=New Line2D(knife[i],knife[i+1]-knife[i])
		Print "kline:"+knife[i]+" "+knife[i+1]
		For Local j:=0 Until poly.Length-1
			Local pline:=New Line2D(poly[j],poly[j+1]-poly[j])
			Print "pline:"+poly[j]+" "+poly[j+1]
			Local pab:=pline.SegmentIntersectsPAB(kline)
			If pab.b=True
				Print "interrrr: "+i+" "+j
				Print pab.p
				If totInts=1 
					If pab.p<>interKnife[0].intPoint 'si lintersection est juste la jonction entre deux edges
						Print "same???: "+pab.p+" "+interKnife[0].intPoint
						totInts+=1
						interKnife.Add(New PIP(pab.p,i,j))
					Else
						Print "intersection is edge extreme, skipping one"
						isEdgeExtreme=True
					End
				Else
					totInts+=1
					interKnife.Add(New PIP(pab.p,i,j))
				End
			End

			If totInts=2 Then Exit
			
		Next
		Local kIn:=InPolyExclLim(knife[i],poly)
		Local kpIn:=InPolyExclLim(knife[i+1],poly)
		If (Not kIn) And (Not kpIn)
			If totInts=1 
				totInts=0
				interKnife.Pop()
			End
			
		End
		If totInts=2 Then Exit
	Next
	
	Print "preknifeChain"
	Print "interL: "+interKnife.Length
	Print "knifeL: "+knife.Length
	Local polyA:=New Stack<Vec2d>
	Local polyB:=New Stack<Vec2d>
	
	If interKnife.Length>2
		#If __DEBUG__
			Print "Error: more than 2 intersection for poly cutting. returning empty Stack"
		#End
		Return retPolys
	End
	
	Local ptBaseIntLR:Vec2d
	Local ptDirLR:Vec2d
	Local ptNormLR:Vec2d
	
	If interKnife.Length<2
		
		Print "noCutHere----------------------"
		retPolys.Add(polygon)
		Return retPolys
		
	Elseif interKnife.Length=2
		Local knifeChain:=New Stack<Vec2d>

		If interKnife[0].polyi=interKnife[1].polyi
			Print "CCCUUUUUUTING ON THE SAME LINE !!!!!!!!!!!!!!!"
			If poly[interKnife[0].polyi].SqDistance(interKnife[0].intPoint)>poly[interKnife[0].polyi].SqDistance(interKnife[1].intPoint)
				interKnife.Reverse()
			End
		Elseif interKnife[0].polyi>interKnife[1].polyi
			interKnife.Reverse()
		End
		knifeChain.Add(interKnife[0].intPoint)

		Local baseLRBegins:Bool

		
		Local diff:=interKnife[1].knifi-interKnife[0].knifi
		If diff=0
			Print "diff=0"
			knifeChain.Add(interKnife[1].intPoint)
			
			baseLRBegins=True
			ptBaseIntLR=interKnife[0].intPoint
			ptDirLR=knife[interKnife[0].knifi+1]
		Else If diff>0
			Print "diff>0"
			baseLRBegins=True
			ptBaseIntLR=interKnife[0].intPoint
			ptDirLR=knife[interKnife[0].knifi+1]
			For Local i:=interKnife[0].knifi Until interKnife[1].knifi
				knifeChain.Add(knife[i+1])
			Next
			knifeChain.Add(interKnife[1].intPoint)
		Else If diff<0
			Print "diff<0$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
			baseLRBegins=False
			ptBaseIntLR=interKnife[1].intPoint
			ptDirLR=knife[interKnife[1].knifi+1]
			For Local i:=interKnife[0].knifi-1 To interKnife[1].knifi Step-1
				knifeChain.Add(knife[i+1])
			Next
			knifeChain.Add(interKnife[1].intPoint)
		End

		Print "preLR"
		'faire poly starting from 0
		For Local i:=0 To interKnife[0].polyi
			polyA.Add(poly[i])
		Next
		For Local i:=0 Until knifeChain.Length
			polyA.Add(knifeChain[i])
		Next
		For Local i:=interKnife[1].polyi+1 Until poly.Length
			polyA.Add(poly[i])
		Next
		
		'faire autre poly 
		For Local i:=interKnife[0].polyi+1 To interKnife[1].polyi
			polyB.Add(poly[i])
		Next
		For Local i:=knifeChain.Length-1 To 0 Step -1
			polyB.Add(knifeChain[i])
		Next
		
		If polyA=Null Then Print "here it's NullAAAAAAAAAAAAAA"
		If polyB=Null Then Print "here it's NullBBBBBBBBBBBBBB"
		'LR
		If baseLRBegins=True
			ptNormLR=poly[interKnife[0].polyi+1]
		Else
			ptNormLR=poly[interKnife[1].polyi]
		End
	End
	
	'déterminer gauche/droite
	Local lRVD:=ptDirLR-ptBaseIntLR
	Local lRVN:=ptNormLR-ptBaseIntLR

	Local pailA:PolyAIL
	Local pailB:PolyAIL

	If lRVD.SignedAngleWith(lRVN)>0
		Print "posAngle"
		pailA=New PolyAIL (polyA,True)
		pailB=New PolyAIL (polyB,False)
	Else
		Print "NegAngle"
		pailA=New PolyAIL (polyA,False)
		pailB=New PolyAIL (polyB,True)
	End	
	
	'Virer premier "knife"
	Local kIndex:=interKnife[0].knifi
	If kIndex<interKnife[1].knifi Then kIndex=interKnife[1].knifi
	kIndex+=1
	Local tknife:=New Stack<Vec2d>
	For Local i:=kIndex Until knife.Length
		tknife.Add(knife[i])
	Next
	knife=tknife
	Local retSta:=New Stack<PolyAIL>
	If knife.Length<2 
		retSta.Add(pailA)
		retSta.Add(pailB)
	Else
		Print "rFirestRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"+knife.Length
		retSta.AddAll(PolyCutRecSided(pailA,knife))
		Print "rSecondRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"+knife.Length
		retSta.AddAll(PolyCutRecSided(pailB,knife))
	End
	
	Return retSta
	
End

Public

Function polyCutter:Stack<Stack<Vec2d>>(polygon:Stack<Vec2d>,cutEdges:Stack<Vec2d>)
	'poly must be convex
	'poly must be CCW
	'poly may not contain straigths (consecutive parallel edges)
	'knife may not self intersect
	Local knife:=New Stack<Vec2d>
	Print "preknif: "+cutEdges.Length
				For Local p:=Eachin cutEdges
					Print p
				Next
	For Local p:=Eachin cutEdges
		If InPolyExclLim(p,polygon) And knife.Length>0
			knife.Add(p)
		Elseif Not InPolyExclLim(p,polygon)
			knife.Add(p)
		End
	End
		
	While knife.Length>1 And InPolyExclLim(knife.Top,polygon)
		knife.Pop()
	End
	
	Print "knifeé"+knife.Length
	For Local p:=Eachin knife
		Print p
	Next
	
	Local retPolys:=New Stack<Stack<Vec2d>>
	If knife.Length<2
		Print "miniknifeInput"
		retPolys.Add(polygon)
		Return retPolys
	End
	
	
	Local poly:=ExtremeLeftise(polygon)
	poly.Add(poly[0])
	Print "preInter:Polylength "+poly.Length
	Local interKnife:=New Stack<PIP>
	Local totInts:=0
	For Local i:=0 Until knife.Length-1
		Local kline:=New Line2D(knife[i],knife[i+1]-knife[i])
		Print "kline:"+knife[i]+" "+knife[i+1]
		For Local j:=0 Until poly.Length-1
			Local pline:=New Line2D(poly[j],poly[j+1]-poly[j])
			Print "pline:"+poly[j]+" "+poly[j+1]
			Local pab:=pline.SegmentIntersectsPAB(kline)
			If pab.b=True
				Print "interrrr: "+i+" "+j
				Print pab.p
				If totInts=1 
					If pab.p<>interKnife[0].intPoint 'si lintersection est juste la jonction entre deux edges
						Print "same???: "+pab.p+" "+interKnife[0].intPoint
						totInts+=1
						interKnife.Add(New PIP(pab.p,i,j))
					Else
						Print "intersection is edge extreme, skipping one"
					End
				Else
					totInts+=1
					interKnife.Add(New PIP(pab.p,i,j))
				End
			End

			If totInts=2 Then Exit
			
		Next
		Local kIn:=InPolyExclLim(knife[i],poly)
		Local kpIn:=InPolyExclLim(knife[i+1],poly)
		If (Not kIn) And (Not kpIn)
			If totInts=1 'tangeant compte pas
				Print "removing single out-out intersection"
				totInts=0
				interKnife.Pop()
			End
		End
		If totInts=2 Then Exit
	Next
	
	Print "preknifeChain"
	Print "interL: "+interKnife.Length
	Print "knifeL: "+knife.Length
	Local pleft:=New Stack<Vec2d>
	Local pright:=New Stack<Vec2d>
	
	If interKnife.Length>2
		#If __DEBUG__
			Print "Error: more than 2 intersection for poly cutting. returning empty Stack"
		#End
		Return retPolys
	End
	
	If interKnife.Length<2
		
		Print "noCutHere----------------------"
		retPolys.Add(polygon)
		Return retPolys
		
	Elseif interKnife.Length=2
		Local knifeChain:=New Stack<Vec2d>

		If interKnife[0].polyi=interKnife[1].polyi
			Print "CCCUUUUUUTING ON THE SAME LINE !!!!!!!!!!!!!!!"
			If poly[interKnife[0].polyi].SqDistance(interKnife[0].intPoint)>poly[interKnife[0].polyi].SqDistance(interKnife[1].intPoint)
				interKnife.Reverse()
			End
		Elseif interKnife[0].polyi>interKnife[1].polyi
			interKnife.Reverse()
		End
		knifeChain.Add(interKnife[0].intPoint)
		

		
		Local diff:=interKnife[1].knifi-interKnife[0].knifi
		If diff=0
			Print "diff=0"
			knifeChain.Add(interKnife[1].intPoint)
		Else If diff>0
			Print "diff>0"
			For Local i:=interKnife[0].knifi Until interKnife[1].knifi
				knifeChain.Add(knife[i+1])
			Next
			knifeChain.Add(interKnife[1].intPoint)
		Else If diff<0
			Print "diff<0$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
			For Local i:=interKnife[0].knifi-1 To interKnife[1].knifi Step-1
				knifeChain.Add(knife[i+1])
			Next
			knifeChain.Add(interKnife[1].intPoint)
		End

		'Print "//"
		'Print interKnife[0].intPoint
		'Print interKnife[1].intPoint
		'Print "******"
		'For Local p:=Eachin knifeChain
		'	Print p
		'Next
		Print "preLR"
		'faire poly left
		For Local i:=0 To interKnife[0].polyi
			pleft.Add(poly[i])
		Next
		For Local i:=0 Until knifeChain.Length
			pleft.Add(knifeChain[i])
		Next
		For Local i:=interKnife[1].polyi+1 Until poly.Length
			pleft.Add(poly[i])
		Next
		
		'faire poly right
		For Local i:=interKnife[0].polyi+1 To interKnife[1].polyi
			pright.Add(poly[i])
		Next
		For Local i:=knifeChain.Length-1 To 0 Step -1
			pright.Add(knifeChain[i])
		Next
	End
	
	'Virer premier "knife"
	Local kIndex:=interKnife[0].knifi
	If kIndex<interKnife[1].knifi Then kIndex=interKnife[1].knifi
	kIndex+=1
	Local tknife:=New Stack<Vec2d>
	For Local i:=kIndex Until knife.Length
		tknife.Add(knife[i])
	Next
	knife=tknife
	Local retSta:=New Stack<Stack<Vec2d>>
	If knife.Length<2 
		retSta.Add(pleft)
		retSta.Add(pright)
	Else
		Print "rFirestRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"+knife.Length
		retSta.AddAll(polyCutter(pleft,knife))
		Print "rSecondRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"+knife.Length
		retSta.AddAll(polyCutter(pright,knife))
	End
	
	Return retSta
	
End



Private

Struct PIP
	
	Field intPoint:Vec2d
	Field knifi:Int
	Field polyi:Int
	
	Method New(iPoint:Vec2d,knifeIndex:Int,polySegmentIndex:Int)
		intPoint=iPoint
		knifi=knifeIndex
		polyi=polySegmentIndex
	End
	
	
End

Struct PolyAIL
	Field poly:Stack<Vec2d>
	Field isLeft:Bool
	Method New(p:Stack<Vec2d>,l:Bool)
		poly=p
		isLeft=l
	End
End

Function ExtremeLeftise:Stack<Vec2d>(poly:Stack<Vec2d>)
	
	If poly.Top=poly[0] Then poly.Pop()
	
	Local extrmIndex:=0
	For Local i:=0 Until poly.Length
		If poly[i].x<poly[extrmIndex].x
			extrmIndex=i
		End
	Next
	
	Local retStack:=New Stack<Vec2d>
	
	For Local i:=extrmIndex Until poly.Length
		retStack.Add(poly[i])
	Next
	If extrmIndex<>0
		For Local i:=0 Until extrmIndex
			retStack.Add(poly[i])
		Next
	End
	
	Return retStack
	
End

Function IsLeft:Int( P0:Vec2d, P1:Vec2d, P2:Vec2d )
	return ( (P1.x - P0.x) * (P2.y - P0.y) - (P2.x - P0.x) * (P1.y - P0.y) )
End

Public

Function InPoly:Bool( P:Vec2d, V:Stack<Vec2d> )
	
	'	Copyright 2000 softSurfer, 2012 Dan Sunday
	'// This code may be freely used and modified for any purpose
	'// providing that this copyright notice is included with it.
	'// SoftSurfer makes no warranty for this code, and cannot be held
	'// liable for any real or imagined damage resulting from its use.
	'// Users of this code must verify correctness for their application.
	
	If V[0]<>V.Top Then V.Add(V[0])

	Local wn := 0
	For Local i:=0 To V.Length-2
		If V[i].y <= P.y		
			If V[i+1].y	> P.y		
					If IsLeft( V[i], V[i+1], P) > 0	
						wn+=1		
					End
			End
		Else							
			If V[i+1].y <= P.y
					If IsLeft( V[i], V[i+1], P) < 0	
						wn-=1		
					End
			End
		End
	Next
	If wn<>0 Then Return True
	Return False
End

Function InPolyExclLim:Bool(point:Vec2d , poly:Stack<Vec2d>)
	
	If poly.Length<3 Then Return False
	
	Local Win:=InPoly(point,poly)
	If poly[0]<>poly.Top Then poly.Add(poly[0])
	If Win=True
		For Local i:=0 Until poly.Length-1
			
			Local lin:=New Line2D(poly[i],poly[i+1]-poly[i])
			
			If lin.IsCollinearAndInsideSegment(point) Then Return False
			
		Next
	End
	
	Return Win
	
End

Function InPolyInclLim:Bool (point:Vec2d, poly:Stack<Vec2d>)

	If poly.Length<3 Then Return False
	
	Local Win:=InPoly(point,poly)
	If poly[0]<>poly.Top Then poly.Add(poly[0])
	If Win=False
		For Local i:=0 Until poly.Length-1
			
			Local lin:=New Line2D(poly[i],poly[i+1]-poly[i])
			
			If lin.IsCollinearAndInsideSegment(point) Then Return True
			
		Next
	End
	
	Return Win
	
End


