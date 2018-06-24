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
		physManager=New b2Manager("asset::collision.json")


'		Print physManager.GetJoint("ropejoint0").GetUserDataToS("jointString")
'		Print physManager.GetJoint("pulleyjoint0").GetUserDataToS("jointString")
'		Print physManager.GetJoint("gearjoint0").GetUserDataToS("jointString")

'		Print Cast <Vec2f>(physManager.GetBody("body0").GetUserDataToV("theVect"))
'		Print Cast <Vec2f>(physManager.GetBody("body1").GetUserDataToV("theVect"))
		Local filt:= physManager.GetFixture("fixture0").GetFilterData()
		filt.categoryBits=$FFFF
		filt.maskBits=$0003
		filt.groupIndex=7
		physManager.GetFixture("fixture0").SetFilterData(filts)
		
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		App.RequestRender()
		
		canvas.PushMatrix()
		'centering the canvas transform on the "ground"
		canvas.SetCameraByCenter(physManager.FromPhysics(physManager.GetBody("body0").GetPosition()),2.2)
		physManager.StepWorld()
		physManager.DrawDebug(canvas)
		physManager.DrawBodies(canvas)
		canvas.PopMatrix()
		
		canvas.DrawText("s to save",5,35)
		
		If Keyboard.KeyPressed(Key.S|Key.Raw)
			Local savePath:=RequestFile( "Save b2dJson","Json files:json",True )
			physManager.Save(savePath,True)
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