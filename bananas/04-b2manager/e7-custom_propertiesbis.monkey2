#Import "<std>"
#Import "<mojo>"
#Import "../../mx2_box2d/b2Manager"

#Import "../assets/"
#Import "../assets/images/@/images/"

Using std..
Using mojo..
Using box2d..

Global w_width:=1000 'initial window size
Global w_height:=700

Class Box2DgfxTest Extends Window

	Field physManager:b2Manager
	Field drawDebug:=True
	
	Method New( title:String,width:Int,height:Int,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
		ClearColor=Color.Black
		'------- Initialising b2Manager (the world and all the stuff associated wth the Json) 
		physManager=New b2Manager("asset::custom_prop2.json")
		
		Local ballUserDataArray:=physManager.GetBodiesUserData("ball")
		Print "user data types and names for each ball objects"
		For Local ballUserData:=Eachin ballUserDataArray
				Print "**"
				For Local mapElem:=Eachin ballUserData
					Print mapElem.Key
					Print mapElem.Value.Type.Name
					Print "-------------------------"
				Next
		Next
		
		Local userDataStack:=physManager.GetBodiesUserData("ball","stringProp")
		Print "StringProp values of the balls"
		For Local v:=Eachin userDataStack
			Print Cast<String>(v)
		Next
		
		Print "---"
		
		 'Or Using the b2Manager (convert help)
		Local stringStack:=physManager.GetBodiesUserDataToS("ball","stringProp")
		For Local s:=Eachin stringStack
			Print s
		Next
		Print "-*-*-*"
		Local floatStack:=physManager.GetBodiesUserDataToN("ball","intProp")
		For Local f:=Eachin floatStack
			Print f
		Next
		Print "*-*-*-*-*"
		Local boolStack:=physManager.GetBodiesUserDataToB("ball","boolProp")
		For Local b:=Eachin boolStack
			Print b
		Next
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		App.RequestRender()
		
		canvas.PushMatrix()
		'centering the canvas transform on the "ground"
		canvas.SetCameraByCenter(physManager.FromPhysics(physManager.GetBody("ground").GetPosition()),6.2)
		physManager.StepWorld()
		physManager.DrawDebug(canvas)
		physManager.DrawBodies(canvas)
		canvas.PopMatrix()
		
		canvas.DrawText("Blah",5,35)
		
	End
End

Function Main()
	New AppInstance
	New Box2DgfxTest( "Box2D_test",w_width,w_height )
	App.Run()
End

Class Canvas Extension
	
	Method SetCameraByCenter(point:Vec2f,zoom:Float=1.0,rotation:Float=0,vr:Vec2f=New Vec2f(0,0))
 
		Translate(Viewport.Width/2,Viewport.Height/2)
		Scale(zoom,zoom)
		Rotate(rotation)
		Translate(-point)
 
	End
	
End