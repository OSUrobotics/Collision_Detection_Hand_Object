function renderFromStructTree()
    global matrices_list
    global matrices_int
    matrices_list = []
    matrices_int = 1
    
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
        
    end

    % Uncomment to render model of full component part
    %axis equal
    %patch('Faces',partFaces,'Vertices',partVerts,'FaceColor','red');
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

