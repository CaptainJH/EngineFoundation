//
//  Shader.fsh
//  EngineFoundation
//
//  Created by JuHeQi on 13-8-25.
//  Copyright (c) 2013年 JU Heqi. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
