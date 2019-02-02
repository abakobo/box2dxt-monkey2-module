Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<box2dxt>"
'#Import "makeconvex.monkey2"

'#Import "bayazit_src/bayazit.h"

Using std..
Using mojo..
Using box2d..
Using box2dxt..

Public


Class MyWindow Extends Window
	
	Field poly:Stack<Vec2d>
	Field polyStack:Stack<Stack<Vec2d>>
	Field convexPolys:Stack<Stack<Vec2d>>
	Field tpoly:Stack<Vec2d>
	Field currentV:Int
	Field zoom:=88.0
	Field follow:=False
	Field showConvex:=False
	
	Field state:="init"

	Method New( title:String="Simple mojo app",width:Int=940,height:Int=580,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		tpoly=New Stack<Vec2d>
		poly=New Stack<Vec2d>
		
		state="init"
		
		tpoly=RegPoly()
		
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
		canvas.Scale(20,20)
		canvas.Translate(30,0)
		If state="init"
			
			Local mouseLoc:Vec2i=MouseLocation
			'mouseLoc.x=10*((5+Int(mouseLoc.x))/10)
			'mouseLoc.y=10*((5+Int(mouseLoc.y))/10)
			canvas.DrawText(" lenght"+tpoly.Length+" Draw any poly, press Spacebar to finish" ,10,10)
			
			If Keyboard.KeyPressed(Key.Space)
				
				If tpoly.Length>2
					
					state="check"
					tpoly.Add(tpoly[0])
					poly=tpoly
					polyStack=SimplePartition(poly)
					
					convexPolys=FullPartition(poly)
					
				End
				
			End
			
			If Mouse.ButtonDown(MouseButton.Left)
				
				If Not tpoly.Empty
					If tpoly.Top.Distance(mouseLoc)>9 Then tpoly.Add(mouseLoc)
				Else
					tpoly.Add(mouseLoc)
				End
			End 
			
			If tpoly.Length>1
				For Local i:=0 Until tpoly.Length-1
					canvas.DrawLine(tpoly[i],tpoly[i+1])
				Next
			End
			
		Elseif state="check"
			
			canvas.PushMatrix()
			
			canvas.Color=New Color(0.5,0,0)
			For Local i:=0 Until poly.Length-1
				canvas.DrawLine (poly[i],poly[i+1])
			Next
			canvas.DrawLine (poly[0],poly[poly.Length-1])
			
			canvas.Color=Color.Red
			
			If polyStack<>Null
				For Local i:=0 Until polyStack.Length
					Local r:=Abs(Sin(i*11.0))
					Local g:=Abs(Cos(i*7.0))
					Local b:=Abs(Sin(1-5.0*i)*0.4)
					canvas.Color=New Color(r,g,b)
					If polyStack[i].Length>0
						Local sPoly:=polyStack[i]
						For Local j:=0 Until sPoly.Length-1
							canvas.DrawLine(sPoly[j],sPoly[j+1])
						Next
						canvas.DrawLine (sPoly[sPoly.Length-1],sPoly[0])
					End
				Next
			End
			canvas.Color=Color.Green
			If showConvex=True
				If convexPolys.Length>1
				
					For Local tiPoly:=Eachin convexPolys
						For Local i:=0 Until tiPoly.Length-1
							canvas.DrawLine(tiPoly[i],tiPoly[i+1])
						Next
						canvas.DrawLine(tiPoly[0],tiPoly[tiPoly.Length-1])
					Next
				
				End	
			End
			
			canvas.PopMatrix()
			
			Local p:=Mouse.Location

			canvas.DrawText("mouse: "+p,10,20)
			
			If Keyboard.KeyPressed(Key.C)
				showConvex=Not showConvex
			End

		End
	End
	
End

Function SavePoly:String(p:Stack<Vec2d>)
	
	If p.Top=p[0] Then p.Pop()
	
	Local ret:=""+p.Length+"~n"
	ret+="0~n"
	For Local i:=0 Until p.Length
		'ret+= "poly.Add(New b2Vec2("+p[i].x+","+p[i].y+"))~n"
		ret+=""+Int(p[i].x)+" "+Int(p[i].y)+"~n"
	Next
	
	p.Add(p[0])
	
	Return ret
End

Function Main()

	New AppInstance
	
	New MyWindow

	App.Run()
End

Function RegPoly:Stack<Vec2d>()
	
Local poly:=New Stack<Vec2d>
poly.Add(New b2Vec2(-25.0666676,13))
poly.Add(New b2Vec2(-25,13.3999996))
poly.Add(New b2Vec2(-24.7999992,14.666667))
poly.Add(New b2Vec2(-24.5333328,15.2666664))
poly.Add(New b2Vec2(-23.333334,15.4666662))
poly.Add(New b2Vec2(-22.5333328,15.1333332))
poly.Add(New b2Vec2(-21.7333336,14.3999996))
poly.Add(New b2Vec2(-21.333334,13.6000004))
poly.Add(New b2Vec2(-21.2666664,12.8000002))
poly.Add(New b2Vec2(-21.3999996,12))
poly.Add(New b2Vec2(-21.666666,11.4666662))
poly.Add(New b2Vec2(-22.5333328,11.8000002))
poly.Add(New b2Vec2(-22.7333336,12.2666664))
poly.Add(New b2Vec2(-22.7333336,12.666667))
poly.Add(New b2Vec2(-22.1333332,13.1333332))
poly.Add(New b2Vec2(-20.8666668,13.1999998))
poly.Add(New b2Vec2(-18.1333332,12.3999996))
poly.Add(New b2Vec2(-17.3999996,11.9333334))
poly.Add(New b2Vec2(-16.7333336,11.6000004))
poly.Add(New b2Vec2(-16.2666664,12.1333332))
poly.Add(New b2Vec2(-15.666667,14.3999996))
poly.Add(New b2Vec2(-15.2666664,16.666666))
poly.Add(New b2Vec2(-14.9333334,18.8666668))
poly.Add(New b2Vec2(-15,19.4666672))
poly.Add(New b2Vec2(-16,19.4666672))
poly.Add(New b2Vec2(-16.9333324,18.666666))
poly.Add(New b2Vec2(-18.1333332,16.333334))
poly.Add(New b2Vec2(-18.3999996,14.5333338))
poly.Add(New b2Vec2(-18.2000008,13.1333332))
poly.Add(New b2Vec2(-17.4666672,12.2666664))
poly.Add(New b2Vec2(-15.666667,11.7333336))
poly.Add(New b2Vec2(-14.666667,11.666667))
poly.Add(New b2Vec2(-15.6000004,11.9333334))
poly.Add(New b2Vec2(-18.8666668,12.1333332))
poly.Add(New b2Vec2(-20.6000004,11.8666668))
poly.Add(New b2Vec2(-21.666666,10.9333334))
poly.Add(New b2Vec2(-22,9.80000019))
poly.Add(New b2Vec2(-22.0666676,7.86666679))
poly.Add(New b2Vec2(-21.7999992,7))
poly.Add(New b2Vec2(-20.9333324,7))
poly.Add(New b2Vec2(-19.7999992,8.0666666))
poly.Add(New b2Vec2(-19.5333328,9.13333321))
poly.Add(New b2Vec2(-20.0666676,10.6000004))
poly.Add(New b2Vec2(-20.9333324,11))
poly.Add(New b2Vec2(-22.1333332,11))
poly.Add(New b2Vec2(-23,10.666667))
poly.Add(New b2Vec2(-23.8666668,9.53333378))
poly.Add(New b2Vec2(-24.333334,6.9333334))
poly.Add(New b2Vec2(-24.1333332,5.4000001))
poly.Add(New b2Vec2(-21.7999992,4.73333311))
poly.Add(New b2Vec2(-20.3999996,4.73333311))
poly.Add(New b2Vec2(-19.4666672,5.26666689))
poly.Add(New b2Vec2(-19.333334,7.26666689))
poly.Add(New b2Vec2(-20.2000008,9.26666641))
poly.Add(New b2Vec2(-22.8666668,10.9333334))
poly.Add(New b2Vec2(-24.3999996,11))
poly.Add(New b2Vec2(-25.2666664,10.8000002))
poly.Add(New b2Vec2(-26.1333332,9.9333334))
poly.Add(New b2Vec2(-26.3999996,8.60000038))
poly.Add(New b2Vec2(-25.666666,5.73333311))
poly.Add(New b2Vec2(-24.5333328,5.13333321))
poly.Add(New b2Vec2(-23.2000008,5.5999999))
poly.Add(New b2Vec2(-22.8666668,6.86666679))
poly.Add(New b2Vec2(-22.8666668,11))
poly.Add(New b2Vec2(-24.2000008,15.2666664))
poly.Add(New b2Vec2(-25,16))
poly.Add(New b2Vec2(-25.666666,16))
poly.Add(New b2Vec2(-26.9333324,13.7333336))
poly.Add(New b2Vec2(-27.333334,11.333333))
poly.Add(New b2Vec2(-26.9333324,8.26666641))
poly.Add(New b2Vec2(-26.333334,7.86666679))
poly.Add(New b2Vec2(-24.7333336,8))
poly.Add(New b2Vec2(-21.7333336,9.9333334))
poly.Add(New b2Vec2(-20.3999996,12.333333))
poly.Add(New b2Vec2(-20.5333328,15.7333336))
poly.Add(New b2Vec2(-21.4666672,16.666666))
poly.Add(New b2Vec2(-22.7333336,16.6000004))
poly.Add(New b2Vec2(-23.7999992,15.333333))
poly.Add(New b2Vec2(-24.2666664,13.6000004))
poly.Add(New b2Vec2(-24.2666664,11.4666662))
poly.Add(New b2Vec2(-23.3999996,10))
poly.Add(New b2Vec2(-21.8666668,9.80000019))
poly.Add(New b2Vec2(-20.1333332,10))
poly.Add(New b2Vec2(-17.4666672,11.4666662))
poly.Add(New b2Vec2(-16.2000008,13.2666664))
poly.Add(New b2Vec2(-16.2000008,16))
poly.Add(New b2Vec2(-17.0666676,17.1333332))
poly.Add(New b2Vec2(-18.7999992,17.5333328))
poly.Add(New b2Vec2(-19.8666668,16.8666668))
poly.Add(New b2Vec2(-20.666666,14.1333332))
poly.Add(New b2Vec2(-19.4666672,9.26666641))
poly.Add(New b2Vec2(-18.2000008,7.80000019))
poly.Add(New b2Vec2(-16.7999992,7.4666667))
poly.Add(New b2Vec2(-16,7.5999999))
poly.Add(New b2Vec2(-15.0666666,8.60000038))
poly.Add(New b2Vec2(-14.8000002,10.4666662))
poly.Add(New b2Vec2(-15.3999996,13.2666664))
poly.Add(New b2Vec2(-17.1333332,14.333333))
poly.Add(New b2Vec2(-18.333334,14.1333332))
poly.Add(New b2Vec2(-20.5333328,11.7333336))
poly.Add(New b2Vec2(-21.6000004,8.26666641))
poly.Add(New b2Vec2(-21.9333324,5.5333333))
poly.Add(New b2Vec2(-21.9333324,4))
poly.Add(New b2Vec2(-21.8666668,3.20000005))
poly.Add(New b2Vec2(-21.7999992,2.86666656))
poly.Add(New b2Vec2(-23,2))
poly.Add(New b2Vec2(-25.5333328,1.20000005))
poly.Add(New b2Vec2(-28.3999996,1.06666672))
poly.Add(New b2Vec2(-29.7999992,1.20000005))
poly.Add(New b2Vec2(-30.3999996,1.5333333))
poly.Add(New b2Vec2(-30.9333324,2.20000005))
poly.Add(New b2Vec2(-31,3.20000005))
	
Return poly
End
	
