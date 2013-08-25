//
//  Surface.cpp
//  GLKit_test
//
//  Created by JuHeQi on 13-8-18.
//  Copyright (c) 2013年 JU Heqi. All rights reserved.
//

#include "Surface.h"
#include <algorithm>


ivec2 operator-(const ivec2& lhs, const ivec2& rhs)
{
    return std::make_pair(lhs.first - rhs.first, lhs.first - rhs.first);
}

void ParametricSurface::SetInterval(const ParametricInterval& interval)
{
    m_divisions = interval.Divisions;
    m_upperBound = interval.UpperBound;
    m_textureCount = interval.TextureCount;
    m_slices = m_divisions - ivec2(1, 1);
}

int ParametricSurface::GetVertexCount() const
{
    return m_divisions.first * m_divisions.second;
}

int ParametricSurface::GetLineIndexCount() const
{
    return 4 * m_slices.first * m_slices.first;
}

int ParametricSurface::GetTriangleIndexCount() const
{
    return 6 * m_slices.first * m_slices.second;
}

vec2 ParametricSurface::ComputeDomain(float x, float y) const
{
    return GLKVector2Make(x * m_upperBound.x / m_slices.first, y * m_upperBound.y / m_slices.second);
}

void ParametricSurface::GenerateVertices(std::vector<float>& vertices,
                                         unsigned char flags) const
{
    int floatsPerVertex = 3;
    if (flags & VertexFlagsNormals)
        floatsPerVertex += 3;
    if (flags & VertexFlagsTexCoords)
        floatsPerVertex += 2;
    
    vertices.resize(GetVertexCount() * floatsPerVertex);
    float* attribute = &vertices[0];
    
    for (int j = 0; j < m_divisions.second; j++) {
        for (int i = 0; i < m_divisions.first; i++) {
            
            // Compute Position
            vec2 domain = ComputeDomain(i, j);
            vec3 range = Evaluate(domain);
            attribute = WriteTofloatArrayThenMoveNext(range, attribute);
            
            // Compute Normal
            if (flags & VertexFlagsNormals) {
                float s = i, t = j;
                
                // Nudge the point if the normal is indeterminate.
                if (i == 0) s += 0.01f;
                if (i == m_divisions.first - 1) s -= 0.01f;
                if (j == 0) t += 0.01f;
                if (j == m_divisions.second - 1) t -= 0.01f;
                
                // Compute the tangents and their cross product.
                vec3 p = Evaluate(ComputeDomain(s, t));
                vec3 u = GLKVector3Subtract(Evaluate(ComputeDomain(s + 0.01f, t)), p);
                vec3 v = GLKVector3Subtract(Evaluate(ComputeDomain(s, t + 0.01f)), p);
                vec3 normal = GLKVector3Normalize(GLKVector3CrossProduct(u, v));
                if (InvertNormal(domain))
                    normal = GLKVector3Negate(normal);
                attribute = WriteTofloatArrayThenMoveNext(normal, attribute);
            }
            
            // Compute Texture Coordinates
            if (flags & VertexFlagsTexCoords) {
                float s = m_textureCount.x * i / m_slices.first;
                float t = m_textureCount.y * j / m_slices.second;
                attribute = WriteTofloatArrayThenMoveNext(GLKVector2Make(s, t), attribute);
            }
        }
    }
}

void ParametricSurface::GenerateLineIndices(std::vector<unsigned int>& indices) const
{
    indices.resize(GetLineIndexCount());
    auto index = indices.begin();
    for (int j = 0, vertex = 0; j < m_slices.second; j++)
    {
        for (int i = 0; i < m_slices.first; i++)
        {
            int next = (i + 1) % m_divisions.first;
            *index++ = vertex + i;
            *index++ = vertex + next;
            *index++ = vertex + i;
            *index++ = vertex + i + m_divisions.first;
        }
        vertex += m_divisions.first;
    }
}

void ParametricSurface::GenerateTriangleIndices(std::vector<unsigned int>& indices) const
{
    indices.resize(GetTriangleIndexCount());
    auto index = indices.begin();
    for (int j = 0, vertex = 0; j < m_slices.second; j++) {
        for (int i = 0; i < m_slices.first; i++) {
            int next = (i + 1) % m_divisions.first;
            *index++ = vertex + i;
            *index++ = vertex + next;
            *index++ = vertex + i + m_divisions.first;
            *index++ = vertex + next;
            *index++ = vertex + next + m_divisions.first;
            *index++ = vertex + i + m_divisions.first;
        }
        vertex += m_divisions.first;
    }
}

////////////////////////////////////////////////
///
////////////////////////////////////////////////

std::vector<GLfloat> BoxDrawable::BoxData =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

BoxDrawable::BoxDrawable()
{
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, BoxData.size() * sizeof(GLfloat), &*BoxData.begin(), GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, getVertexStride(), 0);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, getVertexStride(),
                          (char*)(sizeof(GLfloat) * 3));
    
    _indexData = {0, 1, 2, 3, 4, 5};
    indexCount = _indexData.size();
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexData.size() * sizeof(GLuint), &*_indexData.begin(), GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
}

BoxDrawable::~BoxDrawable()
{
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
}

void BoxDrawable::draw() const
{
    glBindVertexArrayOES(vertexArray);
    //glDrawArrays(GL_TRIANGLES, 0, BoxData.size() * sizeof(GLfloat) / getVertexStride());
    
    glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_INT, 0);

}

unsigned int BoxDrawable::getVertexStride() const
{
    return sizeof(GLfloat) * 6;
}

//////////////////////////////////////////////////////////
SphereDrawable::SphereDrawable()
{
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    Sphere sphere(1.0f);
    sphere.GenerateVertices(_vertexData, VertexFlagsNormals);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _vertexData.size() * sizeof(float), &*_vertexData.begin(), GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, getVertexStride(), 0);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, getVertexStride(),
                          (char*)(sizeof(GLfloat) * 3));
    
    indexCount = sphere.GetTriangleIndexCount();
    _indexData.resize(indexCount);
    sphere.GenerateTriangleIndices(_indexData);
    
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexData.size() * sizeof(GLuint), &*_indexData.begin(), GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
    
}

SphereDrawable::~SphereDrawable()
{
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
}


void SphereDrawable::draw() const
{
    glBindVertexArrayOES(vertexArray);
    glDrawElements(GL_TRIANGLES, indexCount, GL_UNSIGNED_INT, 0);
}

unsigned int SphereDrawable::getVertexStride() const
{
    return sizeof(GLfloat) * 6;
}

