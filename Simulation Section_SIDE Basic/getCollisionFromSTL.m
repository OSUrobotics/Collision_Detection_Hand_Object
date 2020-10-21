function [ amountCollide, handFaces, handVerts ] = getCollisionFromSTL(objVerts, objFaces, objectSurfPoints, objectSurfaceArea, resolution, hand_rot)
   % resolution = 25;
	%[objVerts, objFaces, objNormals, objName] = stlRead(objFilename);
    %objVerts = translateMesh( objVerts, directionVector, distanceTransform );
    %axis: [0,0,1], amount to translate: 0.02
    %stlwrite("new_CubeS.stl",[objFaces,verticesOut]);
    
    %disp("objFaces: ");
    %disp(objFaces);
    
% 	objectVox = getVoxelisedVerts( objVerts, objFaces, resolution );
%     disp(objectVox);
    %objectSurfPoints = read_ply(poissonFilename);
    %objectSurfaceArea = objSurfArea;
    
    [handVerts, handFaces, handNormals, handName] = stlRead("new_hand_full.stl");%"finger_distal.STL"
    
    new_rot = hand_rot; %[-pi/2  0.0  1.9408];
%     disp("OLD");
%     disp(new_rot);
    temp  =  new_rot(1);
    new_rot(1)  =  new_rot(2) - pi/2;
    new_rot(2) = -temp - 1.2;
    new_rot(3)  =  new_rot(3)  + 1.9408;
%     disp("NEW");
%     disp(new_rot);
    loc_origin = [-0.06545 0.06569 0.0218]; %LOCAL ORIGIN((Normal):[-0.01 -0.00654 0.0];
    new_pos_loc = [-0.00024876  0.0579915   0.14];%BIGTD-[0.00179862 0.00018602 0.13695397] MEDIUMTD-[0.00177011 0.00107267 0.12799779] SMALLTD-[0.00174161 0.00195927 0.11904207]
    
    new_pos =  (new_pos_loc - loc_origin);   %x-> new-org; y-> new - org; z-> new - org
    
    new_rot = eul2rotm(new_rot, 'XYZ');
%     disp(new_rot);
    new_rot(end+1,4) = 1;
    new_pos = makehgtform('translate',new_pos);
%     rot2 = [-pi/2  0.0  0.37];
%     
%     rot2 =  eul2rotm(rot2, 'XYZ');
%     rot2(end+1,4) =1;
    
    H = new_pos*new_rot;

    verts = handVerts;
    verts(:,4)  = 1;
    verts = verts';
    verts = H*verts;
    verts = verts';
    handVerts = verts(:, 1:3);
    
    handVox = getVoxelValues( handVerts,handFaces, resolution ); 
    % Default setting for getCollisionVoxelVoxel
    method = 'cubic';
%     disp("GOING IN");
    amountCollide = getCollisionVoxelVoxel( handVox, objectSurfPoints, objectSurfaceArea, resolution, method);%, objectVox);%, 
%     disp("GOING OUT");
    %     disp("SIZE PF OBJECTSURF");
%     disp(size(objectSurfPoints));
%     Verts = [handVerts; objectSurfPoints];
%     %extra = size(objectSurfPoints, 1);
%     Faces = handFaces;
%     %Faces(end + 1 : end+1+extra, :) = nan ;
%     axis equal
%     patch('Faces',Faces,'Vertices',Verts,'FaceColor','red');
    %disp("You made it! :)")
    %disp(amountCollide);
end