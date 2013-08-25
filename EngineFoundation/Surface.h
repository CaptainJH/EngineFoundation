//
//  Surface.h
//  GLKit_test
//
//  Created by JuHeQi on 13-8-18.
//  Copyright (c) 2013年 JU Heqi. All rights reserved.
//

#ifndef __GLKit_test__Surface__
#define __GLKit_test__Surface__

#include <iostream>
#import <GLKit/GLKit.h>
#import <vector>
#import <math.h>

typedef std::pair<int, int> ivec2;
typedef GLKVector2 vec2;
typedef GLKVector3 vec3;

template<class V>
float* WriteTofloatArrayThenMoveNext(V vec, float* dst)
{
    std::copy(std::begin(vec.v), std::end(vec.v), dst);
    return dst + sizeof(vec) / sizeof(float);
}

enum VertexFlags
{
    VertexFlagsNormals = 1 << 0,
    VertexFlagsTexCoords = 1 << 1,
};

struct ISurface
{
    virtual int GetVertexCount() const = 0;
    virtual int GetLineIndexCount() const = 0;
    virtual int GetTriangleIndexCount() const = 0;
    virtual void GenerateVertices(std::vector<float>& vertices,
                                  unsigned char flags = 0) const = 0;
    virtual void GenerateLineIndices(std::vector<unsigned int>& indices) const = 0;
    virtual void GenerateTriangleIndices(std::vector<unsigned int>& indices) const = 0;
    virtual ~ISurface() {}
};

struct ParametricInterval
{
    ivec2 Divisions;
    vec2 UpperBound;
    vec2 TextureCount;
};

class ParametricSurface : public ISurface
{
public:
    int GetVertexCount() const;
    int GetLineIndexCount() const;
    int GetTriangleIndexCount() const;
    void GenerateVertices(std::vector<float>& vertices, unsigned char flags) const;
    void GenerateLineIndices(std::vector<unsigned int>& indices) const;
    void GenerateTriangleIndices(std::vector<unsigned int>& indices) const;
protected:
    void SetInterval(const ParametricInterval& interval);
    virtual vec3 Evaluate(const vec2& domain) const = 0;
    virtual bool InvertNormal(const vec2& domain) const { return false; }
private:
    vec2 ComputeDomain(float i, float j) const;
    ivec2 m_slices;
    ivec2 m_divisions;
    vec2 m_upperBound;
	vec2 m_textureCount;
};

class Sphere : public ParametricSurface
{
public:
    Sphere(float radius) : m_radius(radius)
    {
        ParametricInterval interval = { ivec2(20, 20), GLKVector2Make(M_PI, 2 * M_PI), GLKVector2Make(20, 35) };
        SetInterval(interval);
    }
    vec3 Evaluate(const vec2& domain) const
    {
        float u = domain.x, v = domain.y;
        float x = m_radius * sin(u) * cos(v);
        float y = m_radius * cos(u);
        float z = m_radius * -sin(u) * sin(v);
        return GLKVector3Make(x, y, z);
    }
private:
    float m_radius;
};


struct Drawable
{
    GLuint vertexBuffer;
    GLuint vertexArray;
    GLuint indexBuffer;
    int indexCount;
    
    virtual void draw() const = 0;
    virtual ~Drawable(){}
    
    virtual unsigned int getVertexStride() const = 0;
};


class BoxDrawable : public Drawable
{
public:
    BoxDrawable();
    virtual ~BoxDrawable();
    
    virtual void draw() const;
    virtual unsigned int getVertexStride() const;
    
    std::vector<GLuint> _indexData;

    static std::vector<GLfloat> BoxData;
    
};

class SphereDrawable : public Drawable
{
public:
    SphereDrawable();
    virtual ~SphereDrawable();
    
    virtual void draw() const;
    virtual unsigned int getVertexStride() const;
    
    std::vector<GLuint> _indexData;
    std::vector<GLfloat> _vertexData;
};


#endif /* defined(__GLKit_test__Surface__) */
