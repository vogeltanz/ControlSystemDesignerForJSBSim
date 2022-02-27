//exec XMLSimulation.sci;
//exec DialogsFunctions.sci;
//exec ControllerDesignMethods.sci;
//exec XMLfunctions.sci;


//global GraphWidth;
//GraphWidth = 400;
//global GraphHeight;
//GraphHeight = 300;


global WindowsOSName;
WindowsOSName = "Windows";
global LinuxOSName;
LinuxOSName = "Linux";


function [cmdOutput, cmdbOK, cmdExitCodeOrErr]=JSBSimOrFlightGearExecution(applicationCommandWithParameters)
    
    // execute JSBSim/FlightGear from command line (windows only)
    
    [OSName, OSVersion] = getos();
    global WindowsOSName;
    global LinuxOSName;
    
    //if FlightGear executable file does not exist at the path, try default known windows' paths
    if OSName == WindowsOSName then
        
        [cmdOutput, cmdbOK, cmdExitCodeOrErr] = dos(applicationCommandWithParameters,'-echo');
        
    elseif OSName == LinuxOSName then
        
        [cmdOutput, cmdbOK, cmdExitCodeOrErr] = unix_g(applicationCommandWithParameters);
        
    end
    
endfunction



function [CSVHeader, CSVvalues]=ReadAndEvalCSVfile(filename)
    
    valueSeparator = ",";
    decimalSeparator = ".";
    
    // read csv file
    CSVstring = csvRead(filename, valueSeparator, decimalSeparator, "string");
    
    //extract header (first line)
    CSVHeader = CSVstring(1:1,:);
    
    //read values only (after first line)
    CSVstringValues = CSVstring(2:size(CSVstring, 1),:);
    //CSVvalues = csvRead(filename, valueSeparator, decimalSeparator, "double", [], [], [], 1);
    //convert string to numbers (to double)
    CSVvalues = strtod(CSVstringValues, decimalSeparator);
    
endfunction



function [outCommandsInOneLine]=JoinConsoleCommandsToStringFromStringArray(stringArray)
    
    outCommandsInOneLine = emptystr();
    separatorOfCommands = " ";
    
    if stringArray ~= [] & size(stringArray, 1) > 0 then
        outCommandsInOneLine = stringArray(1);
    end
    for i = 2 : 1 : size(stringArray, 1)
        if strsubst(stringArray(i), " ", "") ~= emptystr() then
            outCommandsInOneLine = outCommandsInOneLine + separatorOfCommands + stringArray(i);
        end
    end
    
endfunction



function [figureWith2DPlots]=CreateAndShowFigureWithJSBsimResultsIn2DPlots(CSVHeader, CSVvalues, timeStart, timeEnd, numberOfGraphsInLine)//, oneGraphWidth, oneGraphHeight)    //(<>Scilab bug - noted because of scrollbar bug)
    
    
    
    //get number of columns and caluclate number of lines for graphs
    numberOfColumns = size(CSVvalues, 2);
    numberOfLinesForGraphs = ceil((numberOfColumns - 1) / numberOfGraphsInLine);
//    (<>Scilab bug - noted because of scrollbar bug)
//    //calculate margins of graphs
//    marginX = 2;
//    marginY = 2;
//    marginsAll = [marginX * numberOfGraphsInLine, marginY * numberOfLinesForGraphs];
//    //calculate axesSize
//    axesSize = [oneGraphWidth * numberOfGraphsInLine + marginsAll(1), oneGraphHeight * numberOfLinesForGraphs + marginsAll(2)];
    
    
    waitBarHandle = waitbar('Loading window with plots, please wait.');
    
    
    //create new figure with 2D plots of results
    //note: figure ID is created automatically - the first free ID, that is the lowest integer not already used by a window
    //figureWith2DPlots = createWindow();
    //figureWith2DPlots.axes_size = axesSize;
    figureWith2DPlots = figure("layout", "grid",...
                                "layout_options", createLayoutOptions("grid", [1 1]),...
                                "figure_size",[800, 600],...
                                "auto_resize", "on",...    //when scrollbars and higher size are needed set it to "off" ; however, it works only for first time after Scilab is run. (<>Scilab bug - set "off" because of scrollbar bug)
                                "toolbar", "none", ...
                                "infobar_visible", "off", ...
                                "dockable", "off",...
                                "backgroundcolor", [1 1 1],...
                                "visible", "off");
                                //'figure_position', [250, 150],...
                                //"menubar", "none",...
                                //"default_axes", "off",...
                                //
                                //"axes_size", axesSize,... //(<>Scilab bug - noted and moved because of scrollbar bug)
    //figureWith2DPlots.figure_id
    
    //axesMainFigureWith2DPlots = get("current_axes");
    //delete(gca());
    //delete(figureWith2DPlots.children(1));
    
    
    waitbar(0.1, waitBarHandle);
    
    
    drawlater();    //delay drawing axes entity
    //(<>Scilab bug - noted because of scrollbar bug)
//    //uicontrol frame
//    frameMainFigureWith2DPlots = uicontrol(figureWith2DPlots, "style", "frame",..
//               "layout" , "gridbag",...
//               "constraints", createConstraints("gridbag", [1 1 1 1], [1 1], "both"),...
//               "scrollable", "on",...
//               "FontSize", 15);
//               //,...
//               //"Units", "pixels",...  //(<>Scilab bug - noted because of scrollbar bug)
//               //"position", [0, 0, axesSize(1), axesSize(2)]); //(<>Scilab bug - noted because of scrollbar bug)
//               //"border", createBorder("line", "Red"),...
               
    
    
    waitbar(0.2, waitBarHandle);
    
    
    
    //(<>Scilab bug - noted because of scrollbar bug)
//    for i = 1 : 1 : numberOfLinesForGraphs
//        
//        for j = 1 : 1 : numberOfGraphsInLine
//            
//            if (i-1) * numberOfGraphsInLine + j <= numberOfColumns - 1 then
//                
//                //create frame for axes
//                frameWith2DPlots = uicontrol(frameMainFigureWith2DPlots, "style", "frame",..
//                        "layout" , "gridbag",...
//                        "constraints", createConstraints("gridbag", [j i 1 1], [1 1], "both"));
//                        //,...
//                        //"Units", "pixels",... //(<>Scilab bug - noted because of scrollbar bug)
//                        //"position", [0, 0, oneGraphWidth, oneGraphHeight]);   //(<>Scilab bug - noted because of scrollbar bug)
//                
//                axesMainFigureWith2DPlots = newaxes(frameWith2DPlots);
//                
//            else
//                
//                break;
//                
//            end
//            
//        end
//        
//    end
    
    //drawnow();  //draw axes entity
    waitbar(0.6, waitBarHandle);
    
    
    
    //indexesHeaderList = GetIndexesCSVvalues(CSVHeader, "Time");
    numberOfRows = size(CSVvalues, 1);
    
    //if time end is infinite or higher than end simulation time, set the end simulation time
    if timeEnd == %inf | timeEnd > CSVvalues(numberOfRows, 1) then
        timeEnd = CSVvalues(numberOfRows, 1);
    end
    
    //if time start is higher than 0, get only specific values depending on time constraints and recalculate CSV time
    indexStartValue = 1;
    if timeStart > 0 then
        indexStartValue = GetIndexesCSVvalues(CSVvalues, 1, timeStart);
        if indexStartValue == 0 then
            indexStartValue = 1;
        end
    end
    
    //if time end is lower than the end simulation time, get only specific values depending on time constraints and recalculate CSV time
    indexEndValue = numberOfRows;
    if timeEnd < CSVvalues(numberOfRows, 1) then
        indexEndValue = GetIndexesCSVvalues(CSVvalues, 1, timeEnd);
        if indexEndValue == 0 then
            indexEndValue = numberOfRows;
        elseif indexEndValue > 1 then
            indexEndValue = indexEndValue - 1;
        end
    end
    
    
    //get only specific range of values and recalculate them if needed
    recalculatedCSVvalues = CSVvalues;
    if indexStartValue ~= 1 | indexEndValue ~= numberOfRows then
        recalculatedCSVvalues = RecalculateValuesInCSV( recalculatedCSVvalues(indexStartValue:indexEndValue, :), 1 );
    end
    
    
    
    waitbar(0.7, waitBarHandle);
    
    
    
    //calculate number of lines for graphs (round up) depending on number of graphs and number of graphs which should be in one line
    NewNumberOfRows = size(recalculatedCSVvalues, 1);
    //go through all properties without the first "Time" property which is used as 'x' axis
    for i = 2 : 1 : numberOfColumns
        
        //add 2D plot with specific values
        Plot2DJSBsimResultsToNewAxis(CSVHeader(1) + " [s]", CSVHeader(i), recalculatedCSVvalues(:, 1), recalculatedCSVvalues(:, i), numberOfLinesForGraphs, numberOfGraphsInLine, i - 1); //frameMainFigureWith2DPlots.children(length(frameMainFigureWith2DPlots.children) - i + 2).children(1)  //(<>Scilab bug - noted because of scrollbar bug)
        waitbar(0.7 + (i / 1000), waitBarHandle);
        
    end
    
    drawnow();  //draw axes entity
    
    waitbar(1.0, waitBarHandle);
    //close wait bar window
    close(waitBarHandle);
    figureWith2DPlots.visible = "on";
    
    
endfunction



function [indexesHeaderList]=GetIndexesCSVheader(CSVHeader, headerPropertyName)
    
    indexesHeaderList = list();
    
    for i = 1 : 1 : size(CSVHeader, 2)
        
        //if the searching name is same as name in header, add the index
        //note: this is case sensitive solution (<>case insensitive solution could cause problems...or not?)
        if CSVHeader(i) == headerPropertyName then
            indexesHeaderList($+1) = i;
        end
        
    end
    
endfunction



function [indexValue]=GetIndexesCSVvalues(CSVvalues, column, value)
    
    indexValue = 0;
    for i = 1 : 1 : size(CSVvalues, 1)
        
        //if the searching value is same as or lower than value in csv values, add the index
        if CSVvalues(i, column) >= value then
            indexValue = i;
            break;
        end
        
    end
    
endfunction



function [outCSVvalues]=RecalculateValuesInCSV(inCSVvalues, column)
    
    outCSVvalues = inCSVvalues;
    
    //get first value for decreasing if exists
    firstValue = 0;
    if size(outCSVvalues, 1) > 0 then
        firstValue = outCSVvalues(1, column);
    end
    
    //for each value, decrease time in csv by the first time number
    for i = 1 : 1 : size(outCSVvalues, 1)
        outCSVvalues(i, column) = outCSVvalues(i, column) - firstValue;
    end
    
    
endfunction



function Plot2DJSBsimResultsToNewAxis(xLabel, yLabel, xValues, yValues, subPlotM, subPlotN, subPlotP)   //axes - //(<>Scilab bug - noted because of scrollbar bug)
    
    //<>debug only
    //disp(string(subPlotM) + " " + string(subPlotN) + " " + string(subPlotP));
    //disp(xValues);
    //disp(yValues);
    
    //subplot(m,n,p) breaks the graphics window into an m-by-n matrix of sub-windows and selects the p-th sub-window for drawing the current plot. The number of a sub-window into the matrices is counted row by row ie the sub-window corresponding to element (i,j) of the matrix has number (i-1)*n + j.
    subplot(subPlotM, subPlotN, subPlotP);
    plot(xValues, yValues); //axes  //(<>Scilab bug - noted because of scrollbar bug)
    fontSizeLabels = 3;
    colorFont = "black";
    xlabel(xLabel, "fontsize", fontSizeLabels, "color", colorFont);
    //ylabel(yLabel, "fontsize", fontSizeLabels, "color", colorFont);
    title(yLabel, "fontsize", fontSizeLabels, "color", colorFont);  //axes  //(<>Scilab bug - noted because of scrollbar bug)
    
//    
//    a=gca(); // Handle on axes entity
//    poly1= a.children(1).children(1); //store polyline handle into poly1
//    poly1.thickness = 3;  // ...and the tickness of a curve.
//    leg.font_style = 9;
//    
//    b=get("current_axes");  //get the handle of the newly created axes
//    b.labels_font_size=3;  //set the font size of value labels
    
    
endfunction



function SimulationExecuteJSBSimOrFlightGear(xmlSimulationStart, xmlSimulation, xmlReset, xmlAutopilot, xmlSimulationStartFilePath, xmlSimulationStartFileName, xmlSimulationFilePath, xmlSimulationFileName, xmlResetFilePath, xmlResetFileName, xmlAircraftFilePath, xmlAircratFileName, xmlAutopilotFilePath, xmlAutopilotFileName)
    
    
    scilabTag = "SCILAB_V6";
    flightGearTag = "FLIGHTGEAR"
    
    
    
    if xmlSimulationStart == [] then
        messagebox("Simulation Start file (xmlSimulationStart) is not set! (SimulationExecuteJSBSimOrFlightGear function)", "modal", "error");
        return;
    end
    
    
    
    //get (or get default) content of jsbsim_command_options xml element
    xmlJsbSimCommandOptionsContentArray = GetXMLContentOrDefault(xmlSimulationStart.root, "jsbsim_command_options", emptystr());
    //join string array to one string
    xmlJsbSimCommandOptionsCompleteString = JoinConsoleCommandsToStringFromStringArray(xmlJsbSimCommandOptionsContentArray);
    if xmlSimulationFileName == [] | strsubst(xmlSimulationFileName, " ", "") == emptystr() then
        messagebox("Filename of simulation definition (script) is empty! (xmlSimulationFileName)", "modal", "error");
        return;
    end
    scriptCommandBasic = "--script=" + """" + "scripts" + filesep() + xmlSimulationFileName + ".xml"" ";
    xmlJsbSimCommandOptionsCompleteString = scriptCommandBasic + xmlJsbSimCommandOptionsCompleteString;
    
    
    //get output processing information or set default
    defaultOutputProcessing = list("0", "%inf", "4", "8", scilabTag);
    defaultOutProcValues = list(0, %inf, 4, 8, %f);
    outputProcessingTimeStart = defaultOutputProcessing(1);
    timeStartNumber = defaultOutProcValues(1);
    outputProcessingTimeEnd = defaultOutputProcessing(2);
    timeEndNumber = defaultOutProcValues(2);
    outputProcessingNumberOfGraphsInLine = defaultOutputProcessing(3);
    numberOfGraphsInLineNumber = defaultOutProcValues(3);
    outputProcessingNumberOfGraphsInWindow = defaultOutputProcessing(4);
    numberOfGraphsInWindow = defaultOutProcValues(4);
    outputProcessingApplication = defaultOutputProcessing(5);
    scilabFlightGearSwitch = defaultOutProcValues(5);
    
    outputProcessingXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlSimulationStart.root, "output_processing");
    if outputProcessingXMLElement ~= [] then
        
        if outputProcessingXMLElement.attributes.time_start ~= [] then
            outputProcessingTimeStart = outputProcessingXMLElement.attributes.time_start;
        end
        
        if outputProcessingXMLElement.attributes.time_end ~= [] then
            outputProcessingTimeEnd = outputProcessingXMLElement.attributes.time_end;
        end
        
        if outputProcessingXMLElement.attributes.number_of_graphs_in_line ~= [] then
            outputProcessingNumberOfGraphsInLine = outputProcessingXMLElement.attributes.number_of_graphs_in_line;
        end
        
        if outputProcessingXMLElement.attributes.number_of_graphs_in_window ~= [] then
            outputProcessingNumberOfGraphsInWindow = outputProcessingXMLElement.attributes.number_of_graphs_in_window;
        end
        
        
        outputProcessingApplication = strsubst(outputProcessingXMLElement.content, " ", "");
        //if FlightGear was selected copy it, or set Scilab as default
        if convstr(outputProcessingApplication, "u") == flightGearTag then
            
            outputProcessingApplication = flightGearTag;
            scilabFlightGearSwitch = %t;
            
        //elseif convstr(outputProcessingApplication, "u") == scilabTag then
        else
            
            //otherwise, set default (Scilab)
            outputProcessingApplication = scilabTag;
            
        end
        
        
        //check time start, time end, and number of graphs in line - for scilab only
        if scilabFlightGearSwitch == %f
            
            //check and set time start for Scilab processing purpose
            isNumberTimeStart = isnum(outputProcessingTimeStart);
            if isNumberTimeStart then
                //convert string to number, if it successful, check value
                timeStartNumber = strtod(outputProcessingTimeStart);
                if string(timeStartNumber) == "Nan" then
                    outputProcessingTimeStart = defaultOutputProcessing(1);
                    timeStartNumber = defaultOutProcValues(1);
                end
            else
                outputProcessingTimeStart = defaultOutputProcessing(1);
                timeStartNumber = defaultOutProcValues(1);
            end
            
            
            //check and set time end for Scilab processing purpose
            isNumberTimeEnd = isnum(outputProcessingTimeEnd);
            if isNumberTimeEnd then
                //convert string to number, if it successful, check value
                timeEndNumber = strtod(outputProcessingTimeEnd);
                if string(timeEndNumber) == "Nan" then
                    outputProcessingTimeEnd = defaultOutputProcessing(2);
                    timeEndNumber = defaultOutProcValues(2);
                end
            else
                outputProcessingTimeEnd = defaultOutputProcessing(2);
                timeEndNumber = defaultOutProcValues(2);
            end
            
            
            //check and set number of graphs in line for Scilab processing purpose
            isNumberNumberOfGraphsInLine = isnum(outputProcessingNumberOfGraphsInLine);
            if isNumberNumberOfGraphsInLine then
                //convert string to number, if it successful, check value
                numberOfGraphsInLineNumber = strtod(outputProcessingNumberOfGraphsInLine);
                if string(numberOfGraphsInLineNumber) == "Nan" then
                    outputProcessingNumberOfGraphsInLine = defaultOutputProcessing(3);
                    numberOfGraphsInLineNumber = defaultOutProcValues(3);
                else
                    numberOfGraphsInLineNumber = ceil(numberOfGraphsInLineNumber);
                end
            else
                outputProcessingNumberOfGraphsInLine = defaultOutputProcessing(3);
                numberOfGraphsInLineNumber = defaultOutProcValues(3);
            end
            
            
            //check and set number of graphs in window for Scilab processing purpose
            isNumberNumberOfGraphsInWindow = isnum(outputProcessingNumberOfGraphsInWindow);
            if isNumberNumberOfGraphsInWindow then
                //convert string to number, if it successful, check value
                numberOfGraphsInWindow = strtod(outputProcessingNumberOfGraphsInWindow);
                if string(numberOfGraphsInWindow) == "Nan" then
                    outputProcessingNumberOfGraphsInWindow = defaultOutputProcessing(4);
                    numberOfGraphsInWindow = defaultOutProcValues(4);
                else
                    numberOfGraphsInWindow = ceil(numberOfGraphsInWindow);
                end
            else
                outputProcessingNumberOfGraphsInWindow = defaultOutputProcessing(4);
                numberOfGraphsInWindow = defaultOutProcValues(4);
            end
            
        end
        
    end
    
    
    
    //get output xml element and add each attribute or default
    defaultOutput = list("CSV", "output_Simulation.csv", "30", emptystr(), "tcp");
    defaultOutValues = list("CSV", "output_Simulation.csv", 30, emptystr(), "tcp");
    //if FlightGear was selected
    if scilabFlightGearSwitch == %t then
        defaultOutput(1) = flightGearTag;
        defaultOutValues(1) = flightGearTag;
        defaultOutput(2) = "localhost";
        defaultOutput(4) = "5500";
        defaultOutValues(4) = 5500;
    end
    outputType = defaultOutput(1);
    outputName = defaultOutput(2);
    outputRate = defaultOutput(3);
    rateNumber = defaultOutValues(3);
    outputPort = defaultOutput(4);
    portNumber = defaultOutValues(4);
    outputProtocol = defaultOutput(5);
    
    outputXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlSimulationStart.root, "output");
    if outputXMLElement ~= [] then
        
        //if Scilab was selected
        if scilabFlightGearSwitch == %f then
            
            if outputXMLElement.attributes.type ~= [] then
                outputType = outputXMLElement.attributes.type;
            end
            
            if outputXMLElement.attributes.name ~= [] then
                //check whether filename contains forbidden chars in name (windows only) and if so, replace them with "_" char
                if strindex(outputXMLElement.attributes.name, [':', '*', '?', '""', '<', '>', '|']) ~= [] then  //'\', '/', - these chars separate path, so they are acceptable sometimes but be careful
                    outputName = outputXMLElement.attributes.name;
                    outputName = strsubst(outputName, ":", "_");
                    outputName = strsubst(outputName, "*", "_");
                    outputName = strsubst(outputName, "?", "_");
                    outputName = strsubst(outputName, """", "_");
                    outputName = strsubst(outputName, "<", "_");
                    outputName = strsubst(outputName, ">", "_");
                    outputName = strsubst(outputName, "|", "_");
                    //outputName = strsubst(outputName, "\", "_");
                    //outputName = strsubst(outputName, "/", "_");
                else
                    outputName = outputXMLElement.attributes.name;
                end
            end
            
        end
        
        
        if outputXMLElement.attributes.rate ~= [] then
            //check and set rate
            isNumberRate = isnum(outputXMLElement.attributes.rate);
            if isNumberRate then
                //convert string to number, if it successful, check value
                rateNumberTemp = strtod(outputXMLElement.attributes.rate);
                if string(rateNumberTemp) ~= "Nan" then
                    if rateNumberTemp > 0 then
                        outputRate = outputXMLElement.attributes.rate;
                        rateNumber = rateNumberTemp;
                    end
                end
            end
        end
        
        
        //if FlightGear was selected
        if scilabFlightGearSwitch == %t then
            
            if outputXMLElement.attributes.port ~= [] then
                //check and set port for FlightGear processing purpose
                isNumberPort = isnum(outputXMLElement.attributes.port);
                if isNumberPort then
                    //convert string to number, if it successful, check value
                    portNumberTemp = strtod(outputXMLElement.attributes.port);
                    if string(portNumberTemp) ~= "Nan" then
                        if portNumberTemp > 0 then
                            outputPort = outputXMLElement.attributes.port;
                            portNumber = portNumberTemp;
                        end
                    end
                end
            end
            
            if outputXMLElement.attributes.protocol ~= [] then
                outputProtocol = outputXMLElement.attributes.protocol;
            end
            
        end
        
        
        //create output xml elment and add all original children as the last (to delete attributes in xml element)
        outXMLDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_empty.xml");
        outXMLElem = outXMLDoc.root;
        for i = 1 : 1 : length(outputXMLElement.children)
            xmlAppend(outXMLElem, outputXMLElement.children(i));
        end
        outputXMLElement = outXMLElem;
        outputXMLElement.attributes.type = outputType;
        outputXMLElement.attributes.name = outputName;
        outputXMLElement.attributes.rate = outputRate;
        outputXMLElement.attributes.port = outputPort;
        outputXMLElement.attributes.protocol = outputProtocol;
        
    else
        
        //get output xml elment with default values and add it as the last
        outXMLDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_with_defaults.xml");
        outXMLElem = outXMLDoc.root;
        outputXMLElement = outXMLElem;
        outputXMLElement.attributes.type = outputType;
        outputXMLElement.attributes.name = outputName;
        outputXMLElement.attributes.rate = outputRate;
        outputXMLElement.attributes.port = outputPort;
        outputXMLElement.attributes.protocol = outputProtocol;
        
    end
    
    
    
    //get (or get default) content of flightgear_path xml element
    xmlFlightgearPathContent = GetXMLContentOrDefault(xmlSimulationStart.root, "flightgear_path", emptystr());
    if scilabFlightGearSwitch == %t then
        
        fileFlightGearExecutableExist = fileinfo(xmlFlightgearPathContent);
        
        [OSName, OSVersion] = getos();
        global WindowsOSName;
        global LinuxOSName;
        
        //if FlightGear executable file does not exist at the path, try default known windows' paths
        if OSName == WindowsOSName then
            
            if fileFlightGearExecutableExist == [] then
                
                //check FlightGear path for 64 bit Windows OS
                xmlFlightgearPathContent = "C:\Program Files\FlightGear\bin\Win64\fgfs.exe";
                fileFlightGearExecutableExist = fileinfo(xmlFlightgearPathContent);
                if fileFlightGearExecutableExist == [] then
                    
                    //check 32 bit FlightGear path for 64 bit Windows OS
                    xmlFlightgearPathContent = "C:\Program Files (x86)\FlightGear\bin\Win32\fgfs.exe";
                    fileFlightGearExecutableExist = fileinfo(xmlFlightgearPathContent);
                    if fileFlightGearExecutableExist == [] then
                        messagebox("FlightGear executable file was not found! (flightgear_path in xmlSimulationStart)", "modal", "error");
                        return;
                    end
                    
                end
                
            end
            
            
        elseif OSName == LinuxOSName then
            
            if fileFlightGearExecutableExist == [] then
                
                //<> <>code for path check of FlightGear in Linux distributions
                
            end
            
        end
        
    end
    
    
    
    //get (or get default) content of flightgear_command_options xml element
    xmlFlightgearCommandOptionsContentArray = GetXMLContentOrDefault(xmlSimulationStart.root, "flightgear_command_options", emptystr());
    //join string array to one string

    xmlFlightgearCommandOptionsCompleteString = JoinConsoleCommandsToStringFromStringArray(xmlFlightgearCommandOptionsContentArray);
    fgCommandBasic = "--native-fdm=socket,in," + outputRate + ",," + outputPort + "," + outputProtocol + " --fdm=external ";
    xmlFlightgearCommandOptionsCompleteString = fgCommandBasic + xmlFlightgearCommandOptionsCompleteString;
    
    
    
    
    
    //check output xml element in simulation definition file (in "runscript" xml element, i.e. the root), if exist, replace it with new output xml element; if does not exist, add output xml element to script definition file
    
    if xmlSimulationFileName == [] | strsubst(xmlSimulationFileName, " ", "") == emptystr() then
        messagebox("There is no simulation definition filename in input! (SimulationExecuteJSBSimOrFlightGear function)", "modal", "error");
        return;
    end
    if xmlSimulation == [] then
        messagebox("Simulation Definition (xmlSimulation) is not set! (SimulationExecuteJSBSimOrFlightGear function)", "modal", "error");
        return;
    end
//    if outputXMLElement == [] then
//        messagebox("Output xml element (xmlOutputElement) for Simulation Definition is not set! (SimulationExecuteJSBSimOrFlightGear function)", "modal", "error");
//        return;
//    end
//    //add output xml element in simulation definition and delete all original output xml elements
//    addedOrChangedOutputXML = AddOrChangeOutputXMLElementInSimulationDefinition(xmlSimulation, outputXMLElement);
    
    
    //find output xml element in simulation definition if any
    outputSimulationDefinitionIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlSimulation.root, "output");
    if outputSimulationDefinitionIndexArray ~= [] then
        
        //replace output xml element in simulation definition for the output xml element in simulation start file
        xmlSimulation.root.children(outputSimulationDefinitionIndexArray(1)) = outputXMLElement;
        
    else
        
        //add the output xml element in simulation definition
        xmlAppend(xmlSimulation.root, outputXMLElement);
        
    end
    
    
    
    
    //copy aircraft, autopilot, reset file to aircraft folder and to inner folder with aircraft name (and autopilot file even to inner system folder) - if folders don't exist, create them
    
    //create the aircraft folder with another folder with aircraft name inside
    if xmlAircratFileName == [] | strsubst(xmlAircratFileName, " ", "") == emptystr() then
        messagebox("There is no aircraft filename in input! (SimulationExecuteJSBSimOrFlightGear function)", "modal", "error");
        return;
    end
    [wasCreatedAircraftFolder, outAircraftPath] = CreateAircraftFolderIfNotExists(xmlAircratFileName);
    if wasCreatedAircraftFolder == %f then
        return;
    end
    
    
    //copy aircraft definition file to output aircraft file, and back up the original if a file in output path exists
    [wasCopiedAircraftFile, outAircraftFilePath] = CopyAircraftDefinitionToAircraftPathAndBackupTheOriginal(xmlAircratFileName, xmlAircraftFilePath);
    if wasCopiedAircraftFile == %f then
        return;
    end
    
    
    //save reset file into aircraft folder, and back up the original if a file in output path exists
    if xmlResetFileName == [] | strsubst(xmlResetFileName, " ", "") == emptystr() then
        messagebox("There is no reset filename in input! (SimulationExecuteJSBSimOrFlightGear function)", "modal", "error");
        return;
    end
    wasSavedReset = SaveResetFileIntoAircraftFolderAndBackupTheOriginal(xmlReset, xmlResetFileName, xmlAircratFileName);
    if wasSavedReset == %f then
        return
    end
    
    
    
    //create new system folder in aircraft folder if it doesn't exist
    [wasCreatedSystemFolder, systemFolderPath] = CreateSystemFolderInAircraftFolderIfNotExists(outAircraftPath);
    if wasCreatedSystemFolder == %f then
        return;
    end
    
    
    //save autopilot file into "aircraft\<aircraft's name>\system" folder, and back up the original if a file in output path exists
    if xmlAutopilotFileName == [] | strsubst(xmlAutopilotFileName, " ", "") == emptystr() then
        messagebox(["There is no autopilot filename in input! (SimulationExecuteJSBSimOrFlightGear function)" ; "Load autopilot file using Open button in the main window or save the current autopilot file using Save button."], "modal", "error");
        return;
    end
    wasSavedAutopilot = SaveAutopilotFileIntoSystemInAircraftFolderAndBackupTheOriginal(xmlAutopilot, xmlAutopilotFileName, xmlAircratFileName);
    if wasSavedAutopilot == %f then
        return;
    end
    
    
    
    
    //change/add autopilot xml element (path to autopilot file) in aircraft file and find and delete (if any) output xml element in aircraft file
    
    //change/add autopilot xml element in aircraft definition
    fileWasChangedAutopilotInAircraft = FindAndChangeOrAddAutopilotFilePathInAircraftFile(outAircraftFilePath, xmlAutopilotFileName);
    if fileWasChangedAutopilotInAircraft == %f then
        return;
    end
    
    
    //delete output xml element in aircraft definition if any
    wasDeletedOrNoOutputInAircraft = DeleteOutputXMLelementInAircraftXMLfile(outAircraftFilePath);
    if wasDeletedOrNoOutputInAircraft == %f then
        return;
    end
    
    
    
    
    //save simulation definition with new output xml element to script folder
    
    //create script folder if it doesn't exist
    wasCreatedScriptFolder = CreateScriptsFolderIfNotExists();
    if wasCreatedScriptFolder == %f then
        return;
    end
    
    
    wasSavedSimulationDefinition = SaveSimulationDefinitionIntoScriptFolderAndBackupTheOriginal(xmlSimulation, xmlSimulationFileName);
    if wasSavedSimulationDefinition == %f then
        return;
    end
    
    
    
    
    //save simulation start to simulation folder - if the filename of simulation start is not set, use default
    
    wasCreatedSimulationFolder = CreateSimulationFolderIfNotExists();
    if wasCreatedSimulationFolder == %f then
        return;
    end
    
    
    wasSavedSimulationStart = SaveSimulationStartIntoSimulationFolderAndBackupTheOriginal(xmlSimulationStart, xmlSimulationStartFileName);
    if wasSavedSimulationStart == %f then
        return;
    end
    
    
    
    
    //if FlightGear was selected, execute FlightGear application first and then, the JSBSim application
    if scilabFlightGearSwitch == %t then
        
        
        //show proggression bar
        proggressBarFlightGear = progressionbar('FlightGear is executed, please, wait until it is loaded (FlightGear has to be installed and has to be executed before JSBSim execution).');
        
        
//        //"start" command in dos function causes a Scilab (currently version 6.0.0 and higher) crash after simulation (sometimes, it shows error in console after user clicks on a uicontrol in GUI: "parser: Cannot open file TMPDIR\command.temp") ; if this line is not used, the application and Scilab work fine after simulation. Therefore we used "figure" solution with button which is neccessary to click to continue - after this bug will be fixted, it will be changed back and FlightGear will be launched automatically in parallel thread
        //(<>Scilab bug - "start" command bug partial bypass - beggining)
        
//        //[flightGearFigure, flightGearFigure_OkButton] = CreateFlightGearWindowForExecution("""" + xmlFlightgearPathContent + """ " + xmlFlightgearCommandOptionsCompleteString);
//        CreateFlightGearWindowForExecution("""" + xmlFlightgearPathContent + """ " + xmlFlightgearCommandOptionsCompleteString);
        
//        //wait until is clicked
//        ibutton = -1;
//        iwin = -1;
//        //while the FlightGear Execution Dialog is not closed
//        while(ibutton ~= -1000 | iwin ~= flightGearFigure.figure_id)
//            
//            //wait until is clicked
//            [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
//            
//            //check whether some callback was clicked
//            if ibutton == -2 then
//                
//                //if OK (i.e. "Run FlightGear") was clicked, break the waiting for click
//                if strindex(cbmenu, flightGearFigure_OkButton.callback) then
//                    
//                    //execstr(flightGearFigure_OkButton.callback);
//                    //break this cycle
//                    break;
//                    
//                end
//                
//            //else if the dialog was closed, end whole function (FlightGear was not executed)
//            elseif ibutton == -1000 then
//                
//                //close proggression bar
//                close(proggressBarFlightGear);
//                //end whole function - i.e. FlightGear was not executed and therefore JSBSim will not be executed too
//                return;
//                
//            end
//            
//        end
        
        
//        global flightGearFigureDialog;
//        //wait until Ok (ie. "Run FlightGear") is clicked, or the FlightGear dialog is closed (<>it doesn't work)
//        while flightGearFigureDialog ~= [] | flightGearFigureDialog.user_data == []
//            
//            //wait for 1.0 seconds
//            sleep(1000);
//            
//        end
//        //the dialog was closed, end whole function (FlightGear was not executed)
//        if flightGearFigureDialog == [] | flightGearFigureDialog.user_data ~= 1 then
//            
//            //close proggression bar
//            close(proggressBarFlightGear);
//            //end whole function - i.e. FlightGear was not executed and therefore JSBSim will not be executed too
//            return;
//            
//        end
//        //if OK (i.e. "Run FlightGear") was clicked, continue with code
        
        //(<>Scilab bug - "start" command bug partial bypass - end)
        
        
        
        [OSName, OSVersion] = getos();
        global WindowsOSName;
        global LinuxOSName;
        
        //execute FlightGear application using "start" command (windows only) to create new command terminal - it enables to continue in Scilab code
        //(<>Scilab bug - noted because using "start" command in command line causes parse error/crash after ending of this function and executing another function or just command)
        if OSName == WindowsOSName then
            dos("start """" " + """" + xmlFlightgearPathContent + """ " + xmlFlightgearCommandOptionsCompleteString);
        elseif OSName == LinuxOSName then
            //<> <>not tested
            unix("nohup """" " + """" + xmlFlightgearPathContent + """ " + xmlFlightgearCommandOptionsCompleteString + " > /dev/null &");
        end
        //[flightGearCmdOutput, flightGearCmdbOK, flightGearCmdExitCode] = JSBSimOrFlightGearExecution("start """" " + """" + xmlFlightgearPathContent + """ " + xmlFlightgearCommandOptionsCompleteString);
        
        
        //wait 2 seconds
        sleep(2000);
        //close proggression bar
        close(proggressBarFlightGear);
        
        
        //wait until the FlightGear is loaded correctly
        answerJSBSimExecute = messagebox("Please, wait until FlightGear is fully loaded and then press OK button.", "modal", "info");
        //if OK was clicked, execute JSBSim
        if answerJSBSimExecute == 1 then
            
            proggressBarJSBSim = progressionbar(['JSBSim is executed, after the JSBSim script is over, this dialog will be closed' ; '(see Scilab command or FlightGear visualization for details.']);
            //execute JSBSim application
            if OSName == WindowsOSName then
                dos("start """" " + """JSBSim"" " + xmlJsbSimCommandOptionsCompleteString);
            elseif OSName == LinuxOSName then
                //<> <>not tested
                unix("nohup """" " + """JSBSim"" " + xmlJsbSimCommandOptionsCompleteString + " > /dev/null &");
            end
            //[jsbSimCmdOutput, jsbSimCmdbOK, jsbSimCmdExitCode] = JSBSimOrFlightGearExecution("start ""JSBSim console window"" " + """JSBSim"" " + xmlJsbSimCommandOptionsCompleteString);
            //[jsbSimCmdOutput, jsbSimCmdbOK, jsbSimCmdExitCode] = JSBSimOrFlightGearExecution("""JSBSim"" " + xmlJsbSimCommandOptionsCompleteString);
            //close proggression bar
            close(proggressBarJSBSim);
            
        else
            disp(["JSBSim was called to cancel the simulation (user closed JSBSim dialog instead of clicking on OK button)" ; ])
            
            if OSName == WindowsOSName then
                
                //this command will kill all launched FlightGear processes for windows only
                dos('taskkill /IM fgfs.exe');
                
            elseif OSName == LinuxOSName then
                
                //this command will kill all launched FlightGear processes for Linux only
                //<> <>not tested
                unix("killall fgfs");
                
            end

        end
        
        
        ////this command will kill all launched FlightGear processes
        //dos('taskkill /IM fgfs.exe');
        ////this command will kill all launched JSBSim processes
        //dos('taskkill /IM JSBSim.exe');
        
        
        
    //if JSBSim was selected, load and show csv file
    elseif scilabFlightGearSwitch == %f then
        
        
        //show proggression bar
        proggressBarJSBSim = progressionbar('JSBSim with the defined simulation script is executed, please wait for results.');
        //execute JSBSim application
        [jsbSimCmdOutput, jsbSimCmdbOK, jsbSimCmdExitCode] = JSBSimOrFlightGearExecution("""JSBSim"" " + xmlJsbSimCommandOptionsCompleteString);
        close(proggressBarJSBSim);
        
        
        
        //after simulation, when Scilab was selected for processing, move csv output to "output" folder but only when the output CSV file is not already there - if exists, backup the original
        wasCreatedOutputFolder = CreateOutputFolderIfNotExists();
        if wasCreatedOutputFolder == %f then
            return;
        end
        wasCopiedOutputCSV = MoveOutputCSVToOutputPathAndBackupTheOriginal(outputName, pwd() + filesep() + outputName);
        //if it was copied properly, change the local path to output CSV file
        if wasCopiedOutputCSV == %t then
            global outputFolderName;
            outputName = outputFolderName + filesep() + outputName;
        end
        
        
        
        //ask question whether user wants to show results from CSV file in graphs depending on settings in simulation start xml
        answerMsgScilabPlotting = messagebox(["Do you want to show results in Scilab plots?"], "Scilab plotting of JSBSim results", "question", ["Yes" "No"], "modal");
        //if a simulation file should be opened or the current simulation file should be edited
        if answerMsgScilabPlotting == 1 then
            
            
            //load csv file and separate header and value parts
            [CSVHeader, CSVvalues] = ReadAndEvalCSVfile(outputName);
            //process the output csv file and show figure with plots
            
            //(<>Scilab bug - noted because of scrollbar bug)
//            global GraphWidth;
//            global GraphHeight;
            
            //calculate number of windows - which depends on number of columns
            numberOfGraphsAll = size(CSVvalues, 2) - 1;
            numberOfWindows = ceil(numberOfGraphsAll / numberOfGraphsInWindow);
            //create and show all figures with a specific number of graphs in one window and with a specific number of graphs in one line
            for i = 1 : 1 : numberOfWindows
                
                //calculate start and end index for graphs' separation
                startIndex = (i - 1) * numberOfGraphsInWindow + 2;  //the first column is ignored because it contains the time data
                endIndex = numberOfGraphsAll + 1;
                if i ~= numberOfWindows then
                    endIndex = i * numberOfGraphsInWindow + 1;
                end
                
                //separate CSV values and CSV headers to parts depending on numberOfGraphsInWindow
                partCSVHeader = cat(2, CSVHeader(:, 1), CSVHeader(:, startIndex:endIndex));
                partCSVvalues = cat(2, CSVvalues(:, 1), CSVvalues(:, startIndex:endIndex));
                
                //create and show one figure with a specific number of graphs in the window and with a specific number of graphs in one line    //figureWith2DPlots = 
                CreateAndShowFigureWithJSBsimResultsIn2DPlots(partCSVHeader, partCSVvalues, timeStartNumber, timeEndNumber, numberOfGraphsInLineNumber);//, GraphWidth, GraphHeight);   //(<>Scilab bug - noted because of scrollbar bug)
                
            end
            
        end
        
    end
    
    
endfunction



function ControllerAdjustmentSimulationExecuteJSBSim(xmlControllerAdjustmentDefinition, xmlSimulation, xmlReset, xmlAutopilot, xmlControllerAdjustmentDefinitionFilePath, xmlControllerAdjustmentDefinitionFileName, xmlSimulationFilePath, xmlSimulationFileName, xmlResetFilePath, xmlResetFileName, xmlAircraftFilePath, xmlAircratFileName, xmlAutopilotFilePath, xmlAutopilotFileName, propertiesAvailable)
    
    
    
    zieglerNichols_CriticalGainTag = "ZIEGLER_NICHOLS-CRITICAL_GAIN";
    geneticAlgorithmTag = "GENETIC_ALGORITHM";
    
    
    
    if xmlControllerAdjustmentDefinition == [] then
        messagebox("Controller Adjustment Definition file (xmlControllerAdjustmentDefinition) is not set! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    
    
    
    //get (or get default) content of jsbsim_command_options xml element
    xmlJsbSimCommandOptionsContentArray = GetXMLContentOrDefault(xmlControllerAdjustmentDefinition.root, "jsbsim_command_options", emptystr());
    //join string array to one string
    xmlJsbSimCommandOptionsCompleteString = JoinConsoleCommandsToStringFromStringArray(xmlJsbSimCommandOptionsContentArray);
    if xmlSimulationFileName == [] | strsubst(xmlSimulationFileName, " ", "") == emptystr() then
        messagebox("Filename of simulation definition (script) is empty! (xmlSimulationFileName in ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    scriptCommandBasic = "--script=" + """" + "scripts" + filesep() + xmlSimulationFileName + ".xml"" ";
    xmlJsbSimCommandOptionsCompleteString = scriptCommandBasic + xmlJsbSimCommandOptionsCompleteString;
    
    
    
    if xmlAutopilotFileName == [] | strsubst(xmlAutopilotFileName, " ", "") == emptystr() then
        messagebox(["There is no autopilot filename in input! (ControllerAdjustmentSimulationExecuteJSBSim function)"], "modal", "error");
        return;
    end
    //find and get autopilot_adjustable_component
    xmlAdjustableComponent = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinition.root, "autopilot_adjustable_component");
    xmlAutopilotAdjustableComponent = [];
    xmlChannelChildrenIndexAutopilotAdjustableComponent = 0;
    xmlAutopilotAdjustableComponentIndexChildrenChannel = 0;
    if xmlAdjustableComponent ~= [] then
        
        //find first pure_gain component
        xmlAdjustableComponentPureGainOrPID = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlAdjustableComponent, "pure_gain");
        if xmlAdjustableComponentPureGainOrPID == [] then
            //if pure_gain component was not found, find first pid component
            xmlAdjustableComponentPureGainOrPID = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlAdjustableComponent, "pid");
            if xmlAdjustableComponentPureGainOrPID == [] then
                messagebox("Autopilot adjustable component was not set properly: no ""pid"" or ""pure_gain"" component was found but these are the only which are supported!", "modal", "error");
                return;
            end
        end
        
        //find and get the selected adjustable component (with channel index and sub-index of component in channel) in autopilot xml file
        [xmlAutopilotAdjustableComponent, xmlChannelChildrenIndexAutopilotAdjustableComponent, xmlAutopilotAdjustableComponentIndexChildrenChannel] = GetSelectedAdjustableComponentFromAutopilot(xmlAutopilot, xmlAdjustableComponentPureGainOrPID);
        if xmlAutopilotAdjustableComponent == [] then
            
            //show error message and end function
            messagebox("xmlAutopilotAdjustableComponent """ + xmlAdjustableComponentPureGainOrPID.attributes.name + """ (JSBSim type: """ + xmlAdjustableComponentPureGainOrPID.name + """) from ControllerAdjustmentDefinition xml file was not found in xmlAutopilot! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        
    else
        
        //show error message and end function
        messagebox("xmlAdjustableComponent (autopilot_adjustable_component) was not found in xmlControllerAdjustmentDefinition (control_design_start) xml file! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
        
    end
    
    
    
    //get output xml element and add each attribute or default
    defaultOutput = list("CSV", "output_ControllerAdjustment.csv", "30");
    defaultOutValues = list("CSV", "output_ControllerAdjustment.csv", 30);
    outputType = defaultOutput(1);
    outputName = defaultOutput(2);
    outputRate = defaultOutput(3);
    rateNumber = defaultOutValues(3);
    outputPropertyName = emptystr();
    
    outputXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinition.root, "output");
    if outputXMLElement ~= [] then
        
        
        if outputXMLElement.attributes.type ~= [] then
            outputType = outputXMLElement.attributes.type;
        end
        
        
        if outputXMLElement.attributes.name ~= [] then
            //check whether filename contains forbidden chars in name (windows only) and if so, replace them with "_" char
            if strindex(outputXMLElement.attributes.name, ['\', '/', ':', '*', '?', '""', '<', '>', '|']) ~= [] then
                outputName = outputXMLElement.attributes.name;
                outputName = strsubst(outputName, "\", "_");
                outputName = strsubst(outputName, "/", "_");
                outputName = strsubst(outputName, ":", "_");
                outputName = strsubst(outputName, "*", "_");
                outputName = strsubst(outputName, "?", "_");
                outputName = strsubst(outputName, """", "_");
                outputName = strsubst(outputName, "<", "_");
                outputName = strsubst(outputName, ">", "_");
                outputName = strsubst(outputName, "|", "_");
            else
                outputName = outputXMLElement.attributes.name;
            end
        end
        
        
        if outputXMLElement.attributes.rate ~= [] then
            //check and set rate
            isNumberRate = isnum(outputXMLElement.attributes.rate);
            if isNumberRate then
                //convert string to number, if it successful, check value
                rateNumberTemp = strtod(outputXMLElement.attributes.rate);
                if string(rateNumberTemp) ~= "Nan" then
                    if rateNumberTemp > 0 then
                        outputRate = outputXMLElement.attributes.rate;
                        rateNumber = rateNumberTemp;
                    end
                end
            end
        end
        
        
        propertyOutputXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(outputXMLElement, "property");
        if propertyOutputXMLElement ~= [] then
            
            //check whether output property is in properties available database
            outputPropertyTextStringWithoutSpaces = strsubst(propertyOutputXMLElement.content, " ", "");
            outputPropertyFound = FindPropertyInPropertiesAvailable(outputPropertyTextStringWithoutSpaces, propertiesAvailable);
            if outputPropertyFound == %t then
                outputPropertyName = outputPropertyTextStringWithoutSpaces;
            else
                //show error message and end function
                messagebox("Output Property: Property """ + outputPropertyTextStringWithoutSpaces + """ does not exist in propertiesAvailable database! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
                return;
            end
            
        else
            //show error message and end function
            messagebox("Output Property: Property xml element was not found in output xml element! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
        end
        
        
        
        //set all original attributes in output xml elment to achieved values
        outputXMLElement.attributes.type = outputType;
        outputXMLElement.attributes.name = outputName;
        outputXMLElement.attributes.rate = outputRate;
        if outputPropertyName ~= emptystr() then
            propertyOutputXMLElement.content = outputPropertyName;
        else
            //show error message and end function
            messagebox("Output Property: Property name is empty! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
        end
        
        
        
    else
        
        //show error message and end function
        messagebox("outputXMLElement (output) was not found in xmlControllerAdjustmentDefinition (control_design_start) xml file! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
        
    end
    
    
    
    //get output analysis information or set default
    defaultOutputAnalysis = list("0", "%inf", emptystr());
    defaultOutAnalysValues = list(0, %inf, 0);
    outputAnalysisTimeStart = defaultOutputAnalysis(1);
    timeStartNumber = defaultOutAnalysValues(1);
    outputAnalysisTimeEnd = defaultOutputAnalysis(2);
    timeEndNumberOrig = defaultOutAnalysValues(2);
    timeEndNumber = defaultOutAnalysValues(2);
    outputAnalysisMethod = defaultOutputAnalysis(3);
    outputAnalysisMethPopupmenuValue = defaultOutAnalysValues(3);
    
    outputAnalysisXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinition.root, "output_analysis");
    if outputAnalysisXMLElement ~= [] then
        
        
        if outputAnalysisXMLElement.attributes.time_start ~= [] then
            outputAnalysisTimeStart = outputAnalysisXMLElement.attributes.time_start;
        end
        
        if outputAnalysisXMLElement.attributes.time_end ~= [] then
            outputAnalysisTimeEnd = outputAnalysisXMLElement.attributes.time_end;
        end
        
        
        outputAnalysisMethod = strsubst(outputAnalysisXMLElement.content, " ", "");
        //check which method for controller adjustment was selected
        if convstr(outputAnalysisMethod, "u") == zieglerNichols_CriticalGainTag then
            
            //set ziegler nichols method with critical gain
            outputAnalysisMethod = zieglerNichols_CriticalGainTag;
            outputAnalysisMethPopupmenuValue = 1;
            
        elseif convstr(outputAnalysisMethod, "u") == geneticAlgorithmTag then
            
            //set genetic algorithm
            outputAnalysisMethod = geneticAlgorithmTag;
            outputAnalysisMethPopupmenuValue = 2;
            
        else
            
            //show error message and end function
            messagebox("outputAnalysisMethod (output_analysis) is not supported """ + outputAnalysisMethod + """! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        
        
        
        //check and set time start for analysis purpose
        isNumberTimeStart = isnum(outputAnalysisTimeStart);
        if isNumberTimeStart then
            //convert string to number, if it successful, check value
            timeStartNumber = strtod(outputAnalysisTimeStart);
            if string(timeStartNumber) == "Nan" then
                outputAnalysisTimeStart = defaultOutputAnalysis(1);
                timeStartNumber = defaultOutAnalysValues(1);
            end
        else
            outputAnalysisTimeStart = defaultOutputAnalysis(1);
            timeStartNumber = defaultOutAnalysValues(1);
        end
        
        
        //check and set time end for analysis purpose
        isNumberTimeEnd = isnum(outputAnalysisTimeEnd);
        if isNumberTimeEnd then
            //convert string to number, if it successful, check value
            timeEndNumberOrig = strtod(outputAnalysisTimeEnd);
            if string(timeEndNumberOrig) == "Nan" then
                outputAnalysisTimeEnd = defaultOutputAnalysis(2);
                timeEndNumberOrig = defaultOutAnalysValues(2);
            end
        else
            outputAnalysisTimeEnd = defaultOutputAnalysis(2);
            timeEndNumberOrig = defaultOutAnalysValues(2);
        end
        
        
    else
        
        //show error message and end function
        messagebox("outputAnalysisXMLElement (output_analysis) was not found in xmlControllerAdjustmentDefinition (control_design_start)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
        
    end
    
    
    //check output analysis start and end values - add error string if necessary
    
    //check whether the start value is higher than or equal to 0
    if timeStartNumber < 0 | timeStartNumber == %inf then
        messagebox("Output Analysis Time Start: " + "It has to be higher than or equal to ""0""!  converted value: """ + string(timeStartNumber) + """ (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    
    //check whether the end value is higher than 0
    if timeEndNumberOrig <= 0 then
        messagebox("Output Analysis Time End:" + "It has to be higher than ""0""!  converted value: " + string(timeEndNumberOrig) + " (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    
    
    //check time numbers and compare with each other
    //check start and end time numbers
    if timeStartNumber >= timeEndNumberOrig then
        messagebox("Output analysis time start has to be lower than time end!  Time start: " + string(timeStartNumber) + "  Time end: " + string(timeEndNumberOrig) + " (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    
    
    
    
    
    //get method_parameters xml element
    methodParametersXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinition.root, "method_parameters");
    if methodParametersXMLElement == [] then
        
        //show error message and end function
        messagebox("methodParametersXMLElement (method_parameters) was not found in xmlControllerAdjustmentDefinition (control_design_start)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
        
    end
    
    
    //decode method parameters xml element and create labels and values
    [labelsXmlMethodParameters, valuesXmlMethodParameters] = DecodeXmlMethodParameters(methodParametersXMLElement, outputAnalysisMethPopupmenuValue);
    //check all options in method parameters xml element depending on selected controller adjustment method
    [isCorrectXmlMethodParameters, errorMessageXmlMethodParameters] = CheckCorrectXmlMethodParameters(valuesXmlMethodParameters, outputAnalysisMethPopupmenuValue, labelsXmlMethodParameters);
    if isCorrectXmlMethodParameters == %f then
        messagebox("Method Parameters error: " + errorMessageXmlMethodParameters, "modal", "error");
        return;
    end
    
    
    
    
    
    //check output xml element in simulation definition file (in "runscript" xml element, i.e. the root), if exist, replace it with new output xml element; if does not exist, add output xml element to script definition file
    
    if xmlSimulationFileName == [] | strsubst(xmlSimulationFileName, " ", "") == emptystr() then
        messagebox("There is no simulation definition filename in input! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    if xmlSimulation == [] then
        messagebox("Simulation Definition (xmlSimulation) is not set! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
//    if outputXMLElement == [] then
//        messagebox("Output xml element (xmlOutputElement) for Simulation Definition is not set! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//        return;
//    end
//    //add output xml element in simulation definition and delete all original output xml elements
//    addedOrChangedOutputXML = AddOrChangeOutputXMLElementInSimulationDefinition(xmlSimulation, outputXMLElement);
    
    
    //find output xml element in simulation definition if any
    outputSimulationDefinitionIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlSimulation.root, "output");
    if outputSimulationDefinitionIndexArray ~= [] then
        
        //replace output xml element in simulation definition for the output xml element in controller adjustment definition file
        xmlSimulation.root.children(outputSimulationDefinitionIndexArray(1)) = outputXMLElement;
        
    else
        
        //add the output xml element in simulation definition
        xmlAppend(xmlSimulation.root, outputXMLElement);
        
    end
    
    
    
    
    //copy aircraft, autopilot, reset file to aircraft folder and to inner folder with aircraft name (and autopilot file even to inner system folder) - if folders don't exist, create them
    
    //create the aircraft folder with another folder with aircraft name inside
    if xmlAircratFileName == [] | strsubst(xmlAircratFileName, " ", "") == emptystr() then
        messagebox("There is no aircraft filename in input! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    [wasCreatedAircraftFolder, outAircraftPath] = CreateAircraftFolderIfNotExists(xmlAircratFileName);
    if wasCreatedAircraftFolder == %f then
        return;
    end
    
    
    //copy aircraft definition file to output aircraft file, and back up the original if a file in output path exists
    [wasCopiedAircraftFile, outAircraftFilePath] = CopyAircraftDefinitionToAircraftPathAndBackupTheOriginal(xmlAircratFileName, xmlAircraftFilePath);
    if wasCopiedAircraftFile == %f then
        return;
    end
    
    
    //save reset file into aircraft folder, and back up the original if a file in output path exists
    if xmlResetFileName == [] | strsubst(xmlResetFileName, " ", "") == emptystr() then
        messagebox("There is no reset filename in input! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
    end
    wasSavedReset = SaveResetFileIntoAircraftFolderAndBackupTheOriginal(xmlReset, xmlResetFileName, xmlAircratFileName);
    if wasSavedReset == %f then
        return
    end
    
    
    
    //create new system folder in aircraft folder if it doesn't exist
    [wasCreatedSystemFolder, systemFolderPath] = CreateSystemFolderInAircraftFolderIfNotExists(outAircraftPath);
    if wasCreatedSystemFolder == %f then
        return;
    end
    
    
    //save autopilot file into "aircraft\<aircraft's name>\system" folder, and back up the original if a file in output path exists
//    if xmlAutopilotFileName == [] | strsubst(xmlAutopilotFileName, " ", "") == emptystr() then
//        messagebox(["There is no autopilot filename in input! (ControllerAdjustmentSimulationExecuteJSBSim function)"], "modal", "error");
//        return;
//    end
    wasSavedAutopilot = SaveAutopilotFileIntoSystemInAircraftFolderAndBackupTheOriginal(xmlAutopilot, xmlAutopilotFileName, xmlAircratFileName);
    if wasSavedAutopilot == %f then
        return;
    end
    
    
    
    
    //change/add autopilot xml element (path to autopilot file) in aircraft file and find and delete (if any) output xml element in aircraft file
    
    //change/add autopilot xml element in aircraft definition
    fileWasChangedAutopilotInAircraft = FindAndChangeOrAddAutopilotFilePathInAircraftFile(outAircraftFilePath, xmlAutopilotFileName);
    if fileWasChangedAutopilotInAircraft == %f then
        return;
    end
    
    
    //delete output xml element in aircraft definition if any
    wasDeletedOrNoOutputInAircraft = DeleteOutputXMLelementInAircraftXMLfile(outAircraftFilePath);
    if wasDeletedOrNoOutputInAircraft == %f then
        return;
    end
    
    
    
    
    //save simulation definition with new output xml element to script folder
    
    //create script folder if it doesn't exist
    wasCreatedScriptFolder = CreateScriptsFolderIfNotExists();
    if wasCreatedScriptFolder == %f then
        return;
    end
    
    
    wasSavedSimulationDefinition = SaveSimulationDefinitionIntoScriptFolderAndBackupTheOriginal(xmlSimulation, xmlSimulationFileName);
    if wasSavedSimulationDefinition == %f then
        return;
    end
    
    
    
    
    //save controller adjustment definition to control_design folder - if the filename of controller adjustment definition is not set, use default
    
    wasCreatedControlDesignFolder = CreateControlDesignFolderIfNotExists();
    if wasCreatedControlDesignFolder == %f then
        return;
    end
    
    
    wasSavedControllerAdjustmentDefinition = SaveControllerAdjustmentDefinitionIntoControlDesignFolderAndBackupTheOriginal(xmlControllerAdjustmentDefinition, xmlControllerAdjustmentDefinitionFileName);
    if wasSavedControllerAdjustmentDefinition == %f then
        return;
    end
    
    
    
    
    //create directory "controller_adjustment_progression" for saving the whole progress from the beginning to the end
    global controllerAdjustmentProgressionFolderName;
    controllerAdjustmentProgressionPath = controllerAdjustmentProgressionFolderName;
    wasCreatedControllerAdjustmentProgressionFolder = CreateFolderIfNotExists(controllerAdjustmentProgressionPath);
    if wasCreatedControllerAdjustmentProgressionFolder == %f then
        return;
    end
    
    //create subdirectory "controller_adjustment_progression\<aircraft's name>"
    controllerAdjustmentProgressionPath = controllerAdjustmentProgressionPath + filesep() + xmlAircratFileName;
    wasCreatedAircratFolderInControllerAdjustmentProgression = CreateFolderIfNotExists(controllerAdjustmentProgressionPath);
    if wasCreatedAircratFolderInControllerAdjustmentProgression == %f then
        return;
    end
    
    //create subdirectory "controller_adjustment_progression\<aircraft's name>\<autopilot_filename>_<adjustable_componenet_name>"
    //check whether adjustable_componenet_name contains forbidden chars in folder name (windows only) and if so, replace them with "-" char
    adjustableComponenetFolderName = emptystr();
    if strindex(xmlAutopilotAdjustableComponent.attributes.name, ['\', '/', ':', '*', '?', '""', '<', '>', '|']) ~= [] then
        adjustableComponenetFolderName = xmlAutopilotAdjustableComponent.attributes.name;
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, "\", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, "/", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, ":", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, "*", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, "?", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, """", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, "<", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, ">", "-");
        adjustableComponenetFolderName = strsubst(adjustableComponenetFolderName, "|", "-");
    else
        adjustableComponenetFolderName = xmlAutopilotAdjustableComponent.attributes.name;
    end
    controllerAdjustmentProgressionPath = controllerAdjustmentProgressionPath + filesep() + xmlAutopilotFileName + "_" + strsubst(adjustableComponenetFolderName, " ", "");
    wasCreatedAutopilotFolderInAircratInControllerAdjustmentProgression = CreateFolderIfNotExists(controllerAdjustmentProgressionPath);
    if wasCreatedAutopilotFolderInAircratInControllerAdjustmentProgression == %f then
        return;
    end
    
    //create subdirectory "controller_adjustment_progression\<aircraft's name>\<autopilot_filename>_<adjustable_componenet_name>\<controller_adjustment_definition_filename>_<datetime>"
    currentTimeAsVector = clock();
    currentTimeAsVector(6) = round(currentTimeAsVector(6));
    currentTimeAsVectString = string(currentTimeAsVector);
    for i = 1 : 1 : size(currentTimeAsVector, 2)
        if currentTimeAsVector(i) < 10 then
            currentTimeAsVectString(i) = "0" + currentTimeAsVectString(i);
        end
    end
    separatorDateTime = "-";
    DateTimeStringFolderName = currentTimeAsVectString(1) + separatorDateTime + currentTimeAsVectString(2) + separatorDateTime + currentTimeAsVectString(3) + "_" + currentTimeAsVectString(4) + separatorDateTime + currentTimeAsVectString(5) + separatorDateTime + currentTimeAsVectString(6);
    controllerAdjustmentProgressionPath = controllerAdjustmentProgressionPath + filesep() + DateTimeStringFolderName;
    //controllerAdjustmentProgressionPath = controllerAdjustmentProgressionPath + filesep() + xmlControllerAdjustmentDefinitionFileName + "_" + DateTimeStringFolderName;   //changed because of possible long folder names and then also paths
    wasCreatedControllerAdjustmentDefinitionWithDateTimeFolderInAutopilotInAircratInControllerAdjustmentProgression = CreateFolderIfNotExists(controllerAdjustmentProgressionPath);
    if wasCreatedControllerAdjustmentDefinitionWithDateTimeFolderInAutopilotInAircratInControllerAdjustmentProgression == %f then
        return;
    end
    
    
    
    
    //copy aircraft, and save reset, script, and controller adjustment definition files into the controllerAdjustmentProgressionPath
    
    //copy aircraft file to the controllerAdjustmentProgressionPath
    wasCopiedAircraftFileInControllerAdjustmentProgression = CopyFileToSpecificPath(outAircraftFilePath, controllerAdjustmentProgressionPath + filesep() + xmlAircratFileName + ".xml");
    if wasCopiedAircraftFileInControllerAdjustmentProgression == %f then
        return;
    end
    
    //save reset file to the controllerAdjustmentProgressionPath
    wasSavedResetInControllerAdjustmentProgression = SaveXMLFileIntoFilePath(xmlReset, controllerAdjustmentProgressionPath + filesep() + xmlResetFileName + ".xml", "Reset (Initial Parameters)");
    if wasSavedResetInControllerAdjustmentProgression == %f then
        return;
    end
    
    //save script file to the controllerAdjustmentProgressionPath
    wasSavedSimulationDefinitionInControllerAdjustmentProgression = SaveXMLFileIntoFilePath(xmlSimulation, controllerAdjustmentProgressionPath + filesep() + xmlSimulationFileName + ".xml", "Simulation Definition");
    if wasSavedSimulationDefinitionInControllerAdjustmentProgression == %f then
        return;
    end
    
    //save controller adjustment definition file to the controllerAdjustmentProgressionPath
    wasSavedControllerAdjustmentDefinitionInControllerAdjustmentProgression = SaveXMLFileIntoFilePath(xmlControllerAdjustmentDefinition, controllerAdjustmentProgressionPath + filesep() + xmlControllerAdjustmentDefinitionFileName + ".xml", "Controller Adjustment Definition");
    if wasSavedControllerAdjustmentDefinitionInControllerAdjustmentProgression == %f then
        return;
    end
    
    
    
    
    
    //define autopilot file path in system folder inside aircraft folder
    global aircraftFolderName;
    global systemsFolderName;
    aircraftPath = aircraftFolderName + filesep() + xmlAircratFileName;
    xmlAutopilotFilePathInSystemInAircraft = aircraftPath + filesep() + systemsFolderName + filesep() + xmlAutopilotFileName + ".xml";
    
    
    
    
    //if ziegler nichols method with critical gain was selected, load and analyze csv file using this method
    if outputAnalysisMethPopupmenuValue == 1 then
        
        
        
        //find and get the specific method parameters from method_parameters xml element
        zieglerNicholsCriticalGainMethodParametersXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(methodParametersXMLElement, "ziegler_nichols-critical_gain");
        if zieglerNicholsCriticalGainMethodParametersXMLElement == [] then
            
            //show error message and end function
            messagebox("zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain) was not found in methodParametersXMLElement (method_parameters)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        
        
        //get each method parameter of ziegler nichols critical gain method
        
        //get iteration_maximum parameter
        iterationMaximumMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsCriticalGainMethodParametersXMLElement, "iteration_maximum");
        if iterationMaximumMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("iterationMaximumMethodParameterXMLElement (iteration_maximum) was not found in zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        iterationMaximumMethodParameter = 0;
        if convstr(strsubst(iterationMaximumMethodParameterXMLElement.content, " ", ""), "l") == "%inf" then
            iterationMaximumMethodParameter = %inf;
        else
            iterationMaximumMethodParameter = strtod(iterationMaximumMethodParameterXMLElement.content);
            if string(iterationMaximumMethodParameter) == "Nan" then
                //show error message and end function
                messagebox(["iterationMaximumMethodParameterXMLElement (iteration_maximum) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(iterationMaximumMethodParameter) + """"], "modal", "error");
                return;
            else
                if iterationMaximumMethodParameter <= 0 then
                    //show error message and end function
                    messagebox(["iterationMaximumMethodParameterXMLElement (iteration_maximum) must be higher than 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(iterationMaximumMethodParameter) + """"], "modal", "error");
                    return;
                else
                    iterationMaximumMethodParameter = ceil(iterationMaximumMethodParameter);
                end
            end
        end
        
        
        //get gain_initial parameter
        gainInitialMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsCriticalGainMethodParametersXMLElement, "gain_initial");
        if gainInitialMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("gainInitialMethodParameterXMLElement (gain_initial) was not found in zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        gainInitialMethodParameter = strtod(gainInitialMethodParameterXMLElement.content);
        if string(gainInitialMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["gainInitialMethodParameterXMLElement (gain_initial) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(gainInitialMethodParameter) + """"], "modal", "error");
            return;
        end
        
        
        //get gain_change_iteration parameter
        gainChangeIterationMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsCriticalGainMethodParametersXMLElement, "gain_change_iteration");
        if gainChangeIterationMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("gainChangeIterationMethodParameterXMLElement (gain_change_iteration) was not found in zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        gainChangeIterationMethodParameter = strtod(gainChangeIterationMethodParameterXMLElement.content);
        if string(gainChangeIterationMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["gainChangeIterationMethodParameterXMLElement (gain_change_iteration) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(gainChangeIterationMethodParameter) + """"], "modal", "error");
            return;
        else
            if gainChangeIterationMethodParameter == 0 then
                //show error message and end function
                messagebox(["gainChangeIterationMethodParameterXMLElement (gain_change_iteration) must not be 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(gainChangeIterationMethodParameter) + """"], "modal", "error");
                return;
            end
        end
        
        
        //get gain_constraint parameter
        gainConstraintMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsCriticalGainMethodParametersXMLElement, "gain_constraint");
        if gainConstraintMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("gainConstraintMethodParameterXMLElement (gain_constraint) was not found in zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        gainConstraintMethodParameter = strtod(gainConstraintMethodParameterXMLElement.content);
        if convstr(strsubst(gainConstraintMethodParameterXMLElement.content, " ", ""), "l") == "%inf" then
            gainConstraintMethodParameter = %inf;
        elseif convstr(strsubst(gainConstraintMethodParameterXMLElement.content, " ", ""), "l") == "-%inf" then
            gainConstraintMethodParameter = -%inf;
        elseif string(gainConstraintMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["gainConstraintMethodParameterXMLElement (gain_constraint) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(gainConstraintMethodParameter) + """"], "modal", "error");
            return;
        end
        
        
        //get tolerance_amplitude parameter
        toleranceAmplitudeMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsCriticalGainMethodParametersXMLElement, "tolerance_amplitude");
        if toleranceAmplitudeMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("toleranceAmplitudeMethodParameterXMLElement (tolerance_amplitude) was not found in zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        toleranceAmplitudeMethodParameter = strtod(toleranceAmplitudeMethodParameterXMLElement.content);
        if string(toleranceAmplitudeMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["toleranceAmplitudeMethodParameterXMLElement (tolerance_amplitude) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(toleranceAmplitudeMethodParameter) + """"], "modal", "error");
            return;
        else
            if toleranceAmplitudeMethodParameter == 0 then
                //show error message and end function
                messagebox(["toleranceAmplitudeMethodParameterXMLElement (tolerance_amplitude) must not be 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(toleranceAmplitudeMethodParameter) + """"], "modal", "error");
                return;
            end
        end
        
        
//        //get tolerance_period parameter
//        tolerancePeriodMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsCriticalGainMethodParametersXMLElement, "tolerance_period");
//        if tolerancePeriodMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("tolerancePeriodMethodParameterXMLElement (tolerance_period) was not found in zieglerNicholsCriticalGainMethodParametersXMLElement (ziegler_nichols-critical_gain)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        tolerancePeriodMethodParameter = strtod(tolerancePeriodMethodParameterXMLElement.content);
        
        
        
        
        
        //show proggression bar
        iterationMaximumIsInfiniteInformation = emptystr();
        if iterationMaximumMethodParameter == %inf then
            iterationMaximumIsInfiniteInformation = "WARNING! BECAUSE ITERATION MAXIMUM IS SET TO INFINITE, THE OPERATION MAY LOOK FOR RESULTS FOREVER! MOREOVER, WAITBAR CANNOT BE REFRESHED (i.e. IT REMAINS 0 DURING WHOLE PROCESS UNTIL IT''S OVER)!";
        end
        waitbarControllerAdjustmentProcess = waitbar(['Please wait for results of controller adjustment process (using Ziegler-Nichols method with Critical Parameters).' ; 'The process may take many minutes or even hours, depending on the controller adjustment definition.' ; 'JSBSim with the defined simulation script is executed each iteration' ; iterationMaximumIsInfiniteInformation]);
        
        
        
        //get the gain xml element
        //[xmlAutopilotAdjustableComponent, xmlChannelChildrenIndexAutopilotAdjustableComponent, xmlAutopilotAdjustableComponentIndexChildrenChannel] = GetSelectedAdjustableComponentFromAutopilot(xmlAutopilot, xmlAdjustableComponent);
        gainBackup = emptystr();
        integralBackup = emptystr();
        derivativeBackup = emptystr();
        [KP_GainXmlElement, KI_IntegralXmlElement, KD_DerivativeXmlElement] = GetKpKiKdXMLelementsFromAdjustableComponentInAutopilot(xmlAutopilot, xmlAutopilotAdjustableComponent);
        gainBackup = KP_GainXmlElement.content;
        if KI_IntegralXmlElement ~= [] then
            integralBackup = KI_IntegralXmlElement.content;
            KI_IntegralXmlElement.content = "0";
        end
        if KD_DerivativeXmlElement ~= [] then
            derivativeBackup = KD_DerivativeXmlElement.content;
            KD_DerivativeXmlElement.content = "0";
        end
        
        
        
        //sleep 50 milliseconds before controller adjustment
        sleep(50);
        
        
        
        
        iterationNumber = 1;
        gainCurrent = gainInitialMethodParameter;
        gainChangeIterationCurrent = gainChangeIterationMethodParameter;
        criticalGain = %inf;
        criticalPeriod = %inf;
        global CriticalGainChangeTolerance;
        while iterationNumber <= iterationMaximumMethodParameter
            
            
            
            //check whether the current gain is critical gain found in the previous dynamic gain-change iteration
            if gainCurrent >= criticalGain then
                
                //decrease the gain change to a half of the current value
                gainChangeIterationCurrent = gainChangeIterationCurrent / 2;
                //set new beginning of the current gain to the previous gain + the half of the current gain change
                gainCurrent = gainCurrent - gainChangeIterationCurrent;
                
                continue;
                
            end
            
            
            
            //check whether current gain brokes gain constraints
            if gainChangeIterationCurrent > 0 then
                if gainCurrent > gainConstraintMethodParameter then
                    messagebox(["The end of the process! The actual gain REACHED OVER the constraint gain choosed by the user!" ; "Actual Gain: " + string(gainCurrent) ; "Constraint Gain: " + string(gainConstraintMethodParameter) ; "Click OK to continue" ], "modal", "info");
                    break;
                end
            elseif gainChangeIterationCurrent < 0 then
                if gainCurrent < gainConstraintMethodParameter then
                    messagebox(["The end of the process! The actual gain FALLED UNDER the constraint gain choosed by the user!" ; "Actual Gain: " + string(gainCurrent) ; "Constraint Gain: " + string(gainConstraintMethodParameter) ; "Click OK to continue" ], "modal", "info");
                    break;
                end
            //else
                ////error which should never happened because all the values of method parameters are checked before in this function (see CheckCorrectXmlMethodParameters for details)
            end
            //set the current gain to the xml element
            //because Scilab 6.0.1 uses 'D' instead of 'E' to express exponent (<>Scilab bug?), we have to change it to 'E'
            KP_GainXmlElement.content = strsubst(string(gainCurrent), "D", "E");
            
            
            
            
            //save autopilot xml file to the system folder inside the aircraft folder
            wasSavedAutopilotInSystemFolderInAircraftFolder = SaveXMLFileIntoFilePath(xmlAutopilot, xmlAutopilotFilePathInSystemInAircraft, "Autopilot (in Systems folder)");
            if wasSavedAutopilotInSystemFolderInAircraftFolder == %f then
                return;
            end
            
            
            //create folder for the current autopilot with the current iteration number
            iterationNumberFolderName = string(iterationNumber);
            currentAutopilotFolderInControllerAdjustmentProgression = controllerAdjustmentProgressionPath + filesep() + "autopilot_" + iterationNumberFolderName;
            wasCreatedCurrentAutopilotFolderInControllerAdjustmentProgression = CreateFolderIfNotExists(currentAutopilotFolderInControllerAdjustmentProgression);
            if wasCreatedCurrentAutopilotFolderInControllerAdjustmentProgression == %f then
                return;
            end
            sleep(10);
            
            //save autopilot with changed adjustable component to each separated folder (in controllerAdjustmentProgressionPath) whose name depending on iteration number
            wasSavedAutopilotInControllerAdjustmentProgression = SaveXMLFileIntoFilePath(xmlAutopilot, currentAutopilotFolderInControllerAdjustmentProgression + filesep() + xmlAutopilotFileName + ".xml", "Autopilot");
            if wasSavedAutopilotInControllerAdjustmentProgression == %f then
                return;
            end
            
            
            
            
            //execute JSBSim application
            [jsbSimCmdOutput, jsbSimCmdbOK, jsbSimCmdExitCode] = JSBSimOrFlightGearExecution("""JSBSim"" " + xmlJsbSimCommandOptionsCompleteString);
            sleep(10);
            
            
            
            //after simulation move csv output to folder with the current autopilot - if the copy is successful, delete the inputed output CSV file
            currentOutputCSVPath = currentAutopilotFolderInControllerAdjustmentProgression + filesep() + outputName;
            wasCopiedOutputCSV = CopyFileToSpecificPath(outputName, currentOutputCSVPath);
            //if the output CSV file was copied successfully, delete the inputed output CSV file
            if wasCopiedOutputCSV == %t then
                deletefile(outputName);
            else
                //if it was not copied properly, change the path to local CSV file name
                currentOutputCSVPath = outputName;
                disp([ "Warning! The output CSV file was not copied properly for iteration no. " + iterationNumberFolderName + "." ; ]);
            end
            
            
            
            //load csv file and separate header and value parts
            [CSVHeader, CSVvalues] = ReadAndEvalCSVfile(currentOutputCSVPath);
            //process the output csv file and show figure with plots
            
            //separate CSV values and CSV headers to parts for sure
            partCSVHeader = cat(2, CSVHeader(:, 1), CSVHeader(:, 2));
            partCSVvalues = cat(2, CSVvalues(:, 1), CSVvalues(:, 2));
            
            
            
            //indexesHeaderList = GetIndexesCSVvalues(CSVHeader, "Time");
            numberOfRows = size(partCSVvalues, 1);
            
            //if time end is infinite or higher than end simulation time, set the end simulation time
            if timeEndNumberOrig == %inf | timeEndNumberOrig > partCSVvalues(numberOfRows, 1) then
                timeEndNumber = partCSVvalues(numberOfRows, 1);
            end
            
            //if time start is higher than 0, get only specific values depending on time constraints and recalculate CSV time
            indexStartValue = 1;
            if timeStartNumber > 0 then
                indexStartValue = GetIndexesCSVvalues(partCSVvalues, 1, timeStartNumber);
                if indexStartValue == 0 then
                    indexStartValue = 1;
                end
            end
            
            //if time end is lower than the end simulation time, get only specific values depending on time constraints and recalculate CSV time
            indexEndValue = numberOfRows;
            if timeEndNumber < partCSVvalues(numberOfRows, 1) then
                indexEndValue = GetIndexesCSVvalues(partCSVvalues, 1, timeEndNumber);
                if indexEndValue == 0 then
                    indexEndValue = numberOfRows;
                elseif indexEndValue > 1 then
                    indexEndValue = indexEndValue - 1;
                end
            end
            
            
            //get only specific range of values and recalculate them if needed
            recalculatedCSVvalues = partCSVvalues;
            if indexStartValue ~= 1 | indexEndValue ~= numberOfRows then
                recalculatedCSVvalues = RecalculateValuesInCSV( recalculatedCSVvalues(indexStartValue:indexEndValue, :), 1 );
            end
            
            
//            disp(partCSVvalues)
//            disp(indexStartValue)
//            disp(indexEndValue)
//            disp(numberOfRows)
//            disp(timeEndNumber)
            
            
            
            //analysis of periodicity of output property data which are captured with same sample rate (user has to provide adequatly high rate (min. 30 Hz is recommended) - if the rate is very low, the analysis may return inaccurate results)
            [isPeriodConstant, isPeriodicAmplitudeSame, T_criticalPeriod, outMessageInfo] = AnalyzePeriodicityOfData_WithSameSampleRate(recalculatedCSVvalues, toleranceAmplitudeMethodParameter);
            WriteControlDesignMethodInformationToTXT(outMessageInfo, currentAutopilotFolderInControllerAdjustmentProgression + filesep() + "outInfo_AnalysisOfPeriodicity.txt");
            
            //check whether critical gain and period were found
            //if the data are periodic and the amplitude is same (with some user-defined tolerance) for each period
            if isPeriodConstant == %t & isPeriodicAmplitudeSame == %t then
                
                
                if T_criticalPeriod > 0 then
                    
                    
                    //copy previous critical gain
                    previousCriticalGain = criticalGain;
                    //set new critical gain
                    criticalGain = gainCurrent;
                    //set new beginning of the current gain to the previous gain - this gain was already simulated and analyzed but the value will be increased in the following code at the end of this cycle
                    gainCurrent = gainCurrent - gainChangeIterationCurrent;
                    //decrease iteration gain change to a half of the current value
                    gainChangeIterationCurrent = gainChangeIterationCurrent / 2;
                    
                    //set new critical period
                    criticalPeriod = T_criticalPeriod;

                    
                    //add or change xml element with critical gain and critical period in autopilot adjustable component
                    //find and get (or create) critical_gain xml element
                    CriticalGainXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "critical_gain");
                    CriticalGainXmlElement.content = string(criticalGain);
                    //find and get (or create) critical_period xml element
                    CriticalPeriodXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "critical_period");
                    CriticalPeriodXmlElement.content = string(criticalPeriod);
                    
                    
                    //if the change between the currently found critical gain and the previous found critical gain is higher than the maximum critical gain change tolerance (global in ControllerDesignMethods.sci), continue the simulation adjustment
                    CurrentCriticalGainChangeTolerance = abs((previousCriticalGain - criticalGain) / criticalGain);
                    if CurrentCriticalGainChangeTolerance > CriticalGainChangeTolerance then
                        
                        //write information about tolerance of critical gain change to TXT file in the current autopilot file in Controller Adjustment Progression folder
                        outMessageCriticalGainChangeToleranceInfo = [];
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "Data are periodical and contain same amplitude of peaks; HOWEVER, tolerance of the dynamical gain-change per iteration was NOT met!";
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "(tolerance: " + string(CriticalGainChangeTolerance) + " - search for ""global CriticalGainChangeTolerance"" in ""ControllerDesignMethods.sci"" if you want to change it)";
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "Current Tolerance = " + string(CurrentCriticalGainChangeTolerance);
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "Iteration no. " + string(iterationNumber);
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "Current Critical Gain = " + string(criticalGain);
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "Previous Critical Gain = " + string(previousCriticalGain);
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = "Current Critical Period = " + string(criticalPeriod);
                        outMessageCriticalGainChangeToleranceInfo(size(outMessageCriticalGainChangeToleranceInfo, 1) + 1) = emptystr();
                        WriteControlDesignMethodInformationToTXT(outMessageCriticalGainChangeToleranceInfo, currentAutopilotFolderInControllerAdjustmentProgression + filesep() + "outInfo_CriticalGainChangeTolerance.txt");
                        //continue the simulation adjustment because tolerance was NOT met, i.e. some gain and period were found but they are not sufficiently accurate
                        disp(outMessageCriticalGainChangeToleranceInfo);
                        
                    else
                        
                        //otherwise, break the cycle, because tolerance was met, i.e. critical gain and critical period were found
                        disp([ "Iteration no. " + string(iterationNumber) + " Critical Gain = " + string(criticalGain) + " Critical Period = " + string(criticalPeriod) + " - Data are periodical and contain same amplitude of peaks; MOREOVER, tolerance of the dynamical gain-change per iteration WAS met!" ; "(tolerance: " + string(CriticalGainChangeTolerance) + " - search for ""global CriticalGainChangeTolerance"" in ""ControllerDesignMethods.sci"" if you want to change it)" ; ]);
                        break;
                        
                    end
                    
                    
                else
                    
                    //show error message and end function
                    messagebox(["Error! - Periodicity and Same Amplitude of Peaks were found in data; however, Critical Period is not higher than zero which is not allowed!" ; "Period [s] = """ + string(T_criticalPeriod) + """  (in ControllerAdjustmentSimulationExecuteJSBSim function)" ], "modal", "error");
                    return;
                    
                end
                
                
            elseif isPeriodConstant == %t then
                disp([ "Iteration no. " + string(iterationNumber) + " Gain = " + string(gainCurrent) + " - Data are periodical but do not contain same amplitude of peaks (or tolerance was not met)!" ; ]);
            elseif isPeriodicAmplitudeSame == %t then
                //actually, this condition will not met because the code for analysis do not check values of amplitude peaks when the data are not periodical
                disp([ "Iteration no. " + string(iterationNumber) + " Gain = " + string(gainCurrent) + " - Data contain same amplitude but they are not periodical!" ; ]);
            else
                disp([ "Iteration no. " + string(iterationNumber) + " Gain = " + string(gainCurrent) + " - Data are not periodical and do not contain same amplitude!" ; ]);
            end
            
            
            //write information about iteration to TXT file in the current autopilot file in Controller Adjustment Progression folder
            outMessageIterationInfo = [];
            outMessageIterationInfo(size(outMessageIterationInfo, 1) + 1) = "Iteration Number = " + string(iterationNumber);
            outMessageIterationInfo(size(outMessageIterationInfo, 1) + 1) = "Current Gain = " + string(gainCurrent);
            outMessageIterationInfo(size(outMessageIterationInfo, 1) + 1) = "Current Gain Change per Iteration = " + string(gainChangeIterationCurrent);
            outMessageIterationInfo(size(outMessageIterationInfo, 1) + 1) = "Current Critical Gain = " + string(criticalGain);
            outMessageIterationInfo(size(outMessageIterationInfo, 1) + 1) = "Current Critical Period = " + string(criticalPeriod);
            WriteControlDesignMethodInformationToTXT(outMessageIterationInfo, currentAutopilotFolderInControllerAdjustmentProgression + filesep() + "outInfo_Iteration.txt");
            
            
            
            
            //gain increase
            gainCurrent = gainCurrent + gainChangeIterationCurrent;
            
            //waitbar update if possible
            if iterationMaximumMethodParameter ~= %inf & iterationMaximumMethodParameter > 0 then
                waitbar(iterationNumber / iterationMaximumMethodParameter, waitbarControllerAdjustmentProcess);
            end
            
            //iteration increase
            iterationNumber = iterationNumber + 1;
            
        end
        
        
        
        
        waitbar(1.0, waitbarControllerAdjustmentProcess);
        close(waitbarControllerAdjustmentProcess);
        
        
        
        
        //if a critical gain and a critical period were found
        if criticalGain ~= %inf & criticalPeriod ~= %inf then
            
            //show information to user and ask which ziegler nichols rule should be used to the controller adjustment
            messagebox(["Critical Gain and Critical Period were successfully found and saved in autopilot xml file!" ; "Critical Gain = " + string(criticalGain) ; "Critical Period [s] = " + string(criticalPeriod) ; emptystr() ; "However, check the output CSV data to be sure that there is periodicity. You may use menu: ""CSV Processing -> Open CSV JSBSim output""" ; "The output CSV data may be found in ""autopilot_"" folders inside path: """ + controllerAdjustmentProgressionPath + """ (check the one whose adjustable component in autopilot contains same gain (Kp) as the critical." ; "If the output CSV data don''t contain periodicity, set the initial gain to slightly higher value and start the adjustment again." ], "modal", "info");
            //show dialog for selecting a Ziegler-Nichols with critical parameters rule to set the adjustable control component
            [zieglerNicholsRuleName] = DialogZieglerNicholsCriticalParametersTablesOkCancel();
            if zieglerNicholsRuleName ~= [] then
                
                //calculate and set P, I, D or gain parameters using a selected rule of Ziegler-Nichols method with critical parameters
                SetPIDparametersUsingZieglerNicholsCriticalParametersTables(KP_GainXmlElement, KI_IntegralXmlElement, KD_DerivativeXmlElement, zieglerNicholsRuleName, criticalGain, criticalPeriod);
                
            else
                
                messagebox("You may adjust the controller component named """ + xmlAutopilotAdjustableComponent.attributes.name + """ of JSBSim component type """ + xmlAutopilotAdjustableComponent.name + """ using menu: ""Control Component Adjustment -> Set rule of Ziegler-Nichols method with critical parameters""", "modal", "info");
                
            end
            
            
        //otherwise, set the original values from backup
        else
            
            KP_GainXmlElement.content = gainBackup;
            if KI_IntegralXmlElement ~= [] then
                KI_IntegralXmlElement.content = integralBackup;
            end
            if KD_DerivativeXmlElement ~= [] then
                KD_DerivativeXmlElement.content = derivativeBackup;
            end
            
            messagebox(["Critical Gain and Critical Period were NOT found! The original controller adjustment will be saved in autopilot xml file!" ; "Critical Gain = " + string(criticalGain) ; "Critical Period [s] = " + string(criticalPeriod)], "modal", "warning");
            
        end
        
        //save autopilot xml file to the system folder inside the aircraft folder
        SaveXMLFileIntoFilePath(xmlAutopilot, xmlAutopilotFilePathInSystemInAircraft, "Autopilot (with results in Systems folder)");    //wasSavedAutopilotInSystemFolderInAircraftFolder = 
//        if wasSavedAutopilotInSystemFolderInAircraftFolder == %f then
//            return;
//        end
        
        
        
        
        
    //else if genetic algorithm was selected, load and analyze csv file using this method
    elseif outputAnalysisMethPopupmenuValue == 2 then
        
        
        
        //get the specific method parameters from method_parameters xml element
        geneticAlgorithmMethodParametersXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(methodParametersXMLElement, "genetic_algorithm");
        if geneticAlgorithmMethodParametersXMLElement == [] then
            
            //show error message and end function
            messagebox("geneticAlgorithmMethodParametersXMLElement (genetic_algorithm) was not found in methodParametersXMLElement (method_parameters)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        
        
        
        //get each method parameter of genetic algorithm
        
        //get iteration_maximum parameter
        iterationMaximumMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "iteration_maximum");
        if iterationMaximumMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("iterationMaximumMethodParameterXMLElement (iteration_maximum) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        iterationMaximumMethodParameter = strtod(iterationMaximumMethodParameterXMLElement.content);
        if string(iterationMaximumMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["iterationMaximumMethodParameterXMLElement (iteration_maximum) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(iterationMaximumMethodParameter) + """"], "modal", "error");
            return;
        else
            if iterationMaximumMethodParameter <= 0 then
                //show error message and end function
                messagebox(["iterationMaximumMethodParameterXMLElement (iteration_maximum) must be higher than 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(iterationMaximumMethodParameter) + """"], "modal", "error");
                return;
            else
                iterationMaximumMethodParameter = ceil(iterationMaximumMethodParameter);
            end
        end
        
        
        //get output_required parameter
        outputRequiredMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "output_required");
        if outputRequiredMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("outputRequiredMethodParameterXMLElement (output_required) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        outputRequiredMethodParameter = strtod(outputRequiredMethodParameterXMLElement.content);
        if string(outputRequiredMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["outputRequiredMethodParameterXMLElement (output_required) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(outputRequiredMethodParameter) + """"], "modal", "error");
            return;
        end
        
        
        //get rise_time_required parameter
        riseTimeRequiredMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "rise_time_required");
        if riseTimeRequiredMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("riseTimeRequiredMethodParameterXMLElement (rise_time_required) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        riseTimeRequiredMethodParameter = strtod(riseTimeRequiredMethodParameterXMLElement.content);
        if string(riseTimeRequiredMethodParameter) ~= "Nan" then
            if riseTimeRequiredMethodParameter <= 0 then
                //show error message and end function
                messagebox(["riseTimeRequiredMethodParameterXMLElement (rise_time_required) must be higher than 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(riseTimeRequiredMethodParameter) + """"], "modal", "error");
                return;
            end
        else
            //show error message and end function
            messagebox(["riseTimeRequiredMethodParameterXMLElement (rise_time_required) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(riseTimeRequiredMethodParameter) + """"], "modal", "error");
            return;
        end
        
        
        //get pid_population_size parameter
        pidPopulationSizeMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "pid_population_size");
        if pidPopulationSizeMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("pidPopulationSizeMethodParameterXMLElement (pid_population_size) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        pidPopulationSizeMethodParameter = strtod(pidPopulationSizeMethodParameterXMLElement.content);
        if string(pidPopulationSizeMethodParameter) ~= "Nan" then
            if pidPopulationSizeMethodParameter <= 3 then
                //show error message and end function
                messagebox(["pidPopulationSizeMethodParameterXMLElement (pid_population_size) must be higher than 3! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(pidPopulationSizeMethodParameter) + """"], "modal", "error");
                return;
            end
        else
            //show error message and end function
            messagebox(["pidPopulationSizeMethodParameterXMLElement (pid_population_size) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(pidPopulationSizeMethodParameter) + """"], "modal", "error");
            return;
        end
        pidPopulationSizeMethodParameter = ceil(pidPopulationSizeMethodParameter);
        
        
        //get pid_generation_initial parameter
        pidGenerationInitialMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "pid_generation_initial");
        if pidGenerationInitialMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("pidGenerationInitialMethodParameterXMLElement (pid_generation_initial) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        //convert string matrix from xml content to equivalent scilab matrix, or show error if failed
        pidGenerationInitialMethodParameter = emptystr();
        try
            pidGenerationInitialMethodParameter = evstr(pidGenerationInitialMethodParameterXMLElement.content);
            if typeof(pidGenerationInitialMethodParameter) ~= "constant" | size(pidGenerationInitialMethodParameter, 2) ~= 3 then
                messagebox(["Converted content of pid_generation_initial is not n×3-matrix of decimal numbers!" ; "Content of pid_generation_initial: " + pidGenerationInitialMethodParameterXMLElement.content ], "modal", "error");
                return;
            else
                NANINFfound = %f;
                for i = 1 : 1 : size(pidGenerationInitialMethodParameter, 1)
                    for j = 1 : 1 : size(pidGenerationInitialMethodParameter, 2)
                        if isinf(pidGenerationInitialMethodParameter(i, j)) | isnan(pidGenerationInitialMethodParameter(i, j)) then
                            NANINFfound = %t;
                            break;
                        end
                    end
                    if NANINFfound == %t then
                        messagebox(["Converted content of pid_generation_initial contains not-a-number values or infinite!" ; "Content of pid_generation_initial: " + pidGenerationInitialMethodParameterXMLElement.content ], "modal", "error");
                        return;
                    end
                end
            end
        catch
            [error_message, error_number] = lasterror(%t);
            messagebox(["Conversion of content of pid_generation_initial failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "Content of pid_generation_initial: " + pidGenerationInitialMethodParameterXMLElement.content ], "modal", "error");
            return;
        end
        
        
        //get binary_length_integer_part parameter
        binaryLengthIntegerPartMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "binary_length_integer_part");
        if binaryLengthIntegerPartMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("binaryLengthIntegerPartMethodParameterXMLElement (binary_length_integer_part) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        binaryLengthIntegerPartMethodParameter = strtod(binaryLengthIntegerPartMethodParameterXMLElement.content);
        if string(binaryLengthIntegerPartMethodParameter) ~= "Nan" then
            if binaryLengthIntegerPartMethodParameter <= 3 then
                //show error message and end function
                messagebox(["binaryLengthIntegerPartMethodParameterXMLElement (binary_length_integer_part) must be higher than 3! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(binaryLengthIntegerPartMethodParameter) + """"], "modal", "error");
                return;
            end
        else
            //show error message and end function
            messagebox(["binaryLengthIntegerPartMethodParameterXMLElement (binary_length_integer_part) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(binaryLengthIntegerPartMethodParameter) + """"], "modal", "error");
            return;
        end
        //binary length must be integer, so round it up
        binaryLengthIntegerPartMethodParameter = ceil(binaryLengthIntegerPartMethodParameter);
        
        
        //get binary_length_fractional_part parameter
        binaryLengthFractionalPartMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "binary_length_fractional_part");
        if binaryLengthFractionalPartMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("binaryLengthFractionalPartMethodParameterXMLElement (binary_length_fractional_part) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        binaryLengthFractionalPartMethodParameter = strtod(binaryLengthFractionalPartMethodParameterXMLElement.content);
        if string(binaryLengthFractionalPartMethodParameter) ~= "Nan" then
            if binaryLengthFractionalPartMethodParameter <= 3 then
                //show error message and end function
                messagebox(["binaryLengthFractionalPartMethodParameterXMLElement (binary_length_fractional_part) must be higher than 3! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(binaryLengthFractionalPartMethodParameter) + """"], "modal", "error");
                return;
            end
        else
            //show error message and end function
            messagebox(["binaryLengthFractionalPartMethodParameterXMLElement (binary_length_fractional_part) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(binaryLengthFractionalPartMethodParameter) + """"], "modal", "error");
            return;
        end
        //binary length must be integer, so round it up
        binaryLengthFractionalPartMethodParameter = ceil(binaryLengthFractionalPartMethodParameter);
        
        
        //get minimum_Kp_Ki_Kd parameter
        minimumKpKiKdMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "minimum_Kp_Ki_Kd");
        if minimumKpKiKdMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("minimumKpKiKdMethodParameterXMLElement (minimum_Kp_Ki_Kd) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        //convert string array from xml content to equivalent scilab array, or show error if failed
        minimumKpKiKdMethodParameter = emptystr();
        try
            minimumKpKiKdMethodParameter = evstr(convstr(minimumKpKiKdMethodParameterXMLElement.content, 'l'));
            if typeof(minimumKpKiKdMethodParameter) ~= "constant" | size(minimumKpKiKdMethodParameter, 1) ~= 1 | size(minimumKpKiKdMethodParameter, 2) ~= 3 then
                messagebox(["Converted content of minimum_Kp_Ki_Kd is not 1×3-matrix of decimal numbers!" ; "Content of minimum_Kp_Ki_Kd: " + minimumKpKiKdMethodParameterXMLElement.content ], "modal", "error");
                return;
            else
                NANfound = %f;
                for i = 1 : 1 : size(minimumKpKiKdMethodParameter, 2)
                    if isnan(minimumKpKiKdMethodParameter(i)) then
                        NANfound = %t;
                        break;
                    end
                end
                if NANfound == %t then
                    messagebox(["Converted content of minimum_Kp_Ki_Kd contains not-a-number values!" ; "Content of minimum_Kp_Ki_Kd: " + minimumKpKiKdMethodParameterXMLElement.content ], "modal", "error");
                    return;
                end
            end
        catch
            [error_message, error_number] = lasterror(%t);
            messagebox(["Conversion of content of minimum_Kp_Ki_Kd failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "Content of minimum_Kp_Ki_Kd: " + minimumKpKiKdMethodParameterXMLElement.content ], "modal", "error");
            return;
        end
        
        
        //get maximum_Kp_Ki_Kd parameter
        maximumKpKiKdMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "maximum_Kp_Ki_Kd");
        if maximumKpKiKdMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("maximumKpKiKdMethodParameterXMLElement (maximum_Kp_Ki_Kd) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        //convert string array from xml content to equivalent scilab array, or show error if failed
        maximumKpKiKdMethodParameter = emptystr();
        try
            maximumKpKiKdMethodParameter = evstr(convstr(maximumKpKiKdMethodParameterXMLElement.content, 'l'));
            if typeof(maximumKpKiKdMethodParameter) ~= "constant" | size(maximumKpKiKdMethodParameter, 1) ~= 1 | size(maximumKpKiKdMethodParameter, 2) ~= 3 then
                messagebox(["Converted content of maximum_Kp_Ki_Kd is not 1×3-matrix of decimal numbers!" ; "Content of maximum_Kp_Ki_Kd: " + maximumKpKiKdMethodParameterXMLElement.content ], "modal", "error");
                return;
            else
                NANfound = %f;
                for i = 1 : 1 : size(maximumKpKiKdMethodParameter, 2)
                    if isnan(maximumKpKiKdMethodParameter(i)) then
                        NANfound = %t;
                        break;
                    end
                end
                if NANfound == %t then
                    messagebox(["Converted content of maximum_Kp_Ki_Kd contains not-a-number values!" ; "Content of maximum_Kp_Ki_Kd: " + maximumKpKiKdMethodParameterXMLElement.content ], "modal", "error");
                    return;
                end
            end
        catch
            [error_message, error_number] = lasterror(%t);
            messagebox(["Conversion of content of maximum_Kp_Ki_Kd failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "Content of maximum_Kp_Ki_Kd: " + maximumKpKiKdMethodParameterXMLElement.content ], "modal", "error");
            return;
        end
        
        
        //get selection_pairs_mode parameter
        selectionPairsModeMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "selection_pairs_mode");
        if selectionPairsModeMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("selectionPairsModeMethodParameterXMLElement (selection_pairs_mode) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
        global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce;
        global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
        global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce;
        global GA_CreatePairs_SelectionMode_TournamentPairs;
        global GA_CreatePairs_SelectionMode_RouletteWheelPairs;
        global GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling;
        global GA_CreatePairs_SelectionMode_RandomPairs;
        selectionPairsModeParameter = strsubst(selectionPairsModeMethodParameterXMLElement.content, " ", "");
        selectionPairsModeParameter = convstr(selectionPairsModeParameter, 'l');
        if selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_TournamentPairs, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_RouletteWheelPairs, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling, " ", ""), 'l')  &  selectionPairsModeParameter ~= convstr(strsubst(GA_CreatePairs_SelectionMode_RandomPairs, " ", ""), 'l') then
            //show error message and end function
            messagebox(["selectionPairsModeMethodParameterXMLElement (selection_pairs_mode) does not contain valid tag!! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current tag: """ + selectionPairsModeParameter + """" ; "Valid tags are: """ + GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs + """, """ + GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce + """, """ + GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals + """, """ + GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce + """, """ + GA_CreatePairs_SelectionMode_TournamentPairs + """, """ + GA_CreatePairs_SelectionMode_RouletteWheelPairs + """, """ + GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling + """, and """ + GA_CreatePairs_SelectionMode_RandomPairs + """"], "modal", "error");
            return;
        end
        
        
        //get number_of_children parameter
        numberOfChildrenMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "number_of_children");
        if numberOfChildrenMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("numberOfChildrenMethodParameterXMLElement (number_of_children) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        numberOfChildrenMethodParameter = strtod(numberOfChildrenMethodParameterXMLElement.content);
        if string(numberOfChildrenMethodParameter) ~= "Nan" then
            if numberOfChildrenMethodParameter ~= 1 & numberOfChildrenMethodParameter ~= 2 then
                //show error message and end function
                messagebox(["numberOfChildrenMethodParameterXMLElement (number_of_children) must be 1 or 2 only! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(numberOfChildrenMethodParameter) + """"], "modal", "error");
                return;
            end
        else
            //show error message and end function
            messagebox(["numberOfChildrenMethodParameterXMLElement (number_of_children) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(numberOfChildrenMethodParameter) + """"], "modal", "error");
            return;
        end
        
        
        //get crossover_number_of_cuts_probability parameter
        crossoverNumberOfCutsProbabilityMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "crossover_number_of_cuts_probability");
        if crossoverNumberOfCutsProbabilityMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("crossoverNumberOfCutsProbabilityMethodParameterXMLElement (crossover_number_of_cuts_probability) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        //convert string array from xml content to equivalent scilab array, or show error if failed
        crossoverNumberOfCutsProbabilityMethodParameter = emptystr();
        try
            crossoverNumberOfCutsProbabilityMethodParameter = evstr(convstr(crossoverNumberOfCutsProbabilityMethodParameterXMLElement.content, 'l'));
            if typeof(crossoverNumberOfCutsProbabilityMethodParameter) ~= "constant" | size(crossoverNumberOfCutsProbabilityMethodParameter, 1) ~= 1 then
                messagebox(["Converted content of crossover_number_of_cuts_probability is not 1×n-matrix of decimal numbers!" ; "Content of crossover_number_of_cuts_probability: " + crossoverNumberOfCutsProbabilityMethodParameterXMLElement.content ], "modal", "error");
                return;
            else
                completeProbability = 0;
                for i = 1 : 1 : size(crossoverNumberOfCutsProbabilityMethodParameter, 2)
                    completeProbability = completeProbability + crossoverNumberOfCutsProbabilityMethodParameter(i);
                end
                //if the sum of the probabilities is not equal to 1, the probabilities are wrong (because some issues in Scilab, we must convert the numbers to string before comparison)
                if string(completeProbability) ~= string(1) then
                    messagebox(["The sum of numbers in crossover_number_of_cuts_probability is not equal to 1!" ; "Sum of crossover_number_of_cuts_probability numbers: " + string(completeProbability) ; "Content of crossover_number_of_cuts_probability: " + crossoverNumberOfCutsProbabilityMethodParameterXMLElement.content ], "modal", "error");
                    return;
                end
            end
        catch
            [error_message, error_number] = lasterror(%t);
            messagebox(["Conversion of content of crossover_number_of_cuts_probability failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "Content of crossover_number_of_cuts_probability: " + crossoverNumberOfCutsProbabilityMethodParameterXMLElement.content ], "modal", "error");
            return;
        end
        
        
        //get mutation_number_of_mutated_bits_probability parameter
        mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "mutation_number_of_mutated_bits_probability");
        if mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement (mutation_number_of_mutated_bits_probability) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        //convert string array from xml content to equivalent scilab array, or show error if failed
        mutationNumberOfMutatedBitsProbabilityMethodParameter = emptystr();
        try
            mutationNumberOfMutatedBitsProbabilityMethodParameter = evstr(convstr(mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement.content, 'l'));
            if typeof(mutationNumberOfMutatedBitsProbabilityMethodParameter) ~= "constant" | size(mutationNumberOfMutatedBitsProbabilityMethodParameter, 1) ~= 1 then
                messagebox(["Converted content of mutation_number_of_mutated_bits_probability is not 1×n-matrix of decimal numbers!" ; "Content of mutation_number_of_mutated_bits_probability: " + mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement.content ], "modal", "error");
                return;
            else
                completeProbability = 0;
                for i = 1 : 1 : size(mutationNumberOfMutatedBitsProbabilityMethodParameter, 2)
                    completeProbability = completeProbability + mutationNumberOfMutatedBitsProbabilityMethodParameter(i);
                end
                //if the sum of the probabilities is not equal to 1, the probabilities are wrong (because some issues in Scilab, we must convert the numbers to string before comparison)
                if string(completeProbability) ~= string(1) then
                    messagebox(["The sum of numbers in mutation_number_of_mutated_bits_probability is not equal to 1!" ; "Sum of mutation_number_of_mutated_bits_probability numbers: " + string(completeProbability) ; "Content of mutation_number_of_mutated_bits_probability: " + mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement.content ], "modal", "error");
                    return;
                end
            end
        catch
            [error_message, error_number] = lasterror(%t);
            messagebox(["Conversion of content of mutation_number_of_mutated_bits_probability failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "Content of mutation_number_of_mutated_bits_probability: " + mutationNumberOfMutatedBitsProbabilityMethodParameterXMLElement.content ], "modal", "error");
            return;
        end
        
        
        //get weights__outputerror_risetime_overshoot parameter
        weights_outputError_risetime_overshootMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "weights__outputerror_risetime_overshoot");
        if weights_outputError_risetime_overshootMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("weights_outputError_risetime_overshootMethodParameterXMLElement (weights__outputerror_risetime_overshoot) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        //convert string array from xml content to equivalent scilab array, or show error if failed
        weights_outputError_risetime_overshootMethodParameter = emptystr();
        try
            weights_outputError_risetime_overshootMethodParameter = evstr(convstr(weights_outputError_risetime_overshootMethodParameterXMLElement.content, 'l'));
            if typeof(weights_outputError_risetime_overshootMethodParameter) ~= "constant" | size(weights_outputError_risetime_overshootMethodParameter, 1) ~= 1 | size(weights_outputError_risetime_overshootMethodParameter, 2) ~= 3 then
                messagebox(["Converted content of weights__outputerror_risetime_overshoot is not 1×3-matrix of decimal numbers!" ; "Content of weights__outputerror_risetime_overshoot: " + weights_outputError_risetime_overshootMethodParameterXMLElement.content ], "modal", "error");
                return;
            else
                completeProbability = 0;
                for i = 1 : 1 : size(weights_outputError_risetime_overshootMethodParameter, 2)
                    completeProbability = completeProbability + weights_outputError_risetime_overshootMethodParameter(i);
                end
                //if the sum of the weights is not equal to 1, the weights are wrong (because some issues in Scilab, we must convert the numbers to string before comparison)
                if string(completeProbability) ~= string(1) then
                    messagebox(["The sum of numbers in weights__outputerror_risetime_overshoot is not equal to 1!" ; "Sum of weights__outputerror_risetime_overshoot numbers: " + string(completeProbability) ; "Content of weights__outputerror_risetime_overshoot: " + weights_outputError_risetime_overshootMethodParameterXMLElement.content ], "modal", "error");
                    return;
                end
            end
        catch
            [error_message, error_number] = lasterror(%t);
            messagebox(["Conversion of content of weights__outputerror_risetime_overshoot failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "Content of weights__outputerror_risetime_overshoot: " + weights_outputError_risetime_overshootMethodParameterXMLElement.content ], "modal", "error");
            return;
        end
        
        
        //get objective_function_value_constraint parameter
        objectiveFunctionValueConstraintMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "objective_function_value_constraint");
        if objectiveFunctionValueConstraintMethodParameterXMLElement == [] then
            
            //show error message and end function
            messagebox("objectiveFunctionValueConstraintMethodParameterXMLElement (objective_function_value_constraint) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
            return;
            
        end
        objectiveFunctionValueConstraintMethodParameter = strtod(objectiveFunctionValueConstraintMethodParameterXMLElement.content);
        if string(objectiveFunctionValueConstraintMethodParameter) == "Nan" then
            //show error message and end function
            messagebox(["objectiveFunctionValueConstraintMethodParameterXMLElement (objective_function_value_constraint) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(objectiveFunctionValueConstraintMethodParameter) + """"], "modal", "error");
            return;
        else
            if objectiveFunctionValueConstraintMethodParameter < 0 then
                //show error message and end function
                messagebox(["objectiveFunctionValueConstraintMethodParameterXMLElement (objective_function_value_constraint) must be higher than or equal to 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(objectiveFunctionValueConstraintMethodParameter) + """"], "modal", "error");
                return;
            end
        end
        
        
        
//        //get gain_initial parameter
//        gainInitialMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "gain_initial");
//        if gainInitialMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("gainInitialMethodParameterXMLElement (gain_initial) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        gainInitialMethodParameter = strtod(gainInitialMethodParameterXMLElement.content);
//        
//        
//        //get integral_initial parameter
//        integralInitialMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "integral_initial");
//        if integralInitialMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("integralInitialMethodParameterXMLElement (integral_initial) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        integralInitialMethodParameter = strtod(integralInitialMethodParameterXMLElement.content);
//        
//        
//        //get derivative_initial parameter
//        derivativeInitialMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "derivative_initial");
//        if derivativeInitialMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("derivativeInitialMethodParameterXMLElement (derivative_initial) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        derivativeInitialMethodParameter = strtod(derivativeInitialMethodParameterXMLElement.content);
//        
//        
//        //get transition_function_required parameter
//        transitionFunctionRequiredMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "transition_function_required");
//        if transitionFunctionRequiredMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("transitionFunctionRequiredMethodParameterXMLElement (transition_function_required) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        //<> <> convert function from xml content to equivalent scilab function
//        //transitionFunctionRequiredMethodParameter = strtod(transitionFunctionRequiredMethodParameterXMLElement.content);
//        
//        
//        //get tolerance_cost parameter
//        toleranceCostMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "tolerance_cost");
//        if toleranceCostMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("toleranceCostMethodParameterXMLElement (tolerance_cost) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        toleranceCostMethodParameter = strtod(toleranceCostMethodParameterXMLElement.content);
//        if string(toleranceCostMethodParameter) ~= "Nan" then
//            if toleranceCostMethodParameter <= 0 then
//                //show error message and end function
//                messagebox(["toleranceCostMethodParameterXMLElement (tolerance_cost) must be higher than 0! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(toleranceCostMethodParameter) + """"], "modal", "error");
//                return;
//            end
//        else
//            //show error message and end function
//            messagebox(["toleranceCostMethodParameterXMLElement (tolerance_cost) was not converted properly to number! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current value: """ + string(toleranceCostMethodParameter) + """"], "modal", "error");
//            return;
//        end
//        
//        
//        //get pareto_filtr parameter
//        paretoFiltrMethodParameterXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(geneticAlgorithmMethodParametersXMLElement, "pareto_filtr");
//        if paretoFiltrMethodParameterXMLElement == [] then
//            
//            //show error message and end function
//            messagebox("paretoFiltrMethodParameterXMLElement (pareto_filtr) was not found in geneticAlgorithmMethodParametersXMLElement (genetic_algorithm)! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
//            return;
//            
//        end
//        paretoFiltrMethodParameter = strsubst(paretoFiltrMethodParameterXMLElement.content, " ", "");
//        paretoFiltrMethodParameter = convstr(paretoFiltrMethodParameter, 'l');
//        if paretoFiltrMethodParameter == "true"
//            paretoFiltrMethodParameter = %t;
//        elseif paretoFiltrMethodParameter == "false" then
//            paretoFiltrMethodParameter = %f;
//        else
//            //show error message and end function
//            messagebox(["paretoFiltrMethodParameterXMLElement (pareto_filtr) was not converted properly to boolean! (ControllerAdjustmentSimulationExecuteJSBSim function)" ; "The current string: """ + string(paretoFiltrMethodParameter) + """" ; "String must be ""true"" or ""false"" only!"], "modal", "error");
//            return;
//        end
        
        
        
        
        
        //show proggression bar
        iterationMaximumIsInfiniteInformation = emptystr();
        if iterationMaximumMethodParameter == %inf then
            iterationMaximumIsInfiniteInformation = "WARNING! BECAUSE ITERATION MAXIMUM IS SET TO INFINITE, THE OPERATION MAY LOOK FOR RESULTS FOREVER! MOREOVER, WAITBAR CANNOT BE REFRESHED (i.e. IT REMAINS 0 DURING WHOLE PROCESS UNTIL IT''S OVER)!";
        end
        waitbarControllerAdjustmentProcess = waitbar(['Please wait for results of controller adjustment process (using Genetic Algorithm).' ; 'The process may take many minutes or even hours, depending on the controller adjustment definition.' ; 'JSBSim with the defined simulation script is executed each iteration' ; iterationMaximumIsInfiniteInformation]);
        
        
        
        //get the gain, integral, and derivative xml element if any
        //[xmlAutopilotAdjustableComponent, xmlChannelChildrenIndexAutopilotAdjustableComponent, xmlAutopilotAdjustableComponentIndexChildrenChannel] = GetSelectedAdjustableComponentFromAutopilot(xmlAutopilot, xmlAdjustableComponent);
        gainBackup = emptystr();
        integralBackup = emptystr();
        derivativeBackup = emptystr();
        [KP_GainXmlElement, KI_IntegralXmlElement, KD_DerivativeXmlElement] = GetKpKiKdXMLelementsFromAdjustableComponentInAutopilot(xmlAutopilot, xmlAutopilotAdjustableComponent);
        gainBackup = KP_GainXmlElement.content;
        if KI_IntegralXmlElement ~= [] then
            integralBackup = KI_IntegralXmlElement.content;
            KI_IntegralXmlElement.content = "0";
        end
        if KD_DerivativeXmlElement ~= [] then
            derivativeBackup = KD_DerivativeXmlElement.content;
            KD_DerivativeXmlElement.content = "0";
        end
        
        
        //sleep 10 milliseconds before controller adjustment
        sleep(10);
        
        
        
        
        
        //check JSBSim type of adjustable component, if it is not supported, show error and end the function
        if xmlAutopilotAdjustableComponent.name ~= "pid" & xmlAutopilotAdjustableComponent.name ~= "pure_gain" then
            messagebox(["Autopilot Adjustable Component is not of supported type! (only ""pid"" or ""pure_gain"" JSBSim types are supported!" ; "JSBSim type of Adjustable Component: " + xmlAutopilotAdjustableComponent.name ], "modal", "error");
            return;
        end
        
        
        
        //get current initial population as list and if applicable, generate more individuals to the initial population
        pidGenerationCurrent = list();
        for i = 1 : 1 : size(pidGenerationInitialMethodParameter, 1)
            //add PID parameters to the list
            pidGenerationCurrent($+1) = pidGenerationInitialMethodParameter(i, :);
        end
        
        
        //set parameters to generate initial population
        ga_initPopulationParams = init_param();
        ga_initPopulationParams = add_param(ga_initPopulationParams, "dimension", 3);
        //set save array values with minimum
        minimumKpKiKdMethodSaveParameter = [0, 0, 0];
        for i = 1 : 1 : size(minimumKpKiKdMethodParameter, 2)
            if isnan(minimumKpKiKdMethodParameter(i)) == %f & isinf(minimumKpKiKdMethodParameter(i)) == %f then
                minimumKpKiKdMethodSaveParameter(i) = minimumKpKiKdMethodParameter(i);
            end
        end
        //set save array values with maximum
        Max_Bin = 2^binaryLengthIntegerPartMethodParameter - 1;
        maximumKpKiKdMethodSaveParameter = [Max_Bin, Max_Bin, Max_Bin];
        for i = 1 : 1 : size(maximumKpKiKdMethodParameter, 2)
            if isnan(maximumKpKiKdMethodParameter(i)) == %f & isinf(maximumKpKiKdMethodParameter(i)) == %f then
                maximumKpKiKdMethodSaveParameter(i) = maximumKpKiKdMethodParameter(i);
            end
        end
        ga_initPopulationParams = add_param(ga_initPopulationParams, "minbound", minimumKpKiKdMethodSaveParameter);
        ga_initPopulationParams = add_param(ga_initPopulationParams, "maxbound", maximumKpKiKdMethodSaveParameter);
        //generate new individuals if more individuals are required than defined
        if pidPopulationSizeMethodParameter > length(pidGenerationCurrent) then
            
            Pop_init = init_ga_default(pidPopulationSizeMethodParameter - length(pidGenerationCurrent), ga_initPopulationParams);
            pidGenerationCurrent = lstcat(pidGenerationCurrent, Pop_init);
            
        else
            //otherwise, set population size to be same as the number of individuals in the current generation
            pidPopulationSizeMethodParameter = length(pidGenerationCurrent);
        end
        
        //create parameters of P, I, D genome for GA coding/decoding binary function
        paramP_GA_CodingBinary = init_param();
        paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "binary_length", binaryLengthIntegerPartMethodParameter);
        paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "binary_length_fractional_part", binaryLengthFractionalPartMethodParameter);
        paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "minbound", minimumKpKiKdMethodSaveParameter(1));
        paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "maxbound", maximumKpKiKdMethodSaveParameter(1));
        paramI_GA_CodingBinary = init_param();
        paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "binary_length", binaryLengthIntegerPartMethodParameter);
        paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "binary_length_fractional_part", binaryLengthFractionalPartMethodParameter);
        paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "minbound", minimumKpKiKdMethodSaveParameter(2));
        paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "maxbound", maximumKpKiKdMethodSaveParameter(2));
        paramD_GA_CodingBinary = init_param();
        paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "binary_length", binaryLengthIntegerPartMethodParameter);
        paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "binary_length_fractional_part", binaryLengthFractionalPartMethodParameter);
        paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "minbound", minimumKpKiKdMethodSaveParameter(3));
        paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "maxbound", maximumKpKiKdMethodSaveParameter(3));
        
        //code PID values or gain value to binary genome
        pidGenerationBinaryCurrent = list();
        for i = 1 : 1 : length(pidGenerationCurrent)
            
            //code the PID parameters to binary representation and add the result to the list
            genomePIDString = emptystr();
            if xmlAutopilotAdjustableComponent.name == "pid" then
                //code the PID values to binary genome
                P_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(1), "code", paramP_GA_CodingBinary);
                I_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(2), "code", paramI_GA_CodingBinary);
                D_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(3), "code", paramD_GA_CodingBinary);
                genomePIDString = GA_JoinGenome( list(P_StringGenome, I_StringGenome, D_StringGenome) );
            elseif xmlAutopilotAdjustableComponent.name == "pure_gain" then
                //code the gain value to binary genome
                P_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(1), "code", paramP_GA_CodingBinary);
                genomePIDString = GA_JoinGenome( list(P_StringGenome) );
            end
            pidGenerationBinaryCurrent($+1) = genomePIDString;
            
        end
        
        
        
        //lists of sorted generation in PID array-form, in binary genome code, and with results of objective function for each individual
        pidGenerationAllSorted = list();
        pidGenerationAllSortedBinary = list();
        pidGenerationAllSortedObjective = [];
        pidGenerationAllSortedSumOfAbsoluteOutputError = list();
        pidGenerationAllSortedAbsoluteRiseTimeError = list();
        pidGenerationAllSortedSumOfAbsoluteOvershootError = list();
        pidGenerationAllSortedGenerationNumber = list();
        pidGenerationAllSortedIterationInGenerationNumber = list();
        
        iterationNumber = 1;
        while iterationNumber <= iterationMaximumMethodParameter
            
            
            //create folder for the current autopilot with the current iteration number
            iterationNumberFolderName = string(iterationNumber);
            currentPopulationFolderInControllerAdjustmentProgression = controllerAdjustmentProgressionPath + filesep() + "g_" + iterationNumberFolderName;
            wasCreatedCurrentAutopilotFolderInControllerAdjustmentProgression = CreateFolderIfNotExists(currentPopulationFolderInControllerAdjustmentProgression);
            if wasCreatedCurrentAutopilotFolderInControllerAdjustmentProgression == %f then
                return;
            end
            sleep(10);
            
            
            
            //for each individual in generation
            pidGenerationObjectiveCurrent = [];
            pidGenerationSumOfAbsoluteOutputErrorCurrent = list();
            pidGenerationAbsoluteRiseTimeErrorCurrent = list();
            pidGenerationSumOfAbsoluteOvershootErrorCurrent = list();
            firstIndividualBinary = pidGenerationBinaryCurrent(1);
            NumberOfClonesOfFirstIndividual = 0;
            for iterationInGeneration = 1 : 1 : length(pidGenerationCurrent)
                
                
                //try to find the individual in the complete population with all individuals in history
                isFoundInAllSortedPopulation = %f;
                indexOfIndividualFoundInAllSortedPopulation = 0;
                for i = 1 : 1 : length(pidGenerationAllSortedBinary)
                    if pidGenerationBinaryCurrent(iterationInGeneration) == pidGenerationAllSortedBinary(i) then
                        isFoundInAllSortedPopulation = %t;
                        indexOfIndividualFoundInAllSortedPopulation = i;
                        break;
                    end
                end
                
                
                //if the individual was found
                if isFoundInAllSortedPopulation == %t & indexOfIndividualFoundInAllSortedPopulation > 0 then
                    
                    
                    //add the individual objective function value to the current lists from the complete population
                    pidGenerationObjectiveCurrent(1, size(pidGenerationObjectiveCurrent, 2) + 1) = pidGenerationAllSortedObjective(indexOfIndividualFoundInAllSortedPopulation);
                    pidGenerationSumOfAbsoluteOutputErrorCurrent($+1) = pidGenerationAllSortedSumOfAbsoluteOutputError(indexOfIndividualFoundInAllSortedPopulation);
                    pidGenerationAbsoluteRiseTimeErrorCurrent($+1) = pidGenerationAllSortedAbsoluteRiseTimeError(indexOfIndividualFoundInAllSortedPopulation);
                    pidGenerationSumOfAbsoluteOvershootErrorCurrent($+1) = pidGenerationAllSortedSumOfAbsoluteOvershootError(indexOfIndividualFoundInAllSortedPopulation);
                    
                    if iterationInGeneration ~= 1 & firstIndividualBinary == pidGenerationBinaryCurrent(iterationInGeneration) then
                        NumberOfClonesOfFirstIndividual = NumberOfClonesOfFirstIndividual + 1;
                    end
                    
                else
                    
                    
                    //set gain, integral, and derivative values in pid or gain only in pure_gain
                    //because Scilab 6.0.1 uses 'D' instead of 'E' to express exponent (<>Scilab bug?), we have to change it to 'E'
                    if xmlAutopilotAdjustableComponent.name == "pid" then
                        
                        //set gain xml element
                        KP_GainXmlElement.content = strsubst(string(pidGenerationCurrent(iterationInGeneration)(1)), "D", "E");
                        //set integral xml element
                        KI_IntegralXmlElement.content = strsubst(string(pidGenerationCurrent(iterationInGeneration)(2)), "D", "E");
                        //set derivative xml element
                        KD_DerivativeXmlElement.content = strsubst(string(pidGenerationCurrent(iterationInGeneration)(3)), "D", "E");
                        
                    elseif xmlAutopilotAdjustableComponent.name == "pure_gain" then
                        
                        //set gain xml element
                        KP_GainXmlElement.content = strsubst(string(pidGenerationCurrent(iterationInGeneration)(1)), "D", "E");
                        
                    end
                    
                    
                    //save autopilot xml file to the system folder inside the aircraft folder
                    wasSavedAutopilotInSystemFolderInAircraftFolder = SaveXMLFileIntoFilePath(xmlAutopilot, xmlAutopilotFilePathInSystemInAircraft, "Autopilot (in Systems folder)");
                    if wasSavedAutopilotInSystemFolderInAircraftFolder == %f then
                        return;
                    end
                    
                    
                    //create folder inside autopilot folder for each individual in generation with all numbers for P, I, D
                    format("v", 6); //format numbers to maximum width less than 6 (including decimal point) - used to create shorter folder name
                    iterationInGenerationFolderName = string(iterationInGeneration);
                    //because Scilab 6.0.1 uses 'D' instead of 'E' to express exponent (<>Scilab bug?), we have to change it to 'E'
                    currentIndividualInControllerAdjustmentProgression = currentPopulationFolderInControllerAdjustmentProgression + filesep() + "i_" + iterationInGenerationFolderName + "__" + "P=" + strsubst(string(pidGenerationCurrent(iterationInGeneration)(1)), "D", "E") + ", I=" + strsubst(string(pidGenerationCurrent(iterationInGeneration)(2)), "D", "E") + ", D=" + strsubst(string(pidGenerationCurrent(iterationInGeneration)(3)), "D", "E");
                    wasCreatedcurrentIndividualFolderInControllerAdjustmentProgression = CreateFolderIfNotExists(currentIndividualInControllerAdjustmentProgression);
                    if wasCreatedcurrentIndividualFolderInControllerAdjustmentProgression == %f then
                        return;
                    end
                    format("v", 10);    // reset format of numbers
                    
                    
                    sleep(10);
                    
                    //save autopilot with changed adjustable component to each separated folder (in controllerAdjustmentProgressionPath) whose name depending on iteration number
                    wasSavedAutopilotInControllerAdjustmentProgression = SaveXMLFileIntoFilePath(xmlAutopilot, currentIndividualInControllerAdjustmentProgression + filesep() + xmlAutopilotFileName + ".xml", "Autopilot (individual no. " + iterationInGenerationFolderName + ")");
                    if wasSavedAutopilotInControllerAdjustmentProgression == %f then
                        return;
                    end
                    
                    
                    
                    
                    //execute JSBSim application
                    [jsbSimCmdOutput, jsbSimCmdbOK, jsbSimCmdExitCode] = JSBSimOrFlightGearExecution("""JSBSim"" " + xmlJsbSimCommandOptionsCompleteString);
                    sleep(10);
                    
                    
                    
                    //after simulation move csv output to folder with the current individual autopilot - if the copy is successful, delete the inputed output CSV file
                    currentOutputCSVPath = currentIndividualInControllerAdjustmentProgression + filesep() + outputName;
                    wasCopiedOutputCSV = CopyFileToSpecificPath(outputName, currentOutputCSVPath);
                    //if the output CSV file was copied successfully, delete the inputed output CSV file
                    if wasCopiedOutputCSV == %t then
                        deletefile(outputName);
                    else
                        //if it was not copied properly, change the path to local CSV file name
                        currentOutputCSVPath = outputName;
                        disp([ "Warning! The output CSV file was not copied properly for iteration no. " + iterationNumberFolderName + " with individual no. " + iterationInGenerationFolderName + "." ; ]);
                    end
                    
                    
                    
                    //load csv file and separate header and value parts
                    [CSVHeader, CSVvalues] = ReadAndEvalCSVfile(currentOutputCSVPath);
                    //process the output csv file and show figure with plots
                    
                    //separate CSV values and CSV headers to parts for sure
                    partCSVHeader = cat(2, CSVHeader(:, 1), CSVHeader(:, 2));
                    partCSVvalues = cat(2, CSVvalues(:, 1), CSVvalues(:, 2));
                    
                    
                    
                    //indexesHeaderList = GetIndexesCSVvalues(CSVHeader, "Time");
                    numberOfRows = size(partCSVvalues, 1);
                    
                    //if time end is infinite or higher than end simulation time, set the end simulation time
                    if timeEndNumberOrig == %inf | timeEndNumberOrig > partCSVvalues(numberOfRows, 1) then
                        timeEndNumber = partCSVvalues(numberOfRows, 1);
                    end
                    
                    //if time start is higher than 0, get only specific values depending on time constraints and recalculate CSV time
                    indexStartValue = 1;
                    if timeStartNumber > 0 then
                        indexStartValue = GetIndexesCSVvalues(partCSVvalues, 1, timeStartNumber);
                        if indexStartValue == 0 then
                            indexStartValue = 1;
                        end
                    end
                    
                    //if time end is lower than the end simulation time, get only specific values depending on time constraints and recalculate CSV time
                    indexEndValue = numberOfRows;
                    if timeEndNumber < partCSVvalues(numberOfRows, 1) then
                        indexEndValue = GetIndexesCSVvalues(partCSVvalues, 1, timeEndNumber);
                        if indexEndValue == 0 then
                            indexEndValue = numberOfRows;
                        elseif indexEndValue > 1 then
                            indexEndValue = indexEndValue - 1;
                        end
                    end
                    
                    
                    //get only specific range of values and recalculate them if needed
                    recalculatedCSVvalues = partCSVvalues;
                    if indexStartValue ~= 1 | indexEndValue ~= numberOfRows then
                        recalculatedCSVvalues = RecalculateValuesInCSV( recalculatedCSVvalues(indexStartValue:indexEndValue, :), 1 );
                    end
                    
                    
                    
                    
                    
                    //analysis of output property data and get Sum of Time multiplied by Absolute Output Error, Absolute Rise Time Error, and Sum of Absolute Overshoot Error
                    [SumOfAbsoluteOutputError, AbsoluteRiseTimeError, SumOfAbsoluteOvershootError] = AnalyzeOutputErrorsOfData(recalculatedCSVvalues, outputRequiredMethodParameter, riseTimeRequiredMethodParameter);
                    
                    objectiveFunctionValue = %inf;
                    if SumOfAbsoluteOutputError ~= %inf & AbsoluteRiseTimeError ~= %inf & SumOfAbsoluteOvershootError ~= %inf then
                        valuesForObjectiveFunctionList = list( SumOfAbsoluteOutputError, AbsoluteRiseTimeError, SumOfAbsoluteOvershootError);
                        objectiveFunctionValue = CalculateObjectiveFunction(valuesForObjectiveFunctionList, weights_outputError_risetime_overshootMethodParameter);
                    end
                    
                    
                    
                    
                    //find the place in list where the new individual may be inserted
                    indexPlaceToInsert = length(pidGenerationAllSortedObjective) + 1;
                    for i = 1 : 1 : length(pidGenerationAllSortedObjective)
                        if objectiveFunctionValue < pidGenerationAllSortedObjective(i) then
                            indexPlaceToInsert = i;
                            break;
                        end
                    end
                    //if there is at least one worse individual but all the individuals are not worse than this current, insert the values to lists at the specific index
                    if indexPlaceToInsert > 1 & indexPlaceToInsert <= length(pidGenerationAllSortedObjective) then
                        
                        pidGenerationAllSortedObjective = cat(2, pidGenerationAllSortedObjective(1:indexPlaceToInsert-1), objectiveFunctionValue, pidGenerationAllSortedObjective(indexPlaceToInsert:length(pidGenerationAllSortedObjective)) );
                        pidGenerationAllSorted = lstcat( pidGenerationAllSorted(1:indexPlaceToInsert-1), pidGenerationCurrent(iterationInGeneration), pidGenerationAllSorted(indexPlaceToInsert:length(pidGenerationAllSorted)) );
                        pidGenerationAllSortedBinary = lstcat( pidGenerationAllSortedBinary(1:indexPlaceToInsert-1), pidGenerationBinaryCurrent(iterationInGeneration), pidGenerationAllSortedBinary(indexPlaceToInsert:length(pidGenerationAllSortedBinary)) );
                        pidGenerationAllSortedSumOfAbsoluteOutputError = lstcat( pidGenerationAllSortedSumOfAbsoluteOutputError(1:indexPlaceToInsert-1), SumOfAbsoluteOutputError, pidGenerationAllSortedSumOfAbsoluteOutputError(indexPlaceToInsert:length(pidGenerationAllSortedSumOfAbsoluteOutputError)) );
                        pidGenerationAllSortedAbsoluteRiseTimeError = lstcat( pidGenerationAllSortedAbsoluteRiseTimeError(1:indexPlaceToInsert-1), AbsoluteRiseTimeError, pidGenerationAllSortedAbsoluteRiseTimeError(indexPlaceToInsert:length(pidGenerationAllSortedAbsoluteRiseTimeError)) );
                        pidGenerationAllSortedSumOfAbsoluteOvershootError = lstcat( pidGenerationAllSortedSumOfAbsoluteOvershootError(1:indexPlaceToInsert-1), SumOfAbsoluteOvershootError, pidGenerationAllSortedSumOfAbsoluteOvershootError(indexPlaceToInsert:length(pidGenerationAllSortedSumOfAbsoluteOvershootError)) );
                        
                        pidGenerationAllSortedGenerationNumber = lstcat( pidGenerationAllSortedGenerationNumber(1:indexPlaceToInsert-1), iterationNumber, pidGenerationAllSortedGenerationNumber(indexPlaceToInsert:length(pidGenerationAllSortedGenerationNumber)) );
                        pidGenerationAllSortedIterationInGenerationNumber = lstcat( pidGenerationAllSortedIterationInGenerationNumber(1:indexPlaceToInsert-1), iterationInGeneration, pidGenerationAllSortedIterationInGenerationNumber(indexPlaceToInsert:length(pidGenerationAllSortedIterationInGenerationNumber)) );
                        
                    //else if this is the best individual, add the values to the start of the lists
                    elseif indexPlaceToInsert == 1 then
                        
                        pidGenerationAllSortedObjective = cat(2, objectiveFunctionValue, pidGenerationAllSortedObjective);
                        pidGenerationAllSorted(0) = pidGenerationCurrent(iterationInGeneration);
                        pidGenerationAllSortedBinary(0) = pidGenerationBinaryCurrent(iterationInGeneration);
                        pidGenerationAllSortedSumOfAbsoluteOutputError(0) = SumOfAbsoluteOutputError;
                        pidGenerationAllSortedAbsoluteRiseTimeError(0) = AbsoluteRiseTimeError;
                        pidGenerationAllSortedSumOfAbsoluteOvershootError(0) = SumOfAbsoluteOvershootError;
                        pidGenerationAllSortedGenerationNumber(0) = iterationNumber;
                        pidGenerationAllSortedIterationInGenerationNumber(0) = iterationInGeneration;
                        
                    //otherwise, add the values to the end of the lists

                    else
                        
                        pidGenerationAllSortedObjective = cat(2, pidGenerationAllSortedObjective, objectiveFunctionValue);
                        pidGenerationAllSorted(indexPlaceToInsert) = pidGenerationCurrent(iterationInGeneration);
                        pidGenerationAllSortedBinary(indexPlaceToInsert) = pidGenerationBinaryCurrent(iterationInGeneration);
                        pidGenerationAllSortedSumOfAbsoluteOutputError(indexPlaceToInsert) = SumOfAbsoluteOutputError;
                        pidGenerationAllSortedAbsoluteRiseTimeError(indexPlaceToInsert) = AbsoluteRiseTimeError;
                        pidGenerationAllSortedSumOfAbsoluteOvershootError(indexPlaceToInsert) = SumOfAbsoluteOvershootError;
                        pidGenerationAllSortedGenerationNumber(indexPlaceToInsert) = iterationNumber;
                        pidGenerationAllSortedIterationInGenerationNumber(indexPlaceToInsert) = iterationInGeneration;
                        
                    end
                    
                    
                    //add the individual objective function value to the current lists
                    pidGenerationObjectiveCurrent(1, size(pidGenerationObjectiveCurrent, 2) + 1) = objectiveFunctionValue;
                    pidGenerationSumOfAbsoluteOutputErrorCurrent($+1) = SumOfAbsoluteOutputError;
                    pidGenerationAbsoluteRiseTimeErrorCurrent($+1) = AbsoluteRiseTimeError;
                    pidGenerationSumOfAbsoluteOvershootErrorCurrent($+1) = SumOfAbsoluteOvershootError;
                    
                    
                end
                
                
            end
            
            
            //log information about individuals in this iteration to TXT file
            messageCurrentInfoStringArray = ["Current PID individuals:" ; emptystr()];
            //also create complete matrix with PID values for the current generation
            matrixPidGenerationCurrentString = "[ ";
            for i = 1 : 1 : length(pidGenerationCurrent)
                
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "Individual no. " + string(i);
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "PID value: [" + strcat(string(pidGenerationCurrent(i)), ", ") + "]";
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "PID binary value: " + pidGenerationBinaryCurrent(i);
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "Objective function value: " + string(pidGenerationObjectiveCurrent(i));
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "Sum of Absolute Output Error: " + string(pidGenerationSumOfAbsoluteOutputErrorCurrent(i));
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "Absolute Rise Time Error: " + string(pidGenerationAbsoluteRiseTimeErrorCurrent(i));
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = "Sum of Absolute Overshoot Error: " + string(pidGenerationSumOfAbsoluteOvershootErrorCurrent(i));
                messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = emptystr();
                
                if i > 1 then
                    matrixPidGenerationCurrentString = matrixPidGenerationCurrentString + " ; [" + strcat(string(pidGenerationCurrent(i)), ", ") + "]";
                else
                    matrixPidGenerationCurrentString = matrixPidGenerationCurrentString + "[" + strcat(string(pidGenerationCurrent(i)), ", ") + "]";
                end
                
            end
            matrixPidGenerationCurrentString = matrixPidGenerationCurrentString + " ]";
            messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = emptystr();
            messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = matrixPidGenerationCurrentString;
            messageCurrentInfoStringArray(size(messageCurrentInfoStringArray, 1) + 1) = emptystr();
            WriteControlDesignMethodInformationToTXT(messageCurrentInfoStringArray, currentPopulationFolderInControllerAdjustmentProgression + filesep() + "outInfo_PID_individuals-Current.txt");
            
            //log information about sorted individuals of global best of the best to TXT file
            messageAllSortedInfoStringArray = ["All sorted PID individuals (from the lowest objective function value to the highest):" ; emptystr()];
            //also create complete matrix with PID values for the complete sorted population
            matrixPidGenerationAllSortedString = "[ ";
            for i = 1 : 1 : length(pidGenerationAllSorted)
                
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Individual no. " + string(i);
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Generation no. " + string(pidGenerationAllSortedGenerationNumber(i));
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Iteration in Generation no. " + string(pidGenerationAllSortedIterationInGenerationNumber(i));
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "PID value: [" + strcat(string(pidGenerationAllSorted(i)), ", ") + "]";
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "PID binary value: " + pidGenerationAllSortedBinary(i);
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Objective function value: " + string(pidGenerationAllSortedObjective(i));
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Sum of Absolute Output Error: " + string(pidGenerationAllSortedSumOfAbsoluteOutputError(i));
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Absolute Rise Time Error: " + string(pidGenerationAllSortedAbsoluteRiseTimeError(i));
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = "Sum of Absolute Overshoot Error: " + string(pidGenerationAllSortedSumOfAbsoluteOvershootError(i));
                messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = emptystr();
                
                if i > 1 then
                    matrixPidGenerationAllSortedString = matrixPidGenerationAllSortedString + " ; [" + strcat(string(pidGenerationAllSorted(i)), ", ") + "]";
                else
                    matrixPidGenerationAllSortedString = matrixPidGenerationAllSortedString + "[" + strcat(string(pidGenerationAllSorted(i)), ", ") + "]";
                end
                
            end
            matrixPidGenerationAllSortedString = matrixPidGenerationAllSortedString + " ]";
            messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = emptystr();
            messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = matrixPidGenerationAllSortedString;
            messageAllSortedInfoStringArray(size(messageAllSortedInfoStringArray, 1) + 1) = emptystr();
            WriteControlDesignMethodInformationToTXT(messageAllSortedInfoStringArray, currentPopulationFolderInControllerAdjustmentProgression + filesep() + "outInfo_PID_individuals-All_Sorted.txt");
            
            
            
            
            
            //check whether there are clones of the first individual only
            if NumberOfClonesOfFirstIndividual >= length(pidGenerationBinaryCurrent) - 1 then
                messagebox(["Error! The whole population was destroyed  - only 1 unique individual was found!"], "modal", "error");
                break;
            end
            
            
            
            //check whether the objective function value met the constraint requirement
            if length(pidGenerationAllSortedObjective) > 0 & pidGenerationAllSortedObjective(1) <= objectiveFunctionValueConstraintMethodParameter then
                disp([ "Constraint of Objective function value was met!" ; "PID value: [" + strcat(string(pidGenerationAllSorted(1)), ", ") + "]" ; "Objective function value: " + string(pidGenerationAllSortedObjective(1)) ; ]);
                break;
            end
            
            
            
            
            
//            //<>debug only - start
//            //create parameters of P, I, D genome for coding/decoding function
//            binaryLengthIntegerPartMethodParameter = 10;
//            binaryLengthFractionalPartMethodParameter = 22;
//            minimumKpKiKdMethodSaveParameter = [0, 0, 0];
//            maximumKpKiKdMethodSaveParameter = [0.7*0.54, 4.0*0.54, 0.8*0.54];
//            paramP_GA_CodingBinary = init_param();
//            paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "binary_length", binaryLengthIntegerPartMethodParameter);
//            paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "binary_length_fractional_part", binaryLengthFractionalPartMethodParameter);
//            paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "minbound", minimumKpKiKdMethodSaveParameter(1));
//            paramP_GA_CodingBinary = add_param(paramP_GA_CodingBinary, "maxbound", maximumKpKiKdMethodSaveParameter(1));
//            paramI_GA_CodingBinary = init_param();
//            paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "binary_length", binaryLengthIntegerPartMethodParameter);
//            paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "binary_length_fractional_part", binaryLengthFractionalPartMethodParameter);
//            paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "minbound", minimumKpKiKdMethodSaveParameter(2));
//            paramI_GA_CodingBinary = add_param(paramI_GA_CodingBinary, "maxbound", maximumKpKiKdMethodSaveParameter(2));
//            paramD_GA_CodingBinary = init_param();
//            paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "binary_length", binaryLengthIntegerPartMethodParameter);
//            paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "binary_length_fractional_part", binaryLengthFractionalPartMethodParameter);
//            paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "minbound", minimumKpKiKdMethodSaveParameter(3));
//            paramD_GA_CodingBinary = add_param(paramD_GA_CodingBinary, "maxbound", maximumKpKiKdMethodSaveParameter(3));
//            
//            pidGenerationCurrent = list( [0.3285022, 0.8058441, 0.0334785] , [0.2463767, 0.3640862, 0] , [45, 45, 46] , [0.2737519, 0, 0] , [0.3832526, 1.1751893, 0.0468699] , [0.1806762, 0.4432142, 0.0486107] , [0.1095007, 0.2686147, 0.0294611] );
//            pidGenerationBinaryCurrent = list();
//            pidGenerationObjectiveCurrent = [0.3285022, 0.2463767, %inf, 0.2737519, 1.1751893, 0.1806762, 0.4432142];
//            for i = 1 : 1 : length(pidGenerationCurrent)
//                P_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(1), "code", paramP_GA_CodingBinary);
//                I_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(2), "code", paramI_GA_CodingBinary);
//                D_StringGenome = GA_CodingBinary(pidGenerationCurrent(i)(3), "code", paramD_GA_CodingBinary);
//                genomePIDString = GA_JoinGenome( list(P_StringGenome, I_StringGenome, D_StringGenome) )
//                pidGenerationBinaryCurrent($+1) = genomePIDString;
//            end
//            pidGenerationAllSorted = list( [0.1806762, 0.4432142, 0.0486107] , [0.645, 0.3640862, 0.46541] , [0.2463767, 0.3640862, 0] , [0.2737519, 0, 0] , [0.3285022, 0.8058441, 0.0334785] , [0.1095007, 0.2686147, 0.0294611] , [0.3832526, 1.1751893, 0.0468699] , [0.4195007, 0.2648947, 0.2161611] , [45, 45, 46] );
//            pidGenerationAllSortedBinary = list();
//            pidGenerationAllSortedObjective = [0.1806762, 0.22458, 0.2463767, 0.2737519, 0.3285022, 0.4432142, 1.1751893, 1.244516, %inf];
//            for i = 1 : 1 : length(pidGenerationAllSorted)
//                P_StringGenome = GA_CodingBinary(pidGenerationAllSorted(i)(1), "code", paramP_GA_CodingBinary);
//                I_StringGenome = GA_CodingBinary(pidGenerationAllSorted(i)(2), "code", paramI_GA_CodingBinary);
//                D_StringGenome = GA_CodingBinary(pidGenerationAllSorted(i)(3), "code", paramD_GA_CodingBinary);
//                genomePIDString = GA_JoinGenome( list(P_StringGenome, I_StringGenome, D_StringGenome) )
//                pidGenerationAllSortedBinary($+1) = genomePIDString;
//            end
//            
////            paretoFiltrMethodParameter = %t;
////            if paretoFiltrMethodParameter == %t then
////                //pareto filtr - a function which extracts non dominated solution from a set
////                [ParetoF_out, ParetoX_out, ParetoInd_out] = pareto_filter(pidGenerationObjectiveCurrent', pidGenerationBinaryCurrent)
////            end
//            
//            //separate individuals with infinite objective function value
//            pidGenerationObjectiveCurrentWithInfinite = []
//            pidGenerationCurrentWithInfinite = list();
//            pidGenerationBinaryCurrentWithInfinite = list()
//            iterationInInfiniteCheck = 1;
//            while iterationInInfiniteCheck <= length(pidGenerationObjectiveCurrent)
//                
//                if isinf(pidGenerationObjectiveCurrent(iterationInInfiniteCheck)) == %t | isnan(pidGenerationObjectiveCurrent(iterationInInfiniteCheck)) == %t then
//                    
//                    pidGenerationObjectiveCurrentWithInfinite(1, size(pidGenerationObjectiveCurrentWithInfinite, 2) + 1) = pidGenerationObjectiveCurrent(iterationInInfiniteCheck)
//                    pidGenerationCurrentWithInfinite($+1) = pidGenerationCurrent(iterationInInfiniteCheck)
//                    pidGenerationBinaryCurrentWithInfinite($+1) = pidGenerationBinaryCurrent(iterationInInfiniteCheck)
//                    
//                    pidGenerationObjectiveCurrent(iterationInInfiniteCheck) = []
//                    pidGenerationCurrent(iterationInInfiniteCheck) = null()
//                    pidGenerationBinaryCurrent(iterationInInfiniteCheck) = null()
//                    
//                    //continue with the cycle without increment
//                    continue;
//                    
//                end
//                
//                iterationInInfiniteCheck = iterationInInfiniteCheck + 1;
//            end
//            
//            //selection - 'elitist' selection function
//            param_GA_Selection = init_param();
//            param_GA_Selection = add_param(param_GA_Selection, "pressure", 0.001);
//            [pidGenerationBinaryCurrent, pidGenerationObjectiveCurrent, pidGenerationEfficiency] = selection_ga_elitist(pidGenerationBinaryCurrent, [], [], pidGenerationObjectiveCurrent, [], [], [], [], [], param_GA_Selection)
//////            [ElitistPop_out, ElitistFObj_Pop_out, ElitistEfficiency] = selection_ga_elitist(pidGenerationAllSortedBinary, pidGenerationBinaryCurrent, [], pidGenerationAllSortedObjective, pidGenerationObjectiveCurrent, [], [], [], [], [])
//////            //selection - a function which performs a random selection of individuals
//////            [RandomPop_out, RandomFObj_Pop_out, RandomEfficiency] = selection_ga_random(pidGenerationBinaryCurrent, [], [], pidGenerationObjectiveCurrent, [], [], [], [], [], [])
//            
//            //join individuals without infinite objective function value and individuals with infinite objective function value back together
//            pidGenerationObjectiveCurrent = cat(2, pidGenerationObjectiveCurrent, pidGenerationObjectiveCurrentWithInfinite)
//            pidGenerationCurrent = lstcat(pidGenerationCurrent, pidGenerationCurrentWithInfinite)
//            pidGenerationBinaryCurrent = lstcat(pidGenerationBinaryCurrent, pidGenerationBinaryCurrentWithInfinite)
//            
//            
//            //[selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionFromCurrentGenerationAndCompletePopulation(pidGenerationBinaryCurrent, pidGenerationObjectiveCurrent, pidGenerationAllSortedBinary, pidGenerationAllSortedObjective, round(length(pidGenerationBinaryCurrent) / 2), 2, %f)
//            [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionFromCurrentGenerationAndCompletePopulation(pidGenerationBinaryCurrent, pidGenerationObjectiveCurrent, pidGenerationAllSortedBinary, pidGenerationAllSortedObjective, length(pidGenerationBinaryCurrent), 2, %f)
//            
//            
////            global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
////            global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
////            global GA_CreatePairs_SelectionMode_RandomPairs;
////            global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
////            global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce;
////            global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
////            global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce;
////            global GA_CreatePairs_SelectionMode_TournamentPairs;
////            global GA_CreatePairs_SelectionMode_RouletteWheelPairs;
////            global GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling;
////            global GA_CreatePairs_SelectionMode_RandomPairs;
//            
//            selectionPairsModeParameter = GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
//            [pairsOfSelectedIndividualsFromBestPairsToWorstPairs, pairsOfSelectedIndividualsIndexesFromBestPairsToWorstPairs] = GA_CreatePairsFromSelectedIndividuals(selectedIndividualsBinary, selectedIndividualsObjective, selectionPairsModeParameter, round(length(pidGenerationBinaryCurrent) / 2))
//            
//            selectionPairsModeParameter = GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
//            [pairsOfSelectedIndividualsBestIndividualsWithWorstIndividuals, pairsOfSelectedIndividualsIndexesBestIndividualsWithWorstIndividuals] = GA_CreatePairsFromSelectedIndividuals(selectedIndividualsBinary, selectedIndividualsObjective, selectionPairsModeParameter, round(length(pidGenerationBinaryCurrent) / 2))
//            
//            selectionPairsModeParameter = GA_CreatePairs_SelectionMode_RandomPairs;
//            [pairsOfSelectedIndividualsRandomPairs, pairsOfSelectedIndividualsIndexesRandomPairs] = GA_CreatePairsFromSelectedIndividuals(selectedIndividualsBinary, selectedIndividualsObjective, selectionPairsModeParameter, round(length(pidGenerationBinaryCurrent) / 2))
//            
//            
//            probabilityArray = [0.2, 0.6, 0.18, 0.02]
//            probabilityArray = [0.950, 0.040, 0.005, 0.005]
//            allNumberOfMultiples = list();
//            for i = 1 : 1 : length(probabilityArray)
//                allNumberOfMultiples($+1) = 0;
//            end
//            for i = 1 : 1 : 100
//                [isMultiple, numberOfMultiples] = GA_GenerateMultiplesByUsingProbabilities(probabilityArray)
//                allNumberOfMultiples(numberOfMultiples+1) = allNumberOfMultiples(numberOfMultiples+1) + 1;
//            end
//            allNumberOfMultiples
//            
//            
//            param_GA_Crossover = init_param();
//            param_GA_Crossover = add_param(param_GA_Crossover, "binary_length", 3*(binaryLengthIntegerPartMethodParameter + binaryLengthFractionalPartMethodParameter));
//            param_GA_Crossover = add_param(param_GA_Crossover, "multi_cross", %t);    // Multiple Crossover
//            param_GA_Crossover = add_param(param_GA_Crossover, "multi_cross_nb", 3);  // Occurs over 3 locations
//            [Crossed_Indiv1, Crossed_Indiv2, mix] = crossover_ga_binary(pidGenerationBinaryCurrent(1), pidGenerationBinaryCurrent(2), param_GA_Crossover)
//            
//            
//            param_GA_Mutation = init_param();
//            param_GA_Mutation = add_param(param_GA_Mutation, "binary_length", 3*(binaryLengthIntegerPartMethodParameter + binaryLengthFractionalPartMethodParameter));
//            param_GA_Mutation = add_param(param_GA_Mutation, "multi_mut", %t);    // Multiple mutation
//            param_GA_Mutation = add_param(param_GA_Mutation, "multi_mut_nb", 2);  // Occurs over 2 locations
//            [Mut_Indiv, pos] = mutation_ga_binary(Crossed_Indiv1, param_GA_Mutation)
//            
//            outGenomeStringList = GA_SplitGenome(Mut_Indiv, binaryLengthIntegerPartMethodParameter + binaryLengthFractionalPartMethodParameter)
//            [NumberOutP] = GA_CodingBinary(outGenomeStringList(1), "decode", paramP_GA_CodingBinary)
//            [NumberOutI] = GA_CodingBinary(outGenomeStringList(2), "decode", paramI_GA_CodingBinary)
//            [NumberOutD] = GA_CodingBinary(outGenomeStringList(3), "decode", paramD_GA_CodingBinary)
//            //<>debug only - end
            
            
            
            
            
            //GA beginning - create new gain, integral, and derivate generation (or gain only generation)
            
            //sets the generator to a uniform random number generator.
            rand("uniform");
            //sleep a second before new seed initialization
            sleep(1001);
            //initialize the seed with the output of the getdate function
            generatorSeed = getdate("s");
            rand("seed", generatorSeed);
            
            
            //separate individuals with infinite objective function value
            pidGenerationObjectiveCurrentWithInfinite = []
            pidGenerationCurrentWithInfinite = list();
            pidGenerationBinaryCurrentWithInfinite = list()
            iterationInInfiniteCheck = 1;
            while iterationInInfiniteCheck <= length(pidGenerationObjectiveCurrent)
                
                if isinf(pidGenerationObjectiveCurrent(iterationInInfiniteCheck)) == %t | isnan(pidGenerationObjectiveCurrent(iterationInInfiniteCheck)) == %t then
                    
                    pidGenerationObjectiveCurrentWithInfinite(1, size(pidGenerationObjectiveCurrentWithInfinite, 2) + 1) = pidGenerationObjectiveCurrent(iterationInInfiniteCheck)
                    pidGenerationCurrentWithInfinite($+1) = pidGenerationCurrent(iterationInInfiniteCheck)
                    pidGenerationBinaryCurrentWithInfinite($+1) = pidGenerationBinaryCurrent(iterationInInfiniteCheck)
                    
                    pidGenerationObjectiveCurrent(iterationInInfiniteCheck) = []
                    pidGenerationCurrent(iterationInInfiniteCheck) = null()
                    pidGenerationBinaryCurrent(iterationInInfiniteCheck) = null()
                    
                    //continue with the cycle without increment
                    continue;
                    
                end
                
                iterationInInfiniteCheck = iterationInInfiniteCheck + 1;
            end
            
            //selection - 'elitist' selection function - sort the individuals by objective function value from the lowest to the highest
            param_GA_Selection = init_param();
            param_GA_Selection = add_param(param_GA_Selection, "pressure", 0.001);
            [pidGenerationBinaryCurrent, pidGenerationObjectiveCurrent, pidGenerationEfficiency] = selection_ga_elitist(pidGenerationBinaryCurrent, [], [], pidGenerationObjectiveCurrent, [], [], [], [], [], param_GA_Selection)
            
            //join individuals without infinite objective function value and individuals with infinite objective function value back together
            pidGenerationObjectiveCurrent = cat(2, pidGenerationObjectiveCurrent, pidGenerationObjectiveCurrentWithInfinite)
            pidGenerationCurrent = lstcat(pidGenerationCurrent, pidGenerationCurrentWithInfinite)
            pidGenerationBinaryCurrent = lstcat(pidGenerationBinaryCurrent, pidGenerationBinaryCurrentWithInfinite)
            
            
////            //if there are at least one previous generation
////            if iterationNumber > 1 then
////            end
//            //select individuals for crossover from current generation and complete population - with information how many individuals should be selected, how many maximal best individuals may be selected from complete population (2), and if an individual may be selected twice (%f)
//            [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionFromCurrentGenerationAndCompletePopulation(pidGenerationBinaryCurrent, pidGenerationObjectiveCurrent, pidGenerationAllSortedBinary, pidGenerationAllSortedObjective, length(pidGenerationBinaryCurrent), 0, %f)
//            if length(selectedIndividualsBinary) < length(pidGenerationBinaryCurrent) then
//                messagebox(["Genetic Algorithm terminated after selection of individuals (i.e. GA_SelectionFromCurrentGenerationAndCompletePopulation)."], "modal", "error");
//                return;
//            end
            //check if the current generation and the complete population have enough valid individuals which DO depend on number of maximum selected individuals from complete population
            [haveEnoughValidIndividuals, numberOfValidIndividuals] = GA_HaveCurrentGenerationAndCompletePopulationEnoughValidIndividuals(pidGenerationBinaryCurrent, pidGenerationObjectiveCurrent, pidGenerationAllSortedBinary, pidGenerationAllSortedObjective, 0, %f, length(pidGenerationBinaryCurrent));
            if numberOfValidIndividuals <= 1 then
                messagebox(["Error! The whole population degenerated - no more than 1 individual was found in selection!" ; "The Number of Valid Individuals: " + string(numberOfValidIndividuals) ; "The Number of necessary individuals: " + string(length(pidGenerationBinaryCurrent)) ; ], "modal", "error");
                break;
            end
            selectedIndividualsBinary = pidGenerationBinaryCurrent;
            selectedIndividualsObjective = pidGenerationObjectiveCurrent;
            
            
            //check if the selection mode for pairs is set to an Individual Once only, than set the number of children to 2
            if selectionPairsModeParameter == convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce, " ", ""), 'l')  |  selectionPairsModeParameter == convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce, " ", ""), 'l') then
                numberOfChildrenMethodParameter = 2;
                disp(["Mode of pair selection is ""Individual_Once"", the number of children must be 2." ; ]);
            end
            //create pairs from selected individuals
            requiredNumberOfPairs = round(length(pidGenerationBinaryCurrent) / numberOfChildrenMethodParameter);
            [pairsOfSelectedIndividuals, pairsOfSelectedIndividualsIndexes] = GA_CreatePairsFromSelectedIndividuals(selectedIndividualsBinary, selectedIndividualsObjective, selectionPairsModeParameter, requiredNumberOfPairs)
            if length(pairsOfSelectedIndividuals) == 0 | length(pairsOfSelectedIndividuals) < requiredNumberOfPairs then
                messagebox(["Genetic Algorithm terminated after selection of pairs - no enough pairs (i.e. GA_CreatePairsFromSelectedIndividuals)." ; "Required Number of Pairs: " + string(requiredNumberOfPairs) ; "Selected Number of Pairs: " + string(length(pairsOfSelectedIndividuals)) ; "Number of Children: " + string(numberOfChildrenMethodParameter)] , "modal", "error");
                break;
            end
            
            
            
            //calculate complete binary length (including integer and fractional parts)
            completeBinaryLength = binaryLengthIntegerPartMethodParameter + binaryLengthFractionalPartMethodParameter;
            if xmlAutopilotAdjustableComponent.name == "pid" then
                completeBinaryLength = completeBinaryLength * 3;
//            elseif xmlAutopilotAdjustableComponent.name == "pure_gain" then
//                completeBinaryLength = completeBinaryLength;
            end
            binaryLengthPerOneNumber = binaryLengthIntegerPartMethodParameter + binaryLengthFractionalPartMethodParameter;
            
            
            
            //reset current pid generation and its binary representation
            pidGenerationCurrent = list();
            pidGenerationBinaryCurrent = list();
            //for each created pair, randomly (based on probability array) generate number of locations for crossover and mutation, and perform crossovers and mutations
            pairNumberOfMultiplesCrossoversList = list();
            pairCrossoverMixList = list();
            crossedIndividualsWithoutMutation = list();
            crossedIndividualsWithoutMutationBinary = list();
            crossedIndividualNumberOfMultiplesMutationList = list();
            crossedIndividualMutationPositionList = list();
            for i = 1 : 1 : length(pairsOfSelectedIndividuals)
                
                
                individualOne = pairsOfSelectedIndividuals(i)(1);
                individualTwo = pairsOfSelectedIndividuals(i)(2);
                
                
                //randomly generate number of locations for crossover (based on probability array)
                [isMultipleCrossover, numberOfMultiplesCrossover] = GA_GenerateMultiplesByUsingProbabilities(crossoverNumberOfCutsProbabilityMethodParameter)
                pairNumberOfMultiplesCrossoversList($+1) = numberOfMultiplesCrossover;
                //sleep(15);
                
                crossedIndividualOne = individualOne;
                crossedIndividualTwo = individualTwo;
                //if there should be at least one location selected for crossover
                if numberOfMultiplesCrossover >= 1 then
                    
                    param_GA_Crossover = init_param();
                    param_GA_Crossover = add_param(param_GA_Crossover, "binary_length", completeBinaryLength);
                    param_GA_Crossover = add_param(param_GA_Crossover, "multi_cross", isMultipleCrossover);    // Multiple Crossover or not
                    param_GA_Crossover = add_param(param_GA_Crossover, "multi_cross_nb", numberOfMultiplesCrossover);  // Occurs over 1 or more locations
                    
                    //perform crossover for two individuals in binary code
                    [crossedIndividualOne, crossedIndividualTwo, mix] = crossover_ga_binary(individualOne, individualTwo, param_GA_Crossover)
                    pairCrossoverMixList($+1) = mix;
                    
                else
                    //otherwise, no crossover is performed, just copy the individuals, and set mix locations to 0 - warning if there is high probability for no crossing, there will often be no crossover which may cause to more identical individuals (clones) in next generation
                    pairCrossoverMixList($+1) = [0];
                end
                
                
                //decode crossed binary genomes to the PID values - this is not necessary, it is here for log purpose
                crossedIndividualOneGenomeStringList = GA_SplitGenome(crossedIndividualOne, binaryLengthPerOneNumber)
                crossedIndividualOneP = GA_CodingBinary(crossedIndividualOneGenomeStringList(1), "decode", paramP_GA_CodingBinary)
                crossedIndividualOneI = GA_CodingBinary(crossedIndividualOneGenomeStringList(2), "decode", paramI_GA_CodingBinary)
                crossedIndividualOneD = GA_CodingBinary(crossedIndividualOneGenomeStringList(3), "decode", paramD_GA_CodingBinary)
                crossedIndividualsWithoutMutation($+1) = [crossedIndividualOneP, crossedIndividualOneI, crossedIndividualOneD];
                crossedIndividualsWithoutMutationBinary($+1) = crossedIndividualOne;
                
                
                //if both two children should be in future generation for crossover
                if numberOfChildrenMethodParameter == 2 then
                    crossedIndividualTwoGenomeStringList = GA_SplitGenome(crossedIndividualTwo, binaryLengthPerOneNumber)
                    crossedIndividualTwoP = GA_CodingBinary(crossedIndividualTwoGenomeStringList(1), "decode", paramP_GA_CodingBinary)
                    crossedIndividualTwoI = GA_CodingBinary(crossedIndividualTwoGenomeStringList(2), "decode", paramI_GA_CodingBinary)
                    crossedIndividualTwoD = GA_CodingBinary(crossedIndividualTwoGenomeStringList(3), "decode", paramD_GA_CodingBinary)
                    crossedIndividualsWithoutMutation($+1) = [crossedIndividualTwoP, crossedIndividualTwoI, crossedIndividualTwoD];
                    crossedIndividualsWithoutMutationBinary($+1) = crossedIndividualTwo;
                end
                
                
                
                mutatedIndividualOne = crossedIndividualOne;
                //randomly generate number of locations for mutation of the first crossed individual (based on probability array)
                [isMultipleMutationOne, numberOfMultiplesMutationOne] = GA_GenerateMultiplesByUsingProbabilities(mutationNumberOfMutatedBitsProbabilityMethodParameter)
                crossedIndividualNumberOfMultiplesMutationList($+1) = numberOfMultiplesMutationOne;
                //sleep(15);
                
                //if there should be at least one position selected for mutation
                if numberOfMultiplesMutationOne >= 1 then
                    
                    param_GA_Mutation = init_param();
                    param_GA_Mutation = add_param(param_GA_Mutation, "binary_length", completeBinaryLength);
                    param_GA_Mutation = add_param(param_GA_Mutation, "multi_mut", isMultipleMutationOne);    // Multiple mutation or not
                    param_GA_Mutation = add_param(param_GA_Mutation, "multi_mut_nb", numberOfMultiplesMutationOne);  // Occurs over 1 or more locations
                    
                    //perform binary mutation for two crossed individuals
                    [mutatedIndividualOne, posOne] = mutation_ga_binary(crossedIndividualOne, param_GA_Mutation)
                    crossedIndividualMutationPositionList($+1) = posOne;
                    
                else
                    //otherwise, no mutation is performed, just copy the crossed individuals and set positions to 0
                    crossedIndividualMutationPositionList($+1) = [0];
                end
                
                
                mutatedIndividualTwo = crossedIndividualTwo;
                //if both two children should be in future generation for crossover
                if numberOfChildrenMethodParameter == 2 then
                    

                    //randomly generate number of locations for mutation of the second crossed individual (based on probability array)
                    [isMultipleMutationTwo, numberOfMultiplesMutationTwo] = GA_GenerateMultiplesByUsingProbabilities(mutationNumberOfMutatedBitsProbabilityMethodParameter)
                    crossedIndividualNumberOfMultiplesMutationList($+1) = numberOfMultiplesMutationTwo;
                    
                    //if there should be at least one position selected for mutation
                    if numberOfMultiplesMutationTwo >= 1 then
                        
                        param_GA_Mutation = init_param();
                        param_GA_Mutation = add_param(param_GA_Mutation, "binary_length", completeBinaryLength);
                        param_GA_Mutation = add_param(param_GA_Mutation, "multi_mut", isMultipleMutationTwo);    // Multiple mutation or not
                        param_GA_Mutation = add_param(param_GA_Mutation, "multi_mut_nb", numberOfMultiplesMutationTwo);  // Occurs over 1 or more locations
                        
                        //perform binary mutation for two crossed individuals
                        [mutatedIndividualTwo, posTwo] = mutation_ga_binary(crossedIndividualTwo, param_GA_Mutation)
                        crossedIndividualMutationPositionList($+1) = posTwo;
                        
                    else
                        //otherwise, no mutation is performed, just copy the crossed individuals and set positions to 0
                        crossedIndividualMutationPositionList($+1) = [0];
                    end
                    
                end
                
                
                
                //if the current generation does not have enough individuals, add the first
                if length(pidGenerationCurrent) < pidPopulationSizeMethodParameter then
                    //decode mutated, and crossed binary genome to the PID values
                    mutatedIndividualOneGenomeStringList = GA_SplitGenome(mutatedIndividualOne, binaryLengthPerOneNumber)
                    mutatedIndividualOneP = GA_CodingBinary(mutatedIndividualOneGenomeStringList(1), "decode", paramP_GA_CodingBinary)
                    mutatedIndividualOneI = GA_CodingBinary(mutatedIndividualOneGenomeStringList(2), "decode", paramI_GA_CodingBinary)
                    mutatedIndividualOneD = GA_CodingBinary(mutatedIndividualOneGenomeStringList(3), "decode", paramD_GA_CodingBinary)
                    //set the first binary genome to the new current generation
                    pidGenerationCurrent($+1) = [mutatedIndividualOneP, mutatedIndividualOneI, mutatedIndividualOneD];
                    pidGenerationBinaryCurrent($+1) = mutatedIndividualOne;
                else
                    break;
                end
                
                //if the current generation does not have enough individuals, and the both children should be in future generation for crossover, add the second
                if length(pidGenerationCurrent) < pidPopulationSizeMethodParameter & numberOfChildrenMethodParameter == 2 then
                    
                    //decode mutated, and crossed binary genome to the PID values
                    mutatedIndividualTwoGenomeStringList = GA_SplitGenome(mutatedIndividualTwo, binaryLengthPerOneNumber)
                    mutatedIndividualTwoP = GA_CodingBinary(mutatedIndividualTwoGenomeStringList(1), "decode", paramP_GA_CodingBinary)
                    mutatedIndividualTwoI = GA_CodingBinary(mutatedIndividualTwoGenomeStringList(2), "decode", paramI_GA_CodingBinary)
                    mutatedIndividualTwoD = GA_CodingBinary(mutatedIndividualTwoGenomeStringList(3), "decode", paramD_GA_CodingBinary)
                    //set the second binary genome to the new current generation
                    pidGenerationCurrent($+1) = [mutatedIndividualTwoP, mutatedIndividualTwoI, mutatedIndividualTwoD];
                    pidGenerationBinaryCurrent($+1) = mutatedIndividualTwo;
                    
                elseif length(pidGenerationCurrent) >= pidPopulationSizeMethodParameter then
                    break;
                end
                
                
            end
            //disp(["pairsOfSelectedIndividuals length: " + string(length(pairsOfSelectedIndividuals)) ; "pairNumberOfMultiplesCrossoversList length:" + string(length(pairNumberOfMultiplesCrossoversList)) ;]);   //<>debug only
            
            
            //GA end - create new gain, integral, and derivate generation (or gain only generation)
            
            
            
            //log information about genetic selections, crossovers, and mutations in this iteration to TXT file
            
            //log process of individual selection
            messageSelectionIndividualsInfoStringArray = [ "Selected PID individuals:" ; emptystr() ];
            //messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = 
//            messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = "Number of selected individuals from complete population: " + string(numberOfSelectedIndividualsFromCompletePopulation);
//            messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = emptystr();
//            messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = emptystr();
            for i = 1 : 1 : length(selectedIndividualsBinary)
                messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = "Individual no. " + string(i);
                messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = "PID binary value: " + selectedIndividualsBinary(i);
                messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = "Objective function value: " + string(selectedIndividualsObjective(i));
                messageSelectionIndividualsInfoStringArray(size(messageSelectionIndividualsInfoStringArray, 1) + 1) = emptystr();
            end
            WriteControlDesignMethodInformationToTXT(messageSelectionIndividualsInfoStringArray, currentPopulationFolderInControllerAdjustmentProgression + filesep() + "outInfo_PID_individuals-selection_individuals.txt")
            
            //log process of pair selection and crossover
            messageSelectionAndCrossoverPairsInfoStringArray = [ "Selected pairs of PID individuals:" ; emptystr() ];
            iTwo = 1;
            for i = 1 : 1 : length(pairsOfSelectedIndividuals)
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Pair no. " + string(i);
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "PID index 1: " + string(pairsOfSelectedIndividualsIndexes(i)(1));
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "PID binary 1: " + pairsOfSelectedIndividuals(i)(1);
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "PID index 2: " + string(pairsOfSelectedIndividualsIndexes(i)(2));
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "PID binary 2: " + pairsOfSelectedIndividuals(i)(2);
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Number of crossover locations: " + string(pairNumberOfMultiplesCrossoversList(i));
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Location indexes of crossover: " + strcat(string(pairCrossoverMixList(i)), ', ');
                
                if iTwo <= length(crossedIndividualsWithoutMutation) then
                    messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Crossed PID 1: [" + strcat(string(crossedIndividualsWithoutMutation(iTwo)), ', ') + "]";
                    messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Crossed PID binary 1: " + crossedIndividualsWithoutMutationBinary(iTwo);
                end
                if iTwo+1 <= length(crossedIndividualsWithoutMutation) & numberOfChildrenMethodParameter == 2 then
                    messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Crossed PID 2: [" + strcat(string(crossedIndividualsWithoutMutation(iTwo+1)), ', ') + "]";
                    messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = "Crossed PID binary 2: " + crossedIndividualsWithoutMutationBinary(iTwo+1);
                end
                if numberOfChildrenMethodParameter == 2 then
                    iTwo = iTwo + 2;
                else
                    iTwo = iTwo + 1;
                end
                
                messageSelectionAndCrossoverPairsInfoStringArray(size(messageSelectionAndCrossoverPairsInfoStringArray, 1) + 1) = emptystr();
            end
            WriteControlDesignMethodInformationToTXT(messageSelectionAndCrossoverPairsInfoStringArray, currentPopulationFolderInControllerAdjustmentProgression + filesep() + "outInfo_PID_individuals-selection_crossover_pairs.txt")
            
            //log process of mutation and new current generation
            messageMutationNewCurrentGenerationInfoStringArray = [ "New Mutated and Crossovered generation of PID individuals (for the next iteration):" ; emptystr() ];
            messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = "Number of Children which can be in the following generation: " + string(numberOfChildrenMethodParameter);
            messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = emptystr();
            messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = emptystr();
            //also create complete matrix with PID values for the current new generation with mutation
            matrixPidGenerationNewCurrentString = "[ ";
            for i = 1 : 1 : length(pidGenerationCurrent)
                
                messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = "New Individual no. " + string(i);
                messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = "PID value: [" + strcat(string(pidGenerationCurrent(i)), ", ") + "]";
                messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = "PID binary value: " + pidGenerationBinaryCurrent(i);
                messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = "Number of mutation positions: " + string(crossedIndividualNumberOfMultiplesMutationList(i));
                messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = "Location indexes of mutations: " + strcat(string(crossedIndividualMutationPositionList(i)), ', ');
                messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = emptystr();
                
                if i > 1 then
                    matrixPidGenerationNewCurrentString = matrixPidGenerationNewCurrentString + " ; [" + strcat(string(pidGenerationCurrent(i)), ", ") + "]";
                else
                    matrixPidGenerationNewCurrentString = matrixPidGenerationNewCurrentString + "[" + strcat(string(pidGenerationCurrent(i)), ", ") + "]";
                end
                
            end
            matrixPidGenerationNewCurrentString = matrixPidGenerationNewCurrentString + " ]";
            messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = emptystr();
            messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = matrixPidGenerationNewCurrentString;
            messageMutationNewCurrentGenerationInfoStringArray(size(messageMutationNewCurrentGenerationInfoStringArray, 1) + 1) = emptystr();
            WriteControlDesignMethodInformationToTXT(messageMutationNewCurrentGenerationInfoStringArray, currentPopulationFolderInControllerAdjustmentProgression + filesep() + "outInfo_PID_individuals-Current_NEW_with_mutation.txt")
            
            
            
            
            
            if iterationMaximumMethodParameter ~= %inf & iterationMaximumMethodParameter > 0 then
                waitbar(iterationNumber / iterationMaximumMethodParameter, waitbarControllerAdjustmentProcess);
            end
            
            iterationNumber = iterationNumber + 1;
            
        end
        
        
        
        
        waitbar(1.0, waitbarControllerAdjustmentProcess);
        close(waitbarControllerAdjustmentProcess);
        
        
        
        
        
        //if a pid adjustment was found
        if length(pidGenerationAllSorted) > 0 then
            
            if pidGenerationAllSortedObjective(1) <= objectiveFunctionValueConstraintMethodParameter then
                
                //show information to user
                messagebox(["Constraint of Objective function value WAS SUCCESSFULLY met!" ; "The Best PID value: [" + strcat(string(pidGenerationAllSorted(1)), ", ") + "]" ; "The Best Objective function value = " + string(pidGenerationAllSortedObjective(1)) ; "However, check the output CSV data to be sure that there is required output. You may use menu: ""CSV Processing -> Open CSV JSBSim output""" ], "modal", "info");
                
            else
                
                //show information to user
                messagebox(["Constraint of Objective function value WAS NOT met!" ; "The Best PID value: [" + strcat(string(pidGenerationAllSorted(1)), ", ") + "]" ; "The Best Objective function value = " + string(pidGenerationAllSortedObjective(1)) ; "Check the output CSV data to be sure that there is required output. You may use menu: ""CSV Processing -> Open CSV JSBSim output""" ], "modal", "info");
                
            end
            
            
            //set P, I, D or gain parameters from the best solution
            //because Scilab 6.0.1 uses 'D' instead of 'E' to express exponent (<>Scilab bug?), we have to change it to 'E'
            KP_GainXmlElement.content = strsubst(string(pidGenerationAllSorted(1)(1)), "D", "E");
            if KI_IntegralXmlElement ~= [] then
                KI_IntegralXmlElement.content = strsubst(string(pidGenerationAllSorted(1)(2)), "D", "E");
            end
            if KD_DerivativeXmlElement ~= [] then
                KD_DerivativeXmlElement.content = strsubst(string(pidGenerationAllSorted(1)(3)), "D", "E");
            end
            
            
            //add or change xml element with the first 10 PID values and the corresponding objective function values in autopilot adjustable component
            FirstTenPIDGenerationAllSortedString = [ emptystr() ];
            for i = 1 : 1 : length(pidGenerationAllSorted)
                FirstTenPIDGenerationAllSortedString(size(FirstTenPIDGenerationAllSortedString, 1) + 1) = ascii(9) + ascii(9) + "[" + strcat(string(pidGenerationAllSorted(i)), ", ") + "] " + ascii(9) + ascii(9) + ascii(9) + ascii(9) + string(pidGenerationAllSortedObjective(i));
                if i >= 10 then
                    break;
                end
            end
            FirstTenPIDGenerationAllSortedString(size(FirstTenPIDGenerationAllSortedString, 1) + 1) = emptystr();
            //find and get (or create) GA_pid_values_with_objective xml element
            GApidValuesWithObjectiveXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "GA_pid_values_with_objective");
            GApidValuesWithObjectiveXmlElement.content = FirstTenPIDGenerationAllSortedString;
            
            
            
        //otherwise, set the original values from backup
        else
            
            KP_GainXmlElement.content = gainBackup;
            if KI_IntegralXmlElement ~= [] then
                KI_IntegralXmlElement.content = integralBackup;
            end
            if KD_DerivativeXmlElement ~= [] then
                KD_DerivativeXmlElement.content = derivativeBackup;
            end
            
            messagebox([ "No results of PID adjustment were found! The original controller adjustment will be saved in autopilot xml file!" ; "Completely Performed Iterations = " + string(iterationNumber-1) ], "modal", "warning");
            
        end
        
        //save autopilot xml file to the system folder inside the aircraft folder
        SaveXMLFileIntoFilePath(xmlAutopilot, xmlAutopilotFilePathInSystemInAircraft, "Autopilot (with results in Systems folder)");    //wasSavedAutopilotInSystemFolderInAircraftFolder = 
//        if wasSavedAutopilotInSystemFolderInAircraftFolder == %f then
//            return;
//        end
        
        
        
        
        
    //otherwise there is error or unsupported method for controller adjustment
    else
        
        //show error message and end function
        messagebox("outputAnalysisMethPopupmenuValue (converted string value from output_analysis) is not supported """ + string(outputAnalysisMethPopupmenuValue) + """! (ControllerAdjustmentSimulationExecuteJSBSim function)", "modal", "error");
        return;
        
    end
    
    
    
endfunction








//<>debug only - just manual example delete it
function ExampleJSBSimRunNo2()
    
    [CSVHeader, CSVvalues] = ReadAndEvalCSVfile("L410.csv");
    [CSVHeader, CSVvalues] = ReadAndEvalCSVfile("L410_edited.csv");
    //process the output csv file and show figure with plots
    
    //(<>Scilab bug - noted because of scrollbar bug)
//    global GraphWidth;
//    global GraphHeight;
    
    numberOfGraphsInLineNumber = 4;
    numberOfGraphsInWindow = 8;
    
    //calculate number of windows - which depends on number of columns
    numberOfGraphsAll = size(CSVvalues, 2) - 1;
    numberOfWindows = ceil(numberOfGraphsAll / numberOfGraphsInWindow);
    //create and show all figures with a specific number of graphs in one window and with a specific number of graphs in one line
    for i = 1 : 1 : numberOfWindows
        
        //calculate start and end index for graphs' separation
        startIndex = (i - 1) * numberOfGraphsInWindow + 2;  //the first column is ignored because it contains the time data
        endIndex = numberOfGraphsAll + 1;
        if i ~= numberOfWindows then
            endIndex = i * numberOfGraphsInWindow + 1;
        end
        
        //separate CSV values and CSV headers to parts depending on numberOfGraphsInWindow
        partCSVHeader = cat(2, CSVHeader(:, 1), CSVHeader(:, startIndex:endIndex));
        partCSVvalues = cat(2, CSVvalues(:, 1), CSVvalues(:, startIndex:endIndex));
        
        figureWith2DPlots = CreateAndShowFigureWithJSBsimResultsIn2DPlots(partCSVHeader, partCSVvalues, 0, %inf, numberOfGraphsInLineNumber);//, GraphWidth, GraphHeight);  //(<>Scilab bug - noted because of scrollbar bug)
        
    end
    
endfunction



//<>debug only - just manual example delete it
function ExampleJSBSimRunNo1()
    
    
    JSBSimOrFlightGearExecution("""JSBSim"" --script=""scripts" + filesep() + "V-TS v1-532_takeoff.xml""");
    [CSVHeader,CSVvalues] = ReadAndEvalCSVfile("V-TS v1-532.csv");
    
    column=107;
    plot2d(CSVvalues(:,1),CSVvalues(:,column));
    xlabel("t [s]", "fontsize", 4);
    ylabel(CSVHeader(1,column), "fontsize", 4, "color", "black");
    
    //CSVvaluesMinus = CSVvalues(:,1) - 150;  //for decrease of time values (minus 150 seconds)
    //plot2d(CSVvaluesMinus(1502:3500,1),CSVvalues(1502:3500,column));
    
    a=gca(); // Handle on axes entity
    poly1= a.children(1).children(1); //store polyline handle into poly1
    poly1.thickness = 3;  // ...and the tickness of a curve.
    leg.font_style = 9;
    
    b=get("current_axes");  //get the handle of the newly created axes
    b.labels_font_size=3;  //set the font size of value labels
    
    
    
    
    //puvodni pred editaci JSBSim
    //JSBSimExecution("""JSBSim"" --script=""scripts" + filesep() + "V-TS v1-532_PID_1,0,0.xml""")
    //[CSVHeader,CSVvalues] = ReadAndEvalCSVfile("V-TS v1-532.csv")
    //
    //column=107;
    ////plot2d(CSVvalues(:,1),CSVvalues(:,column));
    //xlabel("t [s]", "fontsize", 4);
    //ylabel(CSVHeader(1,column), "fontsize", 4, "color", "black");
    //
    //CSVvaluesMinus = CSVvalues(:,1) - 150;  //for decrease of time values (minus 150 seconds)
    //plot2d(CSVvaluesMinus(1502:3500,1),CSVvalues(1502:3500,column));
    //
    //a=gca(); // Handle on axes entity
    //poly1= a.children(1).children(1); //store polyline handle into poly1
    //poly1.thickness = 3;  // ...and the tickness of a curve.
    //leg.font_style = 9;
    //
    //b=get("current_axes");  //get the handle of the newly created axes
    //b.labels_font_size=3;  //set the font size of value labels
    //
    
    
endfunction


