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
		physManager=New b2Manager("asset::everyjointscusto.json")

		Print Cast <String>(physManager.GetJointInfo("ropejoint0").jointUserData["jointString"])
		Local jo:=physManager.GetJoint("ropejoint0")
		Local cmap:=jo.GetUserDataToMap()
		Print Cast <String>(cmap["jointString"])
		Print "----"
		'Print physManager.GetBody("body").GetUserDataToV("b2ManagerBodyInfo")
		Print physManager.GetBody("body8").IsBullet()
		
		Local map:=Cast <StringMap<Variant>>(physManager.GetBody("body8").GetUserDataToMap())
		Print "mapL: "+map.Count()
		For Local nod:=Eachin map
			Print nod.Key
		Next
		Local inf:=Cast <b2BodyImageInfo>(physManager.GetBody("body8").GetUserDataToV("b2ManagerBodyInfo"))

		Print inf.bodyName
		
		Print "+++"
		Print physManager.GetJoint("ropejoint0").GetUserDataToS("jointString")
		Print physManager.GetJoint("pulleyjoint0").GetUserDataToS("jointString")
		Print physManager.GetJoint("gearjoint0").GetUserDataToS("jointString")
		
		Print physManager.GetJoint("gearjoint0").GetUserDataJointInfo().jointName
		
	
		
		
		Local gj:=physManager.GetJoint("ropejoint0").ToRope()
'		Print gj.GetRatio()
'		gj.SetRatio(3.0)
		Print gj.GetUserDataToS("jointString")
		
		physManager.GetJoint("gearjoint0").ToGear().SetRatio(17)
		
		Print "*********"
		
		Local jar:=physManager.GetJoints("duoJoint")
		For Local j:=Eachin jar
			Print j.GetUserDataJointInfo().jointType
		Next
		
		
		
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		App.RequestRender()
		
		canvas.PushMatrix()
		'centering the canvas transform on the "ground"
		canvas.SetCameraByCenter(physManager.FromPhysics(physManager.GetBody("body14").GetPosition()),2.2)
		physManager.StepWorld()
		physManager.DrawDebug(canvas)
		physManager.DrawBodies(canvas)
		canvas.PopMatrix()
		
		canvas.DrawText("s to save",5,35)
		
		If Keyboard.KeyPressed(Key.S|Key.Raw)
			Local savePath:=RequestFile( "Save b2dJson","Json files:json",True )
			physManager.Save(savePath)
		End
		
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