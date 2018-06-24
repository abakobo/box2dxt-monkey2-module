
#include "e4-carjointcontrol.buildv1.1.14/macos_debug/include/e4_5carjointcontrol_e4_5carjointcontrol.h"

#include "box2d/box2d.buildv1.1.14/macos_debug/include/box2d_box2d.h"
#include "box2d/box2d.buildv1.1.14/macos_debug/include/box2d_mx2_0box2d_2b2joints.h"
#include "box2dxt/box2dxt.buildv1.1.14/macos_debug/include/box2dxt_mx2_0box2d_2b2dJsonJoint.h"
#include "box2dxt/box2dxt.buildv1.1.14/macos_debug/include/box2dxt_mx2_0box2d_2b2manager.h"
#include "mojo/mojo.buildv1.1.14/macos_debug/include/mojo_app_2app.h"
#include "mojo/mojo.buildv1.1.14/macos_debug/include/mojo_input_2keyboard.h"
#include "std/std.buildv1.1.14/macos_debug/include/std_geom_2rect.h"
#include "std/std.buildv1.1.14/macos_debug/include/std_geom_2vec2.h"
#include "std/std.buildv1.1.14/macos_debug/include/std_graphics_2color.h"

BB_ENUM(t_mojo_input_Key)

bbInt g_default_w_0width;
bbInt g_default_w_0height;

void g_default_Canvas_SetCameraByCenter(t_mojo_graphics_Canvas* l_self,t_std_geom_Vec2_1f l_point,bbFloat l_zoom,bbFloat l_rotation,t_std_geom_Vec2_1f l_vr){
  bbDBFrame db_f{"SetCameraByCenter:Void(point:std.geom.Vec2f,zoom:monkey.types.Float,rotation:monkey.types.Float,vr:std.geom.Vec2f)","/Users/koko/Desktop/bananas/04-b2manager/e4-carjointcontrol.monkey2"};
  t_mojo_graphics_Canvas*self=l_self;
  bbDBLocal("Self",&self);
  bbDBLocal("point",&l_point);
  bbDBLocal("zoom",&l_zoom);
  bbDBLocal("rotation",&l_rotation);
  bbDBLocal("vr",&l_vr);
  bbDBStmt(303106);
  l_self->m_Translate(bbFloat((l_self->m_Viewport().m_Width()/2)),bbFloat((l_self->m_Viewport().m_Height()/2)));
  bbDBStmt(307202);
  l_self->m_Scale(l_zoom,l_zoom);
  bbDBStmt(311298);
  l_self->m_Rotate(l_rotation);
  bbDBStmt(315394);
  l_self->m_Translate(l_point.m__sub());
}

void bbMain(){
  static bool done;
  if(done) return;
  done=true;
  void mx2_monkey_main();mx2_monkey_main();
  void mx2_box2dxt_main();mx2_box2dxt_main();
  void mx2_e4_5carjointcontrol_e4_5carjointcontrol_init_f();mx2_e4_5carjointcontrol_e4_5carjointcontrol_init_f();
  struct f0_t : public bbGCFrame{
    t_mojo_app_AppInstance* t0{};
    void gcMark(){
      bbGCMark(t0);
    }
  }f0{};
  bbDBFrame db_f{"Main:Void()","/Users/koko/Desktop/bananas/04-b2manager/e4-carjointcontrol.monkey2"};
  bbDBStmt(266241);
  bbGCNew<t_mojo_app_AppInstance>();
  bbDBStmt(270337);
  bbGCNew<t_default_Box2DgfxTest>(bbString(L"Box2D_test",10),g_default_w_0width,g_default_w_0height,t_mojo_app_WindowFlags(8));
  bbDBStmt(274433);
  (f0.t0=g_mojo_app_App.get())->m_Run();
}

void t_default_Box2DgfxTest::gcMark(){
  t_mojo_app_Window::gcMark();
  bbGCMark(m_physManager);
}

void t_default_Box2DgfxTest::dbEmit(){
  t_mojo_app_Window::dbEmit();
  puts( "[default.Box2DgfxTest]");
  bbDBEmit("physManager",&m_physManager);
  bbDBEmit("drawDebug",&m_drawDebug);
}

t_default_Box2DgfxTest::t_default_Box2DgfxTest(bbString l_title,bbInt l_width,bbInt l_height,t_mojo_app_WindowFlags l_flags):t_mojo_app_Window(l_title,l_width,l_height,l_flags){
  bbDBFrame db_f{"new:Void(title:monkey.types.String,width:monkey.types.Int,height:monkey.types.Int,flags:mojo.app.WindowFlags)","/Users/koko/Desktop/bananas/04-b2manager/e4-carjointcontrol.monkey2"};
  t_default_Box2DgfxTest*self=this;
  bbDBLocal("Self",&self);
  bbDBLocal("title",&l_title);
  bbDBLocal("width",&l_width);
  bbDBLocal("height",&l_height);
  bbDBLocal("flags",&l_flags);
  bbDBStmt(98306);
  this->m_ClearColor(g_std_graphics_Color_Black);
  bbDBStmt(106498);
  this->m_physManager=bbGCNew<t_box2dxt_b2Manager>(bbString(L"asset::images.json",18),15.0f,true,b2Vec2{0.0f,0.0f});
}
t_default_Box2DgfxTest::~t_default_Box2DgfxTest(){
}

void t_default_Box2DgfxTest::m_OnRender(t_mojo_graphics_Canvas* l_canvas){
  struct f0_t : public bbGCFrame{
    t_box2dxt_b2JointInfo* l_frontWheelJoint{};
    t_mojo_app_AppInstance* t0{};
    t_box2dxt_b2Manager* t1{};
    t_box2dxt_b2Manager* t2{};
    void gcMark(){
      bbGCMark(l_frontWheelJoint);
      bbGCMark(t0);
      bbGCMark(t1);
      bbGCMark(t2);
    }
  }f0{};
  bbDBFrame db_f{"OnRender:Void(canvas:mojo.graphics.Canvas)","/Users/koko/Desktop/bananas/04-b2manager/e4-carjointcontrol.monkey2"};
  t_default_Box2DgfxTest*self=this;
  bbDBLocal("Self",&self);
  bbDBLocal("canvas",&l_canvas);
  bbDBStmt(131074);
  (f0.t0=g_mojo_app_App.get())->m_RequestRender();
  bbDBStmt(139266);
  l_canvas->m_PushMatrix();
  bbDBStmt(147458);
  g_default_Canvas_SetCameraByCenter(l_canvas,(f0.t1=this->m_physManager.get())->m_FromPhysics((f0.t2=this->m_physManager.get())->m_GetBody(bbString(L"car",3))->GetPosition()),1.7f,0.0f,t_std_geom_Vec2_1f{0.0f,0.0f});
  bbDBStmt(151554);
  (f0.t1=this->m_physManager.get())->m_StepWorld();
  bbDBStmt(155650);
  (f0.t1=this->m_physManager.get())->m_DrawDebug(l_canvas);
  bbDBStmt(159746);
  (f0.t1=this->m_physManager.get())->m_DrawBodies(l_canvas);
  bbDBStmt(163842);
  l_canvas->m_PopMatrix();
  bbDBStmt(172034);
  l_canvas->m_DrawText(bbString(L"Use up/down arrows to move the car",34),5.0f,35.0f,0.0f,0.0f);
  bbDBStmt(200712);
  bbFloat l_MSpeed=0.0f;
  bbDBLocal("MSpeed",&l_MSpeed);
  bbDBStmt(204802);
  if(g_mojo_input_Keyboard.get()->m_KeyDown(t_mojo_input_Key(210))){
    bbDBBlock db_blk;
    bbDBStmt(208899);
    l_MSpeed=-3.0f;
  }
  bbDBStmt(217090);
  if(g_mojo_input_Keyboard.get()->m_KeyDown(t_mojo_input_Key(209))){
    bbDBBlock db_blk;
    bbDBStmt(221187);
    l_MSpeed=1.0f;
  }
  bbDBStmt(233480);
  f0.l_frontWheelJoint=(f0.t1=this->m_physManager.get())->m_GetJointInfo(bbString(L"frontwheel",10));
  bbDBLocal("frontWheelJoint",&f0.l_frontWheelJoint);
  bbDBStmt(237570);
  b2JointTob2WheelJoint(f0.l_frontWheelJoint->m_theb2Joint)->SetMotorSpeed(l_MSpeed);
}
bbString bbDBType(t_default_Box2DgfxTest**){
  return "default.Box2DgfxTest";
}
bbString bbDBValue(t_default_Box2DgfxTest**p){
  return bbDBObjectValue(*p);
}

void x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::dbEmit(){
  t_mojo_graphics_Canvas::dbEmit();
  puts( "[default.Canvas]");
}
x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::~x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol(){
}
bbString bbDBType(x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol**){
  return "default.Canvas";
}
bbString bbDBValue(x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol**p){
  return bbDBObjectValue(*p);
}

void mx2_e4_5carjointcontrol_e4_5carjointcontrol_init_f(){
  g_default_w_0width=1000;
  g_default_w_0height=700;
}
