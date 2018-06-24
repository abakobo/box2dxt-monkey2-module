Namespace box2d

#Import "<std>"
#Import "<mojo>"

#Import "../box2d.monkey2"
#Import "b2dJsonBodyImage.monkey2"
#Import "b2dJsonJoint.monkey2"
#Import "../iforce2d-b2djson/mx2b2djson.monkey2"
#Import "b2draw.monkey2"

#Import "b2ManagerUserDataExtension.monkey2"
#Import "UserDataExtensions.monkey2"

Using std..
Using mojo..
Using box2d..
Using b2dJsonInfo..
Using mx2b2dJson..


Class b2Manager Extends Resource
	
	Field world:b2World
	
	Field physScale:Float
	Field yAxisInversion:=True
	
	'Field timeStep:= 0.01666666667
	'Field velocityIterations := 6
	'Field positionIterations := 2
	
	Field bodyInfos:b2BodyImageInfo[]
	Field bodyImageMap:IntMap<Image>
	Field fixtureInfos:Stack<b2FixtureInfo>
	Field jointInfos:Stack<b2JointInfo>
	
	Field debugDrawer:b2DebugDraw
	
	Field b2dJsons:=New b2dJson[1]
	Field b2dJsonsCount:=0
	
	Private
	Field sortedBodyImageInfos:=New Stack<b2BodyImageInfo>
	
	Public
	
	Method New(gravity:b2Vec2,pScale:Float=15,yAxisInversion:Bool=True)
		world=New b2World(gravity)
		
		debugDrawer=New b2DebugDraw(physScale,yAxisInversion)	
	End
	
	Method New (jsonPath:String,pScale:Float=15,yAxisInversion:Bool=True,offset:b2Vec2=New b2Vec2(0,0))
		
		physScale=pScale
		
		b2dJsons[0]=New mx2b2dJson.b2dJson()
		
		
		world=Loadb2dJsonWithb2dJsonRef(b2dJsons[0] , jsonPath) 'offset TODO!
		
		debugDrawer=New b2DebugDraw(physScale,yAxisInversion)
		
		world.SetDebugDraw( debugDrawer  )
		debugDrawer.SetFlags( e_shapeBit|e_jointBit )
		
		bodyInfos=Createb2BodyImageInfoArray(world,jsonPath )
		bodyImageMap=Createb2BodyImageMap(bodyInfos)
		
		fixtureInfos=Createb2FixtureInfoStack(world,jsonPath)
		
		jointInfos=Createb2JointInfoStack(world,jsonPath)',b2dJsons[0])
		
		SortRenderOrderToBodyDrawStack()
		
	End
	
	Method addJson(jsonPath:String,offset:b2Vec2=New b2Vec2(0,0))
		Local lastBody:=world.GetBodyList()
		Local count:=world.GetBodyCount()
		While count>1
			lastBody=lastBody.GetNext()
			count-=1
		Wend
		
		
		Local l:=b2dJsons.Length
		b2dJsons.Resize(l+1)
		b2dJsons[l]=New mx2b2dJson.b2dJson()
		
		world=Loadb2dJsonWithb2dJsonRef(b2dJsons[l] , jsonPath , world , offset)
		
	End
	
	Method StepWorld()
		world.Stepp(timeStep, velocityIterations, positionIterations)
	End
	
	Method DrawDebug(canvas:Canvas)
		Local col:=canvas.Color
		debugDrawer.SetCanvas(canvas)
		world.DrawDebugData()
		canvas.Color=col
	End
	
	Method DrawBodies(canvas:Canvas)
		
		Local sign:=-1
		If yAxisInversion=False Then sign=1
		#rem
		For Local bodyImageNode:=Eachin bodyImageMap
			
			Local location:=b2Vec2ToVec2f(bodyInfos[bodyImageNode.Key].imageWorldPosition)*(New Vec2f(physScale,sign*physScale)) 'sign for y axis inversion RUBE using standart coordinates system
			Local rotation:=-sign*bodyInfos[bodyImageNode.Key].imageWorldAngle' sign for y axis inversion RUBE using standart coordinates system -sign for trig vs canvas rotation direction????????
			Local scale:=bodyInfos[bodyImageNode.Key].imageRenderScale*New Vec2f(physScale,physScale) 'No yaxis inversion here! because it's an image in left handed coord anyway!
			
			canvas.DrawImage (bodyInfos[bodyImageNode.Key].image , location , rotation , scale)
			
		Next
		#end
		'#rem
		For Local bodyInf:=Eachin sortedBodyImageInfos
			
			Local location:=b2Vec2ToVec2f(bodyInf.imageWorldPosition)*(New Vec2f(physScale,sign*physScale)) 'sign for y axis inversion RUBE using standart coordinates system
			Local rotation:=-sign*bodyInf.imageWorldAngle' sign for y axis inversion RUBE using standart coordinates system -sign for trig vs canvas rotation direction????????
			Local scale:=bodyInf.imageRenderScale*New Vec2f(bodyInf.imageFlip*physScale,physScale) 'No yaxis inversion here! because it's an image in left handed coord anyway!
		
			canvas.DrawImage (bodyInf.image , location , rotation , scale)
			
		Next
		'#end
				'For Local bImgInfo:=Eachin sortedBodyDrawStack
				'	Print bImgInfo.imageRenderOrder
				'Next
		
	End
	
	Method SortRenderOrderToBodyDrawStack()
		
		'copy To an array
		sortedBodyImageInfos=New Stack<b2BodyImageInfo>

		For Local bodyImageNode:=Eachin bodyImageMap
			sortedBodyImageInfos.Add(bodyInfos[bodyImageNode.Key])
		Next
		
		sortedBodyImageInfos.Sort(Lambda:Int(a:b2BodyImageInfo,b:b2BodyImageInfo) 
									Return  a.imageRenderOrder - b.imageRenderOrder
								End )
	End

	
	
	Method UpdateInfos()
		'usefull?
	End
	
	Method GetBodies:b2Body[](name:String)
		
		Local retArray:b2Body[]
		Local bodyStack:=New Stack<b2Body>

		For Local i:=0 Until bodyInfos.Length
			If bodyInfos[i].bodyName=name
				bodyStack.Add(bodyInfos[i].body)
			End
		End
		If bodyStack.Length>0
			retArray=bodyStack.ToArray()
		Else
		#If __DEBUG__
			Print "No body with name "+name+" !!!!!!!!!!!!!!!"
		#End
			Return Null
		End
		Return retArray
		
	End
	
	Method GetBody:b2Body(name:String)
		Local i:=0
		While i<bodyInfos.Length
			If bodyInfos[i].bodyName=name Then Return bodyInfos[i].body
			i+=1
		Wend
		
		#If __DEBUG__
			Print "No body with name "+name+" !!!!!!!!!!!!!!!"
		#End
		
		Return Null

	End
	
	Method GetBodiesInfo:b2BodyImageInfo[](name:String)
		
		Local retArray:b2BodyImageInfo[]
		Local bodyStack:=New Stack<b2BodyImageInfo>

		For Local i:=0 Until bodyInfos.Length
			If bodyInfos[i].bodyName=name
				bodyStack.Add(bodyInfos[i])
			End
		End
		If bodyStack.Length>0
			retArray=bodyStack.ToArray()
		Else
		#If __DEBUG__
			Print "No body with name "+name+" !!!!!!!!!!!!!!!"
		#End
			Return Null
		End
		Return retArray
		
	End
	
	Method GetBodyInfo:b2BodyImageInfo(name:String)
		Local i:=0
		While i<bodyInfos.Length
			If bodyInfos[i].bodyName=name Then Return bodyInfos[i]
			i+=1
		Wend
		
		#If __DEBUG__
			Print "No body with name "+name+" !!!!!!!!!!!!!!!"
		#End
		
		Return Null

	End
	
'----------------------------BodiesData

	Method GetBodiesUserData:StringMap<Variant>[](name:String)
		
		Local retArray:StringMap<Variant>[]
		Local bodyStack:=New Stack<StringMap<Variant>>

		For Local i:=0 Until bodyInfos.Length
			If bodyInfos[i].bodyName=name
				bodyStack.Add(bodyInfos[i].bodyUserData)
			End
		End
		If bodyStack.Length>0
			retArray=bodyStack.ToArray()
		Else
		#If __DEBUG__
			Print "No body with name "+name+" !!!!!!!!!!!!!!!"
		#End
			Return Null
		End
		Return retArray
		
	End

	Method GetBodiesUserData:Stack<Variant>(name:String,dataName:String)
	
		Local variantMapArray:=GetBodiesUserData(name)
		Local retStack:= New Stack<Variant>
		Local retArray:Variant[]
	
		For Local map:=Eachin variantMapArray
			If map.Contains(dataName)
	
				retStack.Add(map[dataName])
	
			End
		End
	
		If retStack.Length=0
	
			#If __DEBUG__
				Print "No body-data "+dataName+" for body with name "+name+" !!!!!!!!!!!!!!!"
			#End
	
			Return Null
		End
		Return retStack
	
	End
	
	Method GetBodiesUserDataToS:Stack<String>(name:String,dataName:String)
	
		Local variantMapArray:=GetBodiesUserData(name)
		Local retStack:= New Stack<String>
		For Local map:=Eachin variantMapArray
			If map.Contains(dataName)
				If map[dataName].Type.Name="String"
					retStack.Add(Cast<String>(map[dataName]))
				Else
					#If __DEBUG__
						Print "body-data "+dataName+" for body "+name+" Is Not a String !!!!!!!!!!!!!!!"
					#End
				End	
			End
		Next
		If retStack.Length=0
			#If __DEBUG__
				Print "No with body-data "+dataName+" for body with name "+name+" !!!!!!!!!!!!!!!"
			#End	
		End
		Return retStack
	End
	
	Method GetBodiesUserDataToB:Stack<Bool>(name:String,dataName:String)
	
		Local variantMapArray:=GetBodiesUserData(name)
		Local retStack:= New Stack<Bool>
		For Local map:=Eachin variantMapArray
			If map.Contains(dataName)
				If map[dataName].Type.Name="Bool"
					Local myVariant:Variant=map[dataName]
					Local myBool:=Cast<Bool>(myVariant)
					retStack.Add(myBool)
				Else
					#If __DEBUG__
						Print "body-data "+dataName+" for body "+name+" Is Not a Bool !!!!!!!!!!!!!!!"
					#End
				End
			Else
				retStack.Add(False)	
			End
		Next
		If retStack.Length=0
			#If __DEBUG__
				Print "No with body-data "+dataName+" for body with name "+name+" !!!!!!!!!!!!!!!"
			#End
		End
		Return retStack
	
	End
	
	Method GetBodiesUserDataToI:Stack<Int>(name:String,dataName:String)
	
		Local variantMapArray:=GetBodiesUserData(name)
		Local retStack:= New Stack<Int>
		For Local map:=Eachin variantMapArray
			If map.Contains(dataName)
				If map[dataName].Type.Name="Int"
					retStack.Add(Cast<Int>(map[dataName]))
				Else
					#If __DEBUG__
						Print "body-data "+dataName+" for body "+name+" Is Not an Int !!!!!!!!!!!!!!!"
					#End
				End	
			End
		End
		If retStack.Length=0
			#If __DEBUG__
				Print "No with body-data "+dataName+" for body with name "+name+" !!!!!!!!!!!!!!!"
			#End	
		End
		Return retStack
	End
	
	Method GetBodiesUserDataToF:Stack<Float>(name:String,dataName:String)
	
		Local variantMapArray:=GetBodiesUserData(name)
		Local retStack:= New Stack<Float>
		For Local map:=Eachin variantMapArray
			If map.Contains(dataName)
				If map[dataName].Type.Name="Float"
					retStack.Add(Cast<Float>(map[dataName]))
				Else
					#If __DEBUG__
						Print "body-data "+dataName+" for body "+name+" Is Not a Float !!!!!!!!!!!!!!!"
					#End
				End	
			End
		End
		If retStack.Length=0
			#If __DEBUG__
				Print "No with body-data "+dataName+" for body with name "+name+" !!!!!!!!!!!!!!!"
			#End	
		End
		Return retStack
	End
	
	Method GetBodiesUserDataToN:Stack<Float>(name:String,dataName:String)
	
		Local variantMapArray:=GetBodiesUserData(name)
		Local retStack:= New Stack<Float>
		For Local map:=Eachin variantMapArray
			If map.Contains(dataName)
				If map[dataName].Type.Name="Float"
					retStack.Add(Cast<Float>(map[dataName]))
				Elseif map[dataName].Type.Name="Int"
					retStack.Add(Float(Cast<Int>(map[dataName])))
				Else
					#If __DEBUG__
						Print "body-data "+dataName+" for body "+name+" Is Not a Float or Int !!!!!!!!!!!!!!!"
					#End
				End	
			End
		End
		If retStack.Length=0
			#If __DEBUG__
				Print "No body-data "+dataName+" for body with name "+name+" !!!!!!!!!!!!!!!"
			#End	
		End
		Return retStack
	End



	'--------------------Fixtures
	
	Method GetFixtures:b2Fixture[](name:String)
	
		Local retArray:b2Fixture[]
		Local fixtureStack:=New Stack<b2Fixture>
	
		For Local fixt:=Eachin fixtureInfos
			If fixt.name=name
				fixtureStack.Add(fixt.fixture)
			End
		End
		If fixtureStack.Length>0
			retArray=fixtureStack.ToArray()
		Else
		#If __DEBUG__
			Print "No fixture with name "+name+" !!!!!!!!!!!!!!!"
		#End
			Return Null
		End
		Return retArray
	
	End
	
	Method GetFixture:b2Fixture(name:String)

		For Local fixt:=Eachin fixtureInfos
			If fixt.name=name Then Return fixt.fixture
		Next
	
		#If __DEBUG__
			Print "No fixture with name "+name+" !!!!!!!!!!!!!!!"
		#End
	
		Return Null
	
	End
	
	Method GetJointsInfo:b2JointInfo[](name:String)
	
		Local retArray:b2JointInfo[]
		Local jointStack:=New Stack<b2JointInfo>
		For Local jo:=Eachin jointInfos
			If jo.jointName=name
				jointStack.Add(jo)
				'Print "Added"
			End
		End
		If jointStack.Length>0
			retArray=jointStack.ToArray()
		Else
		#If __DEBUG__
			Print "No joint with name "+name+" !!!!!!!!!!!!!!!"
		#End
			Return Null
		End
		Return retArray
	
	End
	
	Method GetJoints:b2Joint[](name:String)
		
		Local infArr:=GetJointsInfo(name)
		If infArr<>Null
			If infArr.Length>0
				Local ret:=New b2Joint[infArr.Length]
				For Local i:=0 Until infArr.Length
					ret[i]=infArr[i].theb2Joint
				Next
				Return ret
			End
		End
		
		Return Null
		
	End
	
	Method GetJointInfo:b2JointInfo(name:String)

		For Local jo:=Eachin jointInfos
			If jo.jointName=name
				Return jo
			End
			
		Next
	
		#If __DEBUG__
			Print "No joint with name "+name+" !!!!!!!!!!!!!!!"
		#End
		
		Return Null
	
	End
	
	Method GetJoint:b2Joint(name:String)
		
		Local info:=GetJointInfo(name)
		
		Return info?.theb2Joint
		
	End
	
	
	

	
	Method ToPhysics:b2Vec2(Location:Vec2f)

		Return debugDrawer.ToPhysicsLocation(Location)
		
	End
	
	Method FromPhysics:Vec2f(physLocation:b2Vec2)
		
		Return debugDrawer.FromPhysicsLocation(physLocation)
		
	End
	
	Method Save(path:String,humanReadable:Bool=False)
		'getting the type of vec2f for variant check
		Local someVector:=New Vec2f (0,0)
		Local variantVector:Variant=someVector
		
		
		Local json:b2dJson=New b2dJson(humanReadable)
		
		For Local i:=0 Until bodyInfos.Length
			If bodyInfos[i].bodyName<>"" Then json.setBodyName(bodyInfos[i].body, bodyInfos[i].bodyName)
			If bodyInfos[i].bodyUserData<>Null
				For Local node:=Eachin bodyInfos[i].bodyUserData
					If node.Key<>"b2ManagerBodyInfo"
						If node.Value.Type.Name="Int"
							json.addCustomInt(bodyInfos[i].body,node.Key,Cast <Int>(node.Value))
						Elseif node.Value.Type.Name="Float"
							json.addCustomFloat(bodyInfos[i].body,node.Key,Cast <Float>(node.Value))
						Elseif node.Value.Type.Name="Bool"
							json.addCustomBool(bodyInfos[i].body,node.Key,Cast <Bool>(node.Value))
						Elseif node.Value.Type.Name="String"
							json.addCustomString(bodyInfos[i].body,node.Key,Cast <String>(node.Value))
						Elseif node.Value.Type=variantVector.Type
							json.addCustomVector(bodyInfos[i].body,node.Key,Cast <Vec2f>(node.Value))
						Else
							#If __DEBUG__
								Print "The custom value "+node.Key+" of type: "+node.Value.Type.Name+" has an unsupported type for Saving (and loading)!!!!!"
							#End
						End	
					End
				Next
			End
		Next
		For Local fixInfo:=Eachin fixtureInfos
			json.setFixtureName(fixInfo.fixture,fixInfo.name)
			If fixInfo.fixtureUserData<>Null
				For Local node:=Eachin fixInfo.fixtureUserData
					If node.Key<>"b2ManagerFixtureInfo"
						If node.Value.Type.Name="Int"
							json.addCustomInt(fixInfo.fixture,node.Key,Cast <Int>(node.Value))
						Elseif node.Value.Type.Name="Float"
							json.addCustomFloat(fixInfo.fixture,node.Key,Cast <Float>(node.Value))
						Elseif node.Value.Type.Name="Bool"
							json.addCustomBool(fixInfo.fixture,node.Key,Cast <Bool>(node.Value))
						Elseif node.Value.Type.Name="String"
							json.addCustomString(fixInfo.fixture,node.Key,Cast <String>(node.Value))
						Elseif node.Value.Type=variantVector.Type
							json.addCustomVector(fixInfo.fixture,node.Key,Cast <Vec2f>(node.Value))
						Else
							#If __DEBUG__
								Print "The custom value "+node.Key+" of type: "+node.Value.Type.Name+" has an unsupported type for Saving (and loading)!!!!!"
							#End
						End	
					End
				Next
			End
		Next
		
		For Local joInfo:=Eachin jointInfos
			json.setJointName(joInfo.theb2Joint,joInfo.jointName)
			If joInfo.jointUserData<>Null
				For Local node:=Eachin joInfo.jointUserData
					If node.Key<>"b2ManagerJointInfo"
						If node.Value.Type.Name="Int"
							json.addCustomInt(joInfo.theb2Joint,node.Key,Cast <Int>(node.Value))
						Elseif node.Value.Type.Name="Float"
							json.addCustomFloat(joInfo.theb2Joint,node.Key,Cast <Float>(node.Value))
						Elseif node.Value.Type.Name="Bool"
							json.addCustomBool(joInfo.theb2Joint,node.Key,Cast <Bool>(node.Value))
						Elseif node.Value.Type.Name="String"
							json.addCustomString(joInfo.theb2Joint,node.Key,Cast <String>(node.Value))
						Elseif node.Value.Type=variantVector.Type
							json.addCustomVector(joInfo.theb2Joint,node.Key,Cast <Vec2f>(node.Value))
						Else
							#If __DEBUG__
								Print "The custom value "+node.Key+" of type: "+node.Value.Type.Name+" has an unsupported type for Saving (and loading)!!!!!"
							#End
						End	
					End
				Next
			End
		Next		
		
		
		'getting the size of the string and creating it with iforce2d-b2dJson
		Local strSize:=Getb2dJsonStringSize(world,json)
		Local jsonCStr:=New char_t[strSize+1]
		b2dJsonWriteToString_ext(jsonCStr.Data,world,json)
		
		'converting the b2djson to string then to mx2JsonObject
		Local tempJsonFullString:=String.FromCString(jsonCStr.Data)
		Local mainJsonObj:=JsonObject.Parse(tempJsonFullString)

		'create an object for images info
		Local imageJsonArray:=New JsonArray
		
		
		Local i:=0
		For Local bodyImageNode:=Eachin bodyImageMap
			
			Local ptiJsonObj:=New JsonObject
			
			ptiJsonObj["name"]=New JsonString(bodyInfos[bodyImageNode.Key].imageRubeName)':String
			
			ptiJsonObj["file"]=New JsonString(bodyInfos[bodyImageNode.Key].imageFileName.Replace("asset::",""))':String
			
			ptiJsonObj["angle"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageLocalAngle)':Float
			ptiJsonObj["aspectScale"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageAspectScale)':Float
			ptiJsonObj["scale"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageWorldHeight)':Float
			ptiJsonObj["renderOrder"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageRenderOrder)':Int

			ptiJsonObj["body"]=New JsonNumber(bodyInfos.Length-1-bodyInfos[bodyImageNode.Key].index)':Int Body reference has to be processed backwards compared to .json order (reliable?)
			ptiJsonObj["opacity"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageOpacity)

			If bodyInfos[bodyImageNode.Key].imageFlip=-1
				ptiJsonObj["flip"]=New JsonBool(True)
			End
			
			Local miniJsonObj:=New JsonObject
			miniJsonObj["x"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageLocalPosition.x)
			miniJsonObj["y"]=New JsonNumber(bodyInfos[bodyImageNode.Key].imageLocalPosition.y)
			ptiJsonObj["center"]=miniJsonObj
			
			imageJsonArray.Add(ptiJsonObj)
				
			i+=1
		Next
		
		'Print "-------------Print array"
		'Print imageJsonArray.ToJson()
		
		mainJsonObj["image"]=imageJsonArray
		
		SaveString(mainJsonObj.ToJson(),path,True)
		json.Destroy()
		
	End
	
	Method OnDiscard() Override
		If b2dJsonsCount>0
			For Local i:=0 Until b2dJsonsCount
				b2dJsons[i].Destroy()
			Next
		Endif
		world.Destroy()
		
	End
	
	Method OnFinalize() Override
		'Print "finalaïzing b2Manager"
	End
	
End


