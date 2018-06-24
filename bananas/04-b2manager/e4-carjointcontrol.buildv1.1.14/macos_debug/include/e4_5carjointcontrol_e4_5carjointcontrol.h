
#ifndef MX2_E4_5CARJOINTCONTROL_E4_5CARJOINTCONTROL_H
#define MX2_E4_5CARJOINTCONTROL_E4_5CARJOINTCONTROL_H

#include <bbmonkey.h>

#include "mojo/mojo.buildv1.1.14/macos_debug/include/mojo_app_2window.h"
#include "mojo/mojo.buildv1.1.14/macos_debug/include/mojo_graphics_2canvas.h"

BB_CLASS(t_box2dxt_b2Manager)
BB_STRUCT(t_std_geom_Vec2_1f)

BB_CLASS(t_default_Box2DgfxTest)
BB_CLASS(x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol)

extern bbInt g_default_w_0width;
extern bbInt g_default_w_0height;

void g_default_Canvas_SetCameraByCenter(t_mojo_graphics_Canvas* l_self,t_std_geom_Vec2_1f l_point,bbFloat l_zoom,bbFloat l_rotation,t_std_geom_Vec2_1f l_vr);
void bbMain();

struct t_default_Box2DgfxTest : public t_mojo_app_Window{
  typedef t_default_Box2DgfxTest *bb_object_type;

  bbTypeInfo *typeof()const;
  const char *typeName()const{return "t_default_Box2DgfxTest";}

  bbGCVar<t_box2dxt_b2Manager> m_physManager{};
  bbBool m_drawDebug{true};

  void gcMark();
  void dbEmit();

  t_default_Box2DgfxTest(bbString l_title,bbInt l_width,bbInt l_height,t_mojo_app_WindowFlags l_flags);
  ~t_default_Box2DgfxTest();

  void m_OnRender(t_mojo_graphics_Canvas* l_canvas);

  t_default_Box2DgfxTest(){
  }
};

struct x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol : public t_mojo_graphics_Canvas{
  typedef x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol *bb_object_type;

  bbTypeInfo *typeof()const;
  const char *typeName()const{return "x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol";}

  void dbEmit();

  ~x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol();

  x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol(){
  }
};

#endif
