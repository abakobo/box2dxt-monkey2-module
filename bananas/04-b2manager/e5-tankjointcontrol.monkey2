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
	
	Field driveJointsInf:b2JointInfo[]
	
	Method New( title:String,width:Int,height:Int,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
		ClearColor=Color.Black
		'------- Initialising b2Manager (the world and all the stuff associated wth the Json) 
		physManager=New b2Manager("asset::tank.json")
		
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		App.RequestRender()
		
		canvas.PushMatrix()
		'centering the canvas transform on the "canon"
		canvas.SetCameraByCenter(physManager.FromPhysics(physManager.GetBody("canon").GetPosition()),1.7)
		physManager.StepWorld()
		physManager.DrawDebug(canvas)
		physManager.DrawBodies(canvas)
		canvas.PopMatrix()
		
		canvas.DrawText("press S to Save scene to json (save in same dir as original to keep relative path with images)",5,15)
		canvas.DrawText("Use up/down arrows to move tank.",5,35)
		
		'
		'
		' control of the tank
		'
		'
		Local MSpeed:=0.0
		If Keyboard.KeyDown(Key.Up)
			MSpeed=-15.0
		End
		If Keyboard.KeyDown(Key.Down)
			MSpeed=12.0
		End
		
		'Getting an array with a b2JointInfo array (9 joints,2 revoltue and 7 wheel)
		'for modifying motor speed in OnRender()
		' idealy this should not be in a loop
		driveJointsInf=physManager.GetJointsInfo("drivejoint")
		
		'Setting the motor speed to the 9 joints named "drivejoint"
		 ' the joints "drivejoint" have two types
		 'and you have to know the type of a b2Joint to be able to convert it properly
		For Local joinf:=Eachin driveJointsInf
			If joinf.jointType="wheel"
				b2JointTob2WheelJoint(joinf.theb2Joint).SetMotorSpeed(MSpeed)
			Elseif joinf.jointType="revolute"
				b2JointTob2RevoluteJoint(joinf.theb2Joint).SetMotorSpeed(MSpeed)
			End
		End
		
		'
		'
		' saving statements
		'
		'
		
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