//exec XMLMath.sci;


//margin and distance between components at x and y axis
ComponentsDistanceX = 0.2;
ComponentsDistanceY = 0.35;
TextComponentDistanceX = 0.03;
TextLineDistanceY = -0.025;

//size increase for circle component
sizeCircleIncrease = 5/4;
////size increase for rectangle component
//sizeRectangleIncrease = 5/4;

//tolerance of points during overlapping check
toleranceOverlapX = 0.015;
toleranceOverlapY = toleranceOverlapX;
//tolerance of cross overlap
tolerCrossOverlapX = toleranceOverlapX * 1.4;
tolerCrossOverlapY = toleranceOverlapY * 1.4;
////tolerance of points during cross check
//toleranceCross = 0.000001;
//size of arrow during drawing of arrows
sizeOfArrow = 3;
//decrease number of font size of names for input (including trigger) and output (including clipto/limit information) properties
fontSizeInputOutputNamesDecrease = 1.0;

//define steps for line sub-points in the whole path
stepXLine = ComponentsDistanceX / 2;
stepYLine = ComponentsDistanceY / 2;

//define if overlapping of lines will be checked
checkOverlappingOfLines = %t;


//supported visual types (draw component as rectangle or circle)
//global VisualTypes;
VisualTypes = ["rectangle", "circle"];
//create a struct XMLVisualComponent
//global XMLVisualComponent;
XMLVisualComponent = struct('name', emptystr(), ...
                            'type_xml', emptystr(), ...
                            'inputs' , list(), ...
                            'real_mumber_of_inputs' , 0, ...
                            'outputs', list(), ...
                            'real_mumber_of_outputs' , 0, ...
                            'trigger', emptystr(),...
                            'clipto_min', emptystr(),...
                            'clipto_max', emptystr(),...
                            'visual_type', VisualTypes(1), ...
                            'pos_x', 0, ...
                            'pos_y', 0, ...
                            'size_x', 0, ...
                            'size_y', 0);
//create struct with indexes of XML visual component
IndexesVisualComponent = struct('name', emptystr(), ...
                            'main_index', 0, ...
                            'input_indexes' , list(), ...
                            'output_indexes', list(), ...
                            'trigger_index', 0);


//create struct with connection path using start and end indexes of visual components, and list of the path points
ConnectionPathVisual = struct('start_index', 0, ...
                            'start_name', emptystr(), ...
                            'end_index', 0, ...
                            'end_name', emptystr(), ...
                            'path_points' , list(), ...
                            'number_of_occurrences', 1);
//supported connection types of points (draw lines (usual connection) or arc (connection when two lines crosses each other))
PointConnectionTypes = ["line", "arc"];
//create struct point with x and y location and connection type from the current point to the other
Point = struct('x', 0, ...
               'y', 0, ...
               'connection_type', PointConnectionTypes(1));
////create struct with information about possible line overlapping at x and y axis for connections
//OverlappingLinePathVisual = struct('pos_x_start', -1, ...
//                                'pos_x_end', -1, ...
//                                'pos_y_start', -1, ...
//                                'pos_y_end', -1, ...
//                                'number_of_active_connection_paths', 0);



//function [imageControllerXMLChannel]=DrawControllerOfXMLChannel(xmlChannel)
function [xmlVisualComponentsList]=DrawControllerOfXMLChannel(handleAxes, xmlChannel)
    
//    //<>debug only
//    handleAxes = handles.ImageController;
//    xmlChannel = xmlChannelSelected;
    
    xmlVisualComponentsList = list();
    
    
    //find all drawable components
    components = xmlChannel.children;
    for i = 1 : 1 : length(components)
        
        //create visual component with all information except the position (will be calculated later)
        if ((components(i).name ~= "comment") & (components(i).name ~= "documentation") & (components(i).name ~= "text") & (components(i).name ~= "property")) then 
            
            //add the visual component to the list
            xmlVisualComponentsList($+1) = CreateXMLVisualComponentBasic(components(i));
            
        end
       
    end
    
    
    //calculate real number of inputs and outputs of the components (i.e. without redundant entries and without trigger as input)
    for i = 1 : 1 : length(xmlVisualComponentsList)
        [xmlVisualComponentsList(i).real_mumber_of_inputs, xmlVisualComponentsList(i).real_mumber_of_outputs] = GetRealNumberOfInputsAndOutputs(xmlVisualComponentsList, xmlVisualComponentsList(i));
//        //<>debug only
//        disp(["component name: " + xmlVisualComponentsList(i).name ; "real number of inputs: " + string(xmlVisualComponentsList(i).real_mumber_of_inputs) ; "real number of outputs: " + string(xmlVisualComponentsList(i).real_mumber_of_outputs)]);
    end
    
    
    //sort visual components by their inputs and outputs
    outSortedIndexesVisualComponents = SortXMLVisualComponents(xmlVisualComponentsList);
    
    
    
    //Clear current axes schema
    ClearAxesSchema(handleAxes);
    
    
    //calculate size of all visual components
    for i = 1 : 1 : length(xmlVisualComponentsList)
        visualSize = CalculateVisualSize(handleAxes, xmlVisualComponentsList(i));
        xmlVisualComponentsList(i).size_x = visualSize(1);
        xmlVisualComponentsList(i).size_y = visualSize(2);
    end
    
    
    //calculate positions of all visual components
    for i = 1 : 1 : length(xmlVisualComponentsList)
        positionComponent = CalculateVisualPosition(xmlVisualComponentsList(i), outSortedIndexesVisualComponents, xmlVisualComponentsList, handleAxes);
        xmlVisualComponentsList(i).pos_x = positionComponent(1);
        xmlVisualComponentsList(i).pos_y = positionComponent(2);
    end
//    //<>debug only
//    for i = 1 : 1 : length(xmlVisualComponentsList)
//        disp(["i: " + string(i) ; "name: " + xmlVisualComponentsList(i).name ; "pos_x:" + string(xmlVisualComponentsList(i).pos_x) ; "pos_y: " + string(xmlVisualComponentsList(i).pos_y) ; "size_x: " + string(xmlVisualComponentsList(i).size_x) ; "size_y: " + string(xmlVisualComponentsList(i).size_y) ]);
//    end
    
    //decrease font size
    handleAxes.font_size = handleAxes.font_size - fontSizeInputOutputNamesDecrease;
    
    //calculate all connection paths between visual components and properties
    connectionPathVisualList = CalculateConnectionsOfVisualComponents(handleAxes, xmlVisualComponentsList, outSortedIndexesVisualComponents);
    
    
    //draw visual components - this has to be draw first! because of the order of children in the handleAxes. The highlight of selected visual component would not work.
    //note: If it is necessary to move this lines or draw something different first, you must to change the HighlightSelectedVisualComponent function (e.g. the better option would be find the exact text in children, not to calculate assumed index).
    for i = 1 : 1 : length(xmlVisualComponentsList)
        DrawXMLVisualComponent(handleAxes, xmlVisualComponentsList(i));
    end
    
    DrawCliptoOfXMLVisualComponents(handleAxes, xmlVisualComponentsList);
    
    //draw connections of all visual components
    DrawConnectionsOfVisualComponents(handleAxes, connectionPathVisualList, xmlVisualComponentsList);
    
    //increase font size to the original value
    handleAxes.font_size = handleAxes.font_size + fontSizeInputOutputNamesDecrease;
    
    
    //Calculate image resolution of controller (must be at the end! - in other case, the height and width calculation of text would be calculated wrongly, i.e. will be too high)
    CalculateImageControllerResolution(handleAxes, xmlVisualComponentsList, outSortedIndexesVisualComponents);
    
    
    
    //erase all lists
    while length(outSortedIndexesVisualComponents) > 0
        outSortedIndexesVisualComponents(1) = null();
    end
    while length(connectionPathVisualList) > 0
        connectionPathVisualList(1) = null();
    end
    
    
endfunction



function ClearAxesSchema(handleAxes)
    
    //Clear current axes schema
    delete(handleAxes.children);
    //unzoom the schema
    handleAxes.zoom_box = [];
    plot2d(-1,-1,[0,0],"010"," ",[0, 0, 1,1]);
    [axesXRatioResolution, axesYRatioResolution] = GetXYRatiosOfAxes(handleAxes);
    handleAxes.data_bounds = [0,0 ; axesXRatioResolution, 1];
    

endfunction



//function [imageControllerResolution]=CalculateImageControllerResolution(xmlVisualComponentsList)
function CalculateImageControllerResolution(handleAxes, xmlVisualComponentsList, sortedIndexesVisualComponents)
    
    
    //find the longest name of output with counting the position and size of visual component
    maximumOutputLenghtNameWithPositionSizeIncluded = 0;
    maximumOutputLenghtName = 0;
    for i = 1 : 1 : length(sortedIndexesVisualComponents)
        //go through all visual components of the last sub-path
        for k = 1 : 1 : length(sortedIndexesVisualComponents(i)(length(sortedIndexesVisualComponents(i))))
            
            //go through all outputs
            currentVisualComponent = xmlVisualComponentsList(sortedIndexesVisualComponents(i)(length(sortedIndexesVisualComponents(i)))(k).main_index);
            for q = 1 : 1 : length(currentVisualComponent.outputs)
                //if the name of the input is not in the visual component list, it counts
                if IsElementNameInVisualComponentsList(xmlVisualComponentsList, currentVisualComponent.outputs(q)) == %f then
                    outputNameLength = xstringl(0, 0, strsubst(currentVisualComponent.outputs(q), " ", ""), handleAxes.font_style, handleAxes.font_size);
                    //check if the current length is 'local' maximum
                    totalOutputLength = currentVisualComponent.pos_x + currentVisualComponent.size_x + outputNameLength(3);
                    if maximumOutputLenghtNameWithPositionSizeIncluded < totalOutputLength then
                        //copy only the name length of the 'local' maximum output
                        maximumOutputLenghtName = outputNameLength(3);
                    end
                end
            end
            
        end
    end
    
    
    width = 0;
    heigh = 0;
    //find the maximum position at X and Y axes and calculate width and height
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        if width < (xmlVisualComponentsList(i).pos_x + xmlVisualComponentsList(i).size_x) then
            width = xmlVisualComponentsList(i).pos_x + xmlVisualComponentsList(i).size_x;
        end
        
        if heigh < (xmlVisualComponentsList(i).pos_y + xmlVisualComponentsList(i).size_y) then
            heigh = xmlVisualComponentsList(i).pos_y + xmlVisualComponentsList(i).size_y;
        end
        
    end
    width = width + ComponentsDistanceX + maximumOutputLenghtName;
    heigh = heigh + ComponentsDistanceY;
    
    
    //fit the ratio of the axes uixontrol to calculated width and height
    [axesXRatioResolution, axesYRatioResolution] = GetXYRatiosOfAxes(handleAxes);
    //handleAxes.data_bounds = [0,0 ; axesXRatioResolution, 1];
    resWidthRatio = axesXRatioResolution;
    resHeightRatio = 1;
    overMaxX = width - axesXRatioResolution;
    overMaxY = heigh - 1;
    //check which value is more over the maximum (in percentage)
    if (overMaxX / axesXRatioResolution) > (overMaxY / 1) then
        if overMaxX > 0 then
            resWidthRatio = width;
            resHeightRatio = width / axesXRatioResolution;
        end
    else
        if overMaxY > 0 then
            resHeightRatio = heigh;
            resWidthRatio = heigh * axesXRatioResolution;
        end
    end
    
//    while resWidthRatio < width
//        resWidthRatio = resWidthRatio + axesXRatioResolution;
//        resHeightRatio = resHeightRatio + 1;
//    end
//    while resHeightRatio < heigh
//        resHeightRatio = resHeightRatio + 1;
//        resWidthRatio = resWidthRatio + axesXRatioResolution;
//    end
    
    handleAxes.data_bounds = [0,0 ; resWidthRatio, resHeightRatio];
    
    
    //normalize axes handle
    //plot2d(-1, -1, [0,0], "010", " ", [0, 0, width, heigh]);
    //handleAxes.data_bounds = [0,0 ; width, heigh];
    //plot2d(0,0,[0,0],"010"," ",[0,0,1,1]);
    //plot2d(0,0,[0,0],"010"," ",[0,0,2.18,1]);
    //plot2d(0,0,[0,0],"010"," ",[0,0,3.27,1]);
    //plot2d(0,0,-1,"031"," ",[0,0,2.18,1]);
    //plot2d([0, 2.18], [0, 1], 0);
    //handleAxes.data_bounds = [0, 0 ; 1.5, 3.27];
    //handleAxes.zoom_box = [0, 0, 1.0000, 0.8000, -0.5000, 0.5000] //empty means no zoom
    
    
endfunction



function [axesXRatioResolution, axesYRatioResolution]=GetXYRatiosOfAxes(handleAxes)
    
    //calculate X,Y ratios of axes with resolution inclusion
    global fig_size_x;
    global fig_size_y;
    axesXRatioResolution = (handleAxes.axes_bounds(3) * fig_size_x) / (handleAxes.axes_bounds(4) * fig_size_y);
    axesYRatioResolution = (handleAxes.axes_bounds(4) * fig_size_y) / (handleAxes.axes_bounds(3) * fig_size_x);
    
endfunction



function DrawXMLVisualComponent(handleAxes, xmlVisualComponent)
    
    //if the visual type of the component is circle, draw circle
    if xmlVisualComponent.visual_type == VisualTypes(2) then
        //xarc(xmlVisualComponent.pos_x, xmlVisualComponent.pos_y, xmlVisualComponent.size_x, xmlVisualComponent.size_x, 0, 360*64);
        xarc(xmlVisualComponent.pos_x, xmlVisualComponent.pos_y, xmlVisualComponent.size_x, xmlVisualComponent.size_y, 0, 360*64);
    //otherwise draw rectangle
    else
        xrect(xmlVisualComponent.pos_x, xmlVisualComponent.pos_y, xmlVisualComponent.size_x, xmlVisualComponent.size_y);
    end
    //xstringb(xmlVisualComponent.pos_x, xmlVisualComponent.pos_y - xmlVisualComponent.size_y, xmlVisualComponent.type_xml, xmlVisualComponent.size_x, xmlVisualComponent.size_y, "fill");
    xstringb(xmlVisualComponent.pos_x, xmlVisualComponent.pos_y - xmlVisualComponent.size_y, ["<" + xmlVisualComponent.type_xml + ">" ; xmlVisualComponent.name], xmlVisualComponent.size_x, xmlVisualComponent.size_y, "fill");
    //xstring(xmlVisualComponent.pos_x, xmlVisualComponent.pos_y - xmlVisualComponent.size_y, xmlVisualComponent.type_xml);
    
endfunction



function DrawCliptoOfXMLVisualComponents(handleAxes, xmlVisualComponentsList)
    
    //draw clipto_min and clipto_max information if any
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        xmlVisualComponent = xmlVisualComponentsList(i);
        
        //check if there is any clipto_max value/property, then draw the value/property next to higher-right side of the visual component
        if xmlVisualComponent.clipto_max ~= emptystr() then
            
            rectCliptoMax = xstringl(0, 0, strsubst(xmlVisualComponent.clipto_max, " ", ""), handleAxes.font_style, handleAxes.font_size);
            xstringb(xmlVisualComponent.pos_x + xmlVisualComponent.size_x - rectCliptoMax(3), xmlVisualComponent.pos_y + TextLineDistanceY, strsubst(xmlVisualComponent.clipto_max, " ", ""), rectCliptoMax(3), rectCliptoMax(4), "fill");
            //xstring(xmlVisualComponent.pos_x + xmlVisualComponent.size_x - rectCliptoMax(3), xmlVisualComponent.pos_y - xmlVisualComponent.size_y - rectCliptoMax(4) - TextLineDistanceY, strsubst(xmlVisualComponent.clipto_max, " ", ""));
            
        end
        
        //check if there is any clipto_min value/property, then draw the value/property next to lower-right side of the visual component
        if xmlVisualComponent.clipto_min ~= emptystr() then
            
            rectCliptoMin = xstringl(0, 0, strsubst(xmlVisualComponent.clipto_min, " ", ""), handleAxes.font_style, handleAxes.font_size);
            xstringb(xmlVisualComponent.pos_x + xmlVisualComponent.size_x - rectCliptoMin(3), xmlVisualComponent.pos_y - xmlVisualComponent.size_y - rectCliptoMin(4) - TextLineDistanceY, strsubst(xmlVisualComponent.clipto_min, " ", ""), rectCliptoMin(3), rectCliptoMin(4), "fill");
            //xstring(xmlVisualComponent.pos_x + xmlVisualComponent.size_x - rectCliptoMin(3), xmlVisualComponent.pos_y + TextLineDistanceY, strsubst(xmlVisualComponent.clipto_min, " ", ""));
            
        end
        
    end
    
endfunction



function HighlightSelectedVisualComponent(handleAxes, xmlVisualComponentsList, stringSelectedXMLName)
    
    //find the selected component in the xml visual list by using the name of the component
    IndexOfElementInVisualList = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, stringSelectedXMLName);
//    //<>debug only
//    selectedVisualComponent = xmlVisualComponentsList(IndexOfElementInVisualList);
//    disp(stringSelectedXMLName + " " + string(IndexOfElementInVisualList) + " " + selectedVisualComponent.type_xml);
    
    //set color and thickness for selected visual component
    selectedColor = color("red");
    selectedThickness = handleAxes.thickness * 2;
    selectedFontSize = handleAxes.font_size * 2;
    //change color and thickness of previous selected visual component if any
    for i = 1 : 1 : length(handleAxes.children)
//        //<>debug only
//        disp(handleAxes.children(i).type);
        if handleAxes.children(i).type == "Text"
            if handleAxes.children(i).font_foreground == selectedColor & handleAxes.children(i).font_size == selectedFontSize then
                handleAxes.children(i).font_foreground = -1;
                handleAxes.children(i).font_size = handleAxes.font_size;
            end
        elseif handleAxes.children(i).type == "Rectangle" | handleAxes.children(i).type == "Arc" then
            if handleAxes.children(i).foreground == selectedColor & handleAxes.children(i).thickness == selectedThickness then
                handleAxes.children(i).foreground = -1;
                handleAxes.children(i).thickness = handleAxes.thickness;
            end
        end
    end
    
    //set color and thickness/font_size of selected visual component
    //(note: if the drawing of the visual components starts with first component in xmlVisualComponentsList and iterates to the last and draw two elements (rectancle and text, or ellipse and text), the index in axes uicontrol should be in same order but reverse (the components are added at first position of the children list))
    //
    handleAxes.children(length(handleAxes.children) - (IndexOfElementInVisualList * 2 - 1)).foreground = selectedColor;
    handleAxes.children(length(handleAxes.children) - (IndexOfElementInVisualList * 2 - 1)).thickness = selectedThickness;
    //text element is added second in our code, therefore it will be before the geometry object
    handleAxes.children(length(handleAxes.children) - (IndexOfElementInVisualList * 2)).font_foreground = selectedColor;
    handleAxes.children(length(handleAxes.children) - (IndexOfElementInVisualList * 2)).font_size = selectedFontSize;
    
endfunction



function [connectionPathVisualList]=CalculateConnectionsOfVisualComponents(handleAxes, xmlVisualComponentsList, inSortedIndexesVisualComponents)
    
    
    connectionPathVisualList = list();
    
    
    //create connection paths with basic information
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        //find indexes of inputs which are in the visual list (if any) and create new path
        for j = 1 : 1 : length(xmlVisualComponentsList(i).inputs)
            
            connectionPathVisual = ConnectionPathVisual;
            connectionPathVisual.end_index = i;
            connectionPathVisual.end_name = xmlVisualComponentsList(i).name;
            connectionPathVisual.start_name = xmlVisualComponentsList(i).inputs(j);
            connectionPathVisual.start_index = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).inputs(j));
            
            //add new path to path list
            connectionPathVisualList($+1) = connectionPathVisual;
            
        end
        
        //find indexes of outputs which are in the visual list (if any) and create new path
        for j = 1 : 1 : length(xmlVisualComponentsList(i).outputs)
            
            connectionPathVisual = ConnectionPathVisual;
            connectionPathVisual.start_index = i;
            connectionPathVisual.start_name = xmlVisualComponentsList(i).name;
            connectionPathVisual.end_name = xmlVisualComponentsList(i).outputs(j);
            connectionPathVisual.end_index = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).outputs(j));
            
            //add new path to path list
            connectionPathVisualList($+1) = connectionPathVisual;
            
        end
        
        //find index of trigger which is in the visual list (if any) and set it
        if strsubst(xmlVisualComponentsList(i).trigger, " ", "") ~= emptystr() then
            
            connectionPathVisual = ConnectionPathVisual;
            connectionPathVisual.end_index = i;
            connectionPathVisual.end_name = xmlVisualComponentsList(i).name;
            connectionPathVisual.start_name = xmlVisualComponentsList(i).trigger;
            connectionPathVisual.start_index = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).trigger);
            
            //add new path to path list
            connectionPathVisualList($+1) = connectionPathVisual;
            
        end
        
    end
//    //<>debug only
//    for i = 1 : 1 : length(connectionPathVisualList)
//        disp("start_index: " + string(connectionPathVisualList(i).start_index) + " start_name: " + connectionPathVisualList(i).start_name);
//        disp("end_index: " + string(connectionPathVisualList(i).end_index) + " end_name: " + connectionPathVisualList(i).end_name);
//    end
    
    
    
    //check if there are any paths which starts and ends at the same component; if so increase "number_of_occurrences" and delete the latter path
    iterI = 1;
    while iterI <= length(connectionPathVisualList)
        
        numberOfOccurrences = 1;
        iterJ = iterI+1;
        while iterJ <= length(connectionPathVisualList)
            
            //if there are two same paths, delete the latter and increase number of all occurrences
            if connectionPathVisualList(iterI).start_index == connectionPathVisualList(iterJ).start_index & connectionPathVisualList(iterI).start_name == connectionPathVisualList(iterJ).start_name & connectionPathVisualList(iterI).end_index == connectionPathVisualList(iterJ).end_index & connectionPathVisualList(iterI).end_name == connectionPathVisualList(iterJ).end_name then
                connectionPathVisualList(iterJ) = null();
                numberOfOccurrences = numberOfOccurrences + 1;
                iterJ = iterJ - 1;
            end
            
            iterJ = iterJ + 1;
        end
        connectionPathVisualList(iterI).number_of_occurrences = numberOfOccurrences;
        
        iterI = iterI + 1;
    end
//    //<>debug only
//    for i = 1 : 1 : length(connectionPathVisualList)
//        disp("number_of_occurrences: " + string(connectionPathVisualList(i).number_of_occurrences));
//        disp("start_index: " + string(connectionPathVisualList(i).start_index) + " start_name: " + connectionPathVisualList(i).start_name);
//        disp("end_index: " + string(connectionPathVisualList(i).end_index) + " end_name: " + connectionPathVisualList(i).end_name);
//    end
    
    
    
    
//    //find and calculate possible line obstacles
//    overlappingLinePathVisualList = list();
////    OverlappingLinePathVisual
////    number_of_active_inputs
////    number_of_active__outputs
//    for i = 1 : 1 : length(xmlVisualComponentsList)
//        
//        //create default struct instance for x and y start/end
//        overlappingLinePathVisual_X_start = OverlappingLinePathVisual;
//        overlappingLinePathVisual_X_start.pos_x_start = xmlVisualComponentsList(i).pos_x;
//        overlappingLinePathVisual_X_end = OverlappingLinePathVisual;
//        overlappingLinePathVisual_X_end.pos_x_end = xmlVisualComponentsList(i).pos_x;
//        overlappingLinePathVisual_Y_start = OverlappingLinePathVisual;
//        overlappingLinePathVisual_Y_start.pos_y_start = xmlVisualComponentsList(i).pos_y;
//        overlappingLinePathVisual_Y_end = OverlappingLinePathVisual;
//        overlappingLinePathVisual_Y_end.pos_y_end = xmlVisualComponentsList(i).pos_y;
//        //check if there is the current x and y position in the list; if so, use it
//        for h = 1 : 1 : length(overlappingLinePathVisualList)
//            
//            //if there is the x start position with overlapping information in the list, use it
//            if overlappingLinePathVisualList(h).pos_x_start == xmlVisualComponentsList(i).pos_x then
//                overlappingLinePathVisual_X_start = overlappingLinePathVisualList(h);
//            end
//            
//            //if there is the x end position with overlapping information in the list, use it
//            if overlappingLinePathVisualList(h).pos_x_end == xmlVisualComponentsList(i).pos_x then
//                overlappingLinePathVisual_X_end = overlappingLinePathVisualList(h);
//            end
//            
//            //if there is the y start position with overlapping information in the list, use it
//            if overlappingLinePathVisualList(h).pos_y_start == xmlVisualComponentsList(i).pos_y then
//                overlappingLinePathVisual_Y_start = overlappingLinePathVisualList(h);
//            end
//            
//            //if there is the y end position with overlapping information in the list, use it
//            if overlappingLinePathVisualList(h).pos_y_end == xmlVisualComponentsList(i).pos_y then
//                overlappingLinePathVisual_Y_end = overlappingLinePathVisualList(h);
//            end
//            
//        end
//        
//        
//        
//        //find indexes of inputs which are in the visual list (if any) and create new path
//        for j = 1 : 1 : length(xmlVisualComponentsList(i).inputs)
//            
//            isElementInVisList = IsElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).inputs(j));
//            //if the element is visual component
//            if isElementInVisList > 0 then
//                //increase number of active connection paths for x end
//                overlappingLinePathVisual_X_end.number_of_active_connection_paths = overlappingLinePathVisual_X_end.number_of_active_connection_paths + 1;
//                
//                if xmlVisualComponentsList(xmlVisualComponentsList(i).inputs(j)).pos_y > xmlVisualComponentsList(i).pos_y then
//                    overlappingLinePathVisual_Y_start.number_of_active_connection_paths = overlappingLinePathVisual_Y_start.number_of_active_connection_paths + 1;
//                elseif xmlVisualComponentsList(xmlVisualComponentsList(i).inputs(j)).pos_y < xmlVisualComponentsList(i).pos_y
//                    overlappingLinePathVisual_Y_end.number_of_active_connection_paths = overlappingLinePathVisual_Y_end.number_of_active_connection_paths + 1;
//                else
//                    //y position is same but is the second component exactly the left component or are there some components between them?
//                    
//                end
//                
//            end
//            
//            //
//            
//        end
//        
//        //find indexes of outputs which are in the visual list (if any) and create new path
//        for j = 1 : 1 : length(xmlVisualComponentsList(i).outputs)
//            
//            isElementInVisList = IsElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).outputs(j));
//            
//            //
//            
//        end
//        
//        
////        length(xmlVisualComponentsList(i).inputs)
////        length(xmlVisualComponentsList(i).outputs)
//        
//        
//        if strsubst(xmlVisualComponentsList(i).trigger, " ", "") ~= emptystr() then
//            
//            
//            isElementInVisList = IsElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).trigger);
//            
//            //
//            
//        end
//        
//        
//    end
    
    
    
    
    //create path with specific points to connect components
    //
    //initialization of previously used inputs and outputs of component which are used for calculation of start and end point
    usedInputs = list();
    for i = 1 : 1 : length(xmlVisualComponentsList)
        usedInputs($+1) = 0;
    end
    usedOutputs = list();
    for i = 1 : 1 : length(xmlVisualComponentsList)
        usedOutputs($+1) = 0;
    end
    
    //find start and end point and add it to the point list
    for i = 1 : 1 : length(connectionPathVisualList)
        
        //if at least one index is higher than 0 (i.e. there is at least one path which starts or/and ends with visual component)
        if connectionPathVisualList(i).start_index > 0 | connectionPathVisualList(i).end_index > 0 then
            
            
            //calculate position of start point
            if connectionPathVisualList(i).start_index > 0 then
                
                //get start visual component
                startVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).start_index);
                //increase number of used outputs
                usedOutputs(connectionPathVisualList(i).start_index) = usedOutputs(connectionPathVisualList(i).start_index) + 1;
                //create start point (calculate x and y position using position and size of the visual component)
                startPoint = Point;
                startPoint.y = startVisualComponent.pos_y - (startVisualComponent.size_y / (startVisualComponent.real_mumber_of_outputs + 1) * (startVisualComponent.real_mumber_of_outputs + 1 - usedOutputs(connectionPathVisualList(i).start_index)));
                //if visual type is ellipse/circle
                if startVisualComponent.visual_type == VisualTypes(2) then
                    
                    //get ellipse position of x point which depends on ellipse/circle equation
                    xEllipse = GetXPositionOfEllipse(startVisualComponent.size_x / 2, startVisualComponent.size_y / 2, (startVisualComponent.pos_y - startVisualComponent.size_y / 2) - startPoint.y);
                    startPoint.x = startVisualComponent.pos_x + startVisualComponent.size_x / 2 + xEllipse;
                    
                //otherwise, visual type is rectangle (or not supported)
                else
                    startPoint.x = startVisualComponent.pos_x + startVisualComponent.size_x;
                    //disp(["Visual type of the current path is not supported:" ; "visual type: " + startVisualComponent.visual_type ; "start_index: " + connectionPathVisualList(i).start_index ; "start_name: " + connectionPathVisualList(i).start_name ; "end_index: " + connectionPathVisualList(i).end_index ; "end_name: " + connectionPathVisualList(i).end_name ; "number of path occurences: " + string(connectionPathVisualList(i).number_of_occurrences) ; "path points: " + connectionPathVisualList(i).path_points ]);
                end
                connectionPathVisualList(i).path_points($+1) = startPoint;
                
                
            //otherwise this is an input which does not start at any visual component in this channel (it may start at e.g. property, component from another channel etc.)
            else
                
                //get end visual component (due to the first condition in this cycle, it has to be valid end index if there is no valid start index)
                endVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).end_index);
                
                //if the number of used inputs is higher than the maximum real number of inputs, everything is OK
                if usedInputs(connectionPathVisualList(i).end_index) + 1 <= endVisualComponent.real_mumber_of_inputs then
                    
                    //create start point (calculate x and y position using position and the size of the visual component and the size of name in form of string with specific font)
                    rectStartName = xstringl(0, 0, strsubst(connectionPathVisualList(i).start_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
                    startPoint = Point;
                    startPoint.y = endVisualComponent.pos_y - (endVisualComponent.size_y / (endVisualComponent.real_mumber_of_inputs + 1) * (usedInputs(connectionPathVisualList(i).end_index)+1));
                    //if visual type is ellipse/circle
                    if endVisualComponent.visual_type == VisualTypes(2) then
                        
                        //get ellipse position of x point which depends on ellipse/circle equation
                        xEllipse = GetXPositionOfEllipse(endVisualComponent.size_x / 2, endVisualComponent.size_y / 2, (endVisualComponent.pos_y - endVisualComponent.size_y / 2) - startPoint.y);
                        startPoint.x = endVisualComponent.pos_x - rectStartName(3) - TextComponentDistanceX;
                        //startPoint.x = endVisualComponent.pos_x + (endVisualComponent.size_x / 2 - xEllipse) - rectStartName(3) - TextComponentDistanceX;
                        
                    //otherwise, visual type is rectangle (or not supported)
                    else
                        startPoint.x = endVisualComponent.pos_x - rectStartName(3) - TextComponentDistanceX;
                        //disp(["Visual type of the current path is not supported:" ; "visual type: " + endVisualComponent.visual_type ; "start_index: " + connectionPathVisualList(i).start_index ; "start_name: " + connectionPathVisualList(i).start_name ; "end_index: " + connectionPathVisualList(i).end_index ; "end_name: " + connectionPathVisualList(i).end_name ; "number of path occurences: " + string(connectionPathVisualList(i).number_of_occurrences) ; "path points: " + connectionPathVisualList(i).path_points ]);
                    end
                    connectionPathVisualList(i).path_points($+1) = startPoint;
                    
                    
                //otherwise it is probably trigger without component which was not count to all "real" inputs
                //trigger should be only in PID and Integrator component and should be added to connection paths as the last connection path of the current component
                //PID and Integrator component are in the current version of drawing component function classified as rectangle visual type and thus there is no visual type control
                else
                    
                    //create end point for trigger input (calculate x and y position using position and size of the visual component)
                    startPoint = Point;
                    rectStartName = xstringl(0, 0, strsubst(connectionPathVisualList(i).start_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
                    //just line with text is added - the direction is from below to the component
                    startPoint.y = endVisualComponent.pos_y - endVisualComponent.size_y - rectStartName(4) - TextLineDistanceY; // - ComponentsDistanceY * 0.1;
                    startPoint.x = endVisualComponent.pos_x + endVisualComponent.size_x / 2;
                    connectionPathVisualList(i).path_points($+1) = startPoint;
                    
                end
                
                
            end
            
            
            
            //calculate position of end point
            if connectionPathVisualList(i).end_index > 0 then
                
                //get end visual component
                endVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).end_index);
                
                //if the number of used inputs is higher than the maximum real number of inputs, everything is OK
                if usedInputs(connectionPathVisualList(i).end_index) + 1 <= endVisualComponent.real_mumber_of_inputs then
                    
                    
                    //increase number of used inputs
                    usedInputs(connectionPathVisualList(i).end_index) = usedInputs(connectionPathVisualList(i).end_index) + 1;
                    //create end point (calculate x and y position using position and size of the visual component)
                    endPoint = Point;
                    endPoint.y = endVisualComponent.pos_y - (endVisualComponent.size_y / (endVisualComponent.real_mumber_of_inputs + 1) * usedInputs(connectionPathVisualList(i).end_index));
                    //if visual type is ellipse/circle
                    if endVisualComponent.visual_type == VisualTypes(2) then
                        
                        //get ellipse position of x point which depends on ellipse/circle equation
                        xEllipse = GetXPositionOfEllipse(endVisualComponent.size_x / 2, endVisualComponent.size_y / 2, (endVisualComponent.pos_y - endVisualComponent.size_y / 2) - endPoint.y);
                        endPoint.x = endVisualComponent.pos_x + (endVisualComponent.size_x / 2 - xEllipse);
                        
                    //otherwise, visual type is rectangle (or not supported)
                    else
                        endPoint.x = endVisualComponent.pos_x;
                        //disp(["Visual type of the current path is not supported:" ; "visual type: " + endVisualComponent.visual_type ; "start_index: " + connectionPathVisualList(i).start_index ; "start_name: " + connectionPathVisualList(i).start_name ; "end_index: " + connectionPathVisualList(i).end_index ; "end_name: " + connectionPathVisualList(i).end_name ; "number of path occurences: " + string(connectionPathVisualList(i).number_of_occurrences) ; "path points: " + connectionPathVisualList(i).path_points ]);
                    end
                    connectionPathVisualList(i).path_points($+1) = endPoint;
                    
                    
                //otherwise it is probably trigger which was not count to all "real" inputs
                //trigger should be only in PID and Integrator component and should be added to connection paths as the last connection path of the current component
                //PID and Integrator component are in the current version of drawing component function classified as rectangle visual type and thus there is no visual type control
                else
                    
                    //create end point for trigger input (calculate x and y position using position and size of the visual component)
                    endPoint = Point;
                    //there should be start component but for sure
                    if connectionPathVisualList(i).start_index > 0 then
                        
                        //get start visual component
                        startVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).start_index);
                        
                        //if y position of start component is higher (i.e. start component is above end component)
                        if startVisualComponent.pos_y > endVisualComponent.pos_y
                            endPoint.y = endVisualComponent.pos_y;
                        //otherwise y position of start component is lower or same (i.e. start component is below end component or in same line)
                        else
                            endPoint.y = endVisualComponent.pos_y - endVisualComponent.size_y;
                        end
                        
                    //otherwise if there is no start visual component, just line with text is added
                    else
                        //rectStartName = xstringl(0, 0, strsubst(connectionPathVisualList(i).start_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
                        endPoint.y = endVisualComponent.pos_y - endVisualComponent.size_y;
                    end
                    
                    endPoint.x = endVisualComponent.pos_x + endVisualComponent.size_x / 2;
                    connectionPathVisualList(i).path_points($+1) = endPoint;
                    
                end
                
                
            //otherwise this is an output which does not end at any visual component in this channel (it may end at e.g. property, component in another channel etc.)
            else
                
                //get end visual component (due to the first condition in this cycle, it has to be valid end index if there is no valid start index)
                startVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).start_index);
                //create end point (calculate x and y position using position and the size of the visual component and the size of name in form of string with specific font)
                rectEndName = xstringl(0, 0, strsubst(connectionPathVisualList(i).end_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
                endPoint = Point;
                endPoint.y = startVisualComponent.pos_y - (startVisualComponent.size_y / (startVisualComponent.real_mumber_of_outputs + 1) * (startVisualComponent.real_mumber_of_outputs + 1 - usedOutputs(connectionPathVisualList(i).start_index)));
                //if visual type is ellipse/circle
                if startVisualComponent.visual_type == VisualTypes(2) then
                    
                    //get ellipse position of x point which depends on ellipse/circle equation
                    xEllipse = GetXPositionOfEllipse(startVisualComponent.size_x / 2, startVisualComponent.size_y / 2, (startVisualComponent.pos_y - startVisualComponent.size_y / 2) - endPoint.y);
                    endPoint.x = startVisualComponent.pos_x + startVisualComponent.size_x + rectEndName(3) + TextComponentDistanceX * 2;
                    //endPoint.x = startVisualComponent.pos_x + startVisualComponent.size_x / 2 + xEllipse + rectEndName(3) + TextComponentDistanceX * 2;
                    
                //otherwise, visual type is rectangle (or not supported)
                else
                    endPoint.x = startVisualComponent.pos_x + startVisualComponent.size_x + rectEndName(3) + TextComponentDistanceX * 2;
                    //disp(["Visual type of the current path is not supported:" ; "visual type: " + startVisualComponent.visual_type ; "start_index: " + connectionPathVisualList(i).start_index ; "start_name: " + connectionPathVisualList(i).start_name ; "end_index: " + connectionPathVisualList(i).end_index ; "end_name: " + connectionPathVisualList(i).end_name ; "number of path occurences: " + string(connectionPathVisualList(i).number_of_occurrences) ; "path points: " + connectionPathVisualList(i).path_points ]);
                end
                connectionPathVisualList(i).path_points($+1) = endPoint;
                
                
            end
            
        //otherwise the current path starts and ends at no visual components which cannot happen
        else
            disp(["The current path starts and ends at no visual components:" ; "start_index: " + string(connectionPathVisualList(i).start_index) ; "start_name: " + connectionPathVisualList(i).start_name ; "end_index: " + string(connectionPathVisualList(i).end_index) ; "end_name: " + connectionPathVisualList(i).end_name ; "number of path occurences: " + string(connectionPathVisualList(i).number_of_occurrences) ; "path points: " + connectionPathVisualList(i).path_points ]);
        end
        
        
    end
    
    
    
    
    //go through all connection and add sub points between first and last points to point list if necessary
    for i = 1 : 1 : length(connectionPathVisualList)
        
        //calculate and check rest of point paths
        //if start and end indexes are higher than 0 (i.e. it is path between two visual components)
        if connectionPathVisualList(i).start_index > 0 & connectionPathVisualList(i).end_index > 0 then
            
            
            //find start and end visual components in list of sorted indexed visual components
            [iIndexStart, jIndexStart, kIndexStart] = FindIndexesOfVisualComponentInSortedListIndexes(inSortedIndexesVisualComponents, connectionPathVisualList(i).start_index);
            [iIndexEnd, jIndexEnd, kIndexEnd] = FindIndexesOfVisualComponentInSortedListIndexes(inSortedIndexesVisualComponents, connectionPathVisualList(i).end_index);
            
            //get start and end visual component
            startVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).start_index);
            endVisualComponent = xmlVisualComponentsList(connectionPathVisualList(i).end_index);
            
            
            
            //if the connection is between this and the following component which is right behind the start component at the same line
            if jIndexEnd == jIndexStart + 1 & kIndexEnd == kIndexStart then
                
                
                
                //if it is not ideal vertical or horizontal line from current componennt's output to the following component's input
                if connectionPathVisualList(i).path_points(1).y ~= connectionPathVisualList(i).path_points($).y & connectionPathVisualList(i).path_points(1).x ~= connectionPathVisualList(i).path_points($).x then
                    
                    
                    //if the start visual component is not trigger of the following component
                    if strsubst(endVisualComponent.trigger, " ", "") ~= strsubst(startVisualComponent.name, " ", "") then
                        
                        
                        secondPoint = Point;
                        secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine;
                        secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                        if checkOverlappingOfLines == %t then
                            //correct overlapping line if necessary
                            [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                            secondPoint = correctedPoint2;
                        end
                        
                        thirdPoint = Point;
                        thirdPoint.x = secondPoint.x;
                        thirdPoint.y = connectionPathVisualList(i).path_points($).y;
                        if checkOverlappingOfLines == %t then
                            //correct overlapping line if necessary
                            [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                            secondPoint = correctedPoint1;
                            thirdPoint = correctedPoint2;
                        end
                        
                        
                        //copy the last point and delete the last point from the list 
                        endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                        connectionPathVisualList(i).path_points($) = null();
                        //add the second, third and last point
                        connectionPathVisualList(i).path_points($+1) = secondPoint;
                        connectionPathVisualList(i).path_points($+1) = thirdPoint;
                        connectionPathVisualList(i).path_points($+1) = endPointCopy;
                        
                        
                    //otherwise, it is trigger which is connected to the bottom of the end visual component
                    else
                        
                        
                        secondPoint = Point;
                        secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine;
                        secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                        if checkOverlappingOfLines == %t then
                            //correct overlapping line if necessary
                            [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                            secondPoint = correctedPoint2;
                        end
                        
                        thirdPoint = Point;
                        thirdPoint.x = secondPoint.x;
                        componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                        //disp([string(startVisualComponent.pos_y) ; string(startVisualComponent.size_y) ; string(connectionPathVisualList(i).path_points(1).y) ]); //<>debug only
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence;
                        if checkOverlappingOfLines == %t then
                            //correct overlapping line if necessary
                            [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                            secondPoint = correctedPoint1;
                            thirdPoint = correctedPoint2;
                        end
                        
                        forthPoint = Point;
                        forthPoint.x = connectionPathVisualList(i).path_points($).x;
                        forthPoint.y = thirdPoint.y;
                        if checkOverlappingOfLines == %t then
                            //correct overlapping line if necessary
                            [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                            thirdPoint = correctedPoint1;
                            forthPoint = correctedPoint2;
                        end
                        
                        
                        //copy the last point and delete the last point from the list 
                        endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                        connectionPathVisualList(i).path_points($) = null();
                        //add the second, third and last point
                        connectionPathVisualList(i).path_points($+1) = secondPoint;
                        connectionPathVisualList(i).path_points($+1) = thirdPoint;
                        connectionPathVisualList(i).path_points($+1) = forthPoint;
                        connectionPathVisualList(i).path_points($+1) = endPointCopy;
                        
                        
                    end
                    
                end
                
                
                
            //if the connection is between this and the following component which is behind (but not right behind) the start component at the same line
            elseif jIndexEnd >= jIndexStart + 2 & kIndexEnd == kIndexStart then
                
                
                
                //if the start visual component is not trigger of the following component
                if strsubst(endVisualComponent.trigger, " ", "") ~= strsubst(startVisualComponent.name, " ", "") then
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                    thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x - stepXLine;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    fifthPoint = Point;
                    fifthPoint.x = forthPoint.x;
                    fifthPoint.y = connectionPathVisualList(i).path_points($).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, forthPoint, fifthPoint, %f, %f, thirdPoint);
                        forthPoint = correctedPoint1;
                        fifthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = fifthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                //otherwise, it is trigger which is connected to the bottom of the end visual component
                else
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                    //disp([string(startVisualComponent.pos_y) ; string(startVisualComponent.size_y) ; string(connectionPathVisualList(i).path_points(1).y) ]); //<>debug only
                    thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                end
                
                
            //if the connection is between this and the following component which is right behind the start component and at a different line
            elseif jIndexEnd == jIndexStart + 1 & kIndexEnd ~= kIndexStart then
                
                
                
                //get maximum X size of visual component in current J-column
                sizeXMaxJComponent = FindMaximumSizeXInJColumnOfSortedList(inSortedIndexesVisualComponents, iIndexStart, jIndexStart);
                offsetX = sizeXMaxJComponent - startVisualComponent.size_x;
                
                //if the start visual component is not trigger of the following component
                if strsubst(endVisualComponent.trigger, " ", "") ~= strsubst(startVisualComponent.name, " ", "") then
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine + offsetX;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    thirdPoint.y = connectionPathVisualList(i).path_points($).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                //otherwise, it is trigger which is connected to the top or bottom of the end visual component
                else
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine + offsetX;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    kDifference = abs(kIndexEnd - kIndexStart) - 1;
                    kYSpaceBetweenComponents = (kDifference * startVisualComponent.size_y) + (kDifference * ComponentsDistanceY);
                    //if the start visual copmonent is above the end visual component, the y position of third point has to be caluclated differently
                    if connectionPathVisualList(i).path_points(1).y > connectionPathVisualList(i).path_points($).y then
                        componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence - kYSpaceBetweenComponents;
                    else
                        componentYSizeInfluence = startVisualComponent.pos_y - connectionPathVisualList(i).path_points(1).y;
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y + stepYLine + componentYSizeInfluence + kYSpaceBetweenComponents;
                    end
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                end
                
                
            //if the connection is between this and the following component which is behind (but not right behind) the start component and at a different line
            elseif jIndexEnd >= jIndexStart + 2 & kIndexEnd ~= kIndexStart then
                
                
                
                //get maximum X size of visual component in current J-column
                sizeXMaxJComponent = FindMaximumSizeXInJColumnOfSortedList(inSortedIndexesVisualComponents, iIndexStart, jIndexStart);
                offsetX = sizeXMaxJComponent - startVisualComponent.size_x;
                
                //if the start visual component is not trigger of the following component
                if strsubst(endVisualComponent.trigger, " ", "") ~= strsubst(startVisualComponent.name, " ", "") then
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine + offsetX;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    kDifference = abs(kIndexEnd - kIndexStart) - 1;
                    kYSpaceBetweenComponents = (kDifference * startVisualComponent.size_y) + (kDifference * ComponentsDistanceY);
                    //if the start visual copmonent is above the end visual component, the y position of third point has to be caluclated differently
                    if connectionPathVisualList(i).path_points(1).y > connectionPathVisualList(i).path_points($).y then
                        componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence - kYSpaceBetweenComponents;
                    else
                        componentYSizeInfluence = startVisualComponent.pos_y - connectionPathVisualList(i).path_points(1).y;
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y + stepYLine + componentYSizeInfluence + kYSpaceBetweenComponents;
                    end
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x - stepXLine;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    fifthPoint = Point;
                    fifthPoint.x = forthPoint.x;
                    fifthPoint.y = connectionPathVisualList(i).path_points($).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, forthPoint, fifthPoint, %f, %f, thirdPoint);
                        forthPoint = correctedPoint1;
                        fifthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = fifthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                //otherwise, it is trigger which is connected to the top or bottom of the end visual component
                else
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine + offsetX;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    kDifference = abs(kIndexEnd - kIndexStart) - 1;
                    kYSpaceBetweenComponents = (kDifference * startVisualComponent.size_y) + (kDifference * ComponentsDistanceY);
                    //if the start visual copmonent is above the end visual component, the y position of third point has to be caluclated differently
                    if connectionPathVisualList(i).path_points(1).y > connectionPathVisualList(i).path_points($).y then
                        componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence - kYSpaceBetweenComponents;
                    else
                        componentYSizeInfluence = startVisualComponent.pos_y - connectionPathVisualList(i).path_points(1).y;
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y + stepYLine + componentYSizeInfluence + kYSpaceBetweenComponents;
                    end
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                end
                
                
            //if the connection is between this and the previous or same-J-column component no matter which line it is
            elseif jIndexEnd <= jIndexStart then
                
                
                
                //get maximum X size of visual component in current J-column
                sizeXMaxJComponent = FindMaximumSizeXInJColumnOfSortedList(inSortedIndexesVisualComponents, iIndexStart, jIndexStart);
                offsetX = sizeXMaxJComponent - startVisualComponent.size_x;
                
                //if the start visual component is not trigger of the following component
                if strsubst(endVisualComponent.trigger, " ", "") ~= strsubst(startVisualComponent.name, " ", "") then
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine + offsetX;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    kDifference = abs(kIndexEnd - kIndexStart) - 1;
                    kYSpaceBetweenComponents = (kDifference * startVisualComponent.size_y) + (kDifference * ComponentsDistanceY);
                    //if the start visual copmonent is above the end visual component, the y position of third point has to be caluclated differently
                    if connectionPathVisualList(i).path_points(1).y > connectionPathVisualList(i).path_points($).y then
                        componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence - kYSpaceBetweenComponents;
                    else
                        componentYSizeInfluence = startVisualComponent.pos_y - connectionPathVisualList(i).path_points(1).y;
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y + stepYLine + componentYSizeInfluence + kYSpaceBetweenComponents;
                    end
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x - stepXLine;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    fifthPoint = Point;
                    fifthPoint.x = forthPoint.x;
                    fifthPoint.y = connectionPathVisualList(i).path_points($).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, forthPoint, fifthPoint, %f, %f, thirdPoint);
                        forthPoint = correctedPoint1;
                        fifthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = fifthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                //otherwise, it is trigger which is connected to the top or bottom of the end visual component
                else
                    
                    
                    secondPoint = Point;
                    secondPoint.x = connectionPathVisualList(i).path_points(1).x + stepXLine + offsetX;
                    secondPoint.y = connectionPathVisualList(i).path_points(1).y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(1), secondPoint, %t, %f, []);
                        secondPoint = correctedPoint2;
                    end
                    
                    thirdPoint = Point;
                    thirdPoint.x = secondPoint.x;
                    kDifference = abs(kIndexEnd - kIndexStart) - 1;
                    kYSpaceBetweenComponents = (kDifference * startVisualComponent.size_y) + (kDifference * ComponentsDistanceY);
                    //if the start visual copmonent is above the end visual component, the y position of third point has to be caluclated differently
                    if connectionPathVisualList(i).path_points(1).y > connectionPathVisualList(i).path_points($).y then
                        componentYSizeInfluence = connectionPathVisualList(i).path_points(1).y - (startVisualComponent.pos_y - startVisualComponent.size_y);
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y - stepYLine - componentYSizeInfluence - kYSpaceBetweenComponents;
                    else
                        componentYSizeInfluence = startVisualComponent.pos_y - connectionPathVisualList(i).path_points(1).y;
                        thirdPoint.y = connectionPathVisualList(i).path_points(1).y + stepYLine + componentYSizeInfluence + kYSpaceBetweenComponents;
                    end
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, secondPoint, thirdPoint, %f, %f, connectionPathVisualList(i).path_points(1));
                        secondPoint = correctedPoint1;
                        thirdPoint = correctedPoint2;
                    end
                    
                    forthPoint = Point;
                    forthPoint.x = connectionPathVisualList(i).path_points($).x;
                    forthPoint.y = thirdPoint.y;
                    if checkOverlappingOfLines == %t then
                        //correct overlapping line if necessary
                        [correctedPoint1, correctedPoint2] = GetNotOverlappingPoints(connectionPathVisualList, i-1, thirdPoint, forthPoint, %f, %f, secondPoint);
                        thirdPoint = correctedPoint1;
                        forthPoint = correctedPoint2;
                    end
                    
                    
                    //copy the last point and delete the last point from the list 
                    endPointCopy = CopyPoint(connectionPathVisualList(i).path_points($));
                    connectionPathVisualList(i).path_points($) = null();
                    //add the second, third and last point
                    connectionPathVisualList(i).path_points($+1) = secondPoint;
                    connectionPathVisualList(i).path_points($+1) = thirdPoint;
                    connectionPathVisualList(i).path_points($+1) = forthPoint;
                    connectionPathVisualList(i).path_points($+1) = endPointCopy;
                    
                    
                end
                
                
            //otherwise, something is wrong - this option should not happen
            else
                
                disp(["Unknown error - unpredictable option for path generation: " ; "iIndexStart, jIndexStart, kIndexStart: " + string(iIndexStart) + ", " + string(jIndexStart) + ", " + string(kIndexStart) ; "iIndexEnd, jIndexEnd, kIndexEnd: " + string(iIndexEnd) + ", " + string(jIndexEnd) + ", " + string(kIndexEnd) ; "start_index: " + string(connectionPathVisualList(i).start_index) ; "start_name: " + connectionPathVisualList(i).start_name ; "end_index: " + string(connectionPathVisualList(i).end_index) ; "end_name: " + connectionPathVisualList(i).end_name ; "number of path occurences: " + string(connectionPathVisualList(i).number_of_occurrences) ]);
                
            end
            
            
        end
        
        
        
        //if this is not the first connection path
        if i > 1 then
            
            //go through all path points/lines of the current connection path
            j = 1;
            jIterationMax = 60;
            while j <= length(connectionPathVisualList(i).path_points) - 1 & j < jIterationMax
                
                //check only connection paths which are before the current connection path
                [pathLineCrossAnother, xLocationCross, yLocationCross] = DoesPathLineCrossAnother(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(j), connectionPathVisualList(i).path_points(j+1));
                
//                //<>debug only
//                if pathLineCrossAnother == %t then
//                    disp(["xLocationCross: " + string(xLocationCross) ; "yLocationCross: " + string(yLocationCross) ; "connectionPathVisualList(i).path_points(j): " + string(connectionPathVisualList(i).path_points(j).x) + ", " + string(connectionPathVisualList(i).path_points(j).y) ; "connectionPathVisualList(i).path_points(j+1): " + string(connectionPathVisualList(i).path_points(j+1).x) + ", " + string(connectionPathVisualList(i).path_points(j+1).y)]);
//                end
                
                kIteration = 1;
                kIterationMax = 20;
                //while the line crossed the line (:-)) repeat the cycle to remove the cross using new points with arc connection type
                while pathLineCrossAnother == %t & kIteration < kIterationMax
                    
                    //disp("uvnitr"); //<>debug only
                    startArcPoint = Point;
                    startArcPoint.connection_type = PointConnectionTypes(2);   //set arc connection type
                    endArcPoint = Point;
                    
                    
                    //if the current line is vertical
                    if connectionPathVisualList(i).path_points(j).x == connectionPathVisualList(i).path_points(j+1).x then
                        
                        //set x position as the x position of the start point (end point and xLocationCross should also work)
                        startArcPoint.x = connectionPathVisualList(i).path_points(j).x;
                        endArcPoint.x = connectionPathVisualList(i).path_points(j).x;
                        
                        //if start point is above the end point
                        if connectionPathVisualList(i).path_points(j).y > connectionPathVisualList(i).path_points(j+1).y then
                            startArcPoint.y = yLocationCross + tolerCrossOverlapY;
                            endArcPoint.y = yLocationCross - tolerCrossOverlapY;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.y >= connectionPathVisualList(i).path_points(j).y then
                                startArcPoint.y = connectionPathVisualList(i).path_points(j).y - toleranceOverlapY / 4;
                            end
                            if endArcPoint.y <= connectionPathVisualList(i).path_points(j+1).y then
                                endArcPoint.y = connectionPathVisualList(i).path_points(j+1).y + toleranceOverlapY / 4;
                            end
                            
                        //otherwise, it is below (it should not be at same place)
                        else
                            startArcPoint.y = yLocationCross - tolerCrossOverlapY;
                            endArcPoint.y = yLocationCross + tolerCrossOverlapY;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.y <= connectionPathVisualList(i).path_points(j).y then
                                startArcPoint.y = connectionPathVisualList(i).path_points(j).y + toleranceOverlapY / 4;
                            end
                            if endArcPoint.y >= connectionPathVisualList(i).path_points(j+1).y then
                                endArcPoint.y = connectionPathVisualList(i).path_points(j+1).y - toleranceOverlapY / 4;
                            end
                        end
                        
                        
                    //else if the current line is horizontal
                    elseif connectionPathVisualList(i).path_points(j).y == connectionPathVisualList(i).path_points(j+1).y then
                        
                        //if start point is before the end point
                        if connectionPathVisualList(i).path_points(j).x < connectionPathVisualList(i).path_points(j+1).x then
                            startArcPoint.x = xLocationCross - tolerCrossOverlapX;
                            endArcPoint.x = xLocationCross + tolerCrossOverlapX;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.x <= connectionPathVisualList(i).path_points(j).x then
                                startArcPoint.x = connectionPathVisualList(i).path_points(j).x + toleranceOverlapX / 4;
                            end
                            if endArcPoint.x >= connectionPathVisualList(i).path_points(j+1).x then
                                endArcPoint.x = connectionPathVisualList(i).path_points(j+1).x - toleranceOverlapX / 4;
                            end
                        //otherwise, it is behind (it should not be at same place)
                        else
                            startArcPoint.x = xLocationCross + tolerCrossOverlapX;
                            endArcPoint.x = xLocationCross - tolerCrossOverlapX;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.x >= connectionPathVisualList(i).path_points(j).x then
                                startArcPoint.x = connectionPathVisualList(i).path_points(j).x - toleranceOverlapX / 4;
                            end
                            if endArcPoint.x <= connectionPathVisualList(i).path_points(j+1).x then
                                endArcPoint.x = connectionPathVisualList(i).path_points(j+1).x + toleranceOverlapX / 4;
                            end
                        end
                        
                        //set y position as the y position of the start point (end point and yLocationCross should also work)
                        startArcPoint.y = connectionPathVisualList(i).path_points(j).y;
                        endArcPoint.y = connectionPathVisualList(i).path_points(j).y;
                        
                        
                    //otherwise, this is not vertical neither horizontal but angled line (currently not supported)
                    else
                        
                        disp(["Angled lines are currently not supported in schema." ; "connectionPathVisualList(i).path_points(j): " + string(connectionPathVisualList(i).path_points(j).x) + ", " + connectionPathVisualList(i).path_points(j).y ; "connectionPathVisualList(i).path_points(j+1): " + connectionPathVisualList(i).path_points(j+1).x + ", " + connectionPathVisualList(i).path_points(j+1).y]);
                        
                        //if start point is before the end point
                        if connectionPathVisualList(i).path_points(j).x < connectionPathVisualList(i).path_points(j+1).x then
                            startArcPoint.x = xLocationCross - tolerCrossOverlapX;
                            endArcPoint.x = xLocationCross + tolerCrossOverlapX;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.x <= connectionPathVisualList(i).path_points(j).x then
                                startArcPoint.x = connectionPathVisualList(i).path_points(j).x + toleranceOverlapX / 4;
                            end
                            if endArcPoint.x >= connectionPathVisualList(i).path_points(j+1).x then
                                endArcPoint.x = connectionPathVisualList(i).path_points(j+1).x - toleranceOverlapX / 4;
                            end
                        //otherwise, it is behind (it should not be at same place)
                        else
                            startArcPoint.x = xLocationCross + tolerCrossOverlapX;
                            endArcPoint.x = xLocationCross - tolerCrossOverlapX;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.x >= connectionPathVisualList(i).path_points(j).x then
                                startArcPoint.x = connectionPathVisualList(i).path_points(j).x - toleranceOverlapX / 4;
                            end
                            if endArcPoint.x <= connectionPathVisualList(i).path_points(j+1).x then
                                endArcPoint.x = connectionPathVisualList(i).path_points(j+1).x + toleranceOverlapX / 4;
                            end
                        end
                        
                        //if start point is above the end point
                        if connectionPathVisualList(i).path_points(j).y > connectionPathVisualList(i).path_points(j+1).y then
                            startArcPoint.y = yLocationCross + tolerCrossOverlapY;
                            endArcPoint.y = yLocationCross - tolerCrossOverlapY;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.y >= connectionPathVisualList(i).path_points(j).y then
                                startArcPoint.y = connectionPathVisualList(i).path_points(j).y - toleranceOverlapY / 4;
                            end
                            if endArcPoint.y <= connectionPathVisualList(i).path_points(j+1).y then
                                endArcPoint.y = connectionPathVisualList(i).path_points(j+1).y + toleranceOverlapY / 4;
                            end
                        //otherwise, it is below (it should not be at same place)
                        else
                            startArcPoint.y = yLocationCross - tolerCrossOverlapY;
                            endArcPoint.y = yLocationCross + tolerCrossOverlapY;
                            //check if the arc points are between the start and end point 
                            if startArcPoint.y <= connectionPathVisualList(i).path_points(j).y then
                                startArcPoint.y = connectionPathVisualList(i).path_points(j).y + toleranceOverlapY / 4;
                            end
                            if endArcPoint.y >= connectionPathVisualList(i).path_points(j+1).y then
                                endArcPoint.y = connectionPathVisualList(i).path_points(j+1).y - toleranceOverlapY / 4;
                            end
                        end
                        
                        
                    end
                    
                    
//                    disp(["startArcPoint: " + string(startArcPoint.x) + ", " + string(startArcPoint.y) ; "endArcPoint: " + string(endArcPoint.x) + ", " + string(endArcPoint.y)]);    //<>debug only
                    //insert new start and end arc points to the current path point list
                    connectionPathVisualList(i).path_points = lstcat(list(connectionPathVisualList(i).path_points(1:j)), list(startArcPoint), list(endArcPoint), list(connectionPathVisualList(i).path_points(j+1:length(connectionPathVisualList(i).path_points))));
                    
                    
                    //check only connection paths which are before the current connection path
                    [pathLineCrossAnother, xLocationCross, yLocationCross] = DoesPathLineCrossAnother(connectionPathVisualList, i-1, connectionPathVisualList(i).path_points(j), connectionPathVisualList(i).path_points(j+1));
                    
                    
//                    //<>debug only
//                    if pathLineCrossAnother == %t then
//                        disp(["xLocationCross: " + string(xLocationCross) ; "yLocationCross: " + string(yLocationCross) ; "connectionPathVisualList(i).path_points(j): " + string(connectionPathVisualList(i).path_points(j).x) + ", " + string(connectionPathVisualList(i).path_points(j).y) ; "connectionPathVisualList(i).path_points(j+1): " + string(connectionPathVisualList(i).path_points(j+1).x) + ", " + string(connectionPathVisualList(i).path_points(j+1).y) ; "startArcPoint: " + string(startArcPoint.x) + ", " + string(startArcPoint.y) ; "endArcPoint: " + string(endArcPoint.x) + ", " + string(endArcPoint.y)]);
//                    end
                    
                    
                    //increment the kIteration check index
                    kIteration = kIteration + 1;
                end
                
                //disp("venku");//<>debug only
                //increment the 'j' index
                j = j + 1;
            end
        
        end
        
        
    end
    
    
    
endfunction



function [correctedPoint1, correctedPoint2]=GetNotOverlappingPoints(connectionPathVisualList, endIterationConnectionPath, pointStart, pointEnd, isFixedStart, isFixedEnd, pointPreStart)
    
    correctedPoint1 = CopyPoint(pointStart);
    correctedPoint2 = CopyPoint(pointEnd);
    
    //check if the line overlaps with another which was already drawn
    [pathLineOverlapsAnother, startPointOverlap, endPointOverlap] = DoesPathLineOverlapAnother(connectionPathVisualList, endIterationConnectionPath, correctedPoint1, correctedPoint2);
    
    tempStepXLine = stepXLine / 2;
    tempStepYLine = stepYLine / 2;
    //there are only limited (maxIteration) attempts to solve overlapping
    iteration = 1;
    maxIteration = 20;
    if isFixedStart == %f | isFixedEnd == %f then
        iterationStepDistance = 1;
        while pathLineOverlapsAnother == %t & iteration <= maxIteration
            
            
            //get lower and higher value of x and y position from start and end point
            //[lowerPoint1X, higherPoint1X] = GetLowerAndHigherValue(startPointOverlap.x, endPointOverlap.x);
            //[lowerPoint1Y, higherPoint1Y] = GetLowerAndHigherValue(startPointOverlap.y, endPointOverlap.y);
            
            
            //if start point is not fixed
            if isFixedStart == %f then
                
                
                //if x position of both points is same, only x position will be changed (excluding situation when end point is fixed)
                if pointStart.x == pointEnd.x then
                    
                    
                    //if end point is fixed, it is the end of the path
                    if isFixedEnd == %t then
                        
                        
                        //if y position of end point is between overlapping start point and overlapping end point
                        if pointStart.y >= startPointOverlap.y & pointStart.y <= endPointOverlap.y then
                            
                            
                            //if first point is above the second point, subtract
                            if pointStart.y > pointEnd.y then
                                
                                //overlapping start point is lower, so use it as the origin
                                correctedPoint1.y = startPointOverlap.y - tempStepYLine * iterationStepDistance;
                                
                            //else if first point is below the second point, add
                            elseif pointStart.y < pointEnd.y then
                                
                                //overlapping end point is higher, so use it as the origin
                                correctedPoint1.y = endPointOverlap.y + tempStepYLine * iterationStepDistance;
                                
                            else
                                disp(["X and Y positions of start and end point are same (i.e. exactly same points are not allowed): (isNotFixedStart (1), isFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                                break;
                            end
                            
                            
                        //else if y position of end point is between overlapping end point and overlapping start point
                        elseif pointStart.y >= endPointOverlap.y & pointStart.y <= startPointOverlap.y then
                            
                            
                            //if first point is above the second point, subtract
                            if pointStart.y > pointEnd.y then
                                
                                //overlapping end point is lower, so use it as the origin
                                correctedPoint1.y = endPointOverlap.y - tempStepYLine * iterationStepDistance;
                                
                            //else if first point is below the second point, add
                            elseif pointStart.y < pointEnd.y then
                                
                                //overlapping start point is higher, so use it as the origin
                                correctedPoint1.y = startPointOverlap.y + tempStepYLine * iterationStepDistance;
                                
                            else
                                disp(["X and Y positions of start and end point are same (i.e. exactly same points are not allowed): (isNotFixedStart (2), isFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                                break;
                            end
                            
                            
                        //else if y position of overlapping points are between start and end point
                        elseif startPointOverlap.y >= pointStart.y & endPointOverlap.y >= pointStart.y & startPointOverlap.y <= pointEnd.y & endPointOverlap.y <= pointEnd.y  |  startPointOverlap.y <= pointStart.y & endPointOverlap.y <= pointStart.y & startPointOverlap.y >= pointEnd.y & endPointOverlap.y >= pointEnd.y then
                            
                            
                            //if first point is above the second point, subtract
                            if pointStart.y > pointEnd.y then
                                
                                //if overlapping end point is above overlapping start point
                                if startPointOverlap.y < endPointOverlap.y then
                                    
                                    correctedPoint1.y = startPointOverlap.y - tempStepYLine * iterationStepDistance;
                                    
                                //otherwise, overlapping start point is above overlapping end point or they are same (which should not happen)
                                else
                                    
                                    correctedPoint1.y = endPointOverlap.y - tempStepYLine * iterationStepDistance;
                                    
                                end
                                
                            //else if first point is below the second point, add
                            elseif pointStart.y < pointEnd.y then
                                
                                //if overlapping end point is above overlapping start point
                                if startPointOverlap.y < endPointOverlap.y then
                                    
                                    correctedPoint1.y = endPointOverlap.y + tempStepYLine * iterationStepDistance;
                                    
                                //otherwise, overlapping start point is above overlapping end point or they are same (which should not happen)
                                else
                                    
                                    correctedPoint1.y = startPointOverlap.y + tempStepYLine * iterationStepDistance;
                                    
                                end
                                
                            else
                                disp(["X and Y positions of start and end point are same (i.e. exactly same points are not allowed): (isNotFixedStart (3), isFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                                break;
                            end
                            
                            
                        //otherwise, error occurred
                        else
                            disp(["Y position of end point is not between overlapping line: (isNotFixedStart, isFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                            break;
                        end
                        
                        
                        //decrease step line if necessary (depending on stepYLine' distance parameter) and increase or reset iteration for step distance
                        [tempStepYLine, iterationStepDistance] = DecreseStepLineIfNecessary(tempStepYLine, stepYLine, iterationStepDistance);
                        
                        
                    else
                        
                        
                        correctedPoint1.x = pointStart.x - tempStepXLine * iterationStepDistance;
                        //if x position of corrected point is before x position of the previous point (should be set in this situation) and the path should go to the right, correct the corrected value
                        if pointPreStart ~= [] then
                            if correctedPoint1.x <= pointPreStart.x & pointPreStart.x < pointStart.x then
                                correctedPoint1.x = pointPreStart.x + tempStepXLine / 2 * iterationStepDistance;
                            end
                        else
                            disp(["There is no fixed point but also no previous point: (isNotFixedStart, isNotFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                            break;
                        end
                        //disp(["correctedPoint1.x: " + string(correctedPoint1.x) ; "pointStart.x: " + string(pointStart.x) ; "pointPreStart.x: " + string(pointPreStart.x) ; "tempStepXLine: " + string(tempStepXLine) ; "iterationStepDistance: " + string(iterationStepDistance) ; "stepXLine: " + string(stepXLine) ]);  //<>debug only
                        //decrease step line if necessary (depending on stepXLine' distance parameter) and increase or reset iteration for step distance
                        [tempStepXLine, iterationStepDistance] = DecreseStepLineIfNecessary(tempStepXLine, stepXLine, iterationStepDistance);
                        
//                        //<>debug only
//                        if round(startPointOverlap.x * 10000000) == 36973856.0 & round(startPointOverlap.y * 10000000) == 9928935.0 & round(endPointOverlap.x * 10000000) == 36973856.0 & round(endPointOverlap.y * 10000000) == 8077623.0 then
//                            disp(["je tu stejne x ruzne y" ; "iteration: " + string(iteration) ; "correctedPoint1.x: " + string(correctedPoint1.x) ; "iterationStepDistance: " + string(iterationStepDistance) ; "tempStepXLine: " + string(tempStepXLine) ]);
//                        end
                        
                    end
                    
                    
                //if y position of both points is same, only y position will be changed (excluding situation when end point is fixed)
                elseif pointStart.y == pointEnd.y then
                    
                    
                    //if end point is fixed, it is the end of the path
                    if isFixedEnd == %t then
                        
                        
                        //if x poistion of end point is between overlapping start point and overlapping end point
                        if pointStart.x >= startPointOverlap.x & pointStart.x <= endPointOverlap.x then
                            
                            correctedPoint1.x = endPointOverlap.x + tempStepXLine * iterationStepDistance;
                            
                        //else if x poistion of end point is between overlapping end point and overlapping start point
                        elseif pointStart.x >= endPointOverlap.x & pointStart.x <= startPointOverlap.x then
                            
                            correctedPoint1.x = startPointOverlap.x + tempStepXLine * iterationStepDistance;
                            
                        //else if x poistion of overlapping points are between start and end point
                        elseif startPointOverlap.x >= pointStart.x & endPointOverlap.x >= pointStart.x & startPointOverlap.x <= pointEnd.x & endPointOverlap.x <= pointEnd.x  |  startPointOverlap.x <= pointStart.x & endPointOverlap.x <= pointStart.x & startPointOverlap.x >= pointEnd.x & endPointOverlap.x >= pointEnd.x then
                            
                            //if overlapping end point is behind overlapping start point
                            if startPointOverlap.x < endPointOverlap.x then
                                
                                correctedPoint1.x = endPointOverlap.x + tempStepXLine * iterationStepDistance;
                                
                            //otherwise, overlapping start point is behind overlapping end point or they are same (which should not happen)
                            else
                                
                                correctedPoint1.x = startPointOverlap.x + tempStepXLine * iterationStepDistance;
                                
                            end
                            
                        //otherwise, error occurred
                        else
                            disp(["X position of start point is not between overlapping line: (isNotFixedStart, isFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                            break;
                        end
                        
                        
                        //decrease step line if necessary (depending on stepXLine' distance parameter) and increase or reset iteration for step distance
                        [tempStepXLine, iterationStepDistance] = DecreseStepLineIfNecessary(tempStepXLine, stepXLine, iterationStepDistance);
                        
                        
                    else
                        
                        
                        //if there is a previous point
                        if pointPreStart ~= [] then
                            
                            //if the previous point is above the start point, add
                            if pointPreStart.y > pointStart.y then
                                
                                correctedPoint1.y = pointStart.y + tempStepYLine * iterationStepDistance;
                                
                            //otherwise, the previous point is below the start point (it should not be same due to code), subtract
                            else
                            
                                correctedPoint1.y = pointStart.y - tempStepYLine * iterationStepDistance;
                                
                            end
                            //disp(["correctedPoint1.y: " + string(correctedPoint1.y) ; "pointStart.y: " + string(pointStart.y) ; "pointPreStart.y: " + string(pointPreStart.y) ; "tempStepYLine: " + string(tempStepYLine) ; "iterationStepDistance: " + string(iterationStepDistance) ; "stepYLine: " + string(stepYLine) ]);  //<>debug only
                            //decrease step line if necessary (depending on stepYLine' distance parameter) and increase or reset iteration for step distance
                            [tempStepYLine, iterationStepDistance] = DecreseStepLineIfNecessary(tempStepYLine, stepYLine, iterationStepDistance);
                            
//                            //<>debug only
//                            if round(startPointOverlap.x * 10000000) == 36973856.0 & round(startPointOverlap.y * 10000000) == 8077623.0 & round(endPointOverlap.x * 10000000) == 50199110.0 & round(endPointOverlap.y * 10000000) == 8077623.0 then
//                                disp(["je tu ruzne x stejne y" ; "iteration: " + string(iteration) ; "correctedPoint1.y: " + string(correctedPoint1.y) ; "iterationStepDistance: " + string(iterationStepDistance) ; "tempStepYLine: " + string(tempStepYLine) ]);
//                            end
                            
                        //otherwise, there is no fixed point but also no previous point which cannot happened
                        else
                            disp(["There is no fixed point but also no previous point: (isNotFixedStart, isNotFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; "corrected points:" + string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                            break;
                        end
                        
                        
                    end
                    
                    
                else
                    
                    disp(["Unsupported line in GetNotOverlappingPoints (isNotFixedStart)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; string(pointEnd.x) + ", " + string(pointEnd.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y) ]);
                    break;
                    
                end
                
                
            end
            
            
            
            //if end point is not fixed
            if isFixedEnd == %f then
                
                
                //if x position of both points is same, only x position will be changed
                if pointStart.x == pointEnd.x then
                    
                    
                    //because the x position of start point was already corrected, just copy it
                    //note: start point of vertical line cannot be fixed; excluding trigger with no visual component but there should not be any overlapping line due to principle of code
                    correctedPoint2.x = correctedPoint1.x;
                    
                    
                //if y position of both points is same, only y position will be changed (excluding situation when start point is fixed)
                elseif pointStart.y == pointEnd.y then
                    
                    
                    //if start point is fixed, it is the start of the path (only for the horizontal line because in our case, paths cannot start with a vertical line - excluding trigger without visual component but there should not be any overlapping due to principle of code)
                    if isFixedStart == %t then
                        
                        
                        //if x poistion of end point is between overlapping start point and overlapping end point
                        if pointEnd.x >= startPointOverlap.x & pointEnd.x <= endPointOverlap.x then
                            
                            correctedPoint2.x = startPointOverlap.x - tempStepXLine * iterationStepDistance;
                            
                        //else if x poistion of end point is between overlapping end point and overlapping start point
                        elseif pointEnd.x >= endPointOverlap.x & pointEnd.x <= startPointOverlap.x then
                            
                            correctedPoint2.x = endPointOverlap.x - tempStepXLine * iterationStepDistance;
                            
                        //else if x poistion of overlapping points are between start and end point
                        elseif startPointOverlap.x >= pointStart.x & endPointOverlap.x >= pointStart.x & startPointOverlap.x <= pointEnd.x & endPointOverlap.x <= pointEnd.x  |  startPointOverlap.x <= pointStart.x & endPointOverlap.x <= pointStart.x & startPointOverlap.x >= pointEnd.x & endPointOverlap.x >= pointEnd.x then
                            
                            //if overlapping start point is before overlapping end point
                            if startPointOverlap.x < endPointOverlap.x then
                                
                                correctedPoint2.x = startPointOverlap.x - tempStepXLine * iterationStepDistance;
                                
                            //otherwise, overlapping end point is before overlapping start point or they are same (which should not happen)
                            else
                                
                                correctedPoint2.x = endPointOverlap.x - tempStepXLine * iterationStepDistance;
                                
                            end
                            
                        //otherwise, error occurred
                        else
                            disp(["X position of end point is not between overlapping line: (isFixedStart, isNotFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; string(pointEnd.x) + ", " + string(pointEnd.y) ; "corrected points: " ; string(correctedPoint1.x) + ", " + string(correctedPoint1.y) ; string(correctedPoint2.x) + ", " + string(correctedPoint2.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                            break;
                        end
                        
                        
                        //decrease step line if necessary (depending on stepXLine' distance parameter) and increase or reset iteration for step distance
                        [tempStepXLine, iterationStepDistance] = DecreseStepLineIfNecessary(tempStepXLine, stepXLine, iterationStepDistance);
                        
                        
                    //otherwise, start point is not fixed
                    else
                        
                        //because the y position of start point was already corrected, just copy it
                        correctedPoint2.y = correctedPoint1.y;
                        
                    end
                    
                    
                else
                    
                    disp(["Unsupported line in GetNotOverlappingPoints (isNotFixedEnd)" ; "tested points: " ; string(pointStart.x) + ", " + string(pointStart.y) ; string(pointEnd.x) + ", " + string(pointEnd.y) ; "overlapping points: " ; string(startPointOverlap.x) + ", " + string(startPointOverlap.y) ; string(endPointOverlap.x) + ", " + string(endPointOverlap.y)]);
                    break;
                    
                end
                
                
            end
            
            
            
            //check if the line overlaps with another which was already drawn
            [pathLineOverlapsAnother, startPointOverlap, endPointOverlap] = DoesPathLineOverlapAnother(connectionPathVisualList, endIterationConnectionPath, correctedPoint1, correctedPoint2);
            //increase iteration number
            iteration = iteration + 1;
            
            
            
        end
    end
    
endfunction



function [outStepLine, outIteration]=DecreseStepLineIfNecessary(inStepLine, maxComponentDistance, inIteration)
    
    outStepLine = inStepLine;
    outIteration = inIteration + 1;
    
    //if the next step is out of maximal component distance, decrease the step and reset iteration information
    if outStepLine * outIteration >= maxComponentDistance then
        outStepLine = outStepLine / 2;
        outIteration = 1;
    end
    
endfunction



function [outPointCopied]=CopyPoint(inputPoint)
    
    //create new point and copy the current input point
    outPointCopied = Point;
    outPointCopied.x = inputPoint.x;
    outPointCopied.y = inputPoint.y;
    outPointCopied.connection_type = inputPoint.connection_type;
    
endfunction



function [sizeXMax]=FindMaximumSizeXInJColumnOfSortedList(inSortedIndexesVisualComponents, iIndex, jIndex)
    
    //find maximum X size of the components in the J-column of the current path
    sizeXMax = 0;
    for k = 1 : 1 : length(inSortedIndexesVisualComponents(iIndex)(jIndex))
        
        //check if the current number is maximum
        if sizeXMax < xmlVisualComponentsList(inSortedIndexesVisualComponents(iIndex)(jIndex)(k).main_index).size_x then
            sizeXMax = xmlVisualComponentsList(inSortedIndexesVisualComponents(iIndex)(jIndex)(k).main_index).size_x;
        end
        
    end
    
endfunction



function [iIndex, jIndex, kIndex]=FindIndexesOfVisualComponentInSortedListIndexes(inSortedIndexesVisualComponents, indexVisualComponent)
    
    //find visual component in list of sorted indexed visual components
    for i = 1 : 1 : length(inSortedIndexesVisualComponents)
        for j = 1 : 1 : length(inSortedIndexesVisualComponents(i))
            for k = 1 : 1 : length(inSortedIndexesVisualComponents(i)(j))
                
                if inSortedIndexesVisualComponents(i)(j)(k).main_index == indexVisualComponent then
                    iIndex = i;
                    jIndex = j;
                    kIndex = k;
                    return;
                end
                
            end
        end
    end
    
endfunction



function DrawConnectionsOfVisualComponents(handleAxes, connectionPathVisualList, xmlVisualComponentsList)
    
    
    //Draw connections of the visual components using path points
    for i = 1 : 1 : length(connectionPathVisualList)
        
        
        for j = 1 : 1 : length(connectionPathVisualList(i).path_points) - 1
            
            //if the current path is line
            if connectionPathVisualList(i).path_points(j).connection_type == PointConnectionTypes(1) then
                
                xVector = [connectionPathVisualList(i).path_points(j).x, connectionPathVisualList(i).path_points(j+1).x];
                yVector = [connectionPathVisualList(i).path_points(j).y, connectionPathVisualList(i).path_points(j+1).y];
                //if this is not the pre-last point, draw line only
                if j < length(connectionPathVisualList(i).path_points) - 1 then
                    
                    //join two points using full line
                    xpoly(xVector, yVector, "lines");
                    
                //otherwise, this is the pre-last point, draw line with arrow
                else
                    
                    //join two points using full line with arrow at the end
                    xarrows(xVector, yVector, sizeOfArrow);
                    
                end
                
            //else if the current path is arc
            elseif connectionPathVisualList(i).path_points(j).connection_type == PointConnectionTypes(2) then
                
                if j < length(connectionPathVisualList(i).path_points) - 1 then
                    
                    firstPoint = connectionPathVisualList(i).path_points(j);
                    secondPoint = connectionPathVisualList(i).path_points(j+1);
                    //get start and end x position for xarc function
                    [lowerX, higherX] = GetLowerAndHigherValue(firstPoint.x, secondPoint.x);
                    //get start and end y position for xarc function
                    [lowerY, higherY] = GetLowerAndHigherValue(firstPoint.y, secondPoint.y);
                    
                    //set initial angle and width and height values
                    initialAngle = 0;
                    widthArc = higherX - lowerX;
                    heightArc = higherY - lowerY;
                    //if the arc is vertical
                    if lowerX == higherX then
                        
                        //set width to same value as height (otherwise, the arc would be just strange line)
                        widthArc = heightArc;
                        //lower x position has to be decreased by a half of the arc width
                        lowerX = lowerX - widthArc / 2;
                        
                        //if the path goes from the bottom to the top
                        if firstPoint.y < secondPoint.y then
                            initialAngle = 90*64;   //arc at the left side
                        //otherwise, the path goes from the top to the bottom (or it is equal to - which should not happen)
                        else
                            initialAngle = 270*64;  //arc at the right side
                        end
                        
                    //else if the arc is horizontal
                    elseif lowerY == higherY then
                        
                        //set height to same value as width (otherwise, the arc would be just strange line)
                        heightArc = widthArc;
                        //higher y position has to be increased by a half of the arc height
                        higherY = higherY + heightArc / 2;
                        
                        //if the path goes from the left to the right
                        if firstPoint.x < secondPoint.x then
                            initialAngle = 0;   //arc at the top side
                        //otherwise, the path goes from the right to the left (or it is equal to - which should not happen)
                        else
                            initialAngle = 180*64;   //arc at the bottom side
                        end
                        
                    //otherwise, there is some error, the arc cannot be angled (it is not supported yet)
                    else
                        
                        disp(["Arc cannot be angled." ; "firstPoint: " + string(firstPoint.x) + ", " + string(firstPoint.y) ; "secondPoint: " + string(secondPoint.x) + ", " + string(secondPoint.y)]);
                        //continue;
                        
                    end
                    
                    
                    //create half ellipse to jump over a cross line
                    xarc(lowerX, higherY, widthArc, heightArc, initialAngle, 180*64);
                    
                    
                //the last two points should not create arc but line, something is wrong
                else
                    
                    disp(["The last two points of path cannot create arc: " ; string(connectionPathVisualList(i).path_points(j).x) + ", " + string(connectionPathVisualList(i).path_points(j).y) ; string(connectionPathVisualList(i).path_points(j+1).x) + ", " + string(connectionPathVisualList(i).path_points(j+1).y) ; "start_name: " + connectionPathVisualList(i).start_name ; "end_name: " + connectionPathVisualList(i).end_name]);
                    
                end
                
            //otherwise, something is really wrong
            else
                disp(["Undefined connection type: " + connectionPathVisualList(i).path_points(j).connection_type ; "and path point: (" + string(connectionPathVisualList(i).path_points(j).x) + ", " + string(connectionPathVisualList(i).path_points(j).y) + ")" ; "path point number: " + string(j)]);
                //"for path: " + connectionPathVisualList(i).path_points ; 
            end
            
        end
        
        
        
        
        //draw text if there should be any - e.g. name of input/output/trigger, property, number of occurences.
        //check start and end index of this path - if there is 0, name of component has to be drawn (they should not be both 0 because it would actually mean a path from no component to no component)
        if connectionPathVisualList(i).start_index == 0 then
            
            
            rectStartName = xstringl(0, 0, strsubst(connectionPathVisualList(i).start_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
            
            //check if path begins with vertical line (i.e. there are same first two x points)
            if connectionPathVisualList(i).path_points(1).x == connectionPathVisualList(i).path_points(2).x then
                
                
                xstringb(connectionPathVisualList(i).path_points(1).x - rectStartName(3) - TextComponentDistanceX, connectionPathVisualList(i).path_points(1).y + TextLineDistanceY, strsubst(connectionPathVisualList(i).start_name, " ", ""), rectStartName(3), rectStartName(4), "fill");
                
                
            //check if path begins with horizontal line (i.e. there are same first two y points)
            elseif connectionPathVisualList(i).path_points(1).y == connectionPathVisualList(i).path_points(2).y then
                
                
                xstringb(connectionPathVisualList(i).path_points(1).x - TextComponentDistanceX, connectionPathVisualList(i).path_points(1).y + TextLineDistanceY, strsubst(connectionPathVisualList(i).start_name, " ", ""), rectStartName(3), rectStartName(4), "fill");
                
                
            //otherwise something is wrong because it should not be other type of line
            else
                disp(["Wrong connection with 0 start index (the first two points do not create vertical or horizontal line): " + connectionPathVisualList(i).path_points(1).connection_type ; "for path point: (" + string(connectionPathVisualList(i).path_points(1).x) + ", " + string(connectionPathVisualList(i).path_points(1).y) + ")" ; "path point number: " + string(1)]); //"for path: " + connectionPathVisualList(i).path_points ; 
            end
            
            
        //else if end index is 0, the output is a property, so draw its name
        elseif connectionPathVisualList(i).end_index == 0 then
            
            rectEndName = xstringl(0, 0, strsubst(connectionPathVisualList(i).end_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
            
            //check if path ends with vertical line (i.e. there are same last two x points)
            if connectionPathVisualList(i).path_points($).x == connectionPathVisualList(i).path_points($-1).x then
                
                
                xstringb(connectionPathVisualList(i).path_points($).x + TextComponentDistanceX * 2, connectionPathVisualList(i).path_points($).y + TextLineDistanceY, strsubst(connectionPathVisualList(i).end_name, " ", ""), rectEndName(3), rectEndName(4), "fill");
                //xstring(connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).x + TextComponentDistanceX, connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).y + TextLineDistanceY, strsubst(connectionPathVisualList(i).end_name, " ", ""));
                
                
            //check if path ends with horizontal line (i.e. there are same last two y points)
            elseif connectionPathVisualList(i).path_points($).y == connectionPathVisualList(i).path_points($-1).y then
                
                
                xstringb(connectionPathVisualList(i).path_points($).x - rectEndName(3) - TextComponentDistanceX * 2, connectionPathVisualList(i).path_points($).y + TextLineDistanceY, strsubst(connectionPathVisualList(i).end_name, " ", ""), rectEndName(3), rectEndName(4), "fill");
                //xstring(connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).x - rectEndName(3) - TextComponentDistanceX, connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).y + TextLineDistanceY, strsubst(connectionPathVisualList(i).end_name, " ", ""));
                
                
            //otherwise something is wrong because it should not be other type of lines
            else
                disp(["Wrong connection with 0 end index (the last two points do not create vertical or horizontal line): " + connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).connection_type ; "for path point: (" + string(connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).x) + ", " + string(connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).y) + ")" ; "path point number: " + string(length(connectionPathVisualList(i).path_points))]); //"for path: " + connectionPathVisualList(i).path_points ; 
            end
            
            
        end
        
        
        
        //set color which will be used for drawing of special notes such as number of occurence or trigger tag
        colorForNotes = color("blue4");
        
        //check number of occurences - if there is more than 1, the value should be drawn next to the proper input/output
        if connectionPathVisualList(i).number_of_occurrences > 1 then
            
            decreaseTempFontSize = 0.0;
            handleAxes.font_size = handleAxes.font_size - decreaseTempFontSize;    //temporary decrease of font size
            
            
            stringNumberOfOccurences = "(" + string(connectionPathVisualList(i).number_of_occurrences) + "×)";
            rectNumberOfOccurences = xstringl(0, 0, stringNumberOfOccurences, handleAxes.font_style, handleAxes.font_size);
            //check if path begins with vertical line (i.e. there are same first two x points)
            if connectionPathVisualList(i).path_points(1).x == connectionPathVisualList(i).path_points(2).x then
                
                nameLengthCorrectionX = 0;
                //if there is a name of property instead direct connection with another visual component
                if connectionPathVisualList(i).start_index == 0 then
                    handleAxes.font_size = handleAxes.font_size + decreaseTempFontSize;    //increase of font size
                    rectStartName = xstringl(0, 0, strsubst(connectionPathVisualList(i).start_name, " ", ""), handleAxes.font_style, handleAxes.font_size);
                    nameLengthCorrectionX = rectStartName(3);
                    handleAxes.font_size = handleAxes.font_size - decreaseTempFontSize;    //temporary decrease of font size
                end
                xstringb(connectionPathVisualList(i).path_points(1).x - nameLengthCorrectionX - rectNumberOfOccurences(3) - TextComponentDistanceX, connectionPathVisualList(i).path_points(1).y + TextLineDistanceY, stringNumberOfOccurences, rectNumberOfOccurences(3), rectNumberOfOccurences(4), "fill");
                
            //check if path begins with horizontal line (i.e. there are same first two y points)
            elseif connectionPathVisualList(i).path_points(1).y == connectionPathVisualList(i).path_points(2).y then
                
                
                xstringb(connectionPathVisualList(i).path_points(1).x - rectNumberOfOccurences(3) - TextComponentDistanceX / 2, connectionPathVisualList(i).path_points(1).y + TextLineDistanceY, stringNumberOfOccurences, rectNumberOfOccurences(3), rectNumberOfOccurences(4), "fill");
                
                
            //otherwise something is wrong because it should not be other type of line
            else
                disp(["Wrong connection with 0 start index (the first two points do not create vertical or horizontal line): " + connectionPathVisualList(i).path_points(1).connection_type ; "for path point: (" + string(connectionPathVisualList(i).path_points(1).x) + ", " + string(connectionPathVisualList(i).path_points(1).y) + ")" ; "path point number: " + string(1)]); //"for path: " + connectionPathVisualList(i).path_points ; 
            end
            
            handleAxes.children(1).font_foreground = colorForNotes;    //change color of new added children text element
            handleAxes.font_size = handleAxes.font_size + decreaseTempFontSize;    //increase of font size
            
        end
        
        
        
        if connectionPathVisualList(i).end_index > 0 then
            
            
            //if it is a trigger, draw trigger tag close to end point to emphasize the trigger 'input'
            if xmlVisualComponentsList(connectionPathVisualList(i).end_index).trigger ~= emptystr() then
                
                //try to find trigger in visual components list, if found draw trigger string
                IndexOfElementInVisualList = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(connectionPathVisualList(i).end_index).trigger);
                if IndexOfElementInVisualList == connectionPathVisualList(i).start_index & IndexOfElementInVisualList > 0 then
                    
                    upDownCorrection = 0;
//                    //if y position of visual component with trigger is same as position of the end point
//                    if xmlVisualComponentsList(connectionPathVisualList(i).end_index).pos_y == connectionPathVisualList(i).path_points($).y then
//                        upDownCorrection = 0.4;
//                    end
//                    //if y position of visual component with trigger is higher than position of the end point
                    if xmlVisualComponentsList(connectionPathVisualList(i).end_index).pos_y > connectionPathVisualList(i).path_points($).y then
                        upDownCorrection = 0.35;
                    else
                        upDownCorrection = -0.10;
                    end
                    
                    //calculate size and position of trigger tag and draw it
                    stringTriggerTag = "[trigger]";
                    decreaseTempFontSize = 2.0;
                    handleAxes.font_size = handleAxes.font_size - decreaseTempFontSize;    //temporary decrease of font size
                    rectTriggerTag = xstringl(0, 0, stringTriggerTag, handleAxes.font_style, handleAxes.font_size);
//                    xstringb(connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).x - rectTriggerTag(3) / 2, connectionPathVisualList(i).path_points(length(connectionPathVisualList(i).path_points)).y + TextLineDistanceY - upDownCorrection * rectTriggerTag(4), stringTriggerTag, rectTriggerTag(3), rectTriggerTag(4), "fill");
                    xstringb(connectionPathVisualList(i).path_points($).x + TextComponentDistanceX / 4, connectionPathVisualList(i).path_points($).y + TextLineDistanceY / 1.1 - upDownCorrection * rectTriggerTag(4), stringTriggerTag, rectTriggerTag(3), rectTriggerTag(4), "fill");
                    handleAxes.children(1).font_foreground = colorForNotes;    //change color of new added children text element
                    handleAxes.font_size = handleAxes.font_size + decreaseTempFontSize;    //increase of font size
                    
                end
                
                
            //otherwise, check if start name begins with minus (-) sign, if so, draw the minus sign tag information close to the end point
            elseif part(strsubst(connectionPathVisualList(i).start_name, " ", ""), 1) == "-" then
                
                //calculate size and position of minus sign tag and draw it
                stringMinusTag = "[-]";
                decreaseTempFontSize = 1.0;
                handleAxes.font_size = handleAxes.font_size - decreaseTempFontSize;    //temporary decrease of font size
                rectMinusTag = xstringl(0, 0, stringMinusTag, handleAxes.font_style, handleAxes.font_size);
                xstringb(connectionPathVisualList(i).path_points($).x + TextComponentDistanceX / 4, connectionPathVisualList(i).path_points($).y + TextLineDistanceY - 0.28 * rectMinusTag(4) / 2, stringMinusTag, rectMinusTag(3), rectMinusTag(4), "fill");
                handleAxes.children(1).font_foreground = colorForNotes;    //change color of new added children text element
                handleAxes.font_size = handleAxes.font_size + decreaseTempFontSize;    //increase of font size
                
            end
            
            
        end
        
        
    end
    
    
endfunction



function [x]=GetXPositionOfEllipse(a, b, y)
    
    //if width (a) is heigher than height (b)
    if a > b then
        
        x = sqrt(a^2 - a^2 * y^2 / b^2);
        
    //if width (a) is lower than height (b)
    elseif a < b
        
        x = sqrt(b^2 - b^2 * y^2 / a^2);
        
    //otherwise, width (a) is same as height (b) which means that the ellipse is actually circle
    else
        
        r = a;  //it equals also to r = b;
        x = sqrt(r^2 - y^2);
        
    end
    
endfunction



function [y]=GetYPositionOfEllipse(a, b, x)
    
    //if width (a) is heigher than height (b)
    if a > b then
        
        y = sqrt(b^2 - b^2 * x^2 / a^2);
        
    //if width (a) is lower than height (b)
    elseif a < b
        
        y = sqrt(a^2 - a^2 * x^2 / b^2);
        
    //otherwise, width (a) is same as height (b) which means that the ellipse is actually circle
    else
        
        r = a;  //it equals also to r = b;
        y = sqrt(r^2 - x^2);
        
    end
    
endfunction



function [numberOfInputs, numberOfOutputs]=GetRealNumberOfInputsAndOutputs(xmlVisualComponentsList, visualComponent)
    
    
    numberOfInputs = 0;
    numberOfOutputs = 0;
    
    
    //check all inputs and if any input is redundant, do not count it
    for i = 1 : 1 : length(visualComponent.inputs)
        inputAlreadyInList = %f;
//        //if the input is not number, search for property
//        if isnum(visualComponent.inputs(i)) == %f then
//            for j = 1 : 1 : i - 1
//                if strsubst(visualComponent.inputs(j), " ", "") == strsubst(visualComponent.inputs(i), " ", "") then
//                    inputAlreadyInList = %t;
//                    break;
//                end
//            end
//        //otherwise, search for number
//        else
//            for j = 1 : 1 : i - 1
//                if strsubst(visualComponent.inputs(j), " ", "") == strsubst(visualComponent.inputs(i), " ", "") then
//                    inputAlreadyInList = %t;
//                    break;
//                end
//            end
//        end
        for j = 1 : 1 : i - 1
            if strsubst(visualComponent.inputs(j), " ", "") == strsubst(visualComponent.inputs(i), " ", "") then
                inputAlreadyInList = %t;
                break;
            end
        end
        if inputAlreadyInList == %f then
            numberOfInputs = numberOfInputs + 1;
        end
    end
    
//    //check if the visual component has trigger
//    if DeleteWhiteSpacesAndMinusSign(visualComponent.trigger) ~= emptystr() then
//        numberOfInputs = numberOfInputs + 1;
//    end
    
    //check all outputs and if any output is redundant, do not count it
    for i = 1 : 1 : length(visualComponent.outputs)
        outputAlreadyInList = %f;
        for j = 1 : 1 : i - 1
            if DeleteWhiteSpacesAndMinusSign(visualComponent.outputs(j)) == DeleteWhiteSpacesAndMinusSign(visualComponent.outputs(i)) then
                outputAlreadyInList = %t;
                break;
            end
        end
        if outputAlreadyInList == %f then
            numberOfOutputs = numberOfOutputs + 1;
        end
    end
    
    
    //go through all visual components and try to find name of the current component in inputs and outputs
    visualComponentName = DeleteWhiteSpacesAndMinusSign(visualComponent.name);
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        //try to find component in inputs
        for j = 1 : 1 : length(xmlVisualComponentsList(i).inputs)
            if DeleteWhiteSpacesAndMinusSign(xmlVisualComponentsList(i).inputs(j)) == visualComponentName then
                
                //if the name was found, check whether the component does not have this iterated component in output list
                foundInOutputs = %f;
                for k = 1 : 1 : length(visualComponent.outputs)
                    if strsubst(visualComponent.outputs(k), " ", "") == strsubst(xmlVisualComponentsList(i).name, " ", "") then
                        foundInOutputs = %t;
                        break;
                    end
                end
                //if the iterated component is not in the output list of the checked component, increase number of outputs
                if foundInOutputs == %f then
                    numberOfOutputs = numberOfOutputs + 1;
                    break;
                end
                
            end
        end
        
        //try to find component in outputs
        for j = 1 : 1 : length(xmlVisualComponentsList(i).outputs)
            if DeleteWhiteSpacesAndMinusSign(xmlVisualComponentsList(i).outputs(j)) == visualComponentName then
                
                //if the name was found, check whether the component does not have this iterated component in input list
                foundInInputs = %f;
                for k = 1 : 1 : length(visualComponent.inputs)
                    if strsubst(visualComponent.inputs(k), " ", "") == strsubst(xmlVisualComponentsList(i).name, " ", "") then
                        foundInInputs = %t;
                        break;
                    end
                end
                //if the iterated component is not in the input list of the checked component, increase number of inputs
                if foundInInputs == %f then
                    numberOfInputs = numberOfInputs + 1;
                    break;
                end
                
            end
        end
        
        
        
        //find index of trigger which is in the visual list (if any) and set it
        if DeleteWhiteSpacesAndMinusSign(xmlVisualComponentsList(i).trigger) ~= emptystr() then
            
            //if the trigger is the current component, increase number of outputs
            if DeleteWhiteSpacesAndMinusSign(xmlVisualComponentsList(i).trigger) == visualComponentName then
                numberOfOutputs = numberOfOutputs + 1;
            end
            
        end
        
    end
    
    
endfunction



//function [firstAndLastPointsExist]=DoesFirstAndLastPointsExistInOtherPaths(connectionPathVisualList, firstPoint, lastPoint)
//    firstAndLastPointsExist = %f;
//    //
//endfunction



function [pathLineOverlapsAnother, outStartPointOverlap, outEndPointOverlap]=DoesPathLineOverlapAnother(connectionPathVisualList, endIterationConnectionPath, pointStart, pointEnd)
    
    
    pathLineOverlapsAnother = %f;
    outStartPointOverlap = [];
    outEndPointOverlap = [];
    
    //if the end iteration is higher than 0, check it; otherwise, ignore it
    if endIterationConnectionPath > 0 then
        
        //if the end iteration is higher than length of the connection path list, set the end iteration to the length
        if endIterationConnectionPath > length(connectionPathVisualList) then
            endIterationConnectionPath = length(connectionPathVisualList);
        end
        
        for i = 1 : 1 : endIterationConnectionPath
            for j = 1 : 1 : length(connectionPathVisualList(i).path_points) - 1
                
    //            //correct x and y positions due to tolerance of the line overlapping
    //            correctedStartX = pointStart.x;
    //            correctedStartY = pointStart.y;
    //            correctedEndX = pointEnd.x;
    //            correctedEndY = pointEnd.y;
    //            //correct xs due to their positions
    //            if correctedStartX > correctedEndX then
    //                correctedStartX = correctedStartX + toleranceOverlapX;
    //                correctedEndX = correctedEndX - toleranceOverlapX;
    //            else
    //                correctedStartX = correctedStartX - toleranceOverlapX;
    //                correctedEndX = correctedEndX + toleranceOverlapX;
    //            end
    //            //correct ys due to their positions
    //            if correctedStartY > correctedEndY then
    //                correctedStartY = correctedStartY + toleranceOverlapY;
    //                correctedEndY = correctedEndY - toleranceOverlapY;
    //            else
    //                correctedStartY = correctedStartY - toleranceOverlapY;
    //                correctedEndY = correctedEndY + toleranceOverlapY;
    //            end
                
                //find lower and higher value of checked point
                startX = pointStart.x;
                startY = pointStart.y;
                endX = pointEnd.x;
                endY = pointEnd.y;
                //correct xs due to their positions
                [startX, endX] = GetLowerAndHigherValue(startX, endX);
                //correct ys due to their positions
                [startY, endY] = GetLowerAndHigherValue(startY, endY);
                
                //find lower and higher value of point in list
                listedStartX = connectionPathVisualList(i).path_points(j).x;
                listedStartY = connectionPathVisualList(i).path_points(j).y;
                listedEndX = connectionPathVisualList(i).path_points(j+1).x;
                listedEndY = connectionPathVisualList(i).path_points(j+1).y;
                //correct xs due to their positions
                [listedStartX, listedEndX] = GetLowerAndHigherValue(listedStartX, listedEndX);
                //correct ys due to their positions
                [listedStartY, listedEndY] = GetLowerAndHigherValue(listedStartY, listedEndY);
                
                
                
                //if the both lines are vertical (point has same x start and x end positions)
                if startX == endX & listedStartX == listedEndX then
                    
                    //check if the xs are same or at least very close
                    if (startX - toleranceOverlapX) < listedStartX & (endX + toleranceOverlapX) > listedEndX then
                        
                        //check y positions of the both lines
                        if listedStartY >= startY & listedStartY <= endY | listedEndY >= startY & listedEndY <= endY | startY >= listedStartY & startY <= listedEndY | endY >= listedStartY & endY <= listedEndY then
                            pathLineOverlapsAnother = %t;
                            outStartPointOverlap = connectionPathVisualList(i).path_points(j);
                            outEndPointOverlap = connectionPathVisualList(i).path_points(j+1);
                            //disp(["outStartPointOverlap: " + string(outStartPointOverlap.x) + ", " + string(outStartPointOverlap.y) ; "outEndPointOverlap: " + string(outEndPointOverlap.x) + ", " + string(outEndPointOverlap.y) ] ); //<>debug only
                        end
                        
                    end
                    
                //else if the both lines are horizontal (point has same y start and y end positions)
                elseif startY == endY & listedStartY == listedEndY then
                    
                    //check if the ys are same or at least very close
                    if (startY - toleranceOverlapY) < listedStartY & (endY + toleranceOverlapY) > listedEndY then
                        
                        //check x positions of the both lines
                        if listedStartX >= startX & listedStartX <= endX | listedEndX >= startX & listedEndX <= endX | startX >= listedStartX & startX <= listedEndX | endX >= listedStartX & endX <= listedEndX then
                            pathLineOverlapsAnother = %t;
                            outStartPointOverlap = connectionPathVisualList(i).path_points(j);
                            outEndPointOverlap = connectionPathVisualList(i).path_points(j+1);
                            //disp(["outStartPointOverlap: " + string(outStartPointOverlap.x) + ", " + string(outStartPointOverlap.y) ; "outEndPointOverlap: " + string(outEndPointOverlap.x) + ", " + string(outEndPointOverlap.y) ] ); //<>debug only
                        end
                        
                        
                    end
                    
                    
                //else if start/end xs/ys are not same, it is an angled line which may be used for a circle visual component (e.g. summer or switch) for input/output lines only
                //note: now it is necessary to use original points, not influenced by the finding of the lower and higher x/y values
                elseif startX ~= endX & listedStartX ~= listedEndX & startY ~= endY & listedStartY ~= listedEndY then
                    if pointEnd.x == connectionPathVisualList(i).path_points(j+1).x & pointEnd.y == connectionPathVisualList(i).path_points(j+1).y | pointStart.x == connectionPathVisualList(i).path_points(j).x & pointStart.y == connectionPathVisualList(i).path_points(j).y then
                        pathLineOverlapsAnother = %t;
                        outStartPointOverlap = connectionPathVisualList(i).path_points(j);
                        outEndPointOverlap = connectionPathVisualList(i).path_points(j+1);
                        //disp(["outStartPointOverlap: " + string(outStartPointOverlap.x) + ", " + string(outStartPointOverlap.y) ; "outEndPointOverlap: " + string(outEndPointOverlap.x) + ", " + string(outEndPointOverlap.y) ] ); //<>debug only
                    end
                    
                end
                
            end
        end
        
    end
    
    
endfunction



//function [pathLineCrossAnother, xLocationCross, yLocationCross]=DoesPathLineCrossAnother(connectionPathVisualList, pointStart, pointEnd)
//    
//    pathLineCrossAnother = %f;
//    xLocationCross = -1;
//    yLocationCross = -1;
//    
//    //if the current checked line is correct connection type (i.e. line), check it; otherwise, ignore it
//    if pointStart.connection_type == PointConnectionTypes(1) then
//        
//        //using linear regression, get function of the checked line (only two points => it should be 100% linear line function)
//        xPointsChecked = [pointStart.x, pointEnd.x];
//        //if x positions are same, the line is not function and therefore the regression analysis will fail, so change the x values a little bit
//        if xPointsChecked(1) == xPointsChecked(2) then
//            xPointsChecked(1) = pointStart.x - toleranceCross;
//            xPointsChecked(2) = pointStart.x + toleranceCross;
//        end
//        yPointsChecked = [pointStart.y, pointEnd.y];
//        [aChecked, bChecked, sigChecked] = reglin(xPointsChecked, yPointsChecked);
//        if CheckResultsOfLinearRegression(sigChecked, aChecked, bChecked, xPointsChecked, yPointsChecked) == %t then
//            
//            for i = 1 : 1 : length(connectionPathVisualList)
//                for j = 1 : 1 : length(connectionPathVisualList(i).path_points) - 1
//                    
//                    //if the current points in the connection path list make line together (and not arc)
//                    if connectionPathVisualList(i).path_points(j).connection_type == PointConnectionTypes(1) then
//                        
//                        //check whether any points are same, if so, the lines cross
//                        if pointStart.x == connectionPathVisualList(i).path_points(j).x & pointStart.y == connectionPathVisualList(i).path_points(j).y | pointStart.x == connectionPathVisualList(i).path_points(j+1).x & pointStart.y == connectionPathVisualList(i).path_points(j+1).y then
//                            
//                            pathLineCrossAnother = %t;
//                            xLocationCross = pointStart.x;
//                            yLocationCross = pointStart.y;
//                            return;
//                            
//                        elseif pointEnd.x == connectionPathVisualList(i).path_points(j).x & pointEnd.y == connectionPathVisualList(i).path_points(j).y | pointEnd.x == connectionPathVisualList(i).path_points(j+1).x & pointEnd.y == connectionPathVisualList(i).path_points(j+1).y then
//                            
//                            pathLineCrossAnother = %t;
//                            xLocationCross = pointEnd.x;
//                            yLocationCross = pointEnd.y;
//                            return;
//                            
//                        end
//                        
//                        
//                        //using linear regression, get function of the line in (only two points => it should be 100% linear line function)
//                        xPointsInList = [connectionPathVisualList(i).path_points(j).x, connectionPathVisualList(i).path_points(j+1).x];
//                        //if x positions are same, the line is not function and therefore the regression analysis will fail, so change the x values a little bit
//                        if xPointsInList(1) == xPointsInList(2) then
//                            xPointsInList(1) = connectionPathVisualList(i).path_points(j).x - toleranceCross;
//                            xPointsInList(2) = connectionPathVisualList(i).path_points(j+1).x + toleranceCross;
//                        end
//                        yPointsInList = [connectionPathVisualList(i).path_points(j).y, connectionPathVisualList(i).path_points(j+1).y];
//                        [aInList, bInList, sigInList] = reglin(xPointsInList, yPointsInList);
//                        if CheckResultsOfLinearRegression(sigInList, aInList, bInList, xPointsInList, yPointsInList) == %t then
//                            
//                            
//                            //avoid warning message about redefining function in Scilab
//                            previousprot = funcprot(0);
//                            //define function with two linear functions calculated using linear regression
//                            deff("res=fct0(x)", ["res(1)=x(2)-(x(1)*" + string(aChecked) + "+" + string(bChecked) + ")" ; "res(2)=x(2)-(x(1)*" + string(aInList) + "+" + string(bInList) + ")"]);
//                            funcprot(previousprot);
//                            
//                            
//                            //try to find solution (i.e. intersection point of these two lines) using the checked start point
//                            x0Checked = [pointStart.x ; pointStart.y];
//                            [xSolChecked, vSolChecked, infoSolChecked] = fsolve(x0Checked, fct0);
//                            //if the solution was found (i.e. if algorithm convergates to at most tolerate value and if the results of both functions are 0 when the solution is used as input)
//                            //and if the solution is not same as the start point
//                            if infoSolChecked == 1 & fct0(xSolChecked) == [0 ; 0] & xSolChecked(1) ~= x0Checked(1) & xSolChecked(2) ~= x0Checked(2) then
//                                
//                                
//                                solCheckedPoint = Point;
//                                solCheckedPoint.x = xSolChecked(1);
//                                solCheckedPoint.y = xSolChecked(2);
//                                isInsideSubSpace = CheckIfIntersectionPointIsInsideSubSpace(solCheckedPoint, pointStart, pointEnd, connectionPathVisualList(i).path_points(j), connectionPathVisualList(i).path_points(j+1));
//                                
//                                if isInsideSubSpace == %t then
//                                    pathLineCrossAnother = %t;
//                                    xLocationCross = solCheckedPoint.x;
//                                    yLocationCross = solCheckedPoint.y;
//                                    return;
//                                end
//                                
//                                
//                            //otherwise try to find solution with using the current start point in the connection list
//                            else
//                                
//                                
//                                x0InList = [xPointsInList(1) ; yPointsInList(1)];
//                                [xSolInList, vSolInList, infoSolInList] = fsolve(x0InList, fct0);
//                                //if solution were found for point in list and checked point and the points are same as initial point, the functions overlap
//                                //because we check overlapping in separate function which should be called before this, we do not need to solve this issue
//        
//                                //note: there is problem that we cannot constrain the functions from start and end points; the linear functions are infinite in contrast to lines which are constrained by start and end points
//                                if infoSolInList == 1 & xSolInList(1) == x0InList(1) & xSolInList(2) == x0InList(2) & infoSolChecked == 1 & xSolChecked(1) == x0Checked(1) & xSolChecked(2) == x0Checked(2) then
//                                    
//                                    //<>debug only
//                                    disp(["These two functions overlap: " ; ...
//                                        "function of checked line" + "y = x * " + string(aChecked) + " + " + string(bChecked) ; ...
//                                        "start checked point: (" + string(pointStart.x) + ", " + string(pointStart.y) + ")" ; ...
//                                        "end checked point: (" + string(pointEnd.x) ", " + string(pointEnd.y) + ")"; ...
//                                        "function of line in list" + "y = x * " + string(aInList) + " + " + string(bInList); ...
//                                        "start point in list: (" + string(connectionPathVisualList(i).path_points(j).x) + ", " + string(connectionPathVisualList(i).path_points(j).y) + ")" ; ...
//                                        "end point in list: (" + string(connectionPathVisualList(i).path_points(j+1).x) ", " + string(connectionPathVisualList(i).path_points(j+1).y) + ")"]);
//                                    
//                                //else if the solution was found (i.e. if algorithm convergates to at most tolerate value and if the results of both functions are 0 when the solution is used as input)
//                                elseif infoSolInList == 1 & fct0(xSolInList) == [0 ; 0] & xSolInList(1) ~= x0InList(1) & xSolInList(2) ~= x0InList(2) then
//                                    
//                                    solInListPoint = Point;
//                                    solInListPoint.x = xSolInList(1);
//                                    solInListPoint.y = xSolInList(2);
//                                    isInsideSubSpace = CheckIfIntersectionPointIsInsideSubSpace(solInListPoint, pointStart, pointEnd, connectionPathVisualList(i).path_points(j), connectionPathVisualList(i).path_points(j+1));
//                                    
//                                    if isInsideSubSpace == %t then
//                                        pathLineCrossAnother = %t;
//                                        xLocationCross = solInListPoint.x;
//                                        yLocationCross = solInListPoint.y;
//                                        return;
//                                    end
//                                    
//                                end
//                                
//                                
//                            end
//                            
//                        end
//                        
//                    end
//                    
//                end
//            end
//            
//        end
//        
//    end
//    
//    
//endfunction
//
//
//
//function [isLinearRegression100]=CheckResultsOfLinearRegression(sig, a, b, x, y)
//    
//    isLinearRegression100 = %t;
//    
//    linearTolerance = 10E9;
//    sigRounded = round(sig * linearTolerance) / linearTolerance;
//    if sigRounded ~= 0 then
//        isLinearRegression100 = %f;
//        disp(["Linear Regression didn"'t found linear function!" ; "sig = " + string(sig); "sigRounded = " + string(sigRounded) ; "a = " + string(a) ; "b = " + string(b) ; "start point: " + string(x(1)) + ", " + string(y(1)) ; "end point: " + string(x(2)) + ", " + string(y(2))]);
////    //<>debug only
////    else
////        disp(["Linear Regression found linear function!" ; "sig = " + string(sig); "sigRounded = " + string(sigRounded) ; "a = " + string(a) ; "b = " + string(b) ; "start point: " + string(x(1)) + ", " + string(y(1)) ; "end point: " + string(x(2)) + ", " + string(y(2))]);
//    end
//    
//endfunction
//
//
//
//function [isInsideSubSpace]=CheckIfIntersectionPointIsInsideSubSpace(intersectPoint, point1Start, point1End, point2Start, point2End)
//    
//    isInsideSubSpace = %f;
//    
//    //get lower and higher x and y locations for point 1
//    [lowerPoint1X, higherPoint1X] = GetLowerAndHigherValue(point1Start.x, point1End.x);
//    [lowerPoint1Y, higherPoint1Y] = GetLowerAndHigherValue(point1Start.y, point1End.y);
//    //get lower and higher x and y locations for point 1
//    [lowerPoint2X, higherPoint2X] = GetLowerAndHigherValue(point2Start.x, point2End.x);
//    [lowerPoint2Y, higherPoint2Y] = GetLowerAndHigherValue(point2Start.y, point2End.y);
//    
//    //if intersection point lies inside the areas defined by start and end points, the lines intersect (otherwise the functions intersect but the lines are smaller)
//    if intersectPoint.x >= lowerPoint1X - toleranceCross & intersectPoint.x <= higherPoint1X + toleranceCross & intersectPoint.x >= lowerPoint2X - toleranceCross & intersectPoint.x <= higherPoint2X + toleranceCross  &  intersectPoint.y >= lowerPoint1Y - toleranceCross & intersectPoint.y <= higherPoint1Y + toleranceCross & intersectPoint.y >= lowerPoint2Y - toleranceCross & intersectPoint.y <= higherPoint2Y + toleranceCross then
//        isInsideSubSpace = %t;
//    end
//    
//endfunction



function [pathLineCrossAnother, xLocationCross, yLocationCross]=DoesPathLineCrossAnother(connectionPathVisualList, endIterationConnectionPath, pointStart, pointEnd)
    
    pathLineCrossAnother = %f;
    xLocationCross = -1;
    yLocationCross = -1;
    
    //if the current checked line is correct connection type (i.e. line) and the end iteration is higher than 0, check it; otherwise, ignore it
    if pointStart.connection_type == PointConnectionTypes(1) & endIterationConnectionPath > 0 then
        
        //if iteration at which the cycle should end is higher than the length of the connection path list, set the end iteration to the length
        if endIterationConnectionPath > length(connectionPathVisualList) then
            endIterationConnectionPath = length(connectionPathVisualList);
        end
        
        for i = 1 : 1 : endIterationConnectionPath
            for j = 1 : 1 : length(connectionPathVisualList(i).path_points) - 1
                
                //if the current points in the connection path list make line together (and not arc)
                if connectionPathVisualList(i).path_points(j).connection_type == PointConnectionTypes(1) then
                    
                    
                    
//                    //check whether any points are same, if so, the lines cross (however, it should not happen)
//                    if pointStart.x == connectionPathVisualList(i).path_points(j).x & pointStart.y == connectionPathVisualList(i).path_points(j).y | pointStart.x == connectionPathVisualList(i).path_points(j+1).x & pointStart.y == connectionPathVisualList(i).path_points(j+1).y then
//                        
//                        pathLineCrossAnother = %t;
//                        xLocationCross = pointStart.x;
//                        yLocationCross = pointStart.y;
//                        return;
//                        
//                    elseif pointEnd.x == connectionPathVisualList(i).path_points(j).x & pointEnd.y == connectionPathVisualList(i).path_points(j).y | pointEnd.x == connectionPathVisualList(i).path_points(j+1).x & pointEnd.y == connectionPathVisualList(i).path_points(j+1).y then
//                        
//                        pathLineCrossAnother = %t;
//                        xLocationCross = pointEnd.x;
//                        yLocationCross = pointEnd.y;
//                        return;
//                        
//                    end
                    
                    
                    
                    //if line of checked points is vertical and the line in connection list is horizontal
                    if pointStart.x == pointEnd.x & connectionPathVisualList(i).path_points(j).y == connectionPathVisualList(i).path_points(j+1).y then
                        
                        //get lower and higher y locations for checked points
                        [lowerPointCheckedY, higherPointCheckedY] = GetLowerAndHigherValue(pointStart.y, pointEnd.y);
                        //get lower and higher x locations for points in connection list
                        [lowerPointInListX, higherPointInListX] = GetLowerAndHigherValue(connectionPathVisualList(i).path_points(j).x, connectionPathVisualList(i).path_points(j+1).x);
                        
                        //if x position of checked points are between x positions of points in connection list and y position of points in connection list are between y positions of checked points
                        if pointStart.x >= lowerPointInListX & pointStart.x <= higherPointInListX  &  connectionPathVisualList(i).path_points(j).y >= lowerPointCheckedY & connectionPathVisualList(i).path_points(j).y <= higherPointCheckedY then
                            
                            //a cross was found, the x position is linear position of checked line and y position is linear postion of line in connection list
                            pathLineCrossAnother = %t;
                            xLocationCross = pointStart.x;
                            yLocationCross = connectionPathVisualList(i).path_points(j).y;
                            return;
                            
                        end
                        
                        
                    //else if line of checked points is horizontal and the line in connection list is vertical
                    elseif pointStart.y == pointEnd.y & connectionPathVisualList(i).path_points(j).x == connectionPathVisualList(i).path_points(j+1).x then
                        
                        //get lower and higher x locations for checked points
                        [lowerPointCheckedX, higherPointCheckedX] = GetLowerAndHigherValue(pointStart.x, pointEnd.x);
                        //get lower and higher y locations for points in connection list
                        [lowerPointInListY, higherPointInListY] = GetLowerAndHigherValue(connectionPathVisualList(i).path_points(j).y, connectionPathVisualList(i).path_points(j+1).y);
                        
                        //if y position of checked points are between y positions of points in connection list and x position of points in connection list are between x positions of checked points
                        if pointStart.y >= lowerPointInListY & pointStart.y <= higherPointInListY  &  connectionPathVisualList(i).path_points(j).x >= lowerPointCheckedX & connectionPathVisualList(i).path_points(j).x <= higherPointCheckedX then
                            
                            //a cross was found, the x position is linear postion of line in connection list and y position is linear position of checked line
                            pathLineCrossAnother = %t;
                            xLocationCross = connectionPathVisualList(i).path_points(j).x;
                            yLocationCross = pointStart.y;
                            return;
                            
                        end
                        
                        
                    //else if line of checked points and the line in connection list are not parallel and they are not precisely horizontal or vertical (i.e. they are angled)
                    //<>linear regression for non-vertical line and fsolve? (higher computational cost than necessary)
                    elseif pointStart.x ~= pointEnd.x & pointStart.y ~= pointEnd.y | connectionPathVisualList(i).path_points(j).x ~= connectionPathVisualList(i).path_points(j+1).x & connectionPathVisualList(i).path_points(j).y ~= connectionPathVisualList(i).path_points(j+1).y then
                        
                        //display message with information that these types of lines are not supported for crossing check
                        disp(["Only horizontal or vertical lines can be checked for crossing. Angled lines are not supported yet." ; "pointStart: " + string(pointStart.x) + ", " + string(pointStart.y) ; "pointEnd: " + string(pointEnd.x) + ", " + string(pointEnd.y) ; "connectionPathVisualList(i).path_points(j): " + string(connectionPathVisualList(i).path_points(j).x) + ", " + string(connectionPathVisualList(i).path_points(j).y) ; "connectionPathVisualList(i).path_points(j+1): " + string(connectionPathVisualList(i).path_points(j+1).x) + ", " + string(connectionPathVisualList(i).path_points(j+1).y) ]);
                        
                    end
                    
                    
                end
                
            end
        end
        
    end
    
    
endfunction



function [outCompleteIndexesVisualComponents]=SortXMLVisualComponents(xmlVisualComponentsList)
    
    outCompleteIndexesVisualComponents = list();
    indexesVisualComponentsList = list();
    
    
    //find indexes of all components which are in visual list including the references to inputs, outputs, and trigger
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        indexesVisualComponent = IndexesVisualComponent;
        indexesVisualComponent.name = xmlVisualComponentsList(i).name;
        indexesVisualComponent.main_index = i;
        
        //find indexes of inputs which are in the visual list (if any) and add them to list with input indexes
        for j = 1 : 1 : length(xmlVisualComponentsList(i).inputs)
            
            indexInput = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).inputs(j));
            if indexInput > 0 then
                indexesVisualComponent.input_indexes($+1) = indexInput;
            end
            
        end
        
        //find indexes of outputs which are in the visual list (if any) and add them to list with output indexes
        for j = 1 : 1 : length(xmlVisualComponentsList(i).outputs)
            
            indexOutput = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).outputs(j));
            if indexOutput > 0 then
                indexesVisualComponent.output_indexes($+1) = indexOutput;
            end
            
        end
        
        //find index of trigger which is in the visual list (if any) and set it
        indexesVisualComponent.trigger_index = GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, xmlVisualComponentsList(i).trigger);
        
        
        //add element with indexes to list of indexes of components found in the visual list (e.g. in selected channel)
        indexesVisualComponentsList($+1) = indexesVisualComponent;
        
    end
    
    
    //find indexes of outputs for all components by using their names and inputs/triggers in visual list
    for i = 1 : 1 : length(indexesVisualComponentsList)
        
        //find indexes of inputs which are same as index of the current component in the visual list (if any) and add them to list with output indexes
        for j = 1 : 1 : length(indexesVisualComponentsList)
            
            for k = 1 : 1 : length(indexesVisualComponentsList(j).input_indexes)
                
                //if the current component is in the input list, add it
                if indexesVisualComponentsList(i).main_index == indexesVisualComponentsList(j).input_indexes(k) then
                    indexesVisualComponentsList(i).output_indexes($+1) = indexesVisualComponentsList(j).main_index;
                end
                
            end
            
            //if the current component is the trigger, add it
            if indexesVisualComponentsList(i).main_index == indexesVisualComponentsList(j).trigger_index then
                indexesVisualComponentsList(i).output_indexes($+1) = indexesVisualComponentsList(j).main_index;
            end
           
        end
        
    end
    
    
    
    //for each component, create sub-paths from the current component to the last output component
    //process checks if a component was already used (i.e. whether the schema contains feedbacks)
    outSubIndexesVisualComponents = list();
    for i = 1 : 1 : length(indexesVisualComponentsList)
        
        //create first list and add the current component which outputs will be added
        outSubIndexesVisualComponents($+1) = list();
        outSubIndexesVisualComponents(i)($+1) = list();
        outSubIndexesVisualComponents(i)(1)($+1) = indexesVisualComponentsList(i);
        
        //go recursively through all outputs and outputs of outputs etc. and add new elements in list of visual components with sub-indexes
        [subIndexesVisualComponents, outUsedIndexesInPath] = RecursiveSortByOutputsIndexesVisualComponentsList(indexesVisualComponentsList(i).output_indexes, list(), indexesVisualComponentsList);
        //merge lists together
        for j = 1 : 1 : length(subIndexesVisualComponents)
            outSubIndexesVisualComponents(i)($+1) = subIndexesVisualComponents(j);
        end
        
    end
//    //<>debug only
//    outCompleteIndexesVisualComponents = outSubIndexesVisualComponents;
//    for i = 1 : 1 : length(outSubIndexesVisualComponents)
//        for j = 1 : 1 : length(outSubIndexesVisualComponents(i))
//            for k = 1 : 1 : length(outSubIndexesVisualComponents(i)(j))
//                disp(string(i) + " " + string(j) + " " + string(k) + " :" + outSubIndexesVisualComponents(i)(j)(k).name + " ");
//            end
//        end
//    end
    
    
    
    
    //sort the components from the first inputs to the last outputs
    //(note: the complete sorted list may be influenced by order of the components shown in ComponentsUsed uicontrol (i.e. by order of the components in XML channel))
    //(example of insertion to list: "a = lstcat(a(1:3), 5, a(4:6))")
    //while there are some lists which can be processed
    while length(outSubIndexesVisualComponents) > 0
        
        
        //add the first list which is taken as the initial
        outCompleteIndexesVisualComponents($+1) = outSubIndexesVisualComponents(1);
        outSubIndexesVisualComponents(1) = null();
        
        
        initialLengthOfSubIndexes = length(outSubIndexesVisualComponents);
        //go through all sub-paths of each component
        i = 1;
        while i <= length(outSubIndexesVisualComponents)
            
            
            intersectionJComplete = 0;
            intersectionKComplete = 0;
            intersectionJSub = 0;
            intersectionKSub = 0;
            
            j = 1;
            while j <= length(outSubIndexesVisualComponents(i))
                
                for k = 1 : 1 : length(outSubIndexesVisualComponents(i)(j))
                    
                    //find the current index in the main list of all components with indexes and get indexes where it was found
                    [intersectionJComplete, intersectionKComplete] = GetIndexesOfIndexComponentIfFound(outCompleteIndexesVisualComponents($), outSubIndexesVisualComponents(i)(j)(k));
                    //if the indexes were found, set the intersection indexes of the current component in the current sub-path
                    if intersectionJComplete ~= 0 & intersectionKComplete ~= 0 then
                        intersectionJSub = j;
                        intersectionKSub = k;
                        //set 'j' to value higher than the length of the particular list to break the 'j' while loop
                        j = length(outSubIndexesVisualComponents(i)) + 1;
                        //break this for cycle
                        break;
                    end
                    
                end
                
//                //<>debug only
//                disp("j: " + string(j) + " intersectionJComplete: " + string(intersectionJComplete) + " intersectionJSub: " + string(intersectionJSub));
                
                //increment the 'j' index
                j = j + 1;
            end
            //release 'j' variable
            clear j;
            
            
//            //<>debug only
//            disp("intersectionJComplete: " + string(intersectionJComplete) + " intersectionJSub: " + string(intersectionJSub));
            
            //if an intersection were found
            if intersectionJComplete ~= 0 & intersectionKComplete ~= 0 & intersectionJSub ~= 0 & intersectionKSub ~= 0 then
                
                
                //if the main complete list has less components at the left side (i.e. at the direction from the found intersection to the beginning of the list)
                if intersectionJComplete < intersectionJSub then
                    //add the specific number of new lists at the beginning of the main complete list and increment the 'J' intersection index
                    leftAddition = intersectionJSub - intersectionJComplete;
                    for a = 1 : 1 : leftAddition;
                        outCompleteIndexesVisualComponents($)(0) = list();
                        intersectionJComplete = intersectionJComplete + 1;
                    end
                end
                
                //if the main complete list has less components at the right side (i.e. at the direction from the found intersection to the end of the list)
                if length(outCompleteIndexesVisualComponents($)) - intersectionJComplete < length(outSubIndexesVisualComponents(i)) - intersectionJSub then
                    //add the specific number of new lists at the end of the main complete list
                    rightAddition = (length(outSubIndexesVisualComponents(i)) - intersectionJSub) - (length(outCompleteIndexesVisualComponents($)) - intersectionJComplete);
                    for a = 1 : 1 : rightAddition;
                        outCompleteIndexesVisualComponents($)($+1) = list();
                    end
                end
                
                
                //perform unification of all lists by using the intersection
                for j = 1 : 1 : length(outSubIndexesVisualComponents(i))
                    
                    for k = 1 : 1 : length(outSubIndexesVisualComponents(i)(j))
                        
                        currentIndexJComplete = intersectionJComplete - (intersectionJSub - j);
//                        //<>debug only
//                        disp("i: " + string(i) + " j: " + string(j) + " k: " + string(k) + " currentIndexJComplete: " + string(currentIndexJComplete));
                        //find the current index in the sub-list of main indexed list with all components and get information whether it was found
                        isIndexInIndexComponentList = IsIndexInIndexComponentList(outCompleteIndexesVisualComponents($)(currentIndexJComplete), outSubIndexesVisualComponents(i)(j)(k));
                        //if the index was found, add the current index component to the main list
                        if isIndexInIndexComponentList == %f then
                            outCompleteIndexesVisualComponents($)(currentIndexJComplete)($+1) = outSubIndexesVisualComponents(i)(j)(k);
                        end
                        
                    end
                    
                end
                
                
                //delete the current processed list from the sub-path list and decrease 'i' value (the current 'i' would point to the next sub-path due to the deletion)
                outSubIndexesVisualComponents(i) = null();
                i = i - 1;
                
                
            end
            
            

            //if there was some deletion from sub-path list and the list has still at least one element and this is the last iteration, set new initial length and start the for cycle from the beginning
            if initialLengthOfSubIndexes > length(outSubIndexesVisualComponents) & length(outSubIndexesVisualComponents) > 0 & i == length(outSubIndexesVisualComponents) then
                initialLengthOfSubIndexes = length(outSubIndexesVisualComponents);
                i = 0;
//                //<>debug only
//                disp("some sub-path still exist! initialLengthOfSubIndexes: " + string(initialLengthOfSubIndexes) + " length(outSubIndexesVisualComponents): " + string(length(outSubIndexesVisualComponents)) + " i:" + string(i));
            end
            
            
            //increment the 'i' index
            i = i + 1;
        end
        //release 'i' variable
        clear i;
        
        
    end
//    //<>debug only
//    for i = 1 : 1 : length(outCompleteIndexesVisualComponents)
//        for j = 1 : 1 : length(outCompleteIndexesVisualComponents(i))
//            for k = 1 : 1 : length(outCompleteIndexesVisualComponents(i)(j))
//                disp(string(i) + " " + string(j) + " " + string(k) + " :" + outCompleteIndexesVisualComponents(i)(j)(k).name + " index: " + string(outCompleteIndexesVisualComponents(i)(j)(k).main_index));
//            end
//        end
//    end
    
    
endfunction



function [outJ, outK]=GetIndexesOfIndexComponentIfFound(indexesVisualComponentsList, searchedIndexVisualComponent)
    
    outJ = 0;
    outK = 0;
    
    for j = 1 : 1 : length(indexesVisualComponentsList)
        
        for k = 1 : 1 : length(indexesVisualComponentsList(j))

            
            if indexesVisualComponentsList(j)(k).main_index == searchedIndexVisualComponent.main_index then
                outJ = j;
                outK = k;
            end
            
        end
        
    end
    
endfunction



function [isIndexInIndexComponentList]=IsIndexInIndexComponentList(indexesVisualComponentsList, searchedIndexVisualComponent)
    
    isIndexInIndexComponentList = %f;
    for k = 1 : 1 : length(indexesVisualComponentsList)
        
        if indexesVisualComponentsList(k).main_index == searchedIndexVisualComponent.main_index then
            isIndexInIndexComponentList = %t;
        end
        
    end
    
endfunction



function [outOutputIndexesVisualComponents, outUsedIndexesInPath]=RecursiveSortByOutputsIndexesVisualComponentsList(outputIndexesVisualComponents, inUsedIndexesInPath, indexesVisualComponentsList)
    
    //create output list and go through all output indexes
    outOutputIndexesVisualComponents = list();
    outUsedIndexesInPath = inUsedIndexesInPath;
    for i = 1 : 1 : length(outputIndexesVisualComponents)
        
        
        //if this is the first cycle, create new list
        if i == 1 then
            outOutputIndexesVisualComponents($+1) = list();
        end
        //add the current component to the list
        outOutputIndexesVisualComponents(1)($+1) = indexesVisualComponentsList(outputIndexesVisualComponents(i));

        
        
        //find if the component was already used (i.e. there is a feedback which would create neverending recursive algorithm)
        wasUsedMainIndex = %f;
        for j = 1 : 1 : length(outUsedIndexesInPath)
            if outUsedIndexesInPath(j) == indexesVisualComponentsList(outputIndexesVisualComponents(i)).main_index then
                wasUsedMainIndex = %t;
            end
        end
        
        
        //if the component was not used in the previous path
        if wasUsedMainIndex == %f then
            
//            //<>debug only
//            disp('component name: ' + string(indexesVisualComponentsList(outputIndexesVisualComponents(i)).name) + ' ; component main index: ' + string(indexesVisualComponentsList(outputIndexesVisualComponents(i)).main_index));
            
            //add the index of the component to the list of used components
            outUsedIndexesInPath($+1) = indexesVisualComponentsList(outputIndexesVisualComponents(i)).main_index;
            
            
            //recursively browse all output indexes
            [outSubOutputIndexesVisualComponents, outUsedIndexesInPath] = RecursiveSortByOutputsIndexesVisualComponentsList(indexesVisualComponentsList(outputIndexesVisualComponents(i)).output_indexes, outUsedIndexesInPath, indexesVisualComponentsList);
            
            
            //merge lists together, go through all output lists
            for j = 1 : 1 : length(outSubOutputIndexesVisualComponents)
                
                //if this is the first time when outputs are added and there is any out-recursive sub-list, then create new output sub-list
                if length(outOutputIndexesVisualComponents) < j+1 & length(outSubOutputIndexesVisualComponents(j)) > 0 then
                    outOutputIndexesVisualComponents($+1) = list();
                end
                
                //go through all sub-lists and add all indexed components
                for k = 1 : 1 : length(outSubOutputIndexesVisualComponents(j))
                    outOutputIndexesVisualComponents(j+1)($+1) = outSubOutputIndexesVisualComponents(j)(k);
                end
                
            end
            
        end
        
    end
    
endfunction



function [IndexOfElementInVisualList]=GetIndexOfElementNameInVisualComponentsList(xmlVisualComponentsList, nameOfComponent)
    
    IndexOfElementInVisualList = 0;
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        if DeleteWhiteSpacesAndMinusSign(xmlVisualComponentsList(i).name) == DeleteWhiteSpacesAndMinusSign(nameOfComponent) then
            IndexOfElementInVisualList = i;
            break;
        end
        
    end
    
endfunction



function [isElementInVisualList]=IsElementNameInVisualComponentsList(xmlVisualComponentsList, nameOfComponent)
    
    isElementInVisualList = %f;
    for i = 1 : 1 : length(xmlVisualComponentsList)
        
        if DeleteWhiteSpacesAndMinusSign(xmlVisualComponentsList(i).name) == DeleteWhiteSpacesAndMinusSign(nameOfComponent) then
            isElementInVisualList = %t;
        end
        
    end
    
endfunction



function [outString]=DeleteWhiteSpacesAndMinusSign(inString)
    //delete white spaces in input string
    outString = strsubst(inString, " ", "");
    //if the string has minus sign (i.e. '-') at the beginning, delete it
    if part(outString, 1) == "-" then
        //delete the minus sign
        outString = part(outString, 2:length(outString));
    end
endfunction



function [xmlVisualComponent]=CreateXMLVisualComponentBasic(xmlComponent)
    
    xmlVisualComponent = XMLVisualComponent;
    
    xmlVisualComponent.name = xmlComponent.attributes.name;
    xmlVisualComponent.type_xml = xmlComponent.name;
    
    
    //add all inputs and outputs to the visual component
    propertiesOfXmlComponent = xmlComponent.children;
    for i = 1 : 1 : length(propertiesOfXmlComponent)
        
        //create visual component with all information except the position (will be calculated later)
        if propertiesOfXmlComponent(i).name == "input" then 
            //add the input to the list of inputs
            xmlVisualComponent.inputs($+1) = propertiesOfXmlComponent(i).content;
            
        elseif propertiesOfXmlComponent(i).name == "output" then
            //add the output to the list of outputs
            xmlVisualComponent.outputs($+1) = propertiesOfXmlComponent(i).content;
            
        elseif propertiesOfXmlComponent(i).name == "trigger" then
            //set the trigger (for pid and integrator component)
            if xmlVisualComponent.trigger == emptystr() then
                xmlVisualComponent.trigger = propertiesOfXmlComponent(i).content;
            else
                disp("Warning! Two triggers are defined in: """ + xmlVisualComponent.type_xml + """ component, named: " + xmlVisualComponent.name + """.");
            end
            
        elseif propertiesOfXmlComponent(i).name == "default" | propertiesOfXmlComponent(i).name == "test" then
            //add the default or a test input to the list of inputs (for switch component only)
            xmlVisualComponent.inputs($+1) = propertiesOfXmlComponent(i).attributes.value;
            
        elseif propertiesOfXmlComponent(i).name == "clipto" then
            //set the clipto min or max (or both)
            cliptoChildren = propertiesOfXmlComponent(i).children;
            for j = 1 : 1 : length(cliptoChildren)
                if cliptoChildren(j).name == "min" then
                    if xmlVisualComponent.clipto_min == emptystr() then
                        xmlVisualComponent.clipto_min = cliptoChildren(j).content;
                    else
                        disp("Warning! Two min values are defined in clipto of: """ + xmlVisualComponent.type_xml + """ component, named: " + xmlVisualComponent.name + """.");
                    end
                elseif cliptoChildren(j).name == "max" then
                    if xmlVisualComponent.clipto_max == emptystr() then
                        xmlVisualComponent.clipto_max = cliptoChildren(j).content;
                    else
                        disp("Warning! Two max values are defined in clipto of: """ + xmlVisualComponent.type_xml + """ component, named: " + xmlVisualComponent.name + """.");
                    end
                end
            end
            
        end
        
    end 
    
    
    //depending on type_xml, choose the component's visual type
    if xmlVisualComponent.type_xml ~= "summer" & xmlVisualComponent.type_xml ~= "switch" then
        xmlVisualComponent.visual_type = VisualTypes(1);
    else
        xmlVisualComponent.visual_type = VisualTypes(2);
    end
    
    
endfunction



function [visualSize]=CalculateVisualSize(handleAxes, xmlVisualComponent)
    
    //calculate boundaries for the string with name and type of the component
    str = ["<" + xmlVisualComponent.type_xml + ">" ; xmlVisualComponent.name];
//    //calculate boundaries for the string with type of the component
//    str = xmlVisualComponent.type_xml;
    rectString = xstringl(0, 0, str, handleAxes.font_style, handleAxes.font_size);
    //visualSize = [rectString(3) rectString(4)];
    
    //if the circle should be drawn
    if xmlVisualComponent.visual_type == VisualTypes(2) then
        
        visualSize = [rectString(3)*sizeCircleIncrease, rectString(4)]
        
//        //we need only a radius size (i.e. the bigger size)
//        biggerSize = rectString(3);
//        if rectString(3) < rectString(4) then
//            biggerSize = rectString(4);
//        end
//        //we increase the radius size about 25% (i.e. 5/4 = 1 + 1/4)
//        visualSize = [biggerSize*sizeCircleIncrease biggerSize*sizeCircleIncrease];
        
    //oherwise just copy the calculated boundaries of the rectangle
    else
        visualSize = [rectString(3), rectString(4)];
    end
    
endfunction



function [visualPosition]=CalculateVisualPosition(xmlVisualComponent, sortedIndexesVisualComponents, xmlVisualComponentsList, handleAxes)
    
    visualPosition = [];
    for i = 1 : 1 : length(sortedIndexesVisualComponents)
        for j = 1 : 1 : length(sortedIndexesVisualComponents(i))
            for k = 1 : 1 : length(sortedIndexesVisualComponents(i)(j))
                
                //find the component in the sorted indexed visual component list
                if sortedIndexesVisualComponents(i)(j)(k).name == xmlVisualComponent.name then
                    
//                    //calculate number of components shown in the current 'column' in schema
//                    numberOfComponentsInColumn = 0;
//                    for l = 1 : 1 : i - 1
//                        //if there is the specific column, add the number of components to the total value
//                        if j <= length(sortedIndexesVisualComponents(l)) then
//                            numberOfComponentsInColumn = numberOfComponentsInColumn + length(sortedIndexesVisualComponents(l)(j));
//                        end
//                        
//                    end
                    
                    //find number of maximum components in 'columns' ('j' index) for all previous main ('i' index) paths in schema
                    totalMaxNumberOfKComponentsInPrevPaths = 0;
                    //find total maximum size of components in 'columns'
                    totalMaxSizeYOfKComponentsInPrevPaths = 0;
                    for l = 1 : 1 : i - 1
                        //find the maximum of the components in the 'columns'
                        maximumNumberOfKComponents = 0;
                        maximumSizeYOfKComponents = 0;
                        for m = 1 : 1 : length(sortedIndexesVisualComponents(l))
                            
                            //check if the current number is 'local' maximum
                            if maximumNumberOfKComponents < length(sortedIndexesVisualComponents(l)(m)) then
                                maximumNumberOfKComponents = length(sortedIndexesVisualComponents(l)(m));
                            end
                            
                            //calculate max Y size of the components
                            sizeYOfKComponents = 0;
                            for n = 1 : 1 : length(sortedIndexesVisualComponents(l)(m))
                                sizeYOfKComponents = sizeYOfKComponents + xmlVisualComponentsList(sortedIndexesVisualComponents(l)(m)(n).main_index).size_y;
                            end
                            if maximumSizeYOfKComponents < sizeYOfKComponents then
                                maximumSizeYOfKComponents = sizeYOfKComponents;
                            end
                            
                        end
                        totalMaxNumberOfKComponentsInPrevPaths = totalMaxNumberOfKComponentsInPrevPaths + maximumNumberOfKComponents;
                        totalMaxSizeYOfKComponentsInPrevPaths = totalMaxSizeYOfKComponentsInPrevPaths + maximumSizeYOfKComponents;
                    end
                    //calculate Y size of the previous components in the current path
                    previousSizeYOfKComponentsInCurrentPath = 0;
                    for o = 1 : 1 : k - 1
                        previousSizeYOfKComponentsInCurrentPath = previousSizeYOfKComponentsInCurrentPath + xmlVisualComponentsList(sortedIndexesVisualComponents(i)(j)(o).main_index).size_y;
                    end
                    
                    
                    //find and calculate total maximum X size of the previous components in the current path
                    totalMaxSizeXOfJComponentsInPrevPaths = 0;
                    for o = 1 : 1 : j - 1
                        
                        //find the maximum of the components in the 'columns'
                        maximumSizeXOfJComponents = 0;
                        for p = 1 : 1 : length(sortedIndexesVisualComponents(i)(o))
                            
                            //check if the current number is 'local' maximum
                            if maximumSizeXOfJComponents < xmlVisualComponentsList(sortedIndexesVisualComponents(i)(o)(p).main_index).size_x then
                                maximumSizeXOfJComponents = xmlVisualComponentsList(sortedIndexesVisualComponents(i)(o)(p).main_index).size_x;
                            end
                            
                        end
                        totalMaxSizeXOfJComponentsInPrevPaths = totalMaxSizeXOfJComponentsInPrevPaths + maximumSizeXOfJComponents;
                        
                    end
                    
                    
                    //find and calculate the longest name of inputs and outputs of previous components of the current path and the longest name of inputs of the current 'column'
                    totalMaxSizeXOfInputNameJComponentsInPrevCurrentPaths = 0;
                    totalMaxSizeXOfOutputNameJComponentsInPrevPaths = 0;
                    for o = 1 : 1 : j
                        
                        //find the maximum of the input and output components in the 'columns'
                        maximumSizeXOfInputNameJComponents = 0;
                        maximumSizeXOfOutputNameJComponents = 0;
                        for p = 1 : 1 : length(sortedIndexesVisualComponents(i)(o))
                            
                            //go through all inputs
                            currentVisualComponent = xmlVisualComponentsList(sortedIndexesVisualComponents(i)(o)(p).main_index);
                            for q = 1 : 1 : length(currentVisualComponent.inputs)
                                //if the name of the input is not in the visual component list, it counts
                                if IsElementNameInVisualComponentsList(xmlVisualComponentsList, currentVisualComponent.inputs(q)) == %f then
                                    inputNameLength = xstringl(0, 0, strsubst(currentVisualComponent.inputs(q), " ", ""), handleAxes.font_style, handleAxes.font_size);
                                    //check if the current length is 'local' maximum
                                    if maximumSizeXOfInputNameJComponents < inputNameLength(3) then
                                        maximumSizeXOfInputNameJComponents = inputNameLength(3);
                                    end
                                end
                            end
                            
                            //if this is not the last (i.e. the current) component, count the name length of outputs
                            if o < j then
                                //go through all outputs
                                for q = 1 : 1 : length(currentVisualComponent.outputs)
                                    //if the name of the output is not in the visual component list, it counts
                                    if IsElementNameInVisualComponentsList(xmlVisualComponentsList, currentVisualComponent.outputs(q)) == %f then
                                        outputNameLength = xstringl(0, 0, strsubst(currentVisualComponent.outputs(q), " ", ""), handleAxes.font_style, handleAxes.font_size);
                                        //check if the current length is 'local' maximum
                                        if maximumSizeXOfOutputNameJComponents < outputNameLength(3) then
                                            maximumSizeXOfOutputNameJComponents = outputNameLength(3);
                                        end
                                    end
                                end
                            end
                            
                        end
                        totalMaxSizeXOfInputNameJComponentsInPrevCurrentPaths = totalMaxSizeXOfInputNameJComponentsInPrevCurrentPaths + maximumSizeXOfInputNameJComponents;
                        totalMaxSizeXOfOutputNameJComponentsInPrevPaths = totalMaxSizeXOfOutputNameJComponentsInPrevPaths + maximumSizeXOfOutputNameJComponents;
                        
                    end
                    
                    //correct distance of first component at x axis
                    firstDistanceXCorrection = 1;
                    if j == 1 then firstDistanceXCorrection = 2; end
                    //calculate position of the current visual component due to the position in the sorted indexed list + add some distance between components
                    visualPositionX = totalMaxSizeXOfJComponentsInPrevPaths + j * ComponentsDistanceX * 2 / firstDistanceXCorrection + totalMaxSizeXOfInputNameJComponentsInPrevCurrentPaths + totalMaxSizeXOfOutputNameJComponentsInPrevPaths;
                    visualPositionY = totalMaxSizeYOfKComponentsInPrevPaths + previousSizeYOfKComponentsInCurrentPath + (totalMaxNumberOfKComponentsInPrevPaths + k) * ComponentsDistanceY + xmlVisualComponentsList(sortedIndexesVisualComponents(i)(j)(k).main_index).size_y;
                    visualPosition = [visualPositionX, visualPositionY];
                    return;
                end
                
            end
        end
    end
    
endfunction



