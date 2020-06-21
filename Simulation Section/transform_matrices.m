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

function get_list()
    global euler_list;
    global quat_list;
    global pos_list;
    global matrices_int;
    
    % Get the palm transforms
    palm_list = [];
    for k = 1:numParts
       palm_euler = [euler_list, pos_list(k)];
       
    end
    
end

