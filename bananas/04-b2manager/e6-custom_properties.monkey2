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
		physManager=New b2Manager("asset::custom_prop.json")
		
		Local ballUserData:=physManager.GetBodyUserData("ball")
		
		For Local mapElem:=Eachin ballUserData
			Print mapElem.Key
			Print mapElem.Value.Type.Name
			Print "-------------------------"
		Next
		
		Print Cast<String>(ballUserData["thestring"])
		'or
		Print Cast<String>(physManager.GetBodyUserData("ball")["thestring"])
		Print "+++++"
		
		'or
		Local bod:=physManager.GetBody("ball")
		Local userData:=Cast<StringMap<Variant>>(bod.GetUserData())
		Print Cast<String>(userData["thestring"])
		'or...
		Print Cast<String>(Cast<StringMap<Variant>>(physManager.GetBody("ball").GetUserData())["thestring"])
		
		'OR (b2Manger way)
		Print "-+-+-+-+-+-+-+-"
		Print physManager.GetBodyUserDataToS("ball","thestring")
		Print physManager.GetBodyUserDataToB("ball","thebool")
		Print physManager.GetBodyUserDataToI("ball","theint")
		Print physManager.GetBodyUserDataToF("ball","thefloat")
		
		Print physManager.GetBodyUserDataToN("ball","theint")
		
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