//
//  ViewController.m
//  OpenGL01
//
//  Created by tomxiang on 6/16/16.
//  Copyright © 2016 tomxiang. All rights reserved.
//

#import "ViewController.h"

typedef struct{
    GLKVector3 positionCoords;//三角形
}
SceneVertex;

//定义一个三角形
static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0}}, //左下的那个点
    {{ 0.5f, -0.5f, 0.0}}, //右下的那个点
    {{-0.5f,  0.5f, 0.0}}  //顶部的那个点
};

@interface ViewController ()

@property(nonatomic,assign) GLuint vertexBufferID; //保存了用于盛放本例中用到的顶点数据的缓存的OpenGL ES标识符
@property(nonatomic,strong) GLKBaseEffect *baseEffect; //提供了不依赖于所使用的OpenGL ES版本的控制OpenGL ES的渲染的方法

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Verify the type of view created automatically by the
    // Interface Builder storyboard
    GLKView *view = (GLKView*)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],@"View is not a GLKView");
    
    //kEAGLRenderingAPIOpenGLES2省略了很多特性和在上一个标准中定义的应用支持基础结构，2.0版本是执行为GPU专门定制的程序
    // Create an OpenGL ES 2.0 context and provide it to the
    // view
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // Make the new context current
    [EAGLContext setCurrentContext:view.context];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    // Shading Language programs and set constants to be used for
    // all subsequent rendering
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    //决定像素是不透明还是半透明,三角形的颜色
    self.baseEffect.constantColor = GLKVector4Make(
                                                   1.0f,    //red
                                                   0.0f,    //green
                                                   0.0f,    //blue
                                                   1.0f);   //Alpha
    
    // Set the background color stored in the current context,背景的颜色
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // background color
    
    // Generate, bind, and initialize contents of a buffer to be
    // stored in GPU memory
    glGenBuffers(1, &_vertexBufferID);                 // STEP 1.为缓存生成一个独一无二的标识符
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);    // STEP 2.为接下来的运算绑定缓存
    glBufferData(                  // STEP 3.复制数据到缓存中
                 GL_ARRAY_BUFFER,  // Initialize buffer contents 用于指定一个定点的属性数组,还有这种GL_ELEMENT_ARRAY_BUFFER类型
                 sizeof(vertices), // Number of bytes to copy
                 vertices,         // Address of bytes to copy
                 GL_STATIC_DRAW);  // Hint: cache in GPU memory 缓存的内容适合复制到GPU控制的内存，因为很少对其进行修改，帮助优化内存使用

}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    
    // Clear Frame Buffer (erase previous drawing)
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Enable use of positions from bound vertex buffer
    glEnableVertexAttribArray(GLKVertexAttribPosition); //STEP 4.启动
    
    glVertexAttribPointer(                              // STEP 5.设置指针
                          GLKVertexAttribPosition,  //当前绑定的缓存包含的每个顶点的位置信息
                          3,                   // three components per vertex 每个位置有三个部分
                          GL_FLOAT,            // data is floating point 每个部分都保存为一个浮点类型的值
                          GL_FALSE,            // no fixed point scaling 小数点固定数据是否可以被改变
                          sizeof(SceneVertex), // no gaps in data
                          NULL);               // NULL tells GPU to start at
                                               // beginning of bound buffer
    
    // Draw triangles using the first three vertices in the
    // currently bound vertex buffer
    glDrawArrays(GL_TRIANGLES,      // STEP 6.绘图
                 0,  // Start with first vertex in currently bound buffer
                 3); // Use three vertices from currently bound buffer
}

-(void)dealloc{
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    if (0 != _vertexBufferID)
    {
        glDeleteBuffers (1,          // STEP 7
                         &_vertexBufferID);
        self.vertexBufferID = 0;
    }
    
    // Stop using the context created in -viewDidLoad
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
