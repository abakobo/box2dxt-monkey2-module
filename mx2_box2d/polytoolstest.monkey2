Namespace myapp

#Import "<box2dxt>"
#Import "polytools.monkey2"
#Import "akofw.monkey2"


Using std..
Using mojo..
Using box2d..
Using box2dxt..
Using polytools..
Using akofw..

Class MyWindow Extends Window
	
	Field poly:b2Vec2[]
	Field poly2:b2Vec2[]
	Field tpoly:Stack<b2Vec2>
	Field currentV:Int
	'Field pm:b2Manager
	
	Field state:="init"

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		
		'pm=New b2Manager(New b2Vec2(0,-10))
		
		poly=New b2Vec2[8]
		
		
		tpoly=New Stack<b2Vec2>
		
		currentV=0
		
		#rem
		poly[0]=New b2Vec2(10,10)
		poly[1]=New b2Vec2(100,10)
		poly[2]=New b2Vec2(100,100)
		poly[3]=New b2Vec2(300,10)
		poly[4]=New b2Vec2(400,400)
		poly[5]=New b2Vec2(350,460)
		poly[6]=New b2Vec2(600,200)
		poly[7]=New b2Vec2(10,10)
		#end
		
		Local l1:=New Line2D(New Vec2f(0,0),New Vec2f(1,0))
		Local l2:=New Line2D(New Vec2f(2,0),New Vec2f(0,1))
		
		Print l1.Intersection(l2)
		Print l1.SegmentIntersects(l2)
		
		
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
		
		If state="init"
			
			canvas.DrawText("state: "+state+" lenght"+tpoly.Length,10,10)
			If Keyboard.KeyPressed(Key.Space)
				
				If tpoly.Length>2
					
					state="check"
					tpoly.Add(tpoly[0])
					poly=tpoly.ToArray()

					poly2=cleanPolygon(poly)
					
					Print "poly2 Length"+poly2.Length
					
				End
				
			End
			
			If Mouse.ButtonPressed(MouseButton.Left)
				
				tpoly.Add(MouseLocation)
				
			End 
			
			If tpoly.Length>1
				For Local i:=0 Until tpoly.Length-1
					canvas.DrawLine(tpoly[i],tpoly[i+1])
				Next
			End
			
			
			
		Elseif state="check"
			
			For Local i:=0 Until poly.Length-1
				canvas.DrawLine (poly[i],poly[i+1])
			Next
			
			Local p:=Mouse.Location
			canvas.DrawText("state: "+state+"mouse: "+p+"  wn-Mouse: "+wn_PnPoly( p , poly )+"  wn-Point: "+wn_PnPoly( poly2[currentV] , poly ),10,10)
			
			canvas.Color=Color.Red
			
			For Local i:=0 Until poly2.Length-1
				canvas.DrawLine (poly2[i],poly2[i+1])
			Next
			
			
			If Keyboard.KeyPressed(Key.Up)
				currentV+=1
			Elseif Keyboard.KeyPressed(Key.Down)
				currentV-=1
			End
			If currentV>poly2.Length-1 Then currentV=0
			If currentV<0 Then currentV=poly.Length-1
			canvas.DrawCircle(poly2[currentV].x,poly2[currentV].y,3)
			
		End
	End
	
End
Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End




