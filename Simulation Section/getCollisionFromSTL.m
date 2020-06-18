function [ amountCollide ] = getCollisionFromSTL(objVerts, objFaces, objectSurfPoints, objectSurfaceArea, resolution)
   % resolution = 25;
	%[objVerts, objFaces, objNormals, objName] = stlRead(objFilename);
    %objVerts = translateMesh( objVerts, directionVector, distanceTransform );
    %axis: [0,0,1], amount to translate: 0.02
    %stlwrite("new_CubeS.stl",[objFaces,verticesOut]);
    
    %disp("objFaces: ");
    %disp(objFaces);
    
	%objectVox = getVoxelisedVerts( objVerts, objFaces, resolution );
    
    %objectSurfPoints = read_ply(poissonFilename);
    %objectSurfaceArea = objSurfArea;
    
    [handVerts, handFaces, handNormals, handName] = stlRead("finger_distal.STL");
    handVox = getVoxelValues( handVerts,handFaces, resolution ); 
    
    % Default setting for getCollisionVoxelVoxel
    method = 'cubic';
    amountCollide = getCollisionVoxelVoxel( handVox, objectSurfPoints, objectSurfaceArea, resolution, method )%objectVox, 
    disp("You made it! :)")
    disp(amountCollide);
end