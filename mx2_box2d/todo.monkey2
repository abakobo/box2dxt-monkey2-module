doing:
------



régler prob de lignes colinéaires cutpoly/poly


corriger cutsided avec cas particulers touchtouch:
			faire passer par Print "=In baseFalse"
			faire de petits cas particuliers pour checker

cleanStraight marche pas avec
Vec2(350,130)
Vec2(350,138.97597901025657)
Vec2(350,130.00000000000003) ?


todo:
-----

Cleaner Line2D puor que les methodes intersect segment aient les mêmes epsilon + Tester ça avec complex poly

mettre complex/concave/cut test dans box2dxt bananas

corriger cutpoly pour le bug qui donne un "flat" poly: (pour le moment corrigé par slean straigths mais ça serait bien que ça aille just direct!?)
	voir avec poly hole, le carré et
		knife.Add(New Vec2<Double>(290,100))
		knife.Add(New Vec2<Double>(240,50))
		knife.Add(New Vec2<Double>(170,50))
		knife.Add(New Vec2<Double>(180,150))
		knife.Add(New Vec2<Double>(350,150))
		knife.Add(New Vec2<Double>(350,130))
		knife.Add(New Vec2<Double>(280,140))
		knife.Add(New Vec2<Double>(290,100))

Modifier poly cut non sided pour qu'il marche avec intersecting knife sans créer de doubles
				--> le diviser en parties non intersect puis faire avec chanque parties? (ça risque quand même d'e^tre un peu durdur)

Creer fonction validatePoly (renvoye un polystack de ccw convex sans frichtis)
Créer fonction Validate polyStack

create ball
create edge
create Poly
create joint:
trouver les strings de chaque type de joint et ajouter le bon String ->> "revolute" "motor" ....
Et voir avec pulley et l autre qui est pas RUBE si ça sauve et lis bien 

vérifier que b2Shapes sont bien memory cleaned (Structs?)

optimiser les methodes de Line2D (segmentIntersectionPAB principalement)

voir pour message d'erreur qui a foiré avec b2Manager.GetBody(body pas enregistré dans b2Manager)

tester fixture.getname et joint.getName

tester createrevoluteJoint

faire createJoint tous types

faire destroy joint et fixture

Ajouter ImageHandle à AddImageToBody?

faire b2Manager.destroyFixture (et create?)
faire b2Manager.destroyJoint (et create?)

body/fixture/joint .SetName(String) Extension

checker que ça ce passe bien avec onDiscard/on Finalize et que la ressource b2Manager se fair bien GC (comprendre on finalize)

virer m_blah? ou ajouter getters et Setters pour les m_blah attributes qui sont des bbArray (direct dans box2d .h et . cpps)

AABB box pour dessiner que ce qui sera à l écran (debugdraw compris?)

PolycutNotSided?


TODO
-----
b2json:
--------

plusieurs images pour 1 body?


load/save world state (pas world custom properties?)

AABB box pour DDraw que ça dessine pas le bazar..  (mm chose pour pyro?, il le fait déjà?)

caster vers wrong joint type assert que Return nul alors que assert donc Return rien du tout! (enlever "Return null")

ajouter offset à b2Manager -> fait?
is addjson Completed? (yes?)

checker que imageWorldPosition fonctionne correc avec yAxisInvert=False  checker avec draw bodies aussi...
donc faire un exemple yaxisNonInversé avec images!

ajouter joints/fixtures getuserDataToX comme GetBodiesUserDataToX?
ajouter fixture.getname et joint.getName

is addjson Completed? (yes?)

cleanup the mess!:
	-virer b2djsonImage --> trop chiant tant pis
	-virer cpp fileio et bitmap render...
	
remplacer If debug prints par assert? Bof

trouver ce qui Print du vide dans e0-load_delete -->seulement en debug donc +-ok

load/save collision mask --> fonctionne tout seul avec b2dJson mais RUBE ne lit pas le nom des BitPlanes donc pas implémenté

----> ajouter un petit json avec les noms + mettre quand même les noms dans le json principal?


pyro:
--------


AABB box pour DDraw que ça dessine pas le bazar..  (mm chose pour pyro?, il le fait déjà?)

ajouter opacity et flip dans pyro2.CreatLayerSprites

ajouter offset à Extension camera.GetMatrix ???? playniax?

colision pyro entre 2 layers?

Isort pour exempl tank (et plus multi layers) + enlever les autres Functions de la foire(Create/Updateb2LayerSprites)  -->1/2

