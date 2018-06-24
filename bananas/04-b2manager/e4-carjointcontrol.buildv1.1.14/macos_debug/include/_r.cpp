
#include <bbmonkey.h>
#include <bbtypeinfo_r.h>
#include <bbdeclinfo_r.h>

#include "_r.h"

#include "e4-carjointcontrol.buildv1.1.14/macos_debug/include/e4_5carjointcontrol_e4_5carjointcontrol.h"
#include "box2dxt/box2dxt.buildv1.1.14/macos_debug/include/box2dxt_mx2_0box2d_2b2manager.h"
#include "std/std.buildv1.1.14/macos_debug/include/std_geom_2vec2.h"

BB_CLASS(t_mojo_app_Window)
BB_ENUM(t_mojo_app_WindowFlags)
BB_CLASS(t_mojo_graphics_Canvas)

#if BB_R_default || BB_R_default__
static struct mx2_e4_5carjointcontrol_e4_5carjointcontrol_typeinfo : public bbClassDecls{
  mx2_e4_5carjointcontrol_e4_5carjointcontrol_typeinfo():bbClassDecls(bbClassTypeInfo::getNamespace("default")){
  }
  bbDeclInfo **initDecls(){
    return bbMembers(bbGlobalDecl("w_width",&g_default_w_0width),bbGlobalDecl("w_height",&g_default_w_0height),bbFunctionDecl<void>("Main",&bbMain));
  }
}_mx2_e4_5carjointcontrol_e4_5carjointcontrol_typeinfo;

struct rt_default_Box2DgfxTest : public bbClassTypeInfo{
  static rt_default_Box2DgfxTest instance;
  static struct decls_t : public bbClassDecls{
    decls_t():bbClassDecls(&instance){}
    bbDeclInfo **initDecls(){
      return bbMembers(bbCtorDecl<t_default_Box2DgfxTest,bbString,bbInt,bbInt,t_mojo_app_WindowFlags>(),bbFieldDecl("physManager",&t_default_Box2DgfxTest::m_physManager),bbFieldDecl("drawDebug",&t_default_Box2DgfxTest::m_drawDebug),bbMethodDecl<t_default_Box2DgfxTest,void,t_mojo_graphics_Canvas*>("OnRender",&t_default_Box2DgfxTest::m_OnRender));
    }
  }decls;
  rt_default_Box2DgfxTest():bbClassTypeInfo("default.Box2DgfxTest","Class"){
  }
  bbTypeInfo *superType(){
    return bbGetType<t_mojo_app_Window*>();
  }
  bbVariant nullValue(){
    return bbVariant((t_default_Box2DgfxTest*)0);
  }
  bbVariant newArray( int length ){
    return bbVariant(bbArray<bbGCVar<t_default_Box2DgfxTest>>(length));
  }
};
rt_default_Box2DgfxTest rt_default_Box2DgfxTest::instance;
rt_default_Box2DgfxTest::decls_t rt_default_Box2DgfxTest::decls;

bbTypeInfo *bbGetType(t_default_Box2DgfxTest*const&){
  return &rt_default_Box2DgfxTest::instance;
}
bbTypeInfo *t_default_Box2DgfxTest::typeof()const{
  return &rt_default_Box2DgfxTest::instance;
}

struct rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol : public bbClassTypeInfo{
  static rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol instance;
  static struct decls_t : public bbClassDecls{
    decls_t():bbClassDecls(&instance){}
    bbDeclInfo **initDecls(){
      return bbMembers(bbExtMethodDecl<t_mojo_graphics_Canvas,void,t_std_geom_Vec2_1f,bbFloat,bbFloat,t_std_geom_Vec2_1f>("SetCameraByCenter",&g_default_Canvas_SetCameraByCenter));
    }
  }decls;
  rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol():bbClassTypeInfo("default.Canvas Extension","Class Extension"){
  }
  bbTypeInfo *superType(){
    return bbGetType<t_mojo_graphics_Canvas*>();
  }
  bbVariant nullValue(){
    return bbVariant((x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol*)0);
  }
  bbVariant newArray( int length ){
    return bbVariant(bbArray<bbGCVar<x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol>>(length));
  }
};
rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::instance;
rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::decls_t rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::decls;

bbTypeInfo *bbGetType(x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol*const&){
  return &rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::instance;
}
bbTypeInfo *x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::typeof()const{
  return &rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::instance;
}
#else
static bbUnknownTypeInfo rt_default_Box2DgfxTest("default.Box2DgfxTest");
bbTypeInfo *bbGetType(t_default_Box2DgfxTest*const&){
  return &rt_default_Box2DgfxTest;
}
bbTypeInfo *t_default_Box2DgfxTest::typeof()const{
  return &rt_default_Box2DgfxTest;
}
static bbUnknownTypeInfo rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol("default.Canvas");
bbTypeInfo *bbGetType(x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol*const&){
  return &rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol;
}
bbTypeInfo *x_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol::typeof()const{
  return &rx_default_Canvas_e4_5carjointcontrol_e4_5carjointcontrol;
}
#endif