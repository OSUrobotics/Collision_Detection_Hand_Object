function renderFromStructTree()
    global euler_list;
    global quat_list;
    global pos_list;
    global names_list;
    names_list = [];
    global matrices_int;
    matrices_list = [];
    matrices_int = 1;
    
    % Given Mujoco XML file, return struct of major components
    filename = "j2s7s300_end_effector_v1_sbox.xml";
    [handStruct,objStruct,meshStruct] = XMLtoStructSTL(filename);
    allStructs = {handStruct};
    numStructs = size(allStructs);
    numStructs = numStructs(2);
    %disp(numStructs);
    
    %figure;
    for n = 1:numStructs
        currStruct = allStructs{n};
        disp("MAIN currStruct.Attributes.name: ");
        disp(currStruct.Attributes.name);
        
        partTransform(currStruct, meshStruct);
        
        % If current struct has inner body, transform inner sections
        if isfield(currStruct,'body') == 1
            isLeaf = 0;
            %disp("HAS BODY: currStruct.Attributes.name: ");
            %disp(currStruct.Attributes.name);
            innerTransform(currStruct, meshStruct, isLeaf);
        else
            isLeaf = 1;
        end
    end
    get_list(meshStruct)
    disp("matrices_int: "+ matrices_int);
end

function innerTransform(currStruct, meshStruct, isLeaf)
    b = 0;
    numBodies = size(currStruct.body);
    numBodies = numBodies(2);
    
    while b < numBodies 
        b = b + 1;
        if numBodies > 1
            bodyStruct = currStruct.body{b};
        else
            bodyStruct = currStruct.body;
        end

        disp("INNER bodyStruct.Attributes.name: ");
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
    
    % Append the outter body transformation
    append_to_list(currStruct);
    
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
        %disp("numParts: "+numParts);
        if geomNum <= currStructGeoms
            if currStructGeoms > 0
              %disp("GEOM");
              if currStructGeoms > 1
                currPart = currStruct.geom{geomNum}; 
              else
                currPart = currStruct.geom;
              end
              geomNum = geomNum + 1;
            end
        else
            if currStructSites > 0
              %disp("SITE");
              if currStructSites > 1
                currPart = currStruct.site{siteNum}; 
              else
                currPart = currStruct.site;
              end
              siteNum = siteNum + 1;
            end
        end
        
        disp("PART currpart.Attributes.name: ");
        disp(currPart.Attributes.name);
        append_to_list(currPart);
        
    end

    % Uncomment to render model of full component part
    %axis equal
    %patch('Faces',partFaces,'Vertices',partVerts,'FaceColor','red');
end

function append_to_list(currStruct)
    global euler_list;
    global quat_list;
    global pos_list;
    global matrices_int;    
    global names_list;
    
    bodyEulM = [1 1 1];
    bodyQuatM = [1 1 1 1];
    bodyPosM = [0 0 0];

    disp("append to list, currStruct.Attributes.name: "+currStruct.Attributes.name);
        
    if isfield(currStruct.Attributes,'quat')
        bodyQuatM = currStruct.Attributes.quat;
        bodyQuatM = strsplit(bodyQuatM);
        bodyQuatM = str2double(bodyQuatM);
        disp("HELLO quat");
        disp(bodyQuatM);
    end
    
        % Euler rotation
    if isfield(currStruct.Attributes,'euler')
        bodyEulM = currStruct.Attributes.euler;
        bodyEulM = strsplit(bodyEulM);
        bodyEulM = str2double(bodyEulM);
        disp("HELLO Eul");
        disp(bodyEulM);
    end
    
    if isfield(currStruct.Attributes,'pos')
        bodyPosM = currStruct.Attributes.pos;
        bodyPosM = strsplit(bodyPosM);
        bodyPosM = str2double(bodyPosM);
        disp("HELLO Pos");
        disp(bodyPosM);
    end
    euler_list(matrices_int,:) = bodyEulM;
    quat_list(matrices_int,:) = bodyQuatM;
    pos_list(matrices_int,:) = bodyPosM;
    matrices_int = matrices_int + 1;
    
    disp(currStruct.Attributes.name);
    disp("EUL List is:");
    disp(euler_list);
    
    disp("QUAT List is:");
    disp(quat_list);
    
    disp("POS List is:");
    disp(pos_list);
    
    disp("BEFORE names_list: ");
    disp(names_list);
    name = string(currStruct.Attributes.name);
    if strcmp(name,"cylinder") == 1
        if isfield(currPart.Attributes,'size') == 1
            cyl_size = currPart.Attributes.size;
            cyl_size = strsplit(cyl_size);
            cyl_size = str2double(cyl_size);
            cyl_size = cyl_size(1);
            if cyl_size == 0.002
                name = name+"_002";
            elseif cyl_size == 0.005
                name = name+"_005";
            end
        end
    end
    names_list = [names_list, name];
    disp("AFTER names_list: ");
    disp(names_list);
    
    disp("NAMES List is:");
    name_num = size(names_list);
    name_num = name_num(2);
    for i = 1:name_num
        disp(names_list(i));
    end
end

% Return correct mesh filename from mesh name
function [meshFile] = getMesh(partMeshName,meshStruct)
    shapesFile = "shape_meshes/";
    handFile = "hand_meshes/";
    numMeshes = size(meshStruct);
    numMeshes = numMeshes(2);
    
    % Object - if type = mesh, euler, if type = geom, pos, euler
    if strcmp(partMeshName,"cylinder") == 0
        for i = 1:numMeshes
            meshName = meshStruct{i}.Attributes.name;
            meshDir = handFile;
            if strcmp(partMeshName,meshName) == 1
                if strcmp(currPart.Attributes.name,"object") == 1
                    meshDir = shapesFile;
                else
                    meshDir = handFile;
                end
                meshFile = meshDir + meshStruct{i}.Attributes.file;
            end
        end
    end
    if strcmp(partMeshName,"cylinder_002") == 1
       cylinder_file = "cylinder_002.stl";
        % Get correctly-sized cylinder
       meshFile = handFile + cylinder_file;
    end
    if strcmp(partMeshName,"cylinder_005") == 1
       cylinder_file = "cylinder_005.stl";
        % Get correctly-sized cylinder
       meshFile = handFile + cylinder_file;
    end
end

function finger_distal_transform(euler_list,quat_list,pos_list,palm_eulerM,palm_quatM,palm_posM,prox_idx,distal_idx,meshStruct)
    
    %body_idx, geom_idx, site1, site2
    dist_indexes = [distal_idx,distal_idx+1,distal_idx+2,distal_idx+3];
      
   prox_euler = euler_list(prox_idx);
   prox_eulerM = eul2rotm(prox_euler,'XYZ');

   prox_quat = quat_list(prox_idx);
   prox_quatM = quat2rotm(prox_quat);

   prox_pos = pos_list(i);
   prox_posM = makehgtform('translate',prox_pos); 
    
   dist_size = size(dist_indexes);
   dist_size = dist_size(2);
   
    for j=1:dist_size        
       i=dist_indexes(j);
       
       meshFile = getMesh(partMeshName,meshStruct);
       % Read mesh from stl file
       [objVerts, objFaces, objNormals, objName] = stlRead(meshFile);
       
       idv_euler = euler_list(i);
       eulM = eul2rotm(idv_euler,'XYZ');
       
       idv_quat = quat_list(i);
       quatM = quat2rotm(quatM);
       
       idv_pos = pos_list(i);
       posM = makehgtform('translate',idv_pos);    
        
       newVerts = palm_posM*palm_eulerM*palm_quatM*prox_posM*prox_eulerM*prox_quatM*posM*quatM*eulM*objVerts;
       
       axis equal
       patch('Faces',objFaces,'Vertices',newVerts,'FaceColor','red');
    end
end

function get_list(meshStruct)
    global euler_list;
    global quat_list;
    global pos_list;
    global matrices_int;
    
    palm_idx = 1;
    
   palm_euler = euler_list(palm_idx);
   palmEulM = eul2rotm(palm_euler,'XYZ');

   palm_quat = quat_list(palm_idx);
   palmQuatM = quat2rotm(palm_quat);

   palm_pos = pos_list(palm_pos);
   palmPosM = makehgtform('translate',palm_pos); 
   
   
   finger_distal_transform(euler_list,quat_list,pos_list,palm_eulerM,palm_quatM,palm_posM,prox_idx,distal_idx,meshStruct);

    % Get the palm transforms
    %palm_list = [];
    %for k = 1:numParts
    %   palm_euler = [euler_list, pos_list(k)];  
    %end
    
end

