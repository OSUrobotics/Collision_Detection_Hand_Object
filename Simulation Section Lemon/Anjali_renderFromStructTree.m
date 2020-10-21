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
        
        % Set of vertices and faces used for collecting coords. in
        % PartTransform and InnerBodyTransform
        %finalVerts = [];
        %finalFaces = [];

        % Get outter translation
        %outterPos = strsplit(currStruct.Attributes.pos);
        %outterPos = str2double(outterPos);
        
        % Get outter body quaternion rotation as rotation matrix
        %if isfield(currStruct.Attributes,'quat')
        %    outterQuatM = currStruct.Attributes.quat;
        %    outterQuatM = strsplit(outterQuatM);
        %    outterQuatM = str2double(outterQuatM);
        %    outterQuatM = quat2rotm(outterQuatM);
        %else
        %    outterQuatM = 1;
        %end
                
        % Get outter body euler rotation as rotation matrix
        %if isfield(currStruct.Attributes,'euler')
        %    outterEulM = currStruct.Attributes.euler;
        %    outterEulM = strsplit(outterEulM);
        %    outterEulM = str2double(outterEulM);
        %    outterEulM = eul2rotm(outterEulM,'XYZ');
        %else
        %    outterEulM = 1;
        %end
        
        % If current struct has inner body, transform inner sections
        if isfield(currStruct,'body') == 1
            isLeaf = 0;
            disp("HAS BODY: currStruct.Attributes.name: ");
            disp(currStruct.Attributes.name);
            
            %[endVerts, endFaces] = innerTransform(currStruct, meshStruct, isLeaf);%, finalVerts, finalFaces);
            innerTransform(currStruct, meshStruct, isLeaf);
        else
            %[endVerts, endFaces] = partTransform(currStruct, meshStruct);
            partTransform(currStruct, meshStruct);
            isLeaf = 1;
        end
        
        % Apply outer transformation to all bodies at current level
        % Rotate outer quat transforms
        %endVerts = endVerts*outterQuatM;

        % Rotate outer euler transforms
        %endVerts = endVerts*outterEulM;

        % Translate from outer position
        %endVerts = endVerts+outterPos;
        
        % End faces and verticies is the full final set of coords. ready to
        % be written to stl file      
        % Uncomment to render endVerts
        %patch('Faces',endFaces,'Vertices',endVerts,'FaceColor','blue');
        %if n<numStructs, hold on, end
    end
end

% Apply quaternion rotation to vertices
function [objVerts] = quatTransform(currPart,objVerts)
    quatM = currPart.Attributes.quat;
    quatM = strsplit(quatM);
    quatM = str2double(quatM);
    rotMatrix = quat2rotm(quatM);
    objVerts = objVerts*rotMatrix;
end

% Apply euler rotation to vertices
function [objVerts] = eulTransform(currPart,objVerts)
    eulM = currPart.Attributes.euler;
    eulM = strsplit(eulM);
    eulM = str2double(eulM);
    rotMatrix = eul2rotm(eulM,'XYZ');
    objVerts = objVerts*rotMatrix;
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

% Transform inner bodies; call partTransform for each body part component
%function [finalVerts, finalFaces] = innerTransform(currStruct, meshStruct, isLeaf)%, finalVerts, finalFaces)
function innerTransform(currStruct, meshStruct, isLeaf)
    b = 0;
    numBodies = size(currStruct.body);
    numBodies = numBodies(2);

    % Get outter body quaternion rotation as rotation matrix
    %if isfield(currStruct.Attributes,'quat')
    %    outterQuatM = currStruct.Attributes.quat;
    %    outterQuatM = strsplit(outterQuatM);
    %    outterQuatM = str2double(outterQuatM);
    %    outterQuatM = quat2rotm(outterQuatM);
    %else
    %    outterQuatM = 1;
    %end

    % Get outter body euler rotation as rotation matrix
    %if isfield(currStruct.Attributes,'euler')
    %    outterEulM = currStruct.Attributes.euler;
    %    outterEulM = strsplit(outterEulM);
    %    outterEulM = str2double(outterEulM);
    %    outterEulM = eul2rotm(outterEulM,'XYZ');
    %else
    %    outterEulM = 1;
    %end
    
    % Get outter translation
    %outterPos = strsplit(currStruct.Attributes.pos);
    %outterPos = str2double(outterPos);

    % Transform and traverse each body at current level
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
        
        % Transform current component part
     %   [partVerts, partFaces] = partTransform(bodyStruct, meshStruct);
        
        % Add component part vertices to total set of vertices
     %   checkSize = size(finalVerts);
     %   if checkSize(1) > 0
     %       finalVerts = cat(1, finalVerts,partVerts);
     %       finalFaces = cat(1, finalFaces,partFaces);
     %   else
     %       finalVerts = partVerts;
     %       finalFaces = partFaces;
     %   end

        % Traverse and transform inner parts until leaf node
        if isfield(bodyStruct,'body') == 1
            isLeaf = 0;
            innerTransform(bodyStruct, meshStruct, isLeaf)%, finalVerts, finalFaces);
        else
           isLeaf = 1; 
        end
    end
    
    % Apply outer transformation to all bodies at current level
    % Rotate outer quat transforms
    %finalVerts = finalVerts*outterQuatM;

    % Rotate outer euler transforms
    %finalVerts = finalVerts*outterEulM;
    
    % Translate from outer position
    %finalVerts = finalVerts+outterPos;
end

% Transform current component part
%function [partVerts, partFaces] = partTransform(currStruct, outterPos, outterQuatM, outterEulM, meshStruct)
%function [partVerts, partFaces] = partTransform(currStruct, meshStruct)
function partTransform(currStruct, meshStruct)
    numMeshes = size(meshStruct);
    numMeshes = numMeshes(2);
    meshFile = '';
    shapesFile = "shape_meshes/";
    handFile = "hand_meshes/";
    geomNum = 1;
    siteNum = 1;
    currPart = 0;
    
    % Get current component body transformations
    %bodyPos = strsplit(currStruct.Attributes.pos);
    %bodyPos = str2double(bodyPos);

    % Quaternion rotation
    %if isfield(currStruct.Attributes,'quat')
    %    bodyQuatM = currStruct.Attributes.quat;
    %    bodyQuatM = strsplit(bodyQuatM);
    %    bodyQuatM = str2double(bodyQuatM);
    %    bodyQuatM = quat2rotm(bodyQuatM);
    %else
    %    bodyQuatM = 1;
    %end

    % Euler rotation
    %if isfield(currStruct.Attributes,'euler')
     %   bodyEulM = currStruct.Attributes.euler;
     %   bodyEulM = strsplit(bodyEulM);
     %   bodyEulM = str2double(bodyEulM);
     %   bodyEulM = eul2rotm(bodyEulM,'XYZ');
    %else
     %   bodyEulM = 1;
    %end
    
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
        %meshFile = getMesh(currPart,meshStruct,numMeshes,shapesFile,handFile);

        % Read mesh from stl file
        %[objVerts, objFaces, objNormals, objName] = stlRead(meshFile);

        % Euler angle rotation to individual geom/site vertices
        %if isfield(currPart.Attributes,'euler') == 1
        %    eulTransform(currPart,objVerts);
        %end

        % Quaternion angle rotation to individual geom/site vertices
        %if isfield(currPart.Attributes,'quat') == 1
        %    objVerts = quatTransform(currPart,objVerts);
        %end
        
        % Translate individual geom/site vertices
        %if isfield(currPart.Attributes,'pos') == 1
        %    geomStructPos = strsplit(currPart.Attributes.pos);
        %    geomStructPos = str2double(geomStructPos);
        %    objVerts = objVerts+geomStructPos;            
        %end
                
        % Uncomment to model individual geom/site component parts
        %axis equal
        %patch('Faces',objFaces,'Vertices',objVerts,'FaceColor','blue');
        %%if n<numStructs, hold on, end
        
        % Add individual geom/site to total component part vertices
        %partVerts = cat(1, partVerts, objVerts);
        %partFaces = cat(1, partFaces, objFaces);
        %disp("size of finalVerts: "+size(partVerts));
    end

    % Rotate from body quat transforms
    %partVerts = partVerts*bodyQuatM;

    % Rotate from euler transforms
    %partVerts = partVerts*bodyEulM;
    
    % Translate from body positions
    %partVerts = partVerts+bodyPos;

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

