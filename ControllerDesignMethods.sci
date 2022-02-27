//exec XMLfunctions.sci
//exec XMLSimulation.sci
//exec TXTfunctions.sci
//exec DialogsFunctions.sci;
//exec peak_detect.sci;



//Controller Adjustment Definition XML file

global controlDesignFolderName;
controlDesignFolderName = "control_design";
global controllerAdjustmentDefinitionNameDefault;
controllerAdjustmentDefinitionNameDefault = "controller_adjustment_definition";
global controllerAdjustmentProgressionFolderName;
controllerAdjustmentProgressionFolderName = "controller_adjustment_progression";

function [xmlControllerAdjustmentDefinitionDoc]=EncodeControllerAdjustmentDefinitionXMLFromListsString(inputControllerAdjustmentDefinitionListString, inXmlSimulationFileName, inXmlAutopilotFileName, propertiesAvailable)
    
    xmlControllerAdjustmentDefinitionDoc = [];
    
    zieglerNichols_CriticalGainTag = "ZIEGLER_NICHOLS-CRITICAL_GAIN";
    geneticAlgorithmTag = "GENETIC_ALGORITHM";
    if (inputControllerAdjustmentDefinitionListString ~= [] | inputControllerAdjustmentDefinitionListString ~= list()) then
        
        sizeNeededInputControllerAdjustmentDefinitionListString = 12;
        if length(inputControllerAdjustmentDefinitionListString) == sizeNeededInputControllerAdjustmentDefinitionListString then
            
            xmlControllerAdjustmentDefinitionDoc = xmlRead("templates" + filesep() + "Control_Design_withoutAttributes" + filesep() + "control_design_start_template.xml");
            errorString=ValidateXMLdocument(xmlControllerAdjustmentDefinitionDoc);
            
            //if the root name element of xml template controller adjustment definition file is "control_design_start", it is valid template controller adjustment definition file
            if xmlControllerAdjustmentDefinitionDoc.root.name == "control_design_start" then
                
                
                
                //find and get (or create) description xml element
                descriptionXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "description");
                if inputControllerAdjustmentDefinitionListString(1) ~= [] then
                    descriptionXMLElement.content = inputControllerAdjustmentDefinitionListString(1);
                else
                    descriptionXMLElement.content = emptystr();
                end
                
                
                
                //find and get (or create) script xml element
                scriptXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "script");
                if inXmlSimulationFileName ~= [] & inXmlSimulationFileName ~= emptystr() then
                    scriptXMLElement.content = inXmlSimulationFileName;
                else
                    messagebox("Filename of simulation definition (script) is empty!", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                
                
                
                //find and get (or create) autopilot xml element
                autopilotXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "autopilot");
                if inXmlAutopilotFileName ~= [] & inXmlAutopilotFileName ~= emptystr() then
                    autopilotXMLElement.content = inXmlAutopilotFileName;
                else
                    messagebox("Filename of control system definition (autopilot) is empty!", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                
                
                
                //find and get (or create) autopilot_adjustable_component xml element
                autopilotAdjustableComponentXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "autopilot_adjustable_component");
                if inputControllerAdjustmentDefinitionListString(4) ~= [] then
                    
                    //if the input is xml element and the JSBSim type is supported, append the xml element
                    if typeof(inputControllerAdjustmentDefinitionListString(4)) == "XMLElem" & (inputControllerAdjustmentDefinitionListString(4).name == "pid" | inputControllerAdjustmentDefinitionListString(4).name == "pure_gain") then
                        
                        //if everything with the xml is OK, append it to the xml autopilot adjustable component
                        xmlAppend(autopilotAdjustableComponentXMLElement, inputControllerAdjustmentDefinitionListString(4));
                        
                    //otherwise show error and end function
                    else
                        messagebox("Selected autopilot adjustable component with name: """ + inputControllerAdjustmentDefinitionListString(4).attributes.name + """ and JSBSim type: " + inputControllerAdjustmentDefinitionListString(4).name + """ is not supported type of component; only ""pid"", and ""pure_gain"" types are supported!", "modal", "error");
                        CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                        xmlControllerAdjustmentDefinitionDoc = [];
                        return;
                    end
                    
                else
                    messagebox("Autopilot adjustable component was not set!", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                
                
                
                //find and get (or create) output xml element
                outputXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "output");
                
                //set attributes of output xml element
                
                //set CSV as format of output file
                outputXMLElement.attributes.type = "CSV";
                
                //check if output filename does not contain forbidden chars
                outputNameTextStringTemp = strsubst(inputControllerAdjustmentDefinitionListString(5), " ", "");
                if strindex(outputNameTextStringTemp, ['\', '/', ':', '*', '?', '""', '<', '>', '|']) ~= [] then
                    messagebox("Output Name: The filename of output is not valid! (it contains at least one forbidden char: ''\'', ''/'', '':'', ''*'', ''?'', ''""'', ''<'', ''>'', ''|'' )", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                elseif outputNameTextStringTemp == emptystr() then
                    messagebox("Output Name: The filename of output is empty!", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                //set filename of output CSV file
                extensionCSV = GetExtensionForFileIfNecessary(inputControllerAdjustmentDefinitionListString(5), ".csv");
                outputXMLElement.attributes.name = inputControllerAdjustmentDefinitionListString(5) + extensionCSV;
                
                //check if rate is number and set it or set default
                isNumberRate = isnum(inputControllerAdjustmentDefinitionListString(6));
                if isNumberRate then
                    outputXMLElement.attributes.rate = strsubst(inputControllerAdjustmentDefinitionListString(6), " ", "");
                else
                    outputXMLElement.attributes.rate = "30";
                end
                
                //check if output property is in properties available database
                propertyOutputTextStringWithoutSpaces = strsubst(inputControllerAdjustmentDefinitionListString(7), " ", "");
                propertyOutputFound = FindPropertyInPropertiesAvailable(propertyOutputTextStringWithoutSpaces, propertiesAvailable);
                if propertyOutputFound == %f then
                    messagebox("Output Property: Property """ + propertyOutputTextStringWithoutSpaces + """ does not exist in propertiesAvailable database!", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                //find and get (or create) property xml element in output xml element
                propertyOutputXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, outputXMLElement, "property");
                propertyOutputXMLElement.content = inputControllerAdjustmentDefinitionListString(7);
                
                
                
                outputAnalysisMethodPopupmenuValue = 1;
                //find and get (or create) output_analysis xml element
                outputAnalysisXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "output_analysis");
                if inputControllerAdjustmentDefinitionListString(10) ~= [] then
                    outputAnalysisMethod = strsubst(inputControllerAdjustmentDefinitionListString(10), " ", "");
                    //if genetic algorithm was selected, copy it
                    if convstr(outputAnalysisMethod, "u") == geneticAlgorithmTag then
                        outputAnalysisXMLElement.content = geneticAlgorithmTag;
                        outputAnalysisMethodPopupmenuValue = 2;
                    else
                        //otherwise set ziegler nichols method of critical parameters as the default analysis method
                        outputAnalysisXMLElement.content = zieglerNichols_CriticalGainTag;
                    end
                else
                    //otherwise set ziegler nichols method of critical parameters as the default analysis method
                    outputAnalysisXMLElement.content = zieglerNichols_CriticalGainTag;
                end
                
                //set attributes of output analysis xml element
                isNumberTimeStart = isnum(inputControllerAdjustmentDefinitionListString(8));
                if isNumberTimeStart then
                    outputAnalysisXMLElement.attributes.time_start = inputControllerAdjustmentDefinitionListString(8);
                else
                    outputAnalysisXMLElement.attributes.time_start = "0";
                end
                isNumberTimeEnd = isnum(inputControllerAdjustmentDefinitionListString(9));
                if isNumberTimeEnd then
                    outputAnalysisXMLElement.attributes.time_end = inputControllerAdjustmentDefinitionListString(9);
                else
                    outputAnalysisXMLElement.attributes.time_end = "%inf";
                end
                
                
                
                //if xml method parameters is empty or is not xml element type
                if inputControllerAdjustmentDefinitionListString(11) == [] | typeof(inputControllerAdjustmentDefinitionListString(11)) ~= "XMLElem" then
                    messagebox("Method Parameters error: input element is empty or is not XMLElem type.", "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                
                //decode method parameters xml element and create labels and values
                [labelsXmlMethodParameters, valuesXmlMethodParameters] = DecodeXmlMethodParameters(inputControllerAdjustmentDefinitionListString(11), outputAnalysisMethodPopupmenuValue);
                //check all options in method parameters xml element depending on selected controller adjustment method
                [isCorrectXmlMethodParameters, errorMessageXmlMethodParameters] = CheckCorrectXmlMethodParameters(valuesXmlMethodParameters, outputAnalysisMethodPopupmenuValue, labelsXmlMethodParameters);
                if isCorrectXmlMethodParameters == %f then
                    messagebox("Method Parameters error: " + errorMessageXmlMethodParameters, "modal", "error");
                    CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                    xmlControllerAdjustmentDefinitionDoc = [];
                    return;
                end
                
                //find and get (or create) method_parameters xml element
                xmlMethodParametersIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinitionDoc.root, "method_parameters");
                if xmlMethodParametersIndexArray ~= [] then
                    xmlControllerAdjustmentDefinitionDoc.root.children(xmlMethodParametersIndexArray(1)) = inputControllerAdjustmentDefinitionListString(11);
                else
                    //add new element (with a specific name)
                    newXMLelement = xmlElement(xmlControllerAdjustmentDefinitionDoc, "method_parameters");
                    xmlAppend(xmlControllerAdjustmentDefinitionDoc.root, newXMLelement);
                    xmlControllerAdjustmentDefinitionDoc.root.children(length(xmlControllerAdjustmentDefinitionDoc.root.children)) = inputControllerAdjustmentDefinitionListString(11);
                end
                
                
                
                //find and get (or create) jsbsim_command_options xml element
//                scriptCommandBasic = "--script=" + """" + "scripts" + filesep() + scriptXMLElement.content + """";
                jsbsimCommandOptionsXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlControllerAdjustmentDefinitionDoc, xmlControllerAdjustmentDefinitionDoc.root, "jsbsim_command_options");
                if inputControllerAdjustmentDefinitionListString(12) ~= [] then
//                    inputSimulationStartListString(12)(size(inputSimulationStartListString(12), 1) + 1) = scriptCommandBasic;
                    jsbsimCommandOptionsXMLElement.content = inputControllerAdjustmentDefinitionListString(12);
//                else
//                    jsbsimCommandOptionsXMLElement.content = scriptCommandBasic;
                end
                
                
                
            else
                messagebox("Wrong format! The template XML file is not a valid controller adjustment definition file (check templates" + filesep() + "Control_Design_withoutAttributes" + filesep() + "control_design_start_template.xml)!", "modal", "error");
                CheckAndDeleteXMLDoc(xmlControllerAdjustmentDefinitionDoc);
                xmlControllerAdjustmentDefinitionDoc = [];
                return;
            end
            
        else
            messagebox("inputControllerAdjustmentDefinitionListString does not have necessary number of elements (" + string(sizeNeededInputControllerAdjustmentDefinitionListString) + ") but " + string(length(inputControllerAdjustmentDefinitionListString)) + "!", "modal", "error");
        end
        
    else
        messagebox("inputControllerAdjustmentDefinitionListString is empty list!", "modal", "error");
    end
    
    
endfunction



function [outControllerAdjustmentDefinitionListString]=DecodeControllerAdjustmentDefinitionXMLToListsString(xmlControllerAdjustmentDefinitionDoc)
    
    outControllerAdjustmentDefinitionListString = list();
    
    
    //if it is valid xml object
    if xmlControllerAdjustmentDefinitionDoc ~= [] & typeof(xmlControllerAdjustmentDefinitionDoc) == "XMLDoc" & xmlIsValidObject(xmlControllerAdjustmentDefinitionDoc) == %t then
        
        //if the root name element of xml controller adjustment definition file is "control_design_start", it is valid controller adjustment definition file
        if xmlControllerAdjustmentDefinitionDoc.root.name == "control_design_start" then
            
            
            
            //get (or get default) content of description xml element
            xmlDescriptionContentArray = GetXMLContentOrDefault(xmlControllerAdjustmentDefinitionDoc.root, "description", emptystr());
            outControllerAdjustmentDefinitionListString($+1) = xmlDescriptionContentArray;
            
            
            
            //global scriptsFolderName;
            //get (or get default) content of script xml element
            xmlScriptContent = GetXMLContentOrDefault(xmlControllerAdjustmentDefinitionDoc.root, "script", emptystr());   //pwd() + filesep() + scriptsFolderName + filesep());
            outControllerAdjustmentDefinitionListString($+1) = xmlScriptContent;
            
            
            
            //global systemsFolderName;
            //get (or get default) content of autopilot xml element
            xmlAutopilotContent = GetXMLContentOrDefault(xmlControllerAdjustmentDefinitionDoc.root, "autopilot", emptystr()); //pwd() + filesep() + systemsFolderName + filesep());
            outControllerAdjustmentDefinitionListString($+1) = xmlAutopilotContent;
            
            
            
            //get autopilot_adjustable_component
            xmlAutopilotAdjustableComponent = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinitionDoc.root, "autopilot_adjustable_component");
            outControllerAdjustmentDefinitionListString($+1) = xmlAutopilotAdjustableComponent;
            
            
            
            //get output xml element and add each attribute or default
            defaultOutput = list("output_Simulation-Controller_Adjustment.csv", "30", emptystr());
            
            outputXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinitionDoc.root, "output");
            if outputXMLElement ~= [] then
                
                if outputXMLElement.attributes.name ~= [] then
                    outControllerAdjustmentDefinitionListString($+1) = outputXMLElement.attributes.name;
                else
                    outControllerAdjustmentDefinitionListString($+1) = defaultOutput(1);
                end
                
                if outputXMLElement.attributes.rate ~= [] then
                    outControllerAdjustmentDefinitionListString($+1) = outputXMLElement.attributes.rate;
                else
                    outControllerAdjustmentDefinitionListString($+1) = defaultOutput(2);
                end
                
                //get first property xml element in output xml element
                xmlOutputProperty = FindFirstXMLElementInFirstChildrenOfXMLElement(outputXMLElement, "property");
                //get content of the property (i.e. the property name)
                if xmlOutputProperty ~= [] then
                    outputPropertyName = strsubst(xmlOutputProperty.content, " ", "");
                else
                    outputPropertyName = defaultOutput(3);
                end
                outControllerAdjustmentDefinitionListString($+1) = outputPropertyName;
                
            else
                
                outControllerAdjustmentDefinitionListString($+1) = defaultOutput(1);
                outControllerAdjustmentDefinitionListString($+1) = defaultOutput(2);
                outControllerAdjustmentDefinitionListString($+1) = defaultOutput(3);
                
            end
            
            
            
            //get output_analysis xml element and add each attribute or default
            defaultOutputAnalysis = list("0", "%inf", "ZIEGLER_NICHOLS-CRITICAL_GAIN");
            outputAnalysisXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinitionDoc.root, "output_analysis");
            if outputAnalysisXMLElement ~= [] then
                
                if outputAnalysisXMLElement.attributes.time_start ~= [] then
                    outControllerAdjustmentDefinitionListString($+1) = outputAnalysisXMLElement.attributes.time_start;
                else
                    outControllerAdjustmentDefinitionListString($+1) = defaultOutputAnalysis(1);
                end
                
                if outputAnalysisXMLElement.attributes.time_end ~= [] then
                    outControllerAdjustmentDefinitionListString($+1) = outputAnalysisXMLElement.attributes.time_end;
                else
                    outControllerAdjustmentDefinitionListString($+1) = defaultOutputAnalysis(2);
                end
                
                //add the content as the last
                outControllerAdjustmentDefinitionListString($+1) = strsubst(outputAnalysisXMLElement.content, " ", "");
                
            else
                
                outControllerAdjustmentDefinitionListString($+1) = defaultOutputAnalysis(1);
                outControllerAdjustmentDefinitionListString($+1) = defaultOutputAnalysis(2);
                outControllerAdjustmentDefinitionListString($+1) = defaultOutputAnalysis(3);
                
            end
            
            
            
            //get method_parameters xml element
            xmlMethodParameters = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlControllerAdjustmentDefinitionDoc.root, "method_parameters");
            if xmlMethodParameters == [] | length(xmlMethodParameters.children) == 0 then
                xmlMethodParamsDoc = xmlRead("templates" + filesep() + "Control_Design_withoutAttributes" + filesep() + "method_parameters_with_defaults.xml");
                xmlMethodParameters = xmlMethodParamsDoc.root;
            end
            outControllerAdjustmentDefinitionListString($+1) = xmlMethodParameters;
            
            
            
            
            //get (or get default) content of jsbsim_command_options xml element
            xmlJsbsiCommandOptionsContentArray = GetXMLContentOrDefault(xmlControllerAdjustmentDefinitionDoc.root, "jsbsim_command_options", emptystr());
            outControllerAdjustmentDefinitionListString($+1) = xmlJsbsiCommandOptionsContentArray;
            
            
            
        else
            messagebox("xmlControllerAdjustmentDefinitionDoc is in wrong format! The XML is not a valid controller adjustment definition file!", "modal", "error");
        end
        
    else
        messagebox("xmlControllerAdjustmentDefinitionDoc is not valid xml doc object or it is null!", "modal", "error");
    end
    
    
endfunction




function [outXmlMethodParametersElement]=EncodeXmlMethodParameters(labels, values, inXmlControllerAdjustmentDefinition, inXmlMethodParametersElement, selectedOutputAnalysisMethodPopupmenuValue)
    
    outXmlMethodParametersElement = inXmlMethodParametersElement;
    
    zieglerNichols_CriticalGainTag = "ZIEGLER_NICHOLS-CRITICAL_GAIN";
    geneticAlgorithmTag = "GENETIC_ALGORITHM";
    
    selectedOutputAnalysisMethodString = zieglerNichols_CriticalGainTag;
    if selectedOutputAnalysisMethodPopupmenuValue == 2 then
        selectedOutputAnalysisMethodString = geneticAlgorithmTag;
    elseif  selectedOutputAnalysisMethodPopupmenuValue ~= 1 then
        messagebox("Unsupported method for controller adjustment was selected! No change was made in xml method parameters. (selectedOutputAnalysisMethodPopupmenuValue = " + string(selectedOutputAnalysisMethodPopupmenuValue) + ")", "modal", "error");
        return;
    end
    
    
    //find the specific method parameters in encoded xml element if any
    xmlMethodParametersSpecific = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(inXmlControllerAdjustmentDefinition, outXmlMethodParametersElement, convstr(selectedOutputAnalysisMethodString, "l"));
    outXmlMethodParametersDoc = [];
    //if there is no specific method parameters (ZN or GA), add it
    if xmlMethodParametersSpecific == [] then
        outXmlMethodParametersDoc = xmlReadStr(xmlDump(outXmlMethodParametersElement));
        xmlMethodParametersSubElement = xmlElement(outXmlMethodParametersDoc, convstr(selectedOutputAnalysisMethodString, "l"));
        xmlAppend(outXmlMethodParametersDoc.root, xmlMethodParametersSubElement);
        outXmlMethodParametersElement = outXmlMethodParametersDoc.root;
        xmlMethodParametersSpecific = outXmlMethodParametersElement.children(length(outXmlMethodParametersElement.children));
    end
    
    
//    if xmlMethodParametersSpecific ~= [] then
//        
        //check values of parameters depending on selected controller adjustment method
        [isCorrect, errorMessage] = CheckCorrectXmlMethodParameters(values, selectedOutputAnalysisMethodPopupmenuValue, labels);
        if isCorrect == %f then
            messagebox(errorMessage, "modal", "error");
            continue;
        end
        
        for i = 1 : 1 : size(labels, 2)
            
            xmlMethodParameter = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(inXmlControllerAdjustmentDefinition, xmlMethodParametersSpecific, labels(i));
            if xmlMethodParameter == [] then
                
                //if xml doc doesn't exist, create a copy based on method parameters xml element
                if outXmlMethodParametersDoc == [] then
                    outXmlMethodParametersDoc = xmlReadStr(xmlDump(outXmlMethodParametersElement));
                    outXmlMethodParametersElement = outXmlMethodParametersDoc.root;
                end
                
                //add xml element to xml method parameters
                xmlMethodParametersSubElement = xmlElement(outXmlMethodParametersDoc, labels(i));
                xmlAppend(outXmlMethodParametersElement, xmlMethodParametersSubElement);
                xmlMethodParameter = outXmlMethodParametersElement.children(length(outXmlMethodParametersElement.children));
                
//                messagebox("The specific method parameter was not found in xml element! parameter name: """ + labels(i) + """", "modal", "error");
//                return;
                
            end
            
            xmlMethodParameter.content = values(i);
            
        end
//        
//    else
//        messagebox("The main xml element of the specific method parameters were not found in xml element! selectedOutputAnalysisMethodString = """ + selectedOutputAnalysisMethodString + """", "modal", "error");
//    end
    
    
endfunction



function [labels, values]=DecodeXmlMethodParameters(inXmlMethodParametersElement, selectedOutputAnalysisMethodPopupmenuValue)
    
    
    labels = [];
    values = [];
    xmlMethodParametersDoc = xmlRead("templates" + filesep() + "Control_Design_withoutAttributes" + filesep() + "method_parameters_with_defaults.xml");
    
    zieglerNichols_CriticalGainTag = "ZIEGLER_NICHOLS-CRITICAL_GAIN";
    geneticAlgorithmTag = "GENETIC_ALGORITHM";
    
    //get selected output analysis method name
    selectedOutputAnalysisMethodString = zieglerNichols_CriticalGainTag;
    if selectedOutputAnalysisMethodPopupmenuValue == 2 then
        selectedOutputAnalysisMethodString = geneticAlgorithmTag;
    elseif  selectedOutputAnalysisMethodPopupmenuValue ~= 1 then
        disp(["Warning! Unsupported method for controller adjustment was selected! The ZIEGLER_NICHOLS-CRITICAL_GAIN was used instead. (selectedOutputAnalysisMethodPopupmenuValue = " + string(selectedOutputAnalysisMethodPopupmenuValue) + ")" ; ]) 
    end
    
    
    //find the specific method parameters in decoded xml element if any
    inXmlMethodParametersSpecificElement = FindFirstXMLElementInFirstChildrenOfXMLElement(inXmlMethodParametersElement, convstr(selectedOutputAnalysisMethodString, "l"));
    if inXmlMethodParametersSpecificElement ~= [] then
        
        //go through the specific method parameters
        for j = 1 : 1 : length(inXmlMethodParametersSpecificElement.children)
            
            xmlSubElementName = inXmlMethodParametersSpecificElement.children(j).name;
            if xmlSubElementName ~= "comment" & xmlSubElementName ~= "documentation" & xmlSubElementName ~= "description" & xmlSubElementName ~= "text" then
                
                //disp("1. " + inXmlMethodParametersSpecificElement.children(j).name);   //<>debug only
                //add string to value string array
                values(1, size(values, 2) + 1) = inXmlMethodParametersSpecificElement.children(j).content;
                //add information about input to label
                labels(1, size(labels, 2) + 1) = xmlSubElementName;
                
            end
            
        end
        
    end
    
    
    
    //join the template and the decoded xml element to labels and values
    //find the specific method parameters in template xml element if any
    methodParametersXmlElementTemplate = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlMethodParametersDoc.root, convstr(selectedOutputAnalysisMethodString, "l"));
    if methodParametersXmlElementTemplate ~= [] then
        
        //go through the specific method parameters in template
        for j = 1 : 1 : length(methodParametersXmlElementTemplate.children)
            
            xmlSubElementName = methodParametersXmlElementTemplate.children(j).name;
            decodedMethodParametersSpecificFound = [];
            if inXmlMethodParametersSpecificElement ~= [] then
                decodedMethodParametersSpecificFound = FindXMLElementIndexesInFirstChildrenOfXMLElement(inXmlMethodParametersSpecificElement, xmlSubElementName);
            end
            
            if xmlSubElementName ~= "comment" & xmlSubElementName ~= "documentation" & xmlSubElementName ~= "description" & xmlSubElementName ~= "text"  &  decodedMethodParametersSpecificFound == [] then
                
                //disp("2. " + methodParametersXmlElementTemplate.children(j).name);  //<>debug only
                //add string to value string array
                values(1, size(values, 2) + 1) = methodParametersXmlElementTemplate.children(j).content;
                //add information about input to label
                labels(1, size(labels, 2) + 1) = xmlSubElementName;
                
            end
            
        end
        
    end
    
    
endfunction



function [isCorrect, errorMessage]=CheckCorrectXmlMethodParameters(values, outputAnalysisMethodPopupmenuValue, labels)
    
    isCorrect = %f;
    errorMessage = emptystr();
    errorMessageSeparator = "  ;  ";
    errorMessageSeparActive = emptystr();
    infiniteString = "%inf";
    
    
    if outputAnalysisMethodPopupmenuValue == 1 then
        
        
        isCorrectArray = [];
        //check every value which must be numbers
        for i = 1 : 1 : size(values, 2)
            
            isCorrectArray(size(isCorrectArray, 1) + 1) = CheckCorrectValuesType(values(i), "number", [], %f, %f);
            
            //check specific parameters if it IS a number
            if isCorrectArray(size(isCorrectArray, 1)) == %t then
                
                if labels(i) == "iteration_maximum" then
                    
                    //check if iteration_maximum is equal to infinite
                    [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                    //check if iteration_maximum is higher than 0 
                    [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 0);
                    if egualToInf == %f & higherThanZero == %f then
                        
                        //set the last isCorrect to false
                        isCorrectArray(size(isCorrectArray, 1)) = %f;
                        
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "ZIEGLER_NICHOLS-CRITICAL_GAIN method parameter: iteration_maximum must be number higher than 0 or equal to infinite (%inf)!";
                        errorMessageSeparActive = errorMessageSeparator;
                        
                    end
                    
                    
                elseif labels(i) == "gain_change_iteration" then
                    
                    //check if gain_change_iteration is equal to 0 
                    [isNumber, equalToZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, 0);
                    //check if gain_change_iteration is equal to infinite
                    [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                    //check if gain_change_iteration is equal to minus infinite
                    [isNumber, egualToMinusInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, -%inf);
                    if equalToZero == %t | egualToInf == %t | egualToMinusInf == %t then
                        
                        //set the last isCorrect to false
                        isCorrectArray(size(isCorrectArray, 1)) = %f;
                        
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "ZIEGLER_NICHOLS-CRITICAL_GAIN method parameter: gain_change_iteration must be number which is NOT equal to 0, %inf or -%inf!";
                        errorMessageSeparActive = errorMessageSeparator;
                        
                    end
                    
                    
                elseif labels(i) == "gain_constraint" then
                    
                    //check if gain_constraint is not equal to 0 
                    [isNumber, equalToZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, 0);
                    if equalToZero == %t then
                        
                        //set the last isCorrect to false
                        isCorrectArray(size(isCorrectArray, 1)) = %f;
                        
                        //if numbers are not correct set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "ZIEGLER_NICHOLS-CRITICAL_GAIN method parameter: gain_constraint must be number which is NOT equal to 0!";
                        errorMessageSeparActive = errorMessageSeparator;
                    end
                    
                    
                elseif labels(i) == "tolerance_amplitude" then
                    
                    //check if tolerance_amplitude is higher than 0
                    [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 0);
                    //check if tolerance_amplitude is higher than 1
                    [isNumber, higherThanOne, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 1);
                    if higherThanZero == %f | higherThanOne == %t then
                        
                        //set the last isCorrect to false
                        isCorrectArray(size(isCorrectArray, 1)) = %f;
                        
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "ZIEGLER_NICHOLS-CRITICAL_GAIN method parameter: tolerance_amplitude must be number higher than 0 and lower than or equal to 1!";
                        errorMessageSeparActive = errorMessageSeparator;
                        
                    end
                    
                    
//                elseif labels(i) == "tolerance_period" then
//                    
//                    //check if tolerance_period is higher than 0
//                    [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 0);
//                    //check if tolerance_period is higher than 1
//                    [isNumber, higherThanOne, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 1);
//                    if higherThanZero == %f | higherThanOne == %t then
//                        
//                        //set the last isCorrect to false
//                        isCorrectArray(size(isCorrectArray, 1)) = %f;
//                        
//                        //set error message
//                        errorMessage = errorMessage + errorMessageSeparActive + "ZIEGLER_NICHOLS-CRITICAL_GAIN method parameter: tolerance_period must be number higher than 0 and lower than or equal to 1!";
//                        errorMessageSeparActive = errorMessageSeparator;
//                        
//                    end
                    
                    
                end
                
            end
            
        end
        
        
        //if there is an error message, end the function
        if errorMessage ~= emptystr() then
            errorMessage = "All parameters for ZIEGLER_NICHOLS-CRITICAL_GAIN method has to be numbers!" + errorMessageSeparActive + errorMessage;
            isCorrect = %f;
            return;
        end
        
        //get complete result of checking
        isCorrect = and(isCorrectArray);
        if isCorrect == %f then
            //if numbers are not correct return error message
            errorMessage = "All parameters for ZIEGLER_NICHOLS-CRITICAL_GAIN method has to be numbers!";
            return;
        end
        
        
        
        
    elseif outputAnalysisMethodPopupmenuValue == 2 then
        
        
        isCorrectArray = [];
        //check every value which must be numbers
        for i = 1 : 1 : size(values, 2)
            
            
            if labels(i) == "pid_generation_initial" then
                
                
                isCorrectArray(size(isCorrectArray, 1) + 1) = %f;
                
                //convert string matrix from xml content to equivalent scilab matrix, or show error if failed
                try
                    valueMatrix = evstr(values(i));
                    if typeof(valueMatrix) ~= "constant" | size(valueMatrix, 2) ~= 3 then
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: pid_generation_initial - converted pid_generation_initial is not n×3-matrix of decimal numbers!" + " pid_generation_initial: " + values(i);
                        errorMessageSeparActive = errorMessageSeparator;
                    else
                        NANINFfound = %f;
                        for x = 1 : 1 : size(valueMatrix, 1)
                            for y = 1 : 1 : size(valueMatrix, 2)
                                if isinf(valueMatrix(x, y)) | isnan(valueMatrix(x, y)) then
                                    NANINFfound = %t;
                                    break;
                                end
                            end
                            if NANINFfound == %t then
                                //set error message
                                errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: pid_generation_initial - converted pid_generation_initial contains not-a-number values or infinite!" + " pid_generation_initial: " + values(i);
                                errorMessageSeparActive = errorMessageSeparator;
                                break;
                            end
                        end
                        if NANINFfound == %f then
                            //set the last isCorrect to true
                            isCorrectArray(size(isCorrectArray, 1)) = %t;
                        end
                    end
                catch
                    [error_message, error_number] = lasterror(%t);
                    //set error message
                    errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: pid_generation_initial - conversion failed!" + " error_message: " + error_message + " error_number: " + string(error_number) + " pid_generation_initial: " + values(i);
                    errorMessageSeparActive = errorMessageSeparator;
                end
                
                
                
            elseif labels(i) == "minimum_Kp_Ki_Kd" | labels(i) == "maximum_Kp_Ki_Kd" then
                
                
                isCorrectArray(size(isCorrectArray, 1) + 1) = %f;
                
                //convert string array from xml content to equivalent scilab array, or show error if failed
                try
                    valueArray = evstr(convstr(values(i), 'l'));
                    if typeof(valueArray) ~= "constant" | size(valueArray, 1) ~= 1 | size(valueArray, 2) ~= 3 then
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: Converted " + labels(i) + " is not 1×3-matrix of decimal numbers!" + " " + labels(i) + ": " + values(i);
                        errorMessageSeparActive = errorMessageSeparator;
                    else
                        NANfound = %f;
                        for x = 1 : 1 : size(valueArray, 2)
                            if isnan(valueArray(x)) then
                                NANfound = %t;
                                break;
                            end
                        end
                        if NANfound == %t then
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: Converted " + labels(i) + " contains not-a-number values!" + " " + labels(i) + ": " + values(i);
                            errorMessageSeparActive = errorMessageSeparator;
                        else
                            //set the last isCorrect to true
                            isCorrectArray(size(isCorrectArray, 1)) = %t;
                        end
                    end
                catch
                    [error_message, error_number] = lasterror(%t);
                    //set error message
                    errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: " + labels(i) + " - conversion failed!" + " error_message: " + error_message + " error_number: " + string(error_number) + " " + labels(i) + ": " + values(i);
                    errorMessageSeparActive = errorMessageSeparator;
                end
                
                
                
            elseif labels(i) == "selection_pairs_mode" then
                
                global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
                global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce;
                global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
                global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce;
                global GA_CreatePairs_SelectionMode_TournamentPairs;
                global GA_CreatePairs_SelectionMode_RouletteWheelPairs
                global GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling;
                global GA_CreatePairs_SelectionMode_RandomPairs;
                isCorrectArray(size(isCorrectArray, 1) + 1) = %f;
                
                valueWithoutSpacesAndLower = convstr(strsubst(values(i), " ", ""), 'l');
                if valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_TournamentPairs, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_RouletteWheelPairs, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling, " ", ""), 'l')  |  valueWithoutSpacesAndLower == convstr(strsubst(GA_CreatePairs_SelectionMode_RandomPairs, " ", ""), 'l') then
                    //set the last isCorrect to true
                    isCorrectArray(size(isCorrectArray, 1)) = %t;
                else
                    //set error message
                    errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: " + labels(i) + " does not contain valid tag!" + " " + labels(i) + ": """ + values(i) + """. Valid tags are: """ + GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs + """, """ + GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce + """, """ + GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals + """, """ + GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce + """, """ + GA_CreatePairs_SelectionMode_TournamentPairs + """, """ + GA_CreatePairs_SelectionMode_RouletteWheelPairs + """, """ + GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling + """, and """ + GA_CreatePairs_SelectionMode_RandomPairs + """";
                    errorMessageSeparActive = errorMessageSeparator;
                end
                
                
                
            elseif labels(i) == "crossover_number_of_cuts_probability" | labels(i) == "mutation_number_of_mutated_bits_probability" then
                
                
                isCorrectArray(size(isCorrectArray, 1) + 1) = %f;
                
                //convert string array from xml content to equivalent scilab array, or show error if failed
                try
                    valueArray = evstr(convstr(values(i), 'l'));
                    if typeof(valueArray) ~= "constant" | size(valueArray, 1) ~= 1 then
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: Converted " + labels(i) + " is not 1×n-matrix of decimal numbers!" + " " + labels(i) + ": " + values(i);
                        errorMessageSeparActive = errorMessageSeparator;
                    else
                        completeProbability = 0;
                        for x = 1 : 1 : size(valueArray, 2)
                            completeProbability = completeProbability + valueArray(x);
                        end
                        //if the sum of the probabilities is not equal to 1, the probabilities are wrong (because some issues in Scilab, we must convert the numbers to string before comparison)
                        if string(completeProbability) ~= string(1) then
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: The sum of numbers in " + labels(i) + " is not equal to 1!" + " Sum of " + labels(i) + " numbers: " + string(completeProbability) + " " + labels(i) + ": " + values(i);
                            errorMessageSeparActive = errorMessageSeparator;
                        else
                            //set the last isCorrect to true
                            isCorrectArray(size(isCorrectArray, 1)) = %t;
                        end
                    end
                catch
                    [error_message, error_number] = lasterror(%t);
                    //set error message
                    errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: " + labels(i) + " - conversion failed!" + " error_message: " + error_message + " error_number: " + string(error_number) + " " + labels(i) + ": " + values(i);
                    errorMessageSeparActive = errorMessageSeparator;
                end
                
                
//                
//            elseif labels(i) == "pareto_filtr" then
//                
//                
//                isCorrectArray(size(isCorrectArray, 1) + 1) = %f;
//                
//                valueWithoutSpaces = strsubst(values(i), " ", "");
//                lowerValueWithoutSpaces = convstr(valueWithoutSpaces, 'l');
//                if lowerValueWithoutSpaces == "true" | lowerValueWithoutSpaces == "false" then
//                    isCorrectArray(size(isCorrectArray, 1)) = %t;
//                else
//                    //set error message
//                    errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: " + labels(i) + " must contain ""true"" or ""false"" string only!" + " " + labels(i) + ": " + values(i);
//                    errorMessageSeparActive = errorMessageSeparator;
//                end
                
                
                
            elseif labels(i) == "weights__outputerror_risetime_overshoot" then
                
                
                isCorrectArray(size(isCorrectArray, 1) + 1) = %f;
                
                //convert string array from xml content to equivalent scilab array, or show error if failed
                try
                    valueArray = evstr(convstr(values(i), 'l'));
                    if typeof(valueArray) ~= "constant" | size(valueArray, 1) ~= 1 | size(valueArray, 2) ~= 3 then
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: Converted " + labels(i) + " is not 1×3-matrix of decimal numbers!" + " " + labels(i) + ": " + values(i);
                        errorMessageSeparActive = errorMessageSeparator;
                    else
                        completeProbability = 0;
                        for x = 1 : 1 : size(valueArray, 2)
                            completeProbability = completeProbability + valueArray(x);
                        end
                        //if the sum of the weights is not equal to 1, the weights are wrong (because some issues in Scilab, we must convert the numbers to string before comparison)
                        if string(completeProbability) ~= string(1) then
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: The sum of numbers in " + labels(i) + " is not equal to 1!" + " Sum of " + labels(i) + " numbers: " + string(completeProbability) + " " + labels(i) + ": " + values(i);
                            errorMessageSeparActive = errorMessageSeparator;
                        else
                            //set the last isCorrect to true
                            isCorrectArray(size(isCorrectArray, 1)) = %t;
                        end
                    end
                catch
                    [error_message, error_number] = lasterror(%t);
                    //set error message
                    errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: " + labels(i) + " - conversion failed!" + " error_message: " + error_message + " error_number: " + string(error_number) + " " + labels(i) + ": " + values(i);
                    errorMessageSeparActive = errorMessageSeparator;
                end
                
                
                
            else
                
                isCorrectArray(size(isCorrectArray, 1) + 1) = CheckCorrectValuesType(values(i), "number", [], %f, %f);
                
                //check specific parameters if it IS a number
                if isCorrectArray(size(isCorrectArray, 1)) == %t then
                    
                    if labels(i) == "iteration_maximum" then
                        
                        //check if iteration_maximum is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if iteration_maximum is higher than 0 
                        [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 0);
                        if egualToInf == %t | higherThanZero == %f then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: iteration_maximum must be number higher than 0 but it must not be equal to infinite (%inf)!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "output_required" then
                        
                        //check if output_required is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if output_required is equal to minus infinite
                        [isNumber, egualToMinusInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, -%inf);
                        if egualToInf == %t | egualToMinusInf == %t then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: output_required must be number which is NOT equal to %inf or -%inf!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "rise_time_required" then
                        
                        //check if rise_time_required is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if rise_time_required is higher than 0
                        [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 0);
                        if egualToInf == %t | higherThanZero == %f then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: rise_time_required must be number higher than 0 but it must not be equal to infinite (%inf)!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "pid_population_size" then
                        
                        //check if pid_population_size is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if pid_population_size is higher than 3
                        [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 3);
                        if egualToInf == %t | higherThanZero == %f then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: pid_population_size must be number higher than 3 but it must not be equal to infinite (%inf)!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "binary_length_integer_part" then
                        
                        //check if binary_length_integer_part is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if binary_length_integer_part is higher than 0
                        [isNumber, higherThanThree, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 3);
                        if egualToInf == %t | higherThanThree == %f then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: binary_length_integer_part must be number higher than 3 but it must not be equal to infinite (%inf)!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "binary_length_fractional_part" then
                        
                        //check if binary_length_fractional_part is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if binary_length_fractional_part is higher than 0
                        [isNumber, higherThanThree, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 3);
                        if egualToInf == %t | higherThanThree == %f then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: binary_length_fractional_part must be number higher than 3 but it must not be equal to infinite (%inf)!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "number_of_children" then
                        
                        //check if number_of_children is equal to 1
                        [isNumber, equalToOne, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, 1);
                        //check if number_of_children is equal to 2
                        [isNumber, equalToTwo, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, 2);
                        if equalToOne == %f & equalToTwo == %f then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: number_of_children must be number 1 or 2 only!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    elseif labels(i) == "objective_function_value_constraint" then
                        
                        //check if objective_function_value_constraint is equal to infinite
                        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, %inf);
                        //check if objective_function_value_constraint is higher than 0 
                        [isNumber, higherThanZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %f, 0);
                        //check if objective_function_value_constraint is equal to 0 
                        [isNumber, egualToZero, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(values(i), %t, 0);
                        if egualToInf == %t | (higherThanZero == %f & egualToZero == %f) then
                            
                            //set the last isCorrect to false
                            isCorrectArray(size(isCorrectArray, 1)) = %f;
                            
                            //set error message
                            errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: objective_function_value_constraint must be number higher than or equal to 0 but it must not be equal to infinite (%inf)!";
                            errorMessageSeparActive = errorMessageSeparator;
                            
                        end
                        
                        
                    else
                        
                        //set error message
                        errorMessage = errorMessage + errorMessageSeparActive + "GENETIC_ALGORITHM method parameter: " + labels(i) + " must be number!";
                        errorMessageSeparActive = errorMessageSeparator;
                        
                        
                    end
                    
                end
                
            end
            
        end
        
        
        //if there is an error message, end the function
        if errorMessage ~= emptystr() then
            errorMessage = "At least one parameter for GENETIC_ALGORITHM method was set incorrectly!" + errorMessageSeparActive + errorMessage;
            isCorrect = %f;
            return;
        end
        
        //get complete result of checking
        isCorrect = and(isCorrectArray);
        if isCorrect == %f then
            //if parameters are not correct return error message
            errorMessage = "At least one parameter for GENETIC_ALGORITHM method was set incorrectly! (unknown error)";
            return;
        end
        
        
        
    else
        
        messagebox(["Unsupported method for controller adjustment was selected!" ; "outputAnalysisMethodPopupmenuValue = " + string(outputAnalysisMethodPopupmenuValue)], "modal", "error");
        
    end
    
endfunction



function [outXmlAutopilot, outXmlAutopilotFilePath, outXmlAutopilotFileName] = GetAutopilotDefinitionFromControllerAdjustmentDefinitionXML(XMLControllerAdjustmentDefinitionDoc, rootXmlElementName, xmlAircraftFileName)
    
    outXmlAutopilot = [];




    outXmlAutopilotFilePath = emptystr();
    outXmlAutopilotFileName = emptystr();
    
    //rootSimulationStartName = "simulation_start";
    //rootControllerAdjustmentDefinitionName = "control_design_start";
    
    //if a controller adjustment definition file is valid XMLDoc type and valid XML object
    if typeof(XMLControllerAdjustmentDefinitionDoc) == "XMLDoc" then
        if xmlIsValidObject(XMLControllerAdjustmentDefinitionDoc) == %t then
            
            //if the root name element of the currently edited xml controller adjustment definition file is "control_design_start", it is valid controller adjustment definition file
            if XMLControllerAdjustmentDefinitionDoc.root.name == rootXmlElementName then
                //if the current controller adjustment definition file contains any children element
                if length(XMLControllerAdjustmentDefinitionDoc.root.children) > 0 then
                    
                    //get content or default value of "autopilot" xml element
                    defaultAutopilotPath = "templates" + filesep() + "autopilot_new.xml";
                    xmlAutopilotFileName = GetXMLContentOrDefault(XMLControllerAdjustmentDefinitionDoc.root, "autopilot", defaultAutopilotPath);
                    xmlAutopilotFilePath = pwd() + filesep() + "aircraft" + filesep() + xmlAircraftFileName + filesep() + "Systems" + filesep() + xmlAutopilotFileName + ".xml";
                    xmlAutopilotFilePathNotInSystemFolder = pwd() + filesep() + "aircraft" + filesep() + xmlAircraftFileName + filesep() + xmlAutopilotFileName + ".xml";
                    
                    //if the autopilot file is directly in the aircraft folder but another file with the same name is not inside "Systems" folder, then, the autopilot file path is set to be directly in aircraft folder
                    if fileinfo(xmlAutopilotFilePathNotInSystemFolder) ~= [] & fileinfo(xmlAutopilotFilePath) == [] then
                        xmlAutopilotFilePath = xmlAutopilotFilePathNotInSystemFolder;
                    end
                    
                    //check if the autopilot file exists; if so, set output parameters
                    if fileinfo(xmlAutopilotFilePath) ~= [] then
                        
                        outXmlAutopilot = xmlRead(xmlAutopilotFilePath);
                        errorString=ValidateXMLdocument(outXmlAutopilot);
                        
                        if typeof(outXmlAutopilot) ~= "XMLDoc" | xmlIsValidObject(outXmlAutopilot) == %f then
                            outXmlAutopilot = xmlRead(defaultAutopilotPath);
                        else
                            outXmlAutopilotFilePath = xmlAutopilotFilePath;
                            outXmlAutopilotFileName = xmlAutopilotFileName;
                        end
                        
                    else
                        
                        outXmlAutopilot = xmlRead(defaultAutopilotPath);
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
endfunction



function [xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList, xmlAutopilotAdjustableComponentsIndexesListList]=GetAllAdjustableComponentsFromAutopilot(xmlAutopilot)
    
    xmlChannelChildrenIndexArray = [];
    xmlAutopilotAdjustableComponentsListList = list();
    xmlAutopilotAdjustableComponentsIndexesListList = list();
    
    
    if xmlAutopilot ~= [] then
        
        if convstr(xmlAutopilot.root.name, "l") == "autopilot" then
            
            xmlChannelChildrenIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlAutopilot.root, "channel");
            //if any index was found
            if xmlChannelChildrenIndexArray ~= [] then
                
                //get all xml element which can be adjusted by using currently developed methods ("pid", "pure_gain")
                adjustableComponentTypes = list("pid", "pure_gain");    //, "integrator", "fcs_function"
                for i = 1 : 1 : size(xmlChannelChildrenIndexArray, 1)
                    
                    [xmlAutopilotAdjustableComponentsList, xmlAutopilotAdjustableComponentsIndexesList] = GetAllXMLElementsOfDefinedTypesInChildren(xmlAutopilot.root.children(xmlChannelChildrenIndexArray(i)), adjustableComponentTypes);
                    
                    //add lists to the output lists of lists
                    xmlAutopilotAdjustableComponentsListList($+1) = xmlAutopilotAdjustableComponentsList;
                    xmlAutopilotAdjustableComponentsIndexesListList($+1) = xmlAutopilotAdjustableComponentsIndexesList;
                    
                end
                
            end
            
        else
            
            messagebox("Autopilot xml file doesn''t contain the root name ""autopilot"" but """ + xmlAutopilot.root.name + """ which is not allowed!", "modal", "error");
            
        end
        
    end
    
    
endfunction



function [outXmlAutopilotAdjustableComponent, xmlChannelChildrenIndexAutopilotAdjustableComponent, xmlAutopilotAdjustableComponentIndexChildrenChannel]=GetSelectedAdjustableComponentFromAutopilot(xmlAutopilot, inXmlAdjustableComponent)
    
    outXmlAutopilotAdjustableComponent = [];
    xmlChannelChildrenIndexAutopilotAdjustableComponent = 0;
    xmlAutopilotAdjustableComponentIndexChildrenChannel = 0;
    
    
    if xmlAutopilot ~= [] then
        
        if convstr(xmlAutopilot.root.name, "l") == "autopilot" then
            
            xmlChannelChildrenIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlAutopilot.root, "channel");
            //if any index was found
            if xmlChannelChildrenIndexArray ~= [] then
                
                //get all xml element which has same xml JSBSim type (i.e. name) as the searching xml element
                for i = 1 : 1 : size(xmlChannelChildrenIndexArray, 1)
                    
                    [xmlAutopilotAdjustableComponentsList, xmlAutopilotAdjustableComponentsIndexesList] = GetAllXMLElementsOfDefinedTypesInChildren(xmlAutopilot.root.children(xmlChannelChildrenIndexArray(i)), list( inXmlAdjustableComponent.name ));
                    
                    for j = 1 : 1 : length(xmlAutopilotAdjustableComponentsList)
                        
                        if xmlAutopilotAdjustableComponentsList(j).attributes.name == inXmlAdjustableComponent.attributes.name then
                            
                            outXmlAutopilotAdjustableComponent = xmlAutopilot.root.children(xmlChannelChildrenIndexArray(i)).children(xmlAutopilotAdjustableComponentsIndexesList(j));
                            xmlChannelChildrenIndexAutopilotAdjustableComponent = xmlChannelChildrenIndexArray(i);
                            xmlAutopilotAdjustableComponentIndexChildrenChannel = xmlAutopilotAdjustableComponentsIndexesList(j);
                            
                        end
                        
                    end
                    
                end
                
            end
            
        else
            
            messagebox("Autopilot xml file doesn''t contain the root name ""autopilot"" but """ + xmlAutopilot.root.name + """ which is not allowed!", "modal", "error");
            
        end
        
    end
    
    
endfunction



function [xmlControllerAdjustmentDefinitionFilePath, xmlControllerAdjustmentDefinitionFileName]=ShowSaveDialogXMLControllerAdjustmentDefinition(xmlControllerAdjustmentDefinition)
    
    //show save dialog for controller adjustment definition file
    [fileNameSave, pathNameSave, filterIndexSave] = uiputfile( ["*.xml","XML files"], "control_design", "Save file with controller adjustment definition" );
    
    //check if cancel button was not clicked
    if fileNameSave ~= "" & pathNameSave ~= "" & filterIndexSave ~= 0 then
        
        //check xmlControllerAdjustmentDefinition - whether is in XMLDoc format, and is valid object
        if typeof(xmlControllerAdjustmentDefinition) == "XMLDoc" then
            if xmlIsValidObject(xmlControllerAdjustmentDefinition) == %t then
                
                //get filename without extension
                xmlControllerAdjustmentDefinitionFileName = GetFileNameWithoutExtension(fileNameSave, ".xml");
                
                //set controller adjustment definition file path with extension and save xml controller adjustment definition file
                extension = GetExtensionForFileIfNecessary(fileNameSave, ".xml");
                xmlControllerAdjustmentDefinitionFilePath = pathNameSave + filesep() + fileNameSave + extension;
                xmlWrite(xmlControllerAdjustmentDefinition, xmlControllerAdjustmentDefinitionFilePath, %t);
                
                messagebox("Controller-Adjustment Definition XML-file was saved sucessfully!", "modal", "info");
                
            end
        end
        
    end
    
endfunction



function [wasCreated]=CreateControlDesignFolderIfNotExists()
    
    wasCreated = %f;
    
    
    //if control_design folder is not created in the current Scilab working folder, create it
    global controlDesignFolderName;;
    if isdir(controlDesignFolderName) == %f then
        statusCreationDirControlDesign = createdir(controlDesignFolderName);
        if statusCreationDirControlDesign == %f then
            messagebox("Creation of directory failed: """ + controlDesignFolderName + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction



//save controller adjustment definition to control_design folder - if the filename of controller adjustment definition is not set, use default
function [wasSaved]=SaveControllerAdjustmentDefinitionIntoControlDesignFolderAndBackupTheOriginal(xmlControllerAdjustmentDefinition, xmlControllerAdjustmentDefinitionFileName)
    
    wasSaved = %f;
    
    
    //if the filename of controller adjustment definition is not set, use default "simulation_start" tag with date and time information
    outXmlControllerAdjustmentDefinitionFileName = xmlControllerAdjustmentDefinitionFileName;
    if outXmlControllerAdjustmentDefinitionFileName == [] | strsubst(outXmlControllerAdjustmentDefinitionFileName, " ", "") == emptystr() then
        global controllerAdjustmentDefinitionNameDefault;
        currentTimeAsVector = clock();
        separatorDateTime = "-";
        outXmlControllerAdjustmentDefinitionFileName = controllerAdjustmentDefinitionNameDefault + "_" + string(currentTimeAsVector(1)) + separatorDateTime + string(currentTimeAsVector(2)) + separatorDateTime + string(currentTimeAsVector(3)) + "_" + string(currentTimeAsVector(4)) + separatorDateTime + string(currentTimeAsVector(5)) + separatorDateTime + string(round(currentTimeAsVector(6)));
    end
    
    
    global controlDesignFolderName;
    outXmlControllerAdjustmentDefinitionFilePath = controlDesignFolderName + filesep() + outXmlControllerAdjustmentDefinitionFileName + ".xml";
    
    //if output controller adjustment definition file path exists, backup it
    if isfile(outXmlControllerAdjustmentDefinitionFilePath) == %t then
        
        //back up the original file if any
        wasBackedUp = BackupTheOriginalFile(controlDesignFolderName, outXmlControllerAdjustmentDefinitionFilePath, outXmlControllerAdjustmentDefinitionFileName + ".xml", %t, emptystr());
        if wasBackedUp == %f then
            messagebox(["The original Controller Adjustment Definition file was not backed-up!"; "controlDesignFolderName: " + controlDesignFolderName ; "outXmlControllerAdjustmentDefinitionFilePath: " + outXmlControllerAdjustmentDefinitionFilePath ; "outXmlControllerAdjustmentDefinitionFileName: " + outXmlControllerAdjustmentDefinitionFileName ], "modal", "error");
            return;
        end
        disp(["The original Controller Adjustment Definition xml was sucessfully backed-up!" ; outXmlControllerAdjustmentDefinitionFilePath ; ]);
        
    end
    
    //save opened xml controller adjustment definition file, or show error if failed
    try
        xmlWrite(xmlControllerAdjustmentDefinition, outXmlControllerAdjustmentDefinitionFilePath, %t);
        disp(["Controller Adjustment Definition xml was sucessfully saved!" ; outXmlControllerAdjustmentDefinitionFilePath ; ]);
        wasSaved = %t;
    catch
        [error_message, error_number] = lasterror(%t);
        messagebox(["Saving of Controller Adjustment Definition file failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "outXmlControllerAdjustmentDefinitionFilePath: " + outXmlControllerAdjustmentDefinitionFilePath ; "outXmlControllerAdjustmentDefinitionFileName: " + outXmlControllerAdjustmentDefinitionFileName ], "modal", "error");
        return;
    end
    
endfunction







//from equation: r0 + rI/s + rD*s = r0 * (1 + 1/(Ti*s) + Td*s)
//where KP = r0, KI = rI, KD = rD
//ensue:
//TI = r0 / rI  =>  KP / KI
//TD = rD / r0  =>  KD / KP

//Convert Ti to Ki (rI)
function [Ki]=ConvertTiToKi(Ti, Kp)
    if Ti > 0 & Ti ~= %inf & Ti ~= %nan then
        Ki = Kp / Ti;
    else
        Ki = 0;
    end
endfunction

//Convert Td to Kd (rD)
function [Kd]=ConvertTdToKd(Td, Kp)
    if Kp ~= %inf & Kp ~= %nan then
        Kd = Kp * Td;
    else
        Kd = 0;
    end
endfunction


//get fractional part only (as decimal number)
function [decimalPartOnly]=GetFractionalPart(number)
    
    decimalPartOnly = 0;
//    //get absolute value of the number
//    numberAbs = abs(number)
    //round the value towards zero







    numberTowardsZero = int(number)
    //get deciamal part only (due to rounding the value towards zero, it works to the negative numbers same as the positive)
    decimalPartOnly = number - numberTowardsZero
    
endfunction







//Ziegler-Nichols method with critical parameters

global zieglerNicholsRules;
zieglerNicholsRules = xmlRead("templates" + filesep() + "Control_Design" + filesep() + "ziegler_nichols_rules.xml");
global zieglerNicholsRulesNames;
zieglerNicholsRulesNames = list();
//get all names of ziegler nichols rules
for i = 1 : 1 : length(zieglerNicholsRules.root.children)
    zieglerNicholsRule = zieglerNicholsRules.root.children(i);
    if zieglerNicholsRule.name ~= "comment" & zieglerNicholsRule.name ~= "documentation" & zieglerNicholsRule.name ~= "description" & zieglerNicholsRule.name ~= "text" then
        zieglerNicholsRulesNames($+1) = zieglerNicholsRule.name;
    end
end

global PxmlElementNameInRule;
PxmlElementNameInRule = "p";
global IxmlElementNameInRule;
IxmlElementNameInRule = "i";
global DxmlElementNameInRule;
DxmlElementNameInRule = "d";

global PeriodQuantityRangeMaximum;
PeriodQuantityRangeMaximum = 3;    //range of the peak samples distance should be very low - the maximum is between 1 and 3 depending on conditions - 2 was selected as compromise.
global NumberOfPeaksMinimum;
NumberOfPeaksMinimum = 10;  //minimum of peaks found in data should be at least 10 for sufficient analysis

global CriticalGainChangeTolerance;
CriticalGainChangeTolerance = 0.00001;  //tolerance for critical gain change when the algorithm for dynamic iteration gain change is applied in Ziegler-Nichols method


function [isPeriodConstant, isPeriodicAmplitudeSame, T_criticalPeriod, outMessageInfo]=AnalyzePeriodicityOfData_WithSameSampleRate(CSVvalues, toleranceAmplitudeMethodParameter)
    
    
//    //<>debug only - manually set parameters
//    CSVvalues = recalculatedCSVvalues;
//    toleranceAmplitudeMethodParameter = 0.05;
//    //tolerancePeriodMethodParameter = 0.05;
    
    
    isPeriodConstant = %f;
    isPeriodicAmplitudeSame = %f;
    T_criticalPeriod = -1;
    outMessageInfo = [];    //outMessageInfo(size(outMessageInfo, 1) + 1) = "";
    
    
    //detrend of the CSV data - remove constant, linear or piecewise linear trend from a vector
    detrendedCSVvalues = detrend(CSVvalues(:,2))
//    //get only CSV values of the analyzed parameter (it does not use detrend)
//    detrendedCSVvalues = CSVvalues(:,2)
    
//    if size(detrendedCSVvalues, 1) < 1 then
//        detrendedCSVvalues = CSVvalues(:,2);
//    end
    //find peaks in CSV values - uses function from peak_detect.sci (not in Scilab, see https://fileexchange.scilab.org/toolboxes/209000)
    peaks = peak_detect(detrendedCSVvalues')
    
    //sample period must be same as the frequency (i.e. rate) of JSBSim Script for output xml element
    periodSample = CSVvalues(2, 1) - CSVvalues(1, 1)
    
//    //ignore the first and the last peaks (it should be OK with the first and the last, but for sure)
//    peaksWithoutFirstAndLast = peaks(2:length(peaks)-1);
    //do not ignore the first and the last peaks
    peaksWithoutFirstAndLast = peaks;
    //calculate differences
    differencesBetweenPeaks = diff(peaksWithoutFirstAndLast)
    //calculate range of the differences (distance) - this number should be very low, see the following if case
    periodQuantityRange = strange(differencesBetweenPeaks)
    
    //calculate time period using mean value of the differences (distance) of samples and the sample period
    periodQuantityMean = mean(differencesBetweenPeaks)
    TPeriodMean = periodQuantityMean * periodSample
    //calculate maximum time period which can be tolerate when the periodicity is checked
    periodQuantityMax = max(differencesBetweenPeaks)
    TPeriodMaxAllowed = (periodQuantityMax + 0.7) * periodSample
    periodQuantityMin = min(differencesBetweenPeaks)
    
    
    //get the first and the last time value
    firstTimeValue = CSVvalues(1, 1)
    lastTimeValue = CSVvalues(size(CSVvalues, 1), 1)
    //get the first and the last time value of the peaks
    firstPeakTimeValue = %inf;
    lastPeakTimeValue = %inf;
    if length(peaksWithoutFirstAndLast) > 1 then
        firstPeakTimeValue = CSVvalues(peaksWithoutFirstAndLast(1), 1)
        lastPeakTimeValue = CSVvalues(peaksWithoutFirstAndLast(length(peaksWithoutFirstAndLast)), 1)
    end
    
    
    //range of the peak samples distance should be very low - the maximum was set as global and should be between 1 and 3 depending on conditions
    //difference between first peak and the first time value cannot be higher than period
    //difference between the last time value and the last peak cannot be higher than period
    //number of peaks should be at least 10 for appropriate analysis
    global PeriodQuantityRangeMaximum;
    global NumberOfPeaksMinimum;
    if periodQuantityRange <= PeriodQuantityRangeMaximum  &  (firstPeakTimeValue - firstTimeValue) <= TPeriodMaxAllowed  &  (lastTimeValue - lastPeakTimeValue) <= TPeriodMaxAllowed then   //  &  size(peaks,2) >= NumberOfPeaksMinimum
        
        //now, we know (or think) that it is periodic signal
        isPeriodConstant = %t;
        T_criticalPeriod = TPeriodMean;
        
        
        //get all amplitude values of each peak
        //amplitudesOfPeaks = CSVvalues(peaksWithoutFirstAndLast, 2);
        detrendedAmplitudesOfPeaks = detrendedCSVvalues(peaksWithoutFirstAndLast);
        
        //calculate statistic information
        standardDeviationDetrendedAmplitudesOfPeaks = stdev(detrendedAmplitudesOfPeaks)
        meanDetrendedAmplitudesOfPeaks = mean(detrendedAmplitudesOfPeaks)
        maxDetrendedAmplitudesOfPeaks = max(detrendedAmplitudesOfPeaks)
        minDetrendedAmplitudesOfPeaks = min(detrendedAmplitudesOfPeaks)
        rangeDetrendedAmplitudesOfPeaks = strange(detrendedAmplitudesOfPeaks)
        meanAbsoluteDeviationDetrendedAmplitudesOfPeaks = mad(detrendedAmplitudesOfPeaks)
        varianceDetrendedAmplitudesOfPeaks = variance(detrendedAmplitudesOfPeaks)
        
        //tolerance parameter is calculated and compared with the user definition
        toleranceDetrendedAmplitudesOfPeaks = rangeDetrendedAmplitudesOfPeaks / 2;
        if meanDetrendedAmplitudesOfPeaks ~= 0 then
            toleranceDetrendedAmplitudesOfPeaks = toleranceDetrendedAmplitudesOfPeaks / meanDetrendedAmplitudesOfPeaks;
        end
        if abs(toleranceDetrendedAmplitudesOfPeaks) <= toleranceAmplitudeMethodParameter then
            isPeriodicAmplitudeSame = %t;
        end
        
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Tolerance of Amplitudes of Peaks = " + string(toleranceDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Range of Amplitudes of Peaks = " + string(rangeDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Mean of Amplitudes of Peaks = " + string(meanDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Maximum of Amplitudes of Peaks = " + string(maxDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Minimum of Amplitudes of Peaks = " + string(minDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Standard Deviation of Amplitudes of Peaks = " + string(standardDeviationDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Mean Absolute Deviation of Amplitudes of Peaks = " + string(meanAbsoluteDeviationDetrendedAmplitudesOfPeaks);
        outMessageInfo(size(outMessageInfo, 1) + 1) = "Variance of Amplitudes of Peaks = " + string(varianceDetrendedAmplitudesOfPeaks);
        
    end
    
    
    //add all useful information to the output message
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Is Period Constant? = " + string(isPeriodConstant);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Is Periodic Amplitude Same? = " + string(isPeriodicAmplitudeSame);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Critical Period [s] = " + string(T_criticalPeriod);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Sample Period [s] = " + string(periodSample);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Number of Found Peaks = " + string(size(peaks,2));
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Samples'' Range of Peaks = " + string(periodQuantityRange);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Samples'' Mean of Peaks = " + string(periodQuantityMean);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Samples'' Maximum of Peaks = " + string(periodQuantityMax);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Samples'' Minimum of Peaks = " + string(periodQuantityMin);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Mean Period of Samples'' Peaks [s] = " + string(TPeriodMean);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Max Allowed (tolerance) Period of Samples'' Peaks [s] = " + string(TPeriodMaxAllowed);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Time of First Peak [s] = " + string(firstPeakTimeValue);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Time of Last Peak [s] = " + string(lastPeakTimeValue);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "Start Time of CSV data [s] = " + string(firstTimeValue);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "End Time of CSV data [s] = " + string(lastTimeValue);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "First-Start Time Differences [s] = " + string(firstPeakTimeValue - firstTimeValue);
    outMessageInfo(size(outMessageInfo, 1) + 1) = "End-Last Time Differences [s] = " + string(lastTimeValue - lastPeakTimeValue);
//    outMessageInfo(size(outMessageInfo, 1) + 1) = "";
    
    
endfunction



function SetPIDparametersUsingZieglerNicholsCriticalParametersTables(KP_GainXmlElement, KI_IntegralXmlElement, KD_DerivativeXmlElement, zieglerNicholsRuleName, gainCritical, T_criticalPeriod)
    
    //get PID parameters for the specific Ziegler-Nichols rule
    PIDValuesArray = GetPIDparametersUsingZieglerNicholsCriticalParametersTables(zieglerNicholsRuleName, gainCritical, T_criticalPeriod);
    
    //check if the PID parameters do not contain infinite or not-a-number values
    if or(isinf(PIDValuesArray)) == %f & or(isnan(PIDValuesArray)) == %f then
        
        //because Scilab 6.0.1 uses 'D' instead of 'E' to express exponent (<>Scilab bug?), we have to change it to 'E'
        //set Kp to control component xml element in autopilot
        KP_GainXmlElement.content = strsubst(string(PIDValuesArray(1)), "D", "E");
        //set Ki to control component xml element in autopilot if exists
        if KI_IntegralXmlElement ~= [] then
            KI_IntegralXmlElement.content = strsubst(string(PIDValuesArray(2)), "D", "E");
        end
        //set Kd to control component xml element in autopilot if exists
        if KD_DerivativeXmlElement ~= [] then
            KD_DerivativeXmlElement.content = strsubst(string(PIDValuesArray(3)), "D", "E");
        end
        
    else
        
        messagebox(["The result of PID adjustment contains infinite or not-a-number values!" ; "PID values: [" + strcat(string(PIDValuesArray), ", ") + "]" ; "Ziegler-Nichols'' rule name: """ + zieglerNicholsRuleName + """" ; "Critical Gain: " + string(gainCritical) ; "Critical Period: " + string(T_criticalPeriod) ], "modal", "error");
        return;
        
    end
    
endfunction


function [PIDValuesArray]=GetPIDparametersUsingZieglerNicholsCriticalParametersTables(zieglerNicholsRuleName, gainCritical, T_criticalPeriod)
    
    PIDValuesArray = [-%inf, -%inf, -%inf];
    global zieglerNicholsRules;
    
    xmlZieglerNicholsRuleElement = FindFirstXMLElementInFirstChildrenOfXMLElement(zieglerNicholsRules.root, zieglerNicholsRuleName);
    if xmlZieglerNicholsRuleElement ~= [] then
        
        global PxmlElementNameInRule;
        global IxmlElementNameInRule;
        global DxmlElementNameInRule;
        
        xmlElementP = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlZieglerNicholsRuleElement, PxmlElementNameInRule);
        xmlElementI = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlZieglerNicholsRuleElement, IxmlElementNameInRule);
        xmlElementD = FindFirstXMLElementInFirstChildrenOfXMLElement(xmlZieglerNicholsRuleElement, DxmlElementNameInRule);
        
        KpValue = 0;
        if xmlElementP ~= [] then
            
            //decode and calculate equation for P part
            KpValue = DecodeAndCalculatePIDznRuleEquation(xmlElementP.content, gainCritical, T_criticalPeriod);
            if KpValue == 0 | KpValue == %inf | KpValue == -%inf then
                messagebox(["The result of gain (Kp) must NOT be 0 nor +-Infinite!" ; "Ziegler-Nichols'' rule name: """ + zieglerNicholsRuleName + """" ; "Critical Gain: " + string(gainCritical) ; "Critical Period: " + string(T_criticalPeriod) ], "modal", "error");
                return;
            end
            //set Kp to output PID array with values
            PIDValuesArray(1) = KpValue;
            
        else
            messagebox(["''p'' xml element was not found in Ziegler-Nichols rule template file! (see ""templates\Control_Design\ziegler_nichols_rules.xml"")" ; "Ziegler-Nichols'' rule name: """ + zieglerNicholsRuleName + """" ], "modal", "error");
            return;
        end
        
        
        if xmlElementI ~= [] then
            
            //decode and calculate equation for I part
            TiValue = DecodeAndCalculatePIDznRuleEquation(xmlElementI.content, gainCritical, T_criticalPeriod);
            //convert from Ti to Ki
            KiValue = ConvertTiToKi(TiValue, KpValue);
            //set Ki to output PID array with values
            PIDValuesArray(2) = KiValue;
            
        else
            PIDValuesArray(2) = 0;
        end
        
        
        if xmlElementD ~= [] then
            
            //decode and calculate equation for D part
            TdValue = DecodeAndCalculatePIDznRuleEquation(xmlElementD.content, gainCritical, T_criticalPeriod);
            //convert from Td to Kd
            KdValue = ConvertTdToKd(TdValue, KpValue);
            //set Kd to output PID array with values
            PIDValuesArray(3) = KdValue;
            
        else
            PIDValuesArray(3) = 0;
        end
        
    else
        
        messagebox(["Ziegler-Nichols'' Rule for Critical Parameters was not found!" "Searched Ziegler-Nichols'' rule name: """ + zieglerNicholsRuleName + """" ], "modal", "error");
        
    end
    
endfunction


function [outputValue]=DecodeAndCalculatePIDznRuleEquation(equationWithZNrule, gainCritical, T_criticalPeriod)
    
    outputValue = 0;
    mathSymbolsArray = ['*', '/', '+', '-'];
    CriticalGainTag = "critical_gain";
    CriticalPeriodTag = "critical_period";
    
    //delete white spaces and convert to lower cases
    equationWithZNruleWithoutSpacesAndLower = convstr(strsubst(equationWithZNrule, " ", ""), 'l');
    
    //get each part separated by the basic mathematical operations
    equationTokensArray = tokens(equationWithZNruleWithoutSpacesAndLower, mathSymbolsArray);
    
    //get indexes of each basic mathematical operation
    mathematicalOperationsIndexesArray = strindex(equationWithZNruleWithoutSpacesAndLower, mathSymbolsArray);
    //get each mathematical operation
    mathematicalOperationsList = list();
    for i = 1 : 1 : size(mathematicalOperationsIndexesArray, 2)
        mathematicalOperationsList($+1) = part(equationWithZNruleWithoutSpacesAndLower, mathematicalOperationsIndexesArray(i) : mathematicalOperationsIndexesArray(i));
    end
    
    
    //only positive values are supposed, so the number of values should be higher by 1 than the number of mathematical operations
    if size(equationTokensArray, 1) - 1 ~= length(mathematicalOperationsList) then
        messagebox(["Decoding of Ziegler-Nichols'' Rule for Critical Parameters failed!" ; "There must be exactly n-1 math operations than the number of variables/values!""" + zieglerNicholsRuleName + """" ], "modal", "error");
        return;
    end
    
    
    if size(equationTokensArray, 1) > 0 then
        
        
        //get first number/variable
        outputStringFirst = equationTokensArray(1);
        //check if outputStringFirst is equal to infinite and convert the string to number if possible
        [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(outputStringFirst, %t, %inf);
        //if it is number which is not equal to infinite, and was succesfully converted
        if isNumber == %t & egualToInf == %f & outNumber ~= [] then
            
            outputValue = outNumber;
            
        //else if it is infinite
        elseif isNumber == %t & egualToInf == %t & outNumber ~= [] then
            
            //return infinite as the result value (infinite plus, minus, times, or divide almost everything (except -infinite and infinite) is infinite)
            outputValue = outNumber;
            return;
            
        //else if it is variable name for critical gain
        elseif outputStringFirst == CriticalGainTag then
            
            outputValue = gainCritical;
            
        //else if it is variable name for critical period
        elseif outputStringFirst == CriticalPeriodTag then
            
            outputValue = T_criticalPeriod;
            
        else
            
            messagebox(["Error in Ziegler-Nichols'' Rule for Critical Parameters!" ; "The following variable/value is not supported: """ + outputStringFirst + """" ], "modal", "error");
            return;
            
        end
        
        
        //in real world, the first operations which should be performed are multiplication and division, and then the addition and subtraction - in this case there should be one operation only ... and actually it should be the multiplication only. To create complicated equations, write the multiplication and division first to the equation rule if possible (however, there should not be any reason to create complicated rules for Ziegler-Nichols method!)
        for i = 1 : 1 : length(mathematicalOperationsList)
            
            //get mathe symbol and next string with number or variable name (or nonsense)
            mathSymbol = mathematicalOperationsList(i);
            outputStringNext = equationTokensArray(i+1);
            
            
            //check if outputStringNext is equal to infinite and convert the string to number if possible
            [isNumber, egualToInf, outNumber, errorString] = CheckIfNumberHigherOrEqualAndConvert(outputStringNext, %t, %inf);
            //if it is number which is not equal to infinite, and was succesfully converted
            if isNumber == %t & egualToInf == %f & outNumber ~= [] then
                
                
                if mathSymbol == mathSymbolsArray(2) & outNumber == 0 then
                    messagebox(["Error in Ziegler-Nichols'' Rule for Critical Parameters!" ; "The value cannot be divided by 0 (Number)!" ; "Value: " + string(outputValue) ; "Math Symbol: """ + mathSymbol + """" ; "Number: " + string(outNumber) ], "modal", "error");
                    return;
                end
                outputValue = evstr( string(outputValue) + mathSymbol + outNumber );
                
                
            //else if it is infinite
            elseif isNumber == %t & egualToInf == %t & outNumber ~= [] then
                
                
                //almost everything (except -infinite and infinite) plus, minus, times infinite is infinite ; only division is 0!
                if mathSymbol == mathSymbolsArray(2) then
                    //set 0 as the result value
                    outputValue = 0;
                else
                    //set infinite as the result value
                    outputValue = outNumber;
                end
                

                //return;
                
                
            //else if it is variable name for critical gain
            elseif outputStringNext == CriticalGainTag then
                
                
                if mathSymbol == mathSymbolsArray(2) & gainCritical == 0 then
                    messagebox(["Error in Ziegler-Nichols'' Rule for Critical Parameters!" ; "The value cannot be divided by 0 (gainCritical)!" ; "Value: " + string(outputValue) ; "Math Symbol: """ + mathSymbol + """" ; "Critical Gain: " + string(gainCritical) ], "modal", "error");
                    return;
                end
                outputValue = evstr( string(outputValue) + mathSymbol + string(gainCritical) );
                
                
            //else if it is variable name for critical period
            elseif outputStringNext == CriticalPeriodTag then
                
                
                if mathSymbol == mathSymbolsArray(2) & T_criticalPeriod == 0 then
                    messagebox(["Error in Ziegler-Nichols'' Rule for Critical Parameters!" ; "The value cannot be divided by 0 (T_criticalPeriod)!" ; "Value: " + string(outputValue) ; "Math Symbol: """ + mathSymbol + """" ; "Critical Period: " + string(T_criticalPeriod) ], "modal", "error");
                    return;
                end
                outputValue = evstr( string(outputValue) + mathSymbol + string(T_criticalPeriod) );
                
                
            else
                
                messagebox(["Error in Ziegler-Nichols'' Rule for Critical Parameters!" ; "The following variable/value is not supported: """ + outputStringNext + """" ], "modal", "error");
                return;
                
            end
            
        end
        
    else
        disp(["Warning! Equation with Ziegler-Nichols rule is empty! Equation with ZN rule: """ + equationWithZNrule + """" ; ]);
    end
    
endfunction


function [KP_GainXmlElement, KI_IntegralXmlElement, KD_DerivativeXmlElement]=GetKpKiKdXMLelementsFromAdjustableComponentInAutopilot(xmlAutopilot, xmlAutopilotAdjustableComponent)
    
    KP_GainXmlElement = [];
    KI_IntegralXmlElement = [];
    KD_DerivativeXmlElement = [];
    if xmlAutopilotAdjustableComponent.name == "pid" then
        
        //find and get (or create) gain xml element
        KP_GainXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "kp");
        //find and get (or create) integral xml element
        KI_IntegralXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "ki");
        //find and get (or create) derivative xml element
        KD_DerivativeXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "kd");
        
        
    elseif xmlAutopilotAdjustableComponent.name == "pure_gain" then
        
        //find and get (or create) gain xml element
        KP_GainXmlElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlAutopilot, xmlAutopilotAdjustableComponent, "gain");
        
    end
    
endfunction





//<>debug only - just manual example delete it
function ExampleCSVAnalysisNo1()
    
    
    //<>debug only - manually set parameters
    //currentOutputCSVPath = "controller_adjustment_progression\V-TS v1-532\autopilot-JSBSim_fcs-altitude-pid-controller\2018-06-21_23-46-06\autopilot_55\output.csv";
    currentOutputCSVPath = "ZN_test_analysis\55_output.csv";
    //currentOutputCSVPath = "controller_adjustment_progression\V-TS v1-532\autopilot-JSBSim_fcs-altitude-pid-controller\2018-07-08_01-43-02\autopilot_56\output.csv";
    //currentOutputCSVPath = "controller_adjustment_progression\V-TS v1-532\autopilot-JSBSim_fcs-altitude-pid-controller\2018-07-08_17-31-28\autopilot_6\output.csv";
    timeStartNumber = 200;
    timeEndNumber = %inf;
    toleranceAmplitudeMethodParameter = 0.05;
    //tolerancePeriodMethodParameter = 0.05;
    
    
    
    //load csv file and separate header and value parts
    [CSVHeader, CSVvalues] = ReadAndEvalCSVfile(currentOutputCSVPath);
    //process the output csv file and show figure with plots
    
    //separate CSV values and CSV headers to parts for sure
    partCSVHeader = cat(2, CSVHeader(:, 1), CSVHeader(:, 2));
    partCSVvalues = cat(2, CSVvalues(:, 1), CSVvalues(:, 2));
    
    
    
    //indexesHeaderList = GetIndexesCSVvalues(CSVHeader, "Time");
    numberOfRows = size(partCSVvalues, 1);
    
    //if time end is infinite or higher than end simulation time, set the end simulation time
    if timeEndNumber == %inf | timeEndNumber > partCSVvalues(numberOfRows, 1) then
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
    
    
    
    //analyze periodicity of data which are captured with same sample rate (user has to provide adequatly high rate (min. 30 Hz is recommended) - if the rate is very low, the analysis may return inaccurate results)
    [isPeriodConstant, isPeriodicAmplitudeSame, T_criticalPeriod, outMessageInfo] = AnalyzePeriodicityOfData_WithSameSampleRate(recalculatedCSVvalues, toleranceAmplitudeMethodParameter)
    
    //<>debug only
//    detrendedRecalculatedCSVvalues = detrend(recalculatedCSVvalues(:,2))
//    plot(recalculatedCSVvalues(:,1),detrendedRecalculatedCSVvalues(:,1))
    
//    //find peaks in CSV values - uses function from peak_detect.sci (not in Scilab, see https://fileexchange.scilab.org/toolboxes/209000)
//    peaks = peak_detect(recalculatedCSVvalues(:,2)')
    
//    //sample period must be same as the frequency (i.e. rate) of JSBSim Script for output xml element
//    periodSample = CSVvalues(2,1) - CSVvalues(1,1)
    
//    //ignore the first and the last peak and calculate differences (it should be OK with the first and the last, but for sure)
//    differencesBetweenPeaks = diff(peaks(2:length(peaks)-1))
//    //calculate range of the differences (distance) - this number should be very low (max. 3)
//    periodQuantityRange = strange(differencesBetweenPeaks)
    
//    //calculate time period using mean value of the differences (distance) of samples and the sample period
//    periodQuantityMean = mean(differencesBetweenPeaks)
//    TPeriodMean = periodQuantityMean * periodSample
//    periodQuantityMax = max(differencesBetweenPeaks)
//    periodQuantityMin = min(differencesBetweenPeaks)
    
    
    //Possible useful functions follow:
    
    //Peaks detector (return position of peaks of a signal see peak_detect.sci) - https://fileexchange.scilab.org/toolboxes/209000
    //polyfit (polynomial fit of data sets) - https://fileexchange.scilab.org/toolboxes/249000
    //linfit (multivariate linear fit) - https://fileexchange.scilab.org/toolboxes/250000
    //partfrac (Partial fraction decomposition of a rational in the C set) - https://fileexchange.scilab.org/toolboxes/451000
    
    //Signal Processing - https://help.scilab.org/docs/6.0.1/en_US/section_627bb72892f4d7df420a4374aadcdb86.html
    //detrend (remove constant, linear or piecewise linear trend from a vector) - https://help.scilab.org/docs/6.0.1/en_US/detrend.html
    //filter (filters a data sequence using a digital filter) - https://help.scilab.org/docs/6.0.1/en_US/filter.html
    //fft (fast Fourier transform.) - https://help.scilab.org/docs/6.0.1/en_US/fft.html
    //fftshift (rearranges the fft output, moving the zero frequency to the center of the spectrum) - https://help.scilab.org/docs/6.0.1/en_US/fftshift.html
    //wiener (Wiener estimate) - https://help.scilab.org/docs/6.0.1/en_US/wiener.html
    //yulewalk (least-square filter design) - https://help.scilab.org/docs/6.0.1/en_US/yulewalk.html
    //lattn (recursive solution of normal equations) - https://help.scilab.org/docs/6.0.1/en_US/lattn.html
    //lev (Yule-Walker equations (Levinson's algorithm)) - https://help.scilab.org/docs/6.0.1/en_US/lev.html
    //levin (Toeplitz system solver by Levinson algorithm (multidimensional)) - https://help.scilab.org/docs/6.0.1/en_US/levin.html
    //hilbert (Discrete-time analytic signal computation of a real signal using Hilbert transform) - https://help.scilab.org/docs/6.0.1/en_US/hilbert.html
    //wfir_gui (Graphical user interface that can be used to interactively design wfir filters) - https://help.scilab.org/docs/6.0.1/en_US/wfir_gui.html
    //? pspect (two sided cross-spectral estimate between 2 discrete time signals using the Welch's average periodogram method.) - https://help.scilab.org/docs/6.0.1/en_US/pspect.html
    //? cspect (two sided cross-spectral estimate between 2 discrete time signals using the correlation method) - https://help.scilab.org/docs/6.0.1/en_US/cspect.html
    //intdec (Changes sampling rate of a signal) - https://help.scilab.org/docs/6.0.1/en_US/intdec.html
    
    //Interpolation - https://help.scilab.org/docs/6.0.1/en_US/section_cbe1ff78f1540427ee77c59485db9a3b.html
    //interp (cubic spline evaluation function) - https://help.scilab.org/docs/6.0.1/en_US/interp.html
    //splin (cubic spline interpolation) - https://help.scilab.org/docs/6.0.1/en_US/splin.html
    //smooth (smoothing by spline functions) - https://help.scilab.org/docs/6.0.1/en_US/smooth.html
    //? interp1 (one_dimension interpolation function) - https://help.scilab.org/docs/6.0.1/en_US/interp1.html
    //? interpln (linear interpolation) - https://help.scilab.org/docs/6.0.1/en_US/interpln.html
    
    //Statistics - https://help.scilab.org/docs/6.0.1/en_US/section_6dd82a24bb0d624e68532c20c006409d.html
    //mean (mean (row mean, column mean) of vector/matrix entries) (or nanmean) - https://help.scilab.org/docs/6.0.1/en_US/mean.html
    //geomean (geometric mean) - https://help.scilab.org/docs/6.0.1/en_US/geomean.html
    //harmean (harmonic mean : inverse of the inverses average (without zeros)) - https://help.scilab.org/docs/6.0.1/en_US/harmean.html
    //max (maximum) - https://help.scilab.org/docs/6.0.1/en_US/max.html
    //min (minimum) - https://help.scilab.org/docs/6.0.1/en_US/min.html
    //strange (range) - https://help.scilab.org/docs/6.0.1/en_US/strange.html
    //mad (mean absolute deviation) - https://help.scilab.org/docs/6.0.1/en_US/mad.html
    //stdev (standard deviation (row orcolumn-wise) of vector/matrix entries) (or nanstdev) - https://help.scilab.org/docs/6.0.1/en_US/stdev.html
    //variance (variance (and mean) of a vector or matrix (or hypermatrix) of real or complex numbers) - https://help.scilab.org/docs/6.0.1/en_US/variance.html
    //reglin (Linear regression) (or nanreglin) - https://help.scilab.org/docs/6.0.1/en_US/reglin.html
    //? center (center in Descriptive Statistics) - https://help.scilab.org/docs/6.0.1/en_US/center.html
    //histc (computes an histogram) - https://help.scilab.org/docs/6.0.1/en_US/histc.html
    //thrownan (Eliminates nan values - if data contain any "Nan" values, it deletes them all) - https://help.scilab.org/docs/6.0.1/en_US/thrownan.html
    //trimmean (trimmed mean of a vector or a matrix) - https://help.scilab.org/docs/6.0.1/en_US/trimmean.html
    //median (median (row median, column median,...) of vector/matrix/array entries) (or nanmedian) - https://help.scilab.org/docs/6.0.1/en_US/median.html
    
    //Optimization and Simulation - https://help.scilab.org/docs/6.0.1/en_US/section_d1508de04d414fa1b912d1f0080c6988.html
    //datafit (Parameter identification based on measured data) - https://help.scilab.org/docs/6.0.1/en_US/datafit.html

    //leastsq (Solves non-linear least squares problems) - https://help.scilab.org/docs/6.0.1/en_US/leastsq.html
    //lsqrsolve (minimize the sum of the squares of nonlinear functions, levenberg-marquardt algorithm) - https://help.scilab.org/docs/6.0.1/en_US/lsqrsolve.html
    //lsq (linear least square problems) - https://help.scilab.org/docs/6.0.1/en_US/lsq.html
    
    //<>? Differential calculus, Integration - https://help.scilab.org/docs/6.0.1/en_US/section_0f8e34621beb7427897f84f6341dd0f7.html
    //<>? bvode (boundary value problems for ODE using collocation method) (or bvodeS (Simplified call to bvode)) - https://help.scilab.org/docs/6.0.1/en_US/bvode.html
    
    
endfunction







//genetic algorithm functions

global minimumNumberOfData;
minimumNumberOfData = 100;

global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs = "FromBestToWorst";
global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce;
GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce = "FromBestToWorst_IndividualOnce";
global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals = "BestWithWorst";
global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce;
GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce = "BestWithWorst_IndividualOnce";
global GA_CreatePairs_SelectionMode_TournamentPairs;
GA_CreatePairs_SelectionMode_TournamentPairs = "Tournament";
global GA_SelectionMode_TournamentPairs_SelectedIndividuals;
GA_SelectionMode_TournamentPairs_SelectedIndividuals = 5;
global GA_CreatePairs_SelectionMode_RouletteWheelPairs;
GA_CreatePairs_SelectionMode_RouletteWheelPairs = "RouletteWheel";
global GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling;
GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling = "RouletteWheel_StochasticUniversalSampling";
global GA_CreatePairs_SelectionMode_RandomPairs;
GA_CreatePairs_SelectionMode_RandomPairs = "Random";


//GA_CodingBinary was inspired by coding_ga_binary function in Scilab but it also includes coding/decoding for fractional part of decimal number. However, input/output may be decimal or binary value only; not list with arrays
function [NumberOut] = GA_CodingBinary(NumberIn, direction, param)
    
    // NumberIn     is a decimal number                 or          string with binary value.
    // NumberOut    is a string with binary value       or          a decimal number
    // if NumberOut is empty string or lower than MinBounds, it was not coded or decoded correctly
    
//    //<>debug only
//    NumberIn = 324.4894654;
//    //NumberIn = 4987987.1489498;
//    //NumberIn = 0.4897987987949849;
//    //NumberIn = 0.4897987987949849;
//    //NumberIn = "00000001010001000001001100011111";
//    //NumberIn = "0000000001001100000111000101001100000000111000110100011110000100";
//    //NumberIn = "000000000000000000011101001100011011110010001111";
//    //NumberIn = "00000000010010101011110011000100";
//    direction = "code";
//    //direction = "decode"
//    param = init_param();
//    maxBinaryLenght = 16;
//    //maxBinaryLenght = 32;
//    //maxBinaryLenght = 16;
//    //maxBinaryLenght = 8;
//    maxBinaryLenghtFractionalPart = 16;
//    //maxBinaryLenghtFractionalPart = 32;
//    //maxBinaryLenghtFractionalPart = 32;
//    //maxBinaryLenghtFractionalPart = 24;
//    param = add_param(param, "binary_length", maxBinaryLenght);
//    param = add_param(param, "binary_length_fractional_part", maxBinaryLenghtFractionalPart);
//    param = add_param(param, "minbound", 0);
//    param = add_param(param, "maxbound", 2^maxBinaryLenght-1);
    
    
    if ~isdef("param", "local") then
        param = [];
    end
    
    //get binary length for main part, binary length for fractional part, minimum and maximum value of NumberIn and NumberOut
    [BinLen, err] = get_param(param, "binary_length", 8);
    [BinLen_FracPart, err] = get_param(param, "binary_length_fractional_part", 8);
    Max_Bin = 2^BinLen - 1;
    Max_Bin_FracPart = 2^BinLen_FracPart - 1;
    [MinBounds, err] = get_param(param, "minbound", -0.5 * Max_Bin);
    [MaxBounds, err] = get_param(param, "maxbound",  0.5 * Max_Bin);
    
    //calculate number of digits which can be safely used to code the fraction in binary
    numberOfDigitsAvailable = length(string(Max_Bin_FracPart)) - 1;
    //calculate maximum number which can be safely code to the binary fraction
    maximumFractionalDecimal = 10^numberOfDigitsAvailable - 1;
    
    
    
    // A template of zeros to be sure that the binary code will be binary_length bits long
    template  = strsubst(dec2bin(Max_Bin, BinLen), "1", "0");
    //if the coding is selected
    if (direction == "code") then
        
        
        NumberOut = emptystr();
        
        //calculate the whole bValue with fractional part
        bValue = (NumberIn - MinBounds) * Max_Bin / (MaxBounds - MinBounds)
        
        //convert only integer part to binary code with the specific binary length
        bValueBinary = dec2bin(floor(bValue), BinLen)
        //if length of binary value is lower than the maximum binary length, join part of the template string with the calculated binary value
        if length(bValueBinary) < BinLen then
            bValueBinary = part(template, 1:BinLen-length(bValueBinary)) + bValueBinary;
        end
        
        
        //get fractional part from the bValue
        bValueFractionalPartOnly = abs(GetFractionalPart(bValue));
        
        //if it is not possible to code fractional part due to small binary length, set zeros
        templateFractional  = strsubst(dec2bin(Max_Bin_FracPart, BinLen_FracPart), "1", "0");
        bValueFractionalBinary = templateFractional;
        if maximumFractionalDecimal >= 9 then
            
            //convert the fractional part to integer and round it
            bValueFractionalPartAsInteger = round(bValueFractionalPartOnly * 10^numberOfDigitsAvailable);

            //convert fractional part to binary code with the specific binary length
            bValueFractionalBinary = dec2bin(bValueFractionalPartAsInteger, BinLen_FracPart)
            //if length of fractional binary value is lower than the maximum fractional binary length, join part of the fractional template string with the calculated fractional binary value
            if length(bValueFractionalBinary) < BinLen_FracPart then
                bValueFractionalBinary = part(templateFractional, 1:BinLen_FracPart-length(bValueFractionalBinary)) + bValueFractionalBinary
            end
            
        end
        
        
        
        //create the whole string genome, including the fractional part (the whole binary length (or also string length) equals to "BinLen + BinLen_FracPart")
        NumberOut = bValueBinary + bValueFractionalBinary
        
        
    //else if decoding is selected
    elseif (direction == "decode") then
        

        
        NumberOut = MinBounds - 1;
        
        //get integer binary part
        bValueBinary = part(NumberIn, 1:BinLen);
        //get fractional binary part saved as integer
        bValueFractionalBinary = part(NumberIn, BinLen+1:BinLen+BinLen_FracPart);
        
        //convert the integer part to decimal
        bDecimalValue = bin2dec(bValueBinary)
        //convert the fractional part to decimal (integer)
        bDecimalValueFractionalPart = bin2dec(bValueFractionalBinary)
        
        
        //if the fractional part may contain valid data, convert the integer to fractional part
        if maximumFractionalDecimal >= 9 & numberOfDigitsAvailable > 0 then
            bDecimalValueFractionalPart = bDecimalValueFractionalPart / 10^numberOfDigitsAvailable;
        else
            //otherwise, set zero
            bDecimalValueFractionalPart = 0;
        end
        
        
        //if the integer value is higher or equal to zero, add the integer and fractional part together
        bValue = bDecimalValue;
        if bDecimalValue >= 0 then
            bValue = bDecimalValue + bDecimalValueFractionalPart
        else
            //otherwise, it is negative number, so different equation must be used
            bValue = bDecimalValue + (1 - bDecimalValueFractionalPart)
        end
        
        
        
        //decode the decimal value from the whole bValue with fractional part
        NumberOut = (MaxBounds - MinBounds) * (bValue / Max_Bin) + MinBounds;
        
        
    else
        error(sprintf(gettext("%s: wrong direction"), "GA_CodingBinary"));
    end
    
endfunction


function [outGenomeString]=GA_JoinGenome(inGenomeStringList)
    
    outGenomeString = emptystr();
    for i = 1 : 1 : length(inGenomeStringList)
        outGenomeString = outGenomeString + inGenomeStringList(i);
    end
    
endfunction


function [outGenomeStringList]=GA_SplitGenome(inGenomeString, binaryLengthPerSubGenome)
    
    outGenomeStringList = list();
    for i = 0 : 1 : (length(inGenomeString) / binaryLengthPerSubGenome) - 1
        outGenomeStringList($+1) = part(inGenomeString, (binaryLengthPerSubGenome * i) + 1 : binaryLengthPerSubGenome * (i+1));
    end
    
    
endfunction


function [isMultiple, numberOfMultiples]=GA_GenerateMultiplesByUsingProbabilities(probabilityArray)
    
    isMultiple = %f;
    numberOfMultiples = 0;
    
    //sets the generator to a uniform random number generator.
    rand("uniform");
    randomNumberBetweenZeroAndOne = rand();
    completeProbability = 0;
    for i = 1 : 1 : length(probabilityArray)
        completeProbability = completeProbability + probabilityArray(i);
        if randomNumberBetweenZeroAndOne <= completeProbability | i == length(probabilityArray) then
            numberOfMultiples = i - 1;
            break;
        end
    end
    if numberOfMultiples > 1 then
        isMultiple = %t;
    end
    
endfunction


function [indexIndividual]=GA_GetIndividualIndexByUsingProbabilities(randomNumberBetweenZeroAndOne, selectedIndividualsProbabilities)
    
    indexIndividual = length(selectedIndividualsProbabilities) + 1;
    //if there is random number between 1 and 2 - it may happen in roulette wheel with stochastic universal sampling method, increase the number by 1
    if randomNumberBetweenZeroAndOne > 1 & randomNumberBetweenZeroAndOne <= 2 then
        randomNumberBetweenZeroAndOne = randomNumberBetweenZeroAndOne - 1;
        disp(["Warning! Random number is higher than 1 and less than 2! The random number was decreased by 1."; "Random number: " + string(randomNumberBetweenZeroAndOne) ; "Random number before: " + string(randomNumberBetweenZeroAndOne + 1) ; ]);
    //else if it is not between 0 and 1, end this function
    elseif randomNumberBetweenZeroAndOne < 0 | randomNumberBetweenZeroAndOne > 1 then
        disp(["Error! Random number is less than 0 or higher than 1!"; "Random number: " + string(randomNumberBetweenZeroAndOne) ; ])
        return;
    end
    
    completeProbability = 0;
    for i = 1 : 1 : length(selectedIndividualsProbabilities)
        completeProbability = completeProbability + selectedIndividualsProbabilities(i);
        if randomNumberBetweenZeroAndOne <= completeProbability | i == length(selectedIndividualsProbabilities) then
            indexIndividual = i;
            break;
        end
    end
    
endfunction


function [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation]=GA_SelectionFromCurrentGenerationAndCompletePopulation(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, requiredNumberOfValidIndividuals, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled)
    
    selectedIndividualsBinary = list();
    selectedIndividualsObjective = [];
    numberOfSelectedIndividualsFromCompletePopulation = 0;
    
    //check if the current generation and the complete population have enough valid individuals which DO depend on number of maximum selected individuals from complete population
    [haveEnoughValidIndividuals, numberOfValidIndividuals] = GA_HaveCurrentGenerationAndCompletePopulationEnoughValidIndividuals(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled, requiredNumberOfValidIndividuals);
    
    [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionValidIndividualsFromCurrentGenerationAndCompletePopulation(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled, requiredNumberOfValidIndividuals);
    
    
    if haveEnoughValidIndividuals == %f then
        
        if numberOfValidIndividuals <= 1 then
            messagebox(["Error! The whole population degenerated - no more than 1 individual was found in selection (1)!" ; "The Number of Valid Individuals: " + string(numberOfValidIndividuals) ; "The Number of necessary individuals: " + string(requiredNumberOfValidIndividuals) ; "The number of maximum selected individuals from complete population: " + string(maxCompletePopulationSelectedIndividuals) ; ], "modal", "error");
            return;
        end
        
        
        disp(["Warning! Enough valid individuals were not found in selection! The function performs extreme crossover (7 locations) and mutation (7 locations) to create new individuals." ; "The Number of Valid Individuals: " + string(numberOfValidIndividuals) ; "The Number of necessary individuals: " + string(requiredNumberOfValidIndividuals) ; "The number of maximum selected individuals from complete population: " + string(%inf) ; ]);
        
        
        neededNumberOfNewIndividuals = requiredNumberOfValidIndividuals - numberOfValidIndividuals;
        newIndividsBinary = list();
        newIndividsObjective = [];
        
        //sets the generator to a uniform random number generator.
        rand("uniform");
        //code the PID parameters to binary representation and add the result to the list
        for i = 1 : 2 : neededNumberOfNewIndividuals
            
            //generate indexes of the first and the second individual to crossover and mutation
            indexFirstIndividual = floor(rand() * length(selectedIndividualsBinary) + 1);
            indexSecondIndividual = indexFirstIndividual;
            while indexSecondIndividual == indexFirstIndividual
                indexSecondIndividual = floor(rand() * length(selectedIndividualsBinary) + 1);
            end
            
            //perform crossover for binary code
            param_newIndividsCrossover = init_param();
            param_newIndividsCrossover = add_param(param_newIndividsCrossover, "binary_length", length(selectedIndividualsBinary(1)));
            param_newIndividsCrossover = add_param(param_newIndividsCrossover, "multi_cross", %t);    // Multiple Crossover
            param_newIndividsCrossover = add_param(param_newIndividsCrossover, "multi_cross_nb", 7);  // Occurs over 7 locations
            [Crossed_Indiv1, Crossed_Indiv2, mix] = crossover_ga_binary(selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual), param_newIndividsCrossover);
            
            //perform binary mutation
            param_newIndividsMutation = init_param();
            param_newIndividsMutation = add_param(param_newIndividsMutation, "binary_length", length(selectedIndividualsBinary(1)));
            param_newIndividsMutation = add_param(param_newIndividsMutation, "multi_mut", %t);    // Multiple mutation
            param_newIndividsMutation = add_param(param_newIndividsMutation, "multi_mut_nb", 7);  // Occurs over 7 locations
            [Mut_Indiv1, pos1] = mutation_ga_binary(Crossed_Indiv1, param_newIndividsMutation);
            [Mut_Indiv2, pos2] = mutation_ga_binary(Crossed_Indiv2, param_newIndividsMutation);
            
            
            //add the first new binary individual
            newIndividsBinary($+1) = Mut_Indiv1;
            //add the first unknown (the worst) objective function value
            newIndividsObjective(1, size(newIndividsObjective, 2) + 1) = %inf;
            if length(newIndividsBinary) < neededNumberOfNewIndividuals then
                //add the second new binary individual
                newIndividsBinary($+1) = Mut_Indiv2;
                //add the second unknown (the worst) objective function value
                newIndividsObjective(1, size(newIndividsObjective, 2) + 1) = %inf;
            end
            
            
        end
        
        
        //join the list with binaries and the arrays with objective function values
        selectedIndividualsBinary = lstcat(selectedIndividualsBinary, newIndividsBinary);
        selectedIndividualsObjective = cat(2, selectedIndividualsObjective, newIndividsObjective);
        
        
    end
    
endfunction
//function [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation]=GA_SelectionFromCurrentGenerationAndCompletePopulation0(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, requiredNumberOfValidIndividuals, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled)
//    
//    selectedIndividualsBinary = list();
//    selectedIndividualsObjective = [];
//    numberOfSelectedIndividualsFromCompletePopulation = 0;
//    
//    //check if the current generation and the complete population have enough valid individuals which DO depend on number of maximum selected individuals from complete population
//    [haveEnoughValidIndividuals, numberOfValidIndividuals] = GA_HaveCurrentGenerationAndCompletePopulationEnoughValidIndividuals(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled, requiredNumberOfValidIndividuals);
//    
//    if haveEnoughValidIndividuals == %t then
//        
//        [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionValidIndividualsFromCurrentGenerationAndCompletePopulation(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled, requiredNumberOfValidIndividuals);
//        
//    else
//        
//        
//        disp(["Warning! Enough valid individuals were not found in selection (1)! The number of maximum selected individuals from complete population is set to infinite - the function will try it again." ; "The Number of Valid Individuals: " + string(numberOfValidIndividuals) ; "The Number of necessary individuals: " + string(requiredNumberOfValidIndividuals) ; "The number of maximum selected individuals from complete population: " + string(maxCompletePopulationSelectedIndividuals) ; ]);
//        
//        //check if the current generation and the complete population have enough valid individuals which DO NOT depend on number of maximum selected individuals from complete population
//        [haveEnoughValidIndividualsNoMax, numberOfValidIndividualsNoMax] = GA_HaveCurrentGenerationAndCompletePopulationEnoughValidIndividuals(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, %inf, individualsMayBeDoubled, requiredNumberOfValidIndividuals);
//        
//        if haveEnoughValidIndividualsNoMax == %t then
//            
//            [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionValidIndividualsFromCurrentGenerationAndCompletePopulation(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, %inf, individualsMayBeDoubled, requiredNumberOfValidIndividuals);
//            
//        else
//            
//            disp(["Warning! Enough valid individuals were not found in selection (2)! The number of maximum selected individuals from complete population is set to infinite, and the individuals may be two times in the selection - the function will try it again." ; "The Number of Valid Individuals: " + string(numberOfValidIndividualsNoMax) ; "The Number of necessary individuals: " + string(requiredNumberOfValidIndividuals) ; "The number of maximum selected individuals from complete population: " + string(%inf) ; ]);
//            
//           //check if the current generation and the complete population have enough valid individuals which DO NOT depend on number of maximum selected individuals from complete population and the individuals may be two times in the selection
//            [haveEnoughValidIndividualsNoMaxAndDoubled, numberOfValidIndividualsNoMaxAndDoubled] = GA_HaveCurrentGenerationAndCompletePopulationEnoughValidIndividuals(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, %inf, %t, requiredNumberOfValidIndividuals);
//            
//            [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation] = GA_SelectionValidIndividualsFromCurrentGenerationAndCompletePopulation(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, %inf, %t, requiredNumberOfValidIndividuals);
//            
//            
//            if haveEnoughValidIndividualsNoMaxAndDoubled == %f then
//                
//                
//                if numberOfValidIndividualsNoMaxAndDoubled <= 1 then
//                    messagebox(["Error! The whole population degenerates - no more than 1 individual was found in selection (3)!" ; "The Number of Valid Individuals: " + string(numberOfValidIndividualsNoMaxAndDoubled) ; "The Number of necessary individuals: " + string(requiredNumberOfValidIndividuals) ; "The number of maximum selected individuals from complete population: " + string(%inf) ; ], "modal", "error");
//                    return;
//                end
//                
//                
//                disp(["Warning! Enough valid individuals were not found in selection (3)! The function performs extreme crossover (7 locations) and mutation (7 locations) to create new individuals." ; "The Number of Valid Individuals: " + string(numberOfValidIndividualsNoMaxAndDoubled) ; "The Number of necessary individuals: " + string(requiredNumberOfValidIndividuals) ; "The number of maximum selected individuals from complete population: " + string(%inf) ; ]);
//                
//                
//                neededNumberOfNewIndividuals = requiredNumberOfValidIndividuals - numberOfValidIndividualsNoMaxAndDoubled;
//                newIndividsBinary = list();
//                newIndividsObjective = [];
//                
//                //sets the generator to a uniform random number generator.
//                rand("uniform");
//                //code the PID parameters to binary representation and add the result to the list
//                for i = 1 : 2 : neededNumberOfNewIndividuals
//                    
//                    //generate indexes of the first and the second individual to crossover and mutation
//                    indexFirstIndividual = floor(rand() * length(completePopulationBinary) + 1);
//                    indexSecondIndividual = indexFirstIndividual;
//                    while indexSecondIndividual == indexFirstIndividual
//                        indexSecondIndividual = floor(rand() * length(completePopulationBinary) + 1);
//                    end
//                    
//                    //perform crossover for binary code
//                    param_newIndividsCrossover = init_param();
//                    param_newIndividsCrossover = add_param(param_newIndividsCrossover, "binary_length", length(completePopulationBinary(1)));
//                    param_newIndividsCrossover = add_param(param_newIndividsCrossover, "multi_cross", %t);    // Multiple Crossover
//                    param_newIndividsCrossover = add_param(param_newIndividsCrossover, "multi_cross_nb", 7);  // Occurs over 7 locations
//                    [Crossed_Indiv1, Crossed_Indiv2, mix] = crossover_ga_binary(completePopulationBinary(indexFirstIndividual), completePopulationBinary(indexSecondIndividual), param_newIndividsCrossover);
//                    
//                    //perform binary mutation
//                    param_newIndividsMutation = init_param();
//                    param_newIndividsMutation = add_param(param_newIndividsMutation, "binary_length", length(completePopulationBinary(1)));
//                    param_newIndividsMutation = add_param(param_newIndividsMutation, "multi_mut", %t);    // Multiple mutation
//                    param_newIndividsMutation = add_param(param_newIndividsMutation, "multi_mut_nb", 7);  // Occurs over 7 locations
//                    [Mut_Indiv1, pos1] = mutation_ga_binary(Crossed_Indiv1, param_newIndividsMutation);
//                    [Mut_Indiv2, pos2] = mutation_ga_binary(Crossed_Indiv2, param_newIndividsMutation);
//                    
//                    
//                    //add the first new binary individual
//                    newIndividsBinary($+1) = Mut_Indiv1;
//                    //add the first unknown (the worst) objective function value
//                    newIndividsObjective(1, size(newIndividsObjective, 2) + 1) = %inf;
//                    if length(newIndividsBinary) < neededNumberOfNewIndividuals then
//                        //add the second new binary individual
//                        newIndividsBinary($+1) = Mut_Indiv2;
//                        //add the second unknown (the worst) objective function value
//                        newIndividsObjective(1, size(newIndividsObjective, 2) + 1) = %inf;
//                    end
//                    
//                    
//                end
//                
//                
//                //join the list with binaries and the arrays with objective function values
//                selectedIndividualsBinary = lstcat(selectedIndividualsBinary, newIndividsBinary);
//                selectedIndividualsObjective = cat(2, selectedIndividualsObjective, newIndividsObjective);
//                
//                
//            end
//            
//            
//        end
//        
//        
//    end
//    
//endfunction


function [selectedIndividualsBinary, selectedIndividualsObjective, numberOfSelectedIndividualsFromCompletePopulation]=GA_SelectionValidIndividualsFromCurrentGenerationAndCompletePopulation(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled, requiredNumberOfValidIndividuals)
    
    selectedIndividualsBinary = list();
    selectedIndividualsObjective = [];
    numberOfSelectedIndividualsFromCompletePopulation = 0;
    
    
    SelectedIndividualsFromCompletePopulation = list();
    SelectedIndividualsFromCompletePopulationObjective = [];
    numberOfIndividualsFromCompletePopulation = 0;
    //get possible original individuals from complete population depending on maximum number of individuals
    if numberOfIndividualsFromCompletePopulation < maxCompletePopulationSelectedIndividuals then
        for i = 1 : 1 : length(completePopulationObjective)
            //if objective function value is lower than infinite and higher than 0, the adjustment might be usable
            if completePopulationObjective(i) < %inf & completePopulationObjective(i) >= 0 then
                //if individuals cannot be doubled, check the current generation; in other words, individuals cannot be already in current generation
                if individualsMayBeDoubled == %f then
                    isFoundInCurrentGeneration = %f;
                    for j = 1 : 1 : length(currentGenerationBinary)
                        if currentGenerationBinary(j) == completePopulationBinary(i) then
                            isFoundInCurrentGeneration = %t;
                            break;
                        end
                    end
                    if isFoundInCurrentGeneration == %f then
                        SelectedIndividualsFromCompletePopulation($+1) = completePopulationBinary(i);
                        SelectedIndividualsFromCompletePopulationObjective(1, size(SelectedIndividualsFromCompletePopulationObjective, 2) + 1) = completePopulationObjective(i);
                        numberOfIndividualsFromCompletePopulation = numberOfIndividualsFromCompletePopulation + 1;
                    end
                //otherwise, individuals from complete population can be also in current generation
                else
                    SelectedIndividualsFromCompletePopulation($+1) = completePopulationBinary(i);
                    SelectedIndividualsFromCompletePopulationObjective(1, size(SelectedIndividualsFromCompletePopulationObjective, 2) + 1) = completePopulationObjective(i);
                    numberOfIndividualsFromCompletePopulation = numberOfIndividualsFromCompletePopulation + 1;
                end
                if numberOfIndividualsFromCompletePopulation >= maxCompletePopulationSelectedIndividuals then
                    break;
                end
            end
        end
    end
    
    //go through population size in the current generation
    for i = 1 : 1 : length(currentGenerationObjective)
        //if objective function value is lower than infinite and higher than 0, the adjustment might be usable
        if length(selectedIndividualsBinary) < requiredNumberOfValidIndividuals then
            if currentGenerationObjective(i) < %inf & currentGenerationObjective(i) >= 0 then
                
                //check if possibly selected individual from complete population has better objective function value
                for j = numberOfSelectedIndividualsFromCompletePopulation + 1 : 1 : length(SelectedIndividualsFromCompletePopulationObjective)
                    
                    if SelectedIndividualsFromCompletePopulationObjective(j) < currentGenerationObjective(i) then
                        
                        selectedIndividualsBinary($+1) = SelectedIndividualsFromCompletePopulation(j);
                        selectedIndividualsObjective(1, size(selectedIndividualsObjective, 2) + 1) = SelectedIndividualsFromCompletePopulationObjective(j);
                        numberOfSelectedIndividualsFromCompletePopulation = numberOfSelectedIndividualsFromCompletePopulation + 1;
                        
                    end
                    
                end
                
                if length(selectedIndividualsBinary) < requiredNumberOfValidIndividuals then
                    
                    selectedIndividualsBinary($+1) = currentGenerationBinary(i);
                    selectedIndividualsObjective(1, size(selectedIndividualsObjective, 2) + 1) = currentGenerationObjective(i);
                    
                else
                    break;
                end
                
            end
        else
            break;
        end
    end
    
endfunction


function [haveEnoughValidIndividuals, numberOfValidIndividuals]=GA_HaveCurrentGenerationAndCompletePopulationEnoughValidIndividuals(currentGenerationBinary, currentGenerationObjective, completePopulationBinary, completePopulationObjective, maxCompletePopulationSelectedIndividuals, individualsMayBeDoubled, requiredNumberOfValidIndividuals)
    
    haveEnoughValidIndividuals = %f;
    numberOfValidIndividuals = 0;
    
    //go through population size in the current generation
    for i = 1 : 1 : length(currentGenerationObjective)
        //if objective function value is lower than infinite and higher than 0, the adjustment might be usable
        if currentGenerationObjective(i) < %inf & currentGenerationObjective(i) >= 0 then
            numberOfValidIndividuals = numberOfValidIndividuals + 1;
        end
    end
    numberOfCompletePopulationSelectedIndividuals = 0;
    if numberOfCompletePopulationSelectedIndividuals < maxCompletePopulationSelectedIndividuals then
        for i = 1 : 1 : length(completePopulationObjective)
            //if objective function value is lower than infinite and higher than 0, the adjustment might be usable
            if completePopulationObjective(i) < %inf & completePopulationObjective(i) >= 0 then
                //if individuals cannot be doubled, check the current generation; in other words, individuals cannot be already in current generation
                if individualsMayBeDoubled == %f then
                    isFoundInCurrentGeneration = %f;
                    for j = 1 : 1 : length(currentGenerationBinary)
                        if currentGenerationBinary(j) == completePopulationBinary(i) then
                            isFoundInCurrentGeneration = %t;
                            break;
                        end
                    end
                    if isFoundInCurrentGeneration == %f then
                        numberOfValidIndividuals = numberOfValidIndividuals + 1;
                        numberOfCompletePopulationSelectedIndividuals = numberOfCompletePopulationSelectedIndividuals + 1;
                    end
                //otherwise, individuals from complete population can be also in current generation
                else
                    numberOfValidIndividuals = numberOfValidIndividuals + 1;
                    numberOfCompletePopulationSelectedIndividuals = numberOfCompletePopulationSelectedIndividuals + 1;
                end
                if numberOfCompletePopulationSelectedIndividuals >= maxCompletePopulationSelectedIndividuals then
                    break;
                end
            end
        end
    end
    
    //because two child individuals are created after crossover, we need a half individuals only than the population (generation) size is
    if numberOfValidIndividuals >= requiredNumberOfValidIndividuals then
        haveEnoughValidIndividuals = %t;
    end
    
endfunction


function [pairsOfSelectedIndividuals, pairsOfSelectedIndividualsIndexes]=GA_CreatePairsFromSelectedIndividuals(selectedIndividualsBinary, selectedIndividualsObjective, SelectionMode, requiredNumberOfPairs)
    
    global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs;
    global GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce;
    global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals;
    global GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce;
    global GA_CreatePairs_SelectionMode_TournamentPairs;
    global GA_CreatePairs_SelectionMode_RouletteWheelPairs
    global GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling;
    global GA_CreatePairs_SelectionMode_RandomPairs;
    pairsOfSelectedIndividuals = list();
    pairsOfSelectedIndividualsIndexes = list();
    
    //if there are not enough pairs
    if length(selectedIndividualsBinary) < 2 then
        messagebox(["Error! There are not enough individuals in the list - at least two are necessary! (GA_CreatePairsFromSelectedIndividuals function)" ; "Number of Individuals: " + string(length(selectedIndividualsBinary))], "modal", "error");
        return;
    end
    
    //because of Scilab issues with higher values of input parameter put in factorial function, we have to check the result (input parameter >170 gives infinite as the result)
    maximumPossiblePairs = factorial(length(selectedIndividualsBinary));
    if maximumPossiblePairs < %inf then
        maximumPossiblePairs = maximumPossiblePairs / (factorial(length(selectedIndividualsBinary) - 2) * 2);
    end
    //if there are less maximum possible pairs than it is required
    if maximumPossiblePairs < requiredNumberOfPairs then
        messagebox(["Error! There are less maximum possible pairs than it is required! (GA_CreatePairsFromSelectedIndividuals function)" ; "Maximum Possible Pairs: " + string(maximumPossiblePairs) ; "Required Number of Pairs: " + string(requiredNumberOfPairs)], "modal", "error");
        return;
    end
    
    
    //create pairs from best pairs to worst pairs
    //for example for 6 individuals, there can be maximum 15 unique combinations which are generated with the following order: [1,2] ; [2,3] ; [3,4] ; [4,5] ; [5,6] ; [1,3] ; [2,4] ; [3,5] ; [4,6] ; [1,4] ; [2,5] ; [3,6] ; [1,5] ; [2,6] ; [1,6]
    if SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs, " ", ""), 'l') then
        
        indexFirstIncrement = 1;
        indexSecondIncrement = 1;
        while length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
            
            for indexFirstIndividual = 1 : indexFirstIncrement : length(selectedIndividualsBinary)
                
                indexSecondIndividual = indexFirstIndividual + indexSecondIncrement;
                if indexSecondIndividual <= length(selectedIndividualsBinary) & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                    
                    pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
                    pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
                    
                elseif indexFirstIndividual == 1 & indexSecondIndividual > length(selectedIndividualsBinary) & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                    
                    disp(["Warning! The Required Number of Pairs (" + string(requiredNumberOfPairs) + ") was not achieved!" ; "Current number of Pairs: " + string(length(pairsOfSelectedIndividuals)) ; ]);
                    return;
                    
                else
                    
                    break;
                    
                end
                
            end
            indexSecondIncrement = indexSecondIncrement + 1;
            
        end
        
        
    //create pairs from best pairs to worst pairs but each individual may be used only once
    //for example for 6 individuals, there will be the following (6/2=3) combinations: [1,2] ; [3,4] ; [5,6]
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce, " ", ""), 'l') then
        
        indexFirstIncrement = 2;
        indexSecondIncrement = 1;
        for indexFirstIndividual = 1 : indexFirstIncrement : length(selectedIndividualsBinary)

            indexSecondIndividual = indexFirstIndividual + indexSecondIncrement;
            if indexSecondIndividual <= length(selectedIndividualsBinary) & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                
                pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
                pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
                
            //else if there is last individual only, pair it with the first (it may happen only in the case when the population size is uneven (odd) number)
            elseif indexSecondIndividual > length(selectedIndividualsBinary) & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                
                pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(1)];
                pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, 1];
                
            end
            
            if length(pairsOfSelectedIndividuals) >= requiredNumberOfPairs
                break;
            end
            
        end
        
        
    //create pairs where the best individuals are firstly combined with the worst pairs
    //for example for 6 individuals, there can be maximum 15 unique combinations which are generated with the following order: [1,6] ; [1,5] ; [2,6] ; [1,4] ; [2,5] ; [3,6] ; [1,3] ; [2,4] ; [3,5] ; [4,6] ; [1,2] ; [2,3] ; [3,4] ; [4,5] ; [5,6]
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals, " ", ""), 'l') then
        
        indexFirstIncrement = 1;
        indexSecondIncrement = length(selectedIndividualsBinary) - 1;
        while length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
            
            for indexFirstIndividual = 1 : indexFirstIncrement : length(selectedIndividualsBinary)
                
                indexSecondIndividual = indexFirstIndividual + indexSecondIncrement;
                if indexSecondIncrement > 0 & indexSecondIndividual > 0 & indexSecondIndividual <= length(selectedIndividualsBinary) & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                    
                    pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
                    pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
                    
                elseif indexSecondIncrement <= 0 & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                    
                    disp(["Warning! The Required Number of Pairs (" + string(requiredNumberOfPairs) + ") was not achieved!" ; "Current number of Pairs: " + string(length(pairsOfSelectedIndividuals)) ; ]);
                    return;
                    
                else
                    
                    break;
                    
                end
                
            end
            indexSecondIncrement = indexSecondIncrement - 1;
            
        end
        
        
    //create pairs where the best individuals are firstly combined with the worst pairs but each individual may be used only once
    //for example for 6 individuals, there will be the following (6/2=3) combinations: [1,6] ; [2,5] ; [3,4]
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce, " ", ""), 'l') then
        
        indexFirstIncrement = 1;
        indexSecondIncrement = length(selectedIndividualsBinary) - 1;
        for indexFirstIndividual = 1 : indexFirstIncrement : length(selectedIndividualsBinary)
            
            indexSecondIndividual = indexFirstIndividual + indexSecondIncrement;
            if indexSecondIncrement > 0 & indexSecondIndividual > 0 & indexSecondIndividual <= length(selectedIndividualsBinary) & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                
                pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
                pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
                
            //else if there is last individual only, pair it with the first (it may happen only in the case when the population size is uneven (odd) number)
            elseif indexSecondIncrement <= 0 & length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
                
                pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(1)];
                pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, 1];
                
            end
            
            if length(pairsOfSelectedIndividuals) >= requiredNumberOfPairs
                break;
            end
            
            indexSecondIncrement = indexSecondIncrement - 2;
        end
        
        
    //create pairs where the individuals are selected using tournament selection method with checking whether the individual is randomly selected once only; moreover, the same pair cannot be selected twice.
    //THE FOLLOWING CODE ASSUMES THAT THE INDIVIDUALS ARE SORTED BY OBJECTIVE FUNCTION VALUE WHERE THE FIRST INDEX IS THE BEST INDIVIDUAL!
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_TournamentPairs, " ", ""), 'l') then
        
        //check if there are enough number of individuals, if they are not, decrease the number of selected individuals in tournament
        global GA_SelectionMode_TournamentPairs_SelectedIndividuals;
        tournamentPairs_SelectedIndividuals = GA_SelectionMode_TournamentPairs_SelectedIndividuals;
        if tournamentPairs_SelectedIndividuals >= length(selectedIndividualsBinary) then
            tournamentPairs_SelectedIndividuals = length(selectedIndividualsBinary) - 1;
        end
        //sets the generator to a uniform random number generator.
        rand("uniform");
        while length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
            
            //set zero indexes of the first and the second individual to crossover and mutate
            indexFirstIndividual = 0;
            indexSecondIndividual = indexFirstIndividual;
            
            //generate two tournaments to get two different individuals
            for individualNo = 1 : 1 : 2
                
                //generate the specific number of individuals who participate tournament
                tournamentIndividualsIndexes = list();
                for i = 1 : 1 : tournamentPairs_SelectedIndividuals
                    
                    indexForTournament = floor(rand() * length(selectedIndividualsBinary) + 1);
                    foundInTournament = %t;
                    while foundInTournament == %t
                        //go through all current individuals in tournament and check if this generated index is already there
                        foundInTournament = %f;
                        for j = 1 : 1 : length(tournamentIndividualsIndexes)
                            //check also the constraint; moreover, check whether it was not selected from the first tournament
                            if indexForTournament > length(selectedIndividualsBinary)  |  tournamentIndividualsIndexes(j) == indexForTournament then
                                foundInTournament = %t;
                                break;
                            end
                        end
                        //if the individual is already in tournament, or it is winner of the first tournament, generate new index and set the cycle condition to true
                        if foundInTournament == %t | indexFirstIndividual == indexForTournament then
                            indexForTournament = floor(rand() * length(selectedIndividualsBinary) + 1);
                            foundInTournament = %t;
                        end
                    end
                    tournamentIndividualsIndexes($+1) = indexForTournament;
                    
                end
                //find the lowest index (perform tournament) and set the individual
                if individualNo == 1 then
                    indexFirstIndividual = min(tournamentIndividualsIndexes);
                else
                    indexSecondIndividual = min(tournamentIndividualsIndexes);
                end
                
            end
            
            
            //go through all pairs which were created and check if there is already this pair
            foundInPairs = %f;
            for i = 1 : 1 : length(pairsOfSelectedIndividuals)
                if pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexSecondIndividual)  |  pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexSecondIndividual) then
                    foundInPairs = %t;
                    break;
                end
            end
            
            if foundInPairs == %f then
                pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
                pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
            end
            
        end
        
        
    //create pairs where the individuals are selected using Roulette Wheel method; however, the same pair cannot be selected twice
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_RouletteWheelPairs, " ", ""), 'l') then
        
        //remove Infinite values - to work properly, when it is joint back together, it needs objective function values to be sorted from lowest to highest (or no infinite values)
        [selectedIndividualsObjectiveWithoutInfinite, selectedIndividualsObjectiveInfiniteOnly] = RemoveInfinitesFromArray(selectedIndividualsObjective)
        maximumOfSelectedIndividualsObjectiveWithoutInfinite =  max(selectedIndividualsObjectiveWithoutInfinite);
        //change values of infinites to 2 times higher than maximum value
        for i = 1 : 1 : length(selectedIndividualsObjectiveInfiniteOnly)
            selectedIndividualsObjectiveInfiniteOnly(i) = 2 * maximumOfSelectedIndividualsObjectiveWithoutInfinite;
        end
        selectedIndividualsObjectiveJoinInfinite = cat(2, selectedIndividualsObjectiveWithoutInfinite, selectedIndividualsObjectiveInfiniteOnly);
        
        //calculate normalized fitness function value - 1.01 means that the worst solution will have normalized fitness function value 0.01 - if you want to ignore infinites and the worst solutions, set it to 1.00
        selectedIndividualsFitnessNormalized = 1.01 - selectedIndividualsObjectiveJoinInfinite / max(selectedIndividualsObjectiveJoinInfinite);
        //calculate probabilities using the fitness normalized values
        selectedIndividualsProbabilities = selectedIndividualsFitnessNormalized / sum(selectedIndividualsFitnessNormalized);
        if string(sum(selectedIndividualsProbabilities)) ~= string(1) then
            messagebox(["Warning! The Sum of Probabilities of individuals to be selected is not equal to 1 (the last individuals may not ever be selected)!" ; "The sum of Probabilities = " + string(sum(selectedIndividualsProbabilities)) ], "modal", "error");
            return
        end
        
        //sets the generator to a uniform random number generator.
        rand("uniform");
        //generate indexes of the first and the second individual to crossover and mutation
        while length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
            
            //generate first random number and get corresponding index using probability array
            firstRandom = rand();
            indexFirstIndividual = GA_GetIndividualIndexByUsingProbabilities(firstRandom, selectedIndividualsProbabilities);
            secondRandom = firstRandom;
            indexSecondIndividual = indexFirstIndividual;
            foundInPairs = %t;
            //if indexes are same or the pair is already in the list, generate new second index
            while indexSecondIndividual == indexFirstIndividual | foundInPairs == %t
                
                //generate new second random number and get corresponding index using probability array

                secondRandom = rand();
                indexSecondIndividual = GA_GetIndividualIndexByUsingProbabilities(secondRandom, selectedIndividualsProbabilities);
                
                //go through all pairs which were created and check if there is already this pair
                foundInPairs = %f;
                for i = 1 : 1 : length(pairsOfSelectedIndividuals)
                    if indexFirstIndividual > length(selectedIndividualsBinary) | indexSecondIndividual > length(selectedIndividualsBinary)  |  pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexSecondIndividual)  |  pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexSecondIndividual) then
                        foundInPairs = %t;
                        break;
                    end
                end
                
                //if they were found in list with pairs, generate new index number one
                if foundInPairs == %t then
                    firstRandom = rand();
                    indexFirstIndividual = GA_GetIndividualIndexByUsingProbabilities(firstRandom, selectedIndividualsProbabilities);
                end
                
            end
            
            pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
            pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
            
        end
        
        
    //create pairs where the individuals are selected using Roulette Wheel method with Stochastic Universal Sampling upgrade; however, the same pair cannot be selected twice
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling, " ", ""), 'l') then
        
        
        //remove Infinite values - to work properly, when it is joint back together, it needs objective function values to be sorted from lowest to highest (or no infinite values)
        [selectedIndividualsObjectiveWithoutInfinite, selectedIndividualsObjectiveInfiniteOnly] = RemoveInfinitesFromArray(selectedIndividualsObjective)
        maximumOfSelectedIndividualsObjectiveWithoutInfinite =  max(selectedIndividualsObjectiveWithoutInfinite);
        //change values of infinites to 2 times higher than maximum value
        for i = 1 : 1 : length(selectedIndividualsObjectiveInfiniteOnly)
            selectedIndividualsObjectiveInfiniteOnly(i) = 2 * maximumOfSelectedIndividualsObjectiveWithoutInfinite;
        end
        selectedIndividualsObjectiveJoinInfinite = cat(2, selectedIndividualsObjectiveWithoutInfinite, selectedIndividualsObjectiveInfiniteOnly);
        
        //calculate normalized fitness function value - 1.01 means that the worst solution will have normalized fitness function value 0.01 - if you want to ignore infinites and the worst solutions, set it to 1.00
        selectedIndividualsFitnessNormalized = 1.01 - selectedIndividualsObjectiveJoinInfinite / max(selectedIndividualsObjectiveJoinInfinite);
        //calculate probabilities using the fitness normalized values
        selectedIndividualsProbabilities = selectedIndividualsFitnessNormalized / sum(selectedIndividualsFitnessNormalized);
        if string(sum(selectedIndividualsProbabilities)) ~= string(1) then
            disp(["Warning! The Sum of Probabilities of individuals to be selected is not equal to 1 (the last individuals may not ever be selected)!" ; "The sum of Probabilities = " + string(sum(selectedIndividualsProbabilities)) ; ]);
        end
        
        //sets the generator to a uniform random number generator.
        rand("uniform");
        //generate indexes of the first and the second individual to crossover and mutation
        while length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
            
            //generate start random number and get corresponding index using probability array
            firstRandom = rand();
            indexFirstIndividual = GA_GetIndividualIndexByUsingProbabilities(firstRandom, selectedIndividualsProbabilities);
            selectedIndexIndividualsFromRoulette = list(indexFirstIndividual);
            //calculate sampling constant for probability increase - because this code may be executed more than once, some individuals might be in pairs, so we can generate less individuals and, in addition, we may use higher sampling length
            samplingStepConstant = 1 / (length(selectedIndividualsProbabilities) - length(pairsOfSelectedIndividuals));
            //if sampling step constant is one, it has to be decreased (because same individual would be selected twice - this may happen if only one pair remains which would result in endless loop)
            if samplingStepConstant == 1 then
                samplingStepConstant = samplingStepConstant / 2;
            end
            //disp(["First Random: " + string(firstRandom) ; "samplingStepConstant: " + string(samplingStepConstant) ; "length(selectedIndividualsProbabilities): " + string(length(selectedIndividualsProbabilities)) ; "length(pairsOfSelectedIndividuals)" + string(length(pairsOfSelectedIndividuals)) ; ]);  //<>debug only
            //select all other individuals using stochastic universal sampling method; however, it may contain same individuals. Moreover, some individuals might be also in pairs, so generate only necessary number of individuals
            folloowingSampledRandom = firstRandom;
            for i = 1 : 1 : length(selectedIndividualsProbabilities) - length(pairsOfSelectedIndividuals)
                folloowingSampledRandom = folloowingSampledRandom + samplingStepConstant;
                folloowingSampledIndexIndividual = GA_GetIndividualIndexByUsingProbabilities(folloowingSampledRandom, selectedIndividualsProbabilities);
                selectedIndexIndividualsFromRoulette($+1) = folloowingSampledIndexIndividual;
                //disp(["Folloowing Sampled Random Random: " + string(folloowingSampledRandom) ; "samplingStepConstant: " + string(samplingStepConstant) ; ]);  //<>debug only
            end
            
            //while there are still some indexes, try to select pairs except the situation when the first index is equla to or higher than the length of selected individuals from roulette - it means there are same individuals only or all the valid pairs from these selected individuals from roulette was already created before
            indexFirstInSelectedIndexIndividualsFromRoulette = 1;
            while length(selectedIndexIndividualsFromRoulette) > 0 & indexFirstInSelectedIndexIndividualsFromRoulette < length(selectedIndexIndividualsFromRoulette)
                
                indexFirstIndividual = selectedIndexIndividualsFromRoulette(indexFirstInSelectedIndexIndividualsFromRoulette);
                indexSecondIndividual = indexFirstIndividual;
                pairCanBeAdded = %f;
                indexSecondInSelectedIndexIndividualsFromRoulette = 2;
                for indexSecondInSelectedIndexIndividualsFromRoulette = 2 : 1 : length(selectedIndexIndividualsFromRoulette)
                    indexSecondIndividual = selectedIndexIndividualsFromRoulette(indexSecondInSelectedIndexIndividualsFromRoulette);
                    if indexSecondIndividual ~= indexFirstIndividual then
                        
                        //go through all pairs which were created and check if there is already this pair
                        foundInPairs = %f;
                        for i = 1 : 1 : length(pairsOfSelectedIndividuals)
                            if indexFirstIndividual > length(selectedIndividualsBinary) | indexSecondIndividual > length(selectedIndividualsBinary)  |  pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexSecondIndividual)  |  pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexSecondIndividual) then
                                foundInPairs = %t;
                                break;
                            end
                        end
                        
                        //if they were not found in list with pairs, the pair can be added in the pair list
                        if foundInPairs == %f then
                            pairCanBeAdded = %t;
                            break;
                        end
                        
                    end
                end
                
                
                //if the pair can be added
                if pairCanBeAdded == %t then
                    
                    //disp(["Added/Deleted: " ; ]);  //<>debug only
                    //delete them from selected individuals using roulette
                    selectedIndexIndividualsFromRoulette(indexFirstInSelectedIndexIndividualsFromRoulette) = null();
                    selectedIndexIndividualsFromRoulette(indexSecondInSelectedIndexIndividualsFromRoulette) = null();
                    //set the first index for selection from selected individuals from roulette to initial value
                    indexFirstInSelectedIndexIndividualsFromRoulette = 1;
                    //add pairs and their indexes to the lists
                    pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
                    pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
                    
                else
                    //disp(["Increased: " ; "indexFirstInSelectedIndexIndividualsFromRoulette: " + string(indexFirstInSelectedIndexIndividualsFromRoulette) ; "length(selectedIndexIndividualsFromRoulette): " + string(length(selectedIndexIndividualsFromRoulette)) ]);  //<>debug only
                    //increment first index for selection from selected individuals from roulette 
                    indexFirstInSelectedIndexIndividualsFromRoulette = indexFirstInSelectedIndexIndividualsFromRoulette + 1;
                end
                
            end
            
        end
        
        
    //create pairs where the individuals are selected randomly; however, the same pair cannot be selected twice
    elseif SelectionMode == convstr(strsubst(GA_CreatePairs_SelectionMode_RandomPairs, " ", ""), 'l') then
        
        //sets the generator to a uniform random number generator.
        rand("uniform");
        while length(pairsOfSelectedIndividuals) < requiredNumberOfPairs
            
            //generate indexes of the first and the second individual to crossover and mutation
            indexFirstIndividual = floor(rand() * length(selectedIndividualsBinary) + 1);
            indexSecondIndividual = indexFirstIndividual;
            foundInPairs = %t;
            //if indexes are same or the pair is already in the list, generate new second index
            while indexSecondIndividual == indexFirstIndividual | foundInPairs == %t
                
                //generate new index two
                indexSecondIndividual = floor(rand() * length(selectedIndividualsBinary) + 1);
                
                //go through all pairs which were created and check if there is already this pair
                foundInPairs = %f;
                for i = 1 : 1 : length(pairsOfSelectedIndividuals)
                    if indexFirstIndividual > length(selectedIndividualsBinary) | indexSecondIndividual > length(selectedIndividualsBinary)  |  pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexSecondIndividual)  |  pairsOfSelectedIndividuals(i)(2) == selectedIndividualsBinary(indexFirstIndividual) & pairsOfSelectedIndividuals(i)(1) == selectedIndividualsBinary(indexSecondIndividual) then
                        foundInPairs = %t;
                        break;
                    end
                end
                
                //if they were found in list with pairs, generate new index one
                if foundInPairs == %t then
                    indexFirstIndividual = floor(rand() * length(selectedIndividualsBinary) + 1);
                end
                
            end
            
            pairsOfSelectedIndividuals($+1) = [selectedIndividualsBinary(indexFirstIndividual), selectedIndividualsBinary(indexSecondIndividual)];
            pairsOfSelectedIndividualsIndexes($+1) = [indexFirstIndividual, indexSecondIndividual];
            
        end
        
        
    else
        
        messagebox(["Error! Selection Mode is not valid! (GA_CreatePairsFromSelectedIndividuals function)" ; "Current Selection Mode: " + SelectionMode ; "The Valid Selection Modes: " + GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs + """, """ + GA_CreatePairs_SelectionMode_FromBestPairsToWorstPairs_IndividualOnce + """, """ + GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals + """, """ + GA_CreatePairs_SelectionMode_BestIndividualsWithWorstIndividuals_IndividualOnce + """, """ + GA_CreatePairs_SelectionMode_TournamentPairs + """, """ + GA_CreatePairs_SelectionMode_RouletteWheelPairs + """, """ + GA_CreatePairs_SelectionMode_RouletteWheelPairs_StochasticUniversalSampling + """, and """ + GA_CreatePairs_SelectionMode_RandomPairs + """"], "modal", "error");
        return;
        
    end
    
endfunction



function [objectiveFunctionValue]=CalculateObjectiveFunction(valuesList, weightsList)
    
    objectiveFunctionValue = %inf;
    
    if length(valuesList) == length(weightsList) & length(valuesList) > 0 then
        
        objectiveFunctionValue = 0;
        for i = 1 : 1 : length(valuesList)
            
            objectiveFunctionValue = objectiveFunctionValue + (valuesList(i) * weightsList(i));
            
        end
        
    elseif length(valuesList) == length(weightsList) & length(valuesList) == 0 then
        
        disp(["Warning! Calculation of Objective Function cannot be completed, number of values and number of weights must be higher than 0! Result is set to Infinite!" ; ]);
        
    else
        
        disp(["Warning! Calculation of Objective Function cannot be completed, number of values must be same as number of weights! number of values: """ + string(length(valuesList)) + """, number of weights: """ + string(length(weightsList)) + """ (Result is set to Infinite!)" ; ]);
        
    end
    
endfunction




function [SumOfAbsoluteOutputError, AbsoluteRiseTimeError, SumOfAbsoluteOvershootError]=AnalyzeOutputErrorsOfData(partCSVvalues, outputRequiredValue, riseTimeRequiredValue)
    
    //SumOfTimeMultipliedByAbsoluteOutputError = %inf;
    SumOfAbsoluteOutputError = %inf;
    AbsoluteRiseTimeError = %inf;
    SumOfAbsoluteOvershootError = %inf;
    
    
    timeData = CSVvalues(:, 1);
    valuesData = CSVvalues(:, 2);
    
    
    global minimumNumberOfData;
    if size(timeData, 1) < minimumNumberOfData | size(valuesData, 1) < minimumNumberOfData then
        
        disp(["Warning (AnalyzeOutputErrorsOfData)! Number of data is lower than the currently global minimum number! No calculation was performed and all results are set to Infinite!" ; "Number of data: " + string(size(timeData, 1)) ; "global minimumNumberOfData: " + string(minimumNumberOfData) ; ]);
        return;
        
    elseif size(timeData, 1) ~= size(valuesData, 1) then
        
        disp(["Warning (AnalyzeOutputErrorsOfData)! Number of data is different! No calculation was performed and all results are set to Infinite!" ; "Number of time data: " + string(size(timeData, 1)) ; "Number of value data: " + string(size(valuesData, 1)) ; ]);
        return;
        
    end
    
    
    //calculate Sum of Time Multiplied by Absolute Output Error from data
    //SumOfTimeMultipliedByAbsoluteOutputError = CalculateSumOfTimeMultipliedByAbsoluteOutputError(timeData, valuesData, outputRequiredValue);
    SumOfAbsoluteOutputError = CalculateSumOfAbsoluteOutputError(valuesData, outputRequiredValue)
    
    //calculate Rise Time Absolute Error from data
    [AbsoluteRiseTimeError, riseTime] = CalculateAbsoluteRiseTimeError(timeData, valuesData, outputRequiredValue, riseTimeRequiredValue);
    
    //calculate Sum of Absolute Overshoot/Undershoot Error from data (Overshoot/Undershoot decision depends on comparison of first and required values)
    SumOfAbsoluteOvershootError = CalculateSumOfAbsoluteOvershootOrUndershootError(valuesData, outputRequiredValue);
    
endfunction


function [SumOfTimeMultipliedByAbsoluteOutputError]=CalculateSumOfTimeMultipliedByAbsoluteOutputError(timeData, valuesData, outputRequiredValue)
    
    
    SumOfTimeMultipliedByAbsoluteOutputError = %inf;
    if size(valuesData, 1) == 0 then
        disp(["Warning (CalculateSumOfTimeMultipliedByAbsoluteOutputError)! Data are empty! No calculation was performed and result is set to Infinite!" ; ]);
        return;
    elseif size(timeData, 1) ~= size(valuesData, 1) then
        disp(["Warning (CalculateSumOfTimeMultipliedByAbsoluteOutputError)! Number of data is different! No calculation was performed and result is set to Infinite!" ; "Number of time data: " + string(size(timeData, 1)) ; "Number of value data: " + string(size(valuesData, 1)) ; ]);
        return;
    end
    SumOfTimeMultipliedByAbsoluteOutputError = 0;
    
    
    //calculate sum of Time multiplied by Absolute Output Error (i.e. "sum(t * |e(t)|)")
    for i = 1 : 1 : size(timeData, 1)
        SumOfTimeMultipliedByAbsoluteOutputError = SumOfTimeMultipliedByAbsoluteOutputError + abs( timeData(i) * abs(valuesData(i) - outputRequiredValue) );
    end
    
    
endfunction


function [SumOfAbsoluteOutputError]=CalculateSumOfAbsoluteOutputError(valuesData, outputRequiredValue)
    
    
    SumOfAbsoluteOutputError = %inf;
    if size(valuesData, 1) == 0 then
        disp(["Warning (CalculateSumOfAbsoluteOutputError)! Data are empty! No calculation was performed and result is set to Infinite!" ; ]);
        return;
    end
    SumOfAbsoluteOutputError = 0;
    
    
    //calculate sum of Absolute Output Error (i.e. "sum(|e(t)|)")
    for i = 1 : 1 : size(valuesData, 1)
        SumOfAbsoluteOutputError = SumOfAbsoluteOutputError + abs( valuesData(i) - outputRequiredValue );
    end
    
    
endfunction


function [AbsoluteRiseTimeError, riseTime]=CalculateAbsoluteRiseTimeError(timeData, valuesData, outputRequiredValue, riseTimeRequiredValue)
    
    
    AbsoluteRiseTimeError = %inf;
    riseTime = %inf;
    if size(valuesData, 1) == 0 then
        disp(["Warning (CalculateAbsoluteRiseTimeError)! Data are empty! No calculation was performed and result is set to Infinite!" ; ]);
        return;
    elseif size(timeData, 1) ~= size(valuesData, 1) then
        disp(["Warning (CalculateAbsoluteRiseTimeError)! Number of data is different! No calculation was performed and result is set to Infinite!" ; "Number of time data: " + string(size(timeData, 1)) ; "Number of value data: " + string(size(valuesData, 1)) ; ]);
        return;
    end
    
    
    //find rise time and value from data
    riseTime = FindRiseOrFallTimeInData(timeData, valuesData, outputRequiredValue)
    
    
    //calculate Absolute Error of Rise Time
    AbsoluteRiseTimeError = abs( riseTime - riseTimeRequiredValue );
    
    
endfunction


function [riseOrFallTime]=FindRiseOrFallTimeInData(timeData, valuesData, outputRequiredValue)
    
    
    riseOrFallTime = %inf;
    if size(valuesData, 1) == 0 then
        disp(["Warning (FindRiseFallTimeInData)! Data are empty! No calculation was performed and result is set to Infinite!" ; ]);
        return;
    elseif size(timeData, 1) ~= size(valuesData, 1) then
        disp(["Warning (FindRiseFallTimeInData)! Number of data is different! No calculation was performed and result is set to Infinite!" ; "Number of time data: " + string(size(timeData, 1)) ; "Number of value data: " + string(size(valuesData, 1)) ; ]);
        return;
    end
    
    
    //calculate height of the step and its 10 % and 90 % values
    startValue = valuesData(1);
    stepHeight = outputRequiredValue - startValue;
    stepHeightProcentTen = 0.1 * stepHeight;
    stepHeightProcentNinety = 0.9 * stepHeight;
    startRiseValue = startValue + stepHeightProcentTen;
    endRiseValue = startValue + stepHeightProcentNinety;
    
    
    //find start and end time of rise
    startRiseTime = %inf;
    endRiseTime = %inf;
    for i = 1 : 1 : size(valuesData, 1)
        
        //if start value is lower than or equal to required value, calculate rise time
        if startValue <= outputRequiredValue then
            if startRiseTime == %inf & valuesData(i) >= startRiseValue then
                startRiseTime = timeData(i);
            end
            if endRiseTime == %inf & valuesData(i) >= endRiseValue then
                endRiseTime = timeData(i);
            end
        //otherwise, start value is higher than required value, calculate fall time
        else
            if startRiseTime == %inf & valuesData(i) <= startRiseValue then
                startRiseTime = timeData(i);
            end
            if endRiseTime == %inf & valuesData(i) <= endRiseValue then
                endRiseTime = timeData(i);
            end
        end
        
        if startRiseTime ~= %inf & endRiseTime ~= %inf then
           break; 
        end
    end
    
    
    //if start and end rise time were found, calculate complete rise time
    if startRiseTime ~= %inf & endRiseTime ~= %inf then
        riseOrFallTime = abs( endRiseTime - startRiseTime );
    else
        disp(["Warning (FindRiseOrFallTimeInData)! Start or/and End of the Rise Time was/were not found! No calculation was performed and result is set to Infinite!" ; "Start Rise Time: " + string(startRiseTime) ; "End Rise Time: " + string(endRiseTime) ; ]);
        return;
    end
    
    
endfunction


//the choice of overshooting or undershooting depends on the first value in data and the required output value - if the required value is higher or equal to, function sums overshoot errors, if the required value is lower, function sums undershoot errors
function [SumOfAbsoluteOvershootOrUndershootError]=CalculateSumOfAbsoluteOvershootOrUndershootError(valuesData, outputRequiredValue)
    
    
    SumOfAbsoluteOvershootOrUndershootError = %inf;
    if size(valuesData, 1) == 0 then
        disp(["Warning (CalculateSumOfAbsoluteOvershootOrUndershootError)! Data are empty! No calculation was performed and result is set to Infinite!" ; ]);
        return;
    end
    SumOfAbsoluteOvershootOrUndershootError = 0;
    
    
    overshootsOrUndershoots = list();
    //if the first value is higher than the required value, we try to find overshoots
    if valuesData(1) <= outputRequiredValue then
        overshootsOrUndershoots = GetAllOvershootsFromData(valuesData, outputRequiredValue);
    //otherwise, we try to find undershoots
    else
        overshootsOrUndershoots = GetAllUndershootsFromData(valuesData, outputRequiredValue);
    end
    
    //calculate sum of Absolute Overshoot/Undershoot Error
    for i = 1 : 1 : length(overshootsOrUndershoots)
        SumOfAbsoluteOvershootOrUndershootError = SumOfAbsoluteOvershootOrUndershootError + abs( overshootsOrUndershoots(i) - outputRequiredValue );
    end
    
    
endfunction


function [overshootsList]=GetAllOvershootsFromData(valuesData, outputRequiredValue)
    
    overshootsList = list();
    for i = 1 : 1 : size(valuesData, 1)
        if valuesData(i) > outputRequiredValue then
            overshootsList($+1) = valuesData(i);
        end
    end
    
endfunction


function [undershootsList]=GetAllUndershootsFromData(valuesData, outputRequiredValue)
    
    undershootsList = list();
    for i = 1 : 1 : size(valuesData, 1)
        if valuesData(i) < outputRequiredValue then
            undershootsList($+1) = valuesData(i);
        end
    end
    
endfunction



function [outputArrayWithoutInfinites, outputArrayWithInfinites]=RemoveInfinitesFromArray(inputArrayWithInfinites)
    
        //remove Infinite values
        outputArrayWithoutInfinites = inputArrayWithInfinites;
        outputArrayWithInfinites = [];
        indexRemoveInfinite = 1;
        while indexRemoveInfinite <= length(outputArrayWithoutInfinites)
            if isinf(outputArrayWithoutInfinites(indexRemoveInfinite)) == %t then
                outputArrayWithInfinites(1, size(outputArrayWithInfinites, 2) + 1) = outputArrayWithoutInfinites(indexRemoveInfinite);
                outputArrayWithoutInfinites(indexRemoveInfinite) = [];
                continue;
            end
            indexRemoveInfinite = indexRemoveInfinite + 1;
        end
        
endfunction



