function renderFromStructTree()
    global matrices_list
    global matrices_int
    global num_i 
    matrices_list = []
    matrices_int = 1
    num_i = 1
    
    % Given Mujoco XML file, return struct of major components
    filename = "j2s7s300_end_effector_v1_sbox.xml";
    [handStruct,objStruct,meshStruct] = XMLtoStructSTL(filename);
    allStructs = {handStruct};
    numStructs = size(allStructs);
    numStructs = numStructs(2);
    disp(numStructs);
    
    figure;
    for n = 1:numStructs
        currStruct = allStructs{n};
        disp("currStruct.Attributes.name: ");
        disp(currStruct.Attributes.name);
        
        % If current struct has inner body, transform inner sections
        if isfield(currStruct,'body') == 1
            isLeaf = 0;
            disp("HAS BODY: currStruct.Attributes.name: ");
            disp(currStruct.Attributes.name);
            innerTransform(currStruct, meshStruct, isLeaf);
        else
            partTransform(currStruct, meshStruct);
            isLeaf = 1;
        end
    end
    
end


% Return correct mesh filename from mesh struct
function [meshFile] = getMesh(currPart,meshStruct,numMeshes,shapesFile,handFile)
    % Object - if type = mesh, euler, if type = geom, pos, euler
    if strcmp(currPart.Attributes.type,"mesh") == 1
        objMeshName = currPart.Attributes.mesh;
        for i = 1:numMeshes
            meshName = meshStruct{i}.Attributes.name;
            meshDir = handFile;
            if strcmp(objMeshName,meshName) == 1
                if strcmp(currPart.Attributes.name,"object") == 1
                    meshDir = shapesFile;
                else
                    meshDir = handFile;
                end
                meshFile = meshDir + meshStruct{i}.Attributes.file;
            end
        end
    end
    if strcmp(currPart.Attributes.type,"cylinder") == 1
       cylinder_file = "cylinder.stl";
        % Get correctly-sized cylinder
        if isfield(currPart.Attributes,'size') == 1
            cyl_size = currPart.Attributes.size;
            cyl_size = strsplit(cyl_size);
            cyl_size = str2double(cyl_size);
            cyl_size = cyl_size(1);

            if cyl_size == 0.002
                cylinder_file = "cylinder_002.stl";
            elseif cyl_size == 0.005
                cylinder_file = "cylinder_005.stl";
            end
        end
       meshFile = handFile + cylinder_file;
    end
end

function innerTransform(currStruct, meshStruct, isLeaf)
    b = 0;
    numBodies = size(currStruct.body);
    numBodies = numBodies(2);
    
    while isLeaf == 0 && b < numBodies 
        b = b + 1;
        if numBodies > 1
            bodyStruct = currStruct.body{b};
        else
            bodyStruct = currStruct.body;
        end

        disp("**bodyStruct.Attributes.name: ");
        disp(bodyStruct.Attributes.name);
        partTransform(bodyStruct, meshStruct);
        
        % Traverse and transform inner parts until leaf node
        if isfield(bodyStruct,'body') == 1
            isLeaf = 0;
            innerTransform(bodyStruct, meshStruct, isLeaf)
        else
           isLeaf = 1; 
        end
    end
end

function partTransform(currStruct, meshStruct)
    numMeshes = size(meshStruct);
    numMeshes = numMeshes(2);
    meshFile = '';
    shapesFile = "shape_meshes/";
    handFile = "hand_meshes/";
    geomNum = 1;
    siteNum = 1;
    currPart = 0;
    global num_i;
    
    % Hold number of geoms and sites within current body
    currStructGeoms = 0;
    currStructSites = 0;

    if isfield(currStruct,'geom') == 1
        num = size(currStruct.geom);
        currStructGeoms = num(2);
    end

    if isfield(currStruct,'site') == 1
        num = size(currStruct.site);
        currStructSites = num(2);
    end
    
    % Total meshes/objects within component part body
    numParts = currStructGeoms + currStructSites;
    partVerts = [];
    partFaces = [];
    
    for k = 1:numParts
        disp("numParts: "+numParts);
        if geomNum <= currStructGeoms
            if currStructGeoms > 0
              disp("GEOM");
              if currStructGeoms > 1
                currPart = currStruct.geom{geomNum}; 
              else
                currPart = currStruct.geom;
              end
              geomNum = geomNum + 1;
            end
        else
            if currStructSites > 0
              disp("SITE");
              if currStructSites > 1
                currPart = currStruct.site{siteNum}; 
              else
                currPart = currStruct.site;
              end
              siteNum = siteNum + 1;
            end
        end
        
        disp("currpart.Attributes.name: ");
        disp(currPart.Attributes.name);
        append_to_list(currPart);
        
        % Return correct mesh filename
        meshFile = getMesh(currPart,meshStruct,numMeshes,shapesFile,handFile);

        % Read mesh from stl file
        [objVerts, objFaces, objNormals, objName] = stlRead(meshFile);
        disp("number is:");
        disp(num_i);
        objVerts = try_transform(currStruct, objVerts, objFaces, num_i);
        num_i = num_i + 1;
        
        partVerts = cat(1, partVerts, objVerts);
        partFaces = cat(1, partFaces, objFaces);
        disp("size of finalVerts: "+size(partVerts));
        
    end

    % Uncomment to render model of full component part
    axis equal
    patch('Faces',partFaces,'Vertices',partVerts,'FaceColor','red');
end

function append_to_list(currStruct)
    global matrices_list
    global matrices_int    

    bodyEulM = [1 1 1];
    outterQuatM = [1 1 1];


    if isfield(currStruct.Attributes,'quat')
        outterQuatM = currStruct.Attributes.quat;
        outterQuatM = strsplit(outterQuatM);
        outterQuatM = str2double(outterQuatM);
        disp("HELLO");
        disp(outterQuatM);
    end
    
        % Euler rotation
    if isfield(currStruct.Attributes,'euler')
        bodyEulM = currStruct.Attributes.euler;
        bodyEulM = strsplit(bodyEulM);
        bodyEulM = str2double(bodyEulM);
        disp("HELLO");
        disp(bodyEulM);
    end
    matrices_list(matrices_int,:) = bodyEulM;
    matrices_int = matrices_int + 1;
    disp("List is:");
    disp(currStruct.Attributes.name);
    disp(matrices_list);
end

function [objVerts] = try_transform(currStruct, objVerts, objFaces, num_i)
    disp(currStruct.Attributes);

    %M = 0
    f3_dist_1_rot = [1.57 3.14 1.57];
    f3_dist_1_pos = [0.02 0 0];
    
    f3_dist_cyl_rot = [1.57 3.14 1.5];
    f3_dist_cyl_pos = [0.03 0 0];
    
    finger_tip_3 = [0.044 -0.003 0];
    
    f3_prox_1_rot = [1.57 3.14 1.57];
    f3_prox_1_pos = [0.02 0 0];
    
    f3_prox_cyl_rot = [1.57 3.14 1.57];
    f3_prox_cyl_pos = [0.03 0 0];
    
    finger_3_rot = [0.601679 -0.254671 0.659653 -0.37146]; %quat
    finger_3_pos = [-0.02226 -0.02707 -0.11482];
    
    link_7_rot = [-1.57 0 -1.57];
    link_7_pos = [0.0 0.18 0.0654];
    
    f3_dist_1_rot = eul2rotm(f3_dist_1_rot, 'XYZ');
    f3_dist_1_rot(end+1,4) = 1;

    f3_dist_cyl_rot = eul2rotm(f3_dist_cyl_rot, 'XYZ');
    f3_dist_cyl_rot(end+1,4) = 1;

    f3_prox_1_rot = eul2rotm(f3_prox_1_rot, 'XYZ');
    f3_prox_1_rot(end+1,4) = 1;
    
    f3_prox_cyl_rot = eul2rotm(f3_prox_cyl_rot, 'XYZ');
    f3_prox_cyl_rot(end+1,4) = 1;    
    
    finger_3_rot = quat2rotm(finger_3_rot);
    finger_3_rot(end+1,4) = 1;

    link_7_rot = eul2rotm(link_7_rot, 'XYZ');
    link_7_rot(end+1,4) = 1;
    
    
    f3_dist_1_pos = makehgtform('translate',f3_dist_1_pos);
    f3_dist_cyl_pos = makehgtform('translate',f3_dist_cyl_pos);
    finger_tip_3 = makehgtform('translate',finger_tip_3);
    f3_prox_1_pos = makehgtform('translate',f3_prox_1_pos);
    f3_prox_cyl_pos = makehgtform('translate',f3_prox_cyl_pos);
    finger_3_pos = makehgtform('translate',finger_3_pos);
    link_7_pos = makehgtform('translate',link_7_pos);
    
    %if(num_i==1)
       % M = link_7_rot*link_7_pos;
       % disp("Vertices are:");
       % verts = objVerts;
       % verts(:,4)  = 1;
       % verts = verts';
        %disp(verts);
       % verts = M*verts;
       % verts = verts';
       % disp(size(verts));
       % objVerts = verts(:, 1:3);    
    if (num_i==13)
        M = finger_3_rot*finger_3_pos*link_7_rot*link_7_pos;
        disp("Vertices are:");
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        %disp(verts);
        verts = M*verts;
        verts = verts';
        disp(size(verts));
        objVerts = verts(:, 1:3);
    
    elseif (num_i==14)
        M = f3_prox_cyl_rot*f3_prox_cyl_pos*finger_3_rot*finger_3_pos*link_7_rot*link_7_pos;
        disp("Vertices are:");
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        %disp(verts);
        verts = M*verts;
        verts = verts';
        disp(size(verts));
        objVerts = verts(:, 1:3);
    
    elseif (num_i==15)
        M = f3_prox_1_rot*f3_prox_1_pos*finger_3_rot*finger_3_pos*link_7_rot*link_7_pos;
        disp("Vertices are:");
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        %disp(verts);
        verts = M*verts;
        verts = verts';
        disp(size(verts));
        objVerts = verts(:, 1:3);
    
    elseif (num_i==16)        
        M = finger_tip_3*finger_3_rot*finger_3_pos*link_7_rot*link_7_pos;
        disp("Vertices are:");
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        %disp(verts);
        verts = M*verts;
        verts = verts';
        disp(size(verts));
        objVerts = verts(:, 1:3);
    
    elseif (num_i==17)        
        M = f3_dist_cyl_rot*f3_dist_cyl_pos*finger_tip_3*finger_3_rot*finger_3_pos*link_7_rot*link_7_pos;
        disp("Vertices are:");
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        %disp(verts);
        verts = M*verts;
        verts = verts';
        disp(size(verts));
        objVerts = verts(:, 1:3);
    
    elseif (num_i==18)
        M = f3_dist_1_rot*f3_dist_1_pos*finger_tip_3*finger_3_rot*finger_3_pos*link_7_rot*link_7_pos;
        disp("Vertices are:");
        verts = objVerts;
        verts(:,4)  = 1;
        verts = verts';
        %disp(verts);
        verts = M*verts;
        verts = verts';
        disp(size(verts));
        objVerts = verts(:, 1:3);
        

        
    else
        objVerts(:,3) = 0;
    end
    
    
    
    %disp("Vertices are:");
    %verts = objVerts;
    %verts(:,4)  = 1;
    %verts = verts';
    %disp(verts);
    %verts = M*verts;
    %verts = verts';
    %disp(size(verts));
    %objVerts = verts(:, 1:3);
    %disp(objVerts);
    
    %axis equal
    %patch('Faces',objFaces,'Vertices',objVerts,'FaceColor','red');
    
end


