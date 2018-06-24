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
	
	Field fixtures:b2Fixture[]
	
	Method New( title:String,width:Int,height:Int,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
		ClearColor=Color.Black
		'------- Initialising b2Manager (the world and all the stuff associated wth the Json) 
		physManager=New b2Manager("asset::fixturebalance.json")	
		
		fixtures=physManager.GetFixtures("stonefixtureright")
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		App.RequestRender()
		
		canvas.PushMatrix()
		canvas.Translate(500,350)
		canvas.Scale(New Vec2f(4.0,4.0))

		physManager.StepWorld()

		physManager.DrawDebug(canvas)
		physManager.DrawBodies(canvas)
		canvas.PopMatrix()
		canvas.DrawText("Press up/down arrows to modify the density of the right stones fixtures",5,15)
				
		If Keyboard.KeyPressed(Key.Up)
			For Local i:=0 Until fixtures.Length
				fixtures[i].SetDensity(1.8)
				fixtures[i].GetBody().ResetMassData()
				physManager.GetBody("arm").SetAwake(True)
			Next
		End
		If Keyboard.KeyPressed(Key.Down)
			For Local i:=0 Until fixtures.Length
				fixtures[i].SetDensity(0.7)
				fixtures[i].GetBody().ResetMassData()
				physManager.GetBody("arm").SetAwake(True)
			Next
		End
		
	End
End

Function Main()

	New AppInstance
	New Box2DgfxTest( "Box2D_test",w_width,w_height )
	App.Run()
End