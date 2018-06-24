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
		
#rem
		Print "+++++++++++++++++"
		Local bod:=physManager.GetBody("ground")
		Local variantMap:=physManager.GetBodyUserDataToM(bod)
		Print Cast<String>(variantMap["stringProp"])
		
		Local s:String=physManager.GetBodyUserDataToS(bod,"stringProp")
		Print s
		
		Local b:Bool=physManager.GetBodyUserDataToB(bod,"boolProp")
		Print b
		
		Local f:Float=physManager.GetBodyUserDataToF(bod,"floatProp")
		Print f
		
		Local i:Int=physManager.GetBodyUserDataToI(bod,"intProp")
		Print i
		
		Local f2:Float=physManager.GetBodyUserDataToN(bod,"intProp")
		Print f2
#end
		
		
		
		'OOP approach
		Print physManager.GetBody("ground").GetUserDataToS("stringProp")
		
		Print physManager.GetBody("ground").GetUserDataBodyInfo().bodyName

		
		
		
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