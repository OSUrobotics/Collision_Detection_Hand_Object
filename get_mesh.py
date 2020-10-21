import numpy as np
from stl import mesh

verts = np.transpose(np.loadtxt("hello_VERTS.txt", delimiter=" ", unpack=True))
#print (verts.shape)
faces = np.transpose(np.loadtxt("hello_FACES.txt", delimiter=" ", unpack=True))
faces = faces.astype(int)
#print (faces.shape)
# Define the 8 vertices of the cube
'''vertices = np.array([\
    [-1, -1, -1],
    [+1, -1, -1],
    [+1, +1, -1],
    [-1, +1, -1],
    [-1.0, -1, +1],
    [+1, -1, +1],
    [+1, +1, +1],
    [-1, +1, +1]])
# Define the 12 triangles composing the cube
faces = np.array([\
    [0,3,1],
    [1,3,2],
    [0,4,7],
    [0,7,3],
    [4,5,6],
    [4,6,7],
    [5,1,2],
    [5,2,6],
    [2,3,6],
    [3,7,6],
    [0,1,5],
    [0,5,4]])
print (vertices.shape)
print (faces.shape)'''
cube = mesh.Mesh(np.zeros(faces.shape[0], dtype=mesh.Mesh.dtype))
for i, f in enumerate(faces):
    for j in range(3):
        cube.vectors[i][j] = verts[f[j],:]

# Write the mesh to file "cube.stl"
cube.save('hand_full.stl')