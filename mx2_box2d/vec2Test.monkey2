
Namespace myapp

#Import "<box2dxt>"
#Import "polytools.monkey2"

Using std..
Using mojo..
Using box2d..
Using box2dxt..
Using polytools..

Class MyWindow Extends Window
	
	Field origin:=New b2Vec2 (320,240)
	Field v1:=New b2Vec2 (50,0)
	Field v3:=New b2Vec2 (50,0)

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		Print v1<>v3
		Print v1=v3
		Print origin<>v3
		Print v1
		'v1.Normalize()
		Print v1
		Local m:= New Map<b2Vec2,String>
		m.Add(v1,"yo")
		m.Add(origin,"oo")
		Print m.Contains(v3)
		Print m.Contains(New b2Vec2(0,0))
		Print m[v3]
		
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	

		Local ml:b2Vec2=MouseLocation
		Local v2:=ml-origin
		
		canvas.DrawLine(origin,origin+v1)
		canvas.DrawLine(origin,origin+v2)
	
		canvas.DrawText( "angle: "+v1.PositiveAngleWith(v2)+" cross1-2:"+v1.Cross(v2)+" cross2-1:"+v2.Cross(v1),10,10 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
