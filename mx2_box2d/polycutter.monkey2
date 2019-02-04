Namespace box2dxt.polytools

#Import "<std>"
#Import "extsandfuncs.monkey2"

Using std..
Using box2d..
Using box2dxt..


Function polyCutter:Stack<Stack<Vec2d>>(polygon:Stack<Vec2d>,cutEdges:Stack<Vec2d>)
	'poly must be convex
	'poly must be CCW
	'poly may not contain straigths (consecutive parallel edges)
	'knife may not self intersect

	Local knife:=New Stack<Vec2d>
	For Local p:=Eachin cutEdges
		If InPoly(p,polygon) And knife.Length>0
			knife.Add(p)
		Elseif Not InPoly(p,polygon)
			knife.Add(p)
		End
	End
		
	While knife.Length>1 And InPoly(knife.Top,polygon)
		knife.Pop()
	End
	'enlever multi externes
	While (knife.Length>1) And (Not InPoly(knife.Top,polygon)) And (Not InPoly(knife[knife.Length-2],polygon))
		knife.Pop()
	End
	knife.Reverse()
	While (knife.Length>1) And (Not InPoly(knife.Top,polygon)) And (Not InPoly(knife[knife.Length-2],polygon))
		knife.Pop()
	End
			Print "knifeé"
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
	Print "preInter"
	Local interKnife:=New Stack<PIP>
	Local totInts:=0
	For Local i:=0 Until poly.Length-1
		Local pline:=New Line2D(poly[i],poly[i+1]-poly[i])
		For Local j:=0 Until knife.Length-1
			Local kline:=New Line2D(knife[j],knife[j+1]-knife[j])
			Local pab:=pline.SegmentIntersectsPAB(kline)
			If pab.b=True
				Print "interrrr: "+i+" "+j
				Print pab.p
				totInts+=1
				interKnife.Add(New PIP(pab.p,j,i))
			End
			If totInts=2 Then Exit
		Next
		If totInts=2 Then Exit
	Next
	
	Print "preknifeChain"
	Print "interL: "+interKnife.Length
	Print "knifeL: "+knife.Length
	Local pleft:=New Stack<Vec2d>
	Local pright:=New Stack<Vec2d>
	If interKnife.Length=2
		Local knifeChain:=New Stack<Vec2d>

		If interKnife[0].polyi>interKnife[1].polyi Then interKnife.Reverse()
		Print "what?"
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
			Print "diff<0"
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
	Local tknife:=New Stack<Vec2d>
	For Local i:=kIndex Until knife.Length
		tknife.Add(knife[i])
	Next
	knife=tknife
	Local retSta:=New Stack<Stack<Vec2d>>
	'If knife.Length<2
		retSta.Add(pleft)
		retSta.Add(pright)
	'Else
	'	Print "Recurse"
	'	Print "r"+knife.Length
	'	retSta.AddAll(polyCutter(pleft,knife))
	'	Print "r"+knife.Length
	'	retSta.AddAll(polyCutter(pright,knife))
	'	Print "r"+knife.Length
		
	'End
	
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

Function InPoly:Bool( P:Vec2d, V:Stack<Vec2d> )
	
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

