//exec XMLfunctions.sci;
//exec TXTfunctions.sci;
//exec XMLTest.sci;
//exec XMLMath.sci



attributeTag = "<attribute>";
separatorLabelNames = ".";

//initial parameters - JSBSim reset XML file
function [labels, values]=DecodeInitialParametersLabelsValues(xmlReset)
    
    labels = [];
    values = [];
    
    asterisk = "*";
    childrenResetParameter = xmlReset.root.children;
    
    for i = 1 : 1 : length(childrenResetParameter)
        
        //if child of reset parameter is comment or documentation continue with cycle
        if childrenResetParameter(i).name == "comment" | childrenResetParameter(i).name == "documentation" then
            continue;
        end
        
        
        //get attribute names and values
        attributeNames = xmlName(childrenResetParameter(i).attributes);
        for j = 1 : 1 : length(childrenResetParameter(i).attributes)
            
            //add default strings to text boxes in dialog
            values(size(values, 1) + 1) = strsubst(childrenResetParameter(i).attributes(j), " ", "");
            //add information about input to label in dialog (the magic word "<attribute>" defines that the value has to be put in attributes, not in children of the element)
            labels(size(labels, 1) + 1) = childrenResetParameter(i).name + separatorLabelNames + attributeTag + separatorLabelNames + attributeNames(j) + asterisk;
            
        end
        
        
        if length(childrenResetParameter(i).children) > 1 then
            
            
            for j = 1 : 1 : length(childrenResetParameter(i).children)
                
                //if child of reset parameter is comment or documentation continue with cycle
                if childrenResetParameter(i).children(j).name == "comment" | childrenResetParameter(i).children(j).name == "documentation" then
                    continue;
                end
                
                
                //get attribute names and values
                attributeNamesSub = xmlName(childrenResetParameter(i).children(j).attributes);
                for k = 1 : 1 : length(childrenResetParameter(i).children(j).attributes)
                    
                    //add default strings to text boxes in dialog
                    values(size(values, 1) + 1) = strsubst(childrenResetParameter(i).children(j).attributes(k), " ", "");
                    //add information about input to label in dialog (the magic word "<attribute>" defines that the value has to be put in attributes, not in children of the element)
                    labels(size(labels, 1) + 1) = childrenResetParameter(i).name + separatorLabelNames + childrenResetParameter(i).children(j).name + separatorLabelNames + attributeTag + separatorLabelNames + attributeNamesSub(k) + asterisk;
                    
                end
                
                
                //there should be no other sub xml elements (otherwise, there should be recursive function)
                //add default strings to text boxes in dialog
                values(size(values, 1) + 1) = strsubst(childrenResetParameter(i).children(j).content, " ", "");
                //add information about input to label in dialog
                labels(size(labels, 1) + 1) = childrenResetParameter(i).name + separatorLabelNames + childrenResetParameter(i).children(j).name;
                
                
            end
            
            
        //else if there is only one child
        elseif length(childrenResetParameter(i).children) == 1 then
            
            
            //if the child is text
            if childrenResetParameter(i).children(1).name  == "text" then
                
                //add default strings to text boxes in dialog
                values(size(values, 1) + 1) = strsubst(childrenResetParameter(i).content, " ", "");
                //add information about input to label in dialog
                labels(size(labels, 1) + 1) = childrenResetParameter(i).name;
                
                
            //otherwise, child element is not a text but another xml element
            else
                
                
                for j = 1 : 1 : length(childrenResetParameter(i).children)
                    
                    //if child of reset parameter is comment or documentation continue with cycle
                    if childrenResetParameter(i).children(j).name == "comment" | childrenResetParameter(i).children(j).name == "documentation" then
                        continue;
                    end
                    
                    
                    //get attribute names and values
                    attributeNamesSub = xmlName(childrenResetParameter(i).children(j).attributes);
                    for k = 1 : 1 : length(childrenResetParameter(i).children(j).attributes)
                        
                        //add default strings to text boxes in dialog
                        values(size(values, 1) + 1) = strsubst(childrenResetParameter(i).children(j).attributes(k), " ", "");
                        //add information about input to label in dialog (the magic word "<attribute>" defines that the value has to be put in attributes, not in children of the element)
                        labels(size(labels, 1) + 1) = childrenResetParameter(i).name + separatorLabelNames + childrenResetParameter(i).children(j).name + separatorLabelNames + attributeTag + separatorLabelNames + attributeNamesSub(k) + asterisk;
                        
                    end
                    
                    
                    //there should be no other sub xml elements (otherwise, there should be recursive function)
                    //add default strings to text boxes in dialog
                    values(size(values, 1) + 1) = strsubst(childrenResetParameter(i).children(j).content, " ", "");
                    //add information about input to label in dialog
                    labels(size(labels, 1) + 1) = childrenResetParameter(i).name + separatorLabelNames + childrenResetParameter(i).children(j).name;
                    
                    
                end
                
                
            end
            
        end
        
    end
    
    
endfunction



function [outLabels]=GetLabelsWithPossibleInputInformation(inLabels, inPossibleInputTypesList)
    
    outLabels = inLabels;
    
    for i = 1 : 1 : size(inLabels, 1)
        
        outLabels(i) = inLabels(i) + " (" + inPossibleInputTypesList(i) + ")";
        
    end
    
endfunction



function EncodeInitialParameters(xmlReset, labels, values)
    
    
    //decode label information
    labelsDecoded = list();
    for i = 1 : 1 : size(labels, 1)
        
        //find asterisk in label
        indexPossibleTypesStart = strindex(labels(i), "*");
        //if asterisk was not found, try to find white space (i.e. " ")
        if indexPossibleTypesStart == [] then
            indexPossibleTypesStart = strindex(labels(i), " ");
        end
        
        //if asterisk or white space was found, get only part before these characters, and separate XML element/attribute names, finally add the array output array to the list
        if indexPossibleTypesStart ~= [] then
            
            labelsWithoutPossibleTypes = part(labels(i), 1:indexPossibleTypesStart(1)-1);
            labelsSeparated = tokens(labelsWithoutPossibleTypes, separatorLabelNames);
            labelsDecoded($+1) = labelsSeparated;
            
        else
            
            labelsDecoded($+1) = [labels(i)];
            disp(["Label of initial parameter could not have been encoded. (in EncodeInitialParameters function)" ; labels(i) ; ]);
            
        end
        
    end
    
    
    //if length of decoded labels is same as size of array of the original labels and values
    if length(labelsDecoded) == size(labels, 1) & length(labelsDecoded) == size(values, 1) then
        
        
        //go through all decoded labels
        for i = 1 : 1 : length(labelsDecoded)
            
            xmlElementFound = xmlReset.root;
            //go through all element/attribute names in a decoded label
            for j = 1 : 1 : size(labelsDecoded(i), 1)
                
                //<>debug only
                //disp([ "iteration: " + string(i) ; labelsDecoded(i) ; xmlElementFound.name ; ]);
                
                //if the first label was already checked and the previous label was dynamic tag for attribute
                if j > 1 & labelsDecoded(i)(j-1) == attributeTag then
                    
                    
                    //<>debug only
                    //disp([ "iteration <attribute>: " + string(i) ; labelsDecoded(i) ; xmlElementFound.name ; ]);
                    //set attribute of XML element (if does not exist, create it)
                    xmlSetAttributes(xmlElementFound, [labelsDecoded(i)(j) values(i)]);
                    //this iteration should be the last but for sure
                    break;
                    
                    
                //else if this label is not dynamic tag for attribute
                elseif labelsDecoded(i)(j) ~= attributeTag then
                    
                    
                    xmlElementIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementFound, labelsDecoded(i)(j));
                    //if the XML element was found, get it from children
                    if xmlElementIndexArray ~= [] then
                        
                        xmlElementFound = xmlElementFound.children(xmlElementIndexArray(1));
                        //if this is the last iteration, change the content of the XML element to the value in array with values
                        if j == size(labelsDecoded(i), 1) then
                            xmlElementFound.content = values(i);
                        end
                        
                    //otherwise, create new xml element
                    else
                        
                        xmlElementParent = xmlElementFound;
                        xmlElementFound = xmlElement(xmlReset, labelsDecoded(i)(j));
                        xmlAppend(xmlElementParent, xmlElementFound);
                        xmlElementFound = xmlElementParent.children(length(xmlElementParent.children));
                        //if this is the last iteration, change the content of the XML element to the value in array with values
                        if j == size(labelsDecoded(i), 1) then
                            xmlElementFound.content = values(i);
                        end
                        
                    end
                    
                    
                end
                
                
            end
            
        end
        
        
    end
    
    
endfunction



function [xmlResetFilePath, xmlResetFileName]=ShowCheckSaveResetParametersDialog(xmlReset, labels, values, possibleInputTypesList, inXmlResetFilePath, inXmlResetFileName)
    
    
    xmlResetFilePath = [];
    xmlResetFileName = [];
    
    
    //show mDialog for editation of attributes/content of xml elements of reset file (add labels and textBox elements with default values into dialog)
    valuesOut = x_mdialog(["Reset file (" + xmlReset.root.name + ")" ; "(* means required)" ; "(all parameters excluding attributes must be numbers)" ; "(attributes cannot be numbers)"], labels, values);
    
    //if cancel button was not clicked
    if valuesOut ~= [] then
        
        
        //check if all inputs were set properly
        asterisk = "*";
        inputsSetPropery = [];
        for i = 1 : 1 : size(possibleInputTypesList, 1)
            isOptional = %t;
            if strindex(labels(i), asterisk) ~= [] then
                isOptional = %f;
            end
            inputsSetPropery(size(inputsSetPropery, 1) + 1) = CheckCorrectValuesType(valuesOut(i), possibleInputTypesList(i), [], isOptional, %f);
        end
        
        while and(inputsSetPropery) == %f
            
            //show mDialog again because error occurs -> Required fields are empty, set incorrectly (e.g. must be number) or the name identifier of the component is already used!
            valuesOut = x_mdialog(["Reset file (" + xmlReset.root.name + ")" ; "(* means required)" ; "(all parameters excluding attributes must be numbers)" ; "(attributes cannot be numbers)" ; "Required fields (*) are empty or fields are set incorrectly (e.g. must be number)!"], labels, valuesOut);
            
            if valuesOut == [] then
                return;
            end
            
            //check if all inputs were set properly
            inputsSetPropery = [];
            for i = 1 : 1 : size(possibleInputTypesList, 1)
                isOptional = %t;
                if strindex(labels(i), asterisk) ~= [] then
                    isOptional = %f;
                end
                inputsSetPropery(size(inputsSetPropery, 1) + 1) = CheckCorrectValuesType(valuesOut(i), possibleInputTypesList(i), [], isOptional, %f);
            end
            
            
        end
        
        
        //if there is a empty field whose possible type is number, set it to 0
        for i = 1 : 1 : size(valuesOut, 1)
            if strsubst(valuesOut(i), " ", "") == emptystr() & strindex(convstr(possibleInputTypesList(i), 'l'), "number") ~= [] then
                valuesOut(i) = "0";
            end
        end
        
        
        
        //encode initial parameters to xml reset instance
        EncodeInitialParameters(xmlReset, labels, valuesOut);
        
        
        
        if (inXmlResetFilePath == [] | inXmlResetFilePath == emptystr()) & (inXmlResetFileName == [] | inXmlResetFileName == emptystr()) then
            
            //show save dialog for JSBSim reset file
            //<>zmenit "aircraft\V-TS v1-532" na "aircraft"
            [fileNameSave, pathNameSave, filterIndexSave] = uiputfile( ["*.xml","XML files"], "aircraft\V-TS v1-532", "Save file with JSBSim reset information" );
            
            //check if cancel button was not clicked
            if fileNameSave ~= "" & pathNameSave ~= "" & filterIndexSave ~= 0 then
                
                //check xmlReset - whether exists, are in XMLDoc format, and is valid object
                if exists("xmlReset") == 1 then
                    if typeof(xmlReset) == "XMLDoc" then
                        if xmlIsValidObject(xmlReset) == %t then
                            
                            //set name attribute of the root xml element to the filename without extension
                            xmlReset.root.attributes.name = GetFileNameWithoutExtension(fileNameSave, ".xml");
                            xmlResetFileName = xmlReset.root.attributes.name;
                            
                            //set reset file path with extension and save xml reset file
                            extension = GetExtensionForFileIfNecessary(fileNameSave, ".xml");
                            xmlResetFilePath = pathNameSave + filesep() + fileNameSave + extension;
                            xmlWrite(xmlReset, xmlResetFilePath, %t);
                            
                            messagebox("Reset file was saved sucessfully!", "modal", "info");
                            
                        end
                    end
                end
                
            end
            
        else
            
            //check xmlReset - whether is in XMLDoc format, and is valid object
            if typeof(xmlReset) == "XMLDoc" then
                if xmlIsValidObject(xmlReset) == %t then
                    
                    //set name attribute of the root xml element to the filename without extension
                    xmlReset.root.attributes.name = inXmlResetFileName;
                    xmlResetFileName = xmlReset.root.attributes.name;
                    
                    //set reset file path and save xml reset file
                    xmlResetFilePath = inXmlResetFilePath;
                    xmlWrite(xmlReset, xmlResetFilePath, %t);
                    
                    messagebox("Reset file was saved sucessfully!", "modal", "info");
                    
                end
            end
            
        end
        
    end
    
    
endfunction



function [outLabels, outValues, outPossibleInputTypesList]=JoinResetFileAndTemplate(inLabels, inValues, inLabelsTemplate, inPossibleInputTypesList)
    
    
    outLabels = [];
    outValues = [];
    outPossibleInputTypesList = [];
    
    
    //for all labels in reset file, find the alternative in template, and add it to the labels, values, and possible input types, or add just the default data from opened reset file
    for i = 1 : 1 : size(inLabels, 1)
        
        indexesFound = find(inLabelsTemplate == inLabels(i));
        
        if indexesFound ~= [] then
            
            //add labels, values, and possible input types to output arrays
            outLabels(size(outLabels, 1) + 1) = inLabels(i);
            outValues(size(outValues, 1) + 1) = inValues(i);


            outPossibleInputTypesList(size(outPossibleInputTypesList, 1) + 1) = inPossibleInputTypesList(indexesFound(1));
            
            //delete data from the input labels of template and input possible types
            inLabelsTemplate(indexesFound(1)) = [];
            inPossibleInputTypesList(indexesFound(1)) = [];
            
        else
            
            //add labels, values, and possible input types to output arrays
            outLabels(size(outLabels, 1) + 1) = inLabels(i);
            outValues(size(outValues, 1) + 1) = inValues(i);
            
            //if the value is number define possible type as number but put also the <unknown> tag
            possibleType = "number|<unknown>";
            if isnum(inValues(i)) == %f then
                //if the value is not number, define possible type as the value with also the <unknown> tag
                possibleType = inValues(i) + "|<unknown>";
            end
            outPossibleInputTypesList(size(outPossibleInputTypesList, 1) + 1) = possibleType;
            
        end
        
    end
    
    
    //for all labels from template reset file which was not used in opened reset file, add all remaining labels, default values, and possible input types
    for i = 1 : 1 : size(inLabelsTemplate, 1)
        
        outLabels(size(outLabels, 1) + 1) = inLabelsTemplate(i);
        outValues(size(outValues, 1) + 1) = SetIDinValue(inPossibleInputTypesList(i));
        outPossibleInputTypesList(size(outPossibleInputTypesList, 1) + 1) = inPossibleInputTypesList(i);
        
    end
    
    
    ////include information about possible inputs to labels
    //outLabels = GetLabelsWithPossibleInputInformation(outLabels, outPossibleInputTypesList);
    
    
endfunction







//JSBSim simulation XML file

global SimulationFilePossibleInputTypesListGlobal;
SimulationFilePossibleInputTypesListGlobal = [ "description" ; "path_file" ; "path_file" ; "number" ; "number" ; "number" ; "property_definition" ];

global EventPossibleInputTypesListGlobal;
EventPossibleInputTypesListGlobal = [ emptystr() ; "false|true" ; "false|true" ; emptystr() ; "condition_functions" ; "number" ; "set_definition" ; "property_array" ];

global SetAttributesPossibleInputTypesListGlobal;
SetAttributesPossibleInputTypesListGlobal = [ "value|fg_value|delta|fg_delta" ; "step|fg_step|ramp|fg_ramp|exp|fg_exp" ; "number" ];

//rootSimulationName = "runscript";

function [XMLSimulationScriptElement]=EncodeSimulationScriptXMLElementFromListsString(inputSimulationScriptListString, inputEventListListString, tableXMLElementsList, propertiesAvailable, showTableDialog)
    
    modifiedPropertiesAvailable = propertiesAvailable;
    XMLSimulationScriptElement = [];
    
    if (inputSimulationScriptListString ~= [] | inputSimulationScriptListString ~= list()) & (inputEventListListString ~= [] | inputEventListListString ~= list()) then
        
        sizeNeededInputSimulationScriptListString = 7;
        if length(inputSimulationScriptListString) == sizeNeededInputSimulationScriptListString then
            
            XMLSimulationScriptElement = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "script_template.xml");
            errorString=ValidateXMLdocument(XMLSimulationScriptElement);
            
            //if the root name element of xml template simulation file is "runscript", it is valid JSBSim template simulation file
            if XMLSimulationScriptElement.root.name == "runscript" then
                
                ////if the template simulation file contains any children element
                //if length(XMLSimulationScriptElement.root.children) > 0 then
                
                //find and get (or create) description xml element
                descriptionXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationScriptElement, XMLSimulationScriptElement.root, "description");
                if inputSimulationScriptListString(1) ~= [] then
                    descriptionXMLElement.content = inputSimulationScriptListString(1);
                else
                    descriptionXMLElement.content = emptystr();
                end
                
                
                //find and get (or create) use xml element
                useXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationScriptElement, XMLSimulationScriptElement.root, "use");
                useXMLElement.attributes.aircraft = inputSimulationScriptListString(2);
                useXMLElement.attributes.initialize = inputSimulationScriptListString(3);
                
                //find and get (or create) run xml element
                runXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationScriptElement, XMLSimulationScriptElement.root, "run");
                runXMLElement.attributes.start = inputSimulationScriptListString(4);
                runXMLElement.attributes.end = inputSimulationScriptListString(5);
                runXMLElement.attributes.dt = inputSimulationScriptListString(6);
                
                
                //encode property string and create list of property XML elements (this part has to be always before all the parts which use property database (PropertiesAvailable))
                [XMLPropertyElementsList, modifiedPropertiesAvailable] = EncodePropertyDefinitionsFromStringArray(inputSimulationScriptListString(7), modifiedPropertiesAvailable);
                for i = 1 : 1 : length(XMLPropertyElementsList)
                    //add new XML property element to the output XML run element
                    xmlAppend(runXMLElement, XMLPropertyElementsList(i));
                end
                
                
                //encode event arrays in list and create xml event element
                XMLEventElementsList = EncodeEventXMLElementsFromListListString(inputEventListListString, tableXMLElementsList, modifiedPropertiesAvailable, showTableDialog);
                for i = 1 : 1 : length(XMLEventElementsList)
                    //add new XML property element to the output XML run element
                    xmlAppend(runXMLElement, XMLEventElementsList(i));
                end
                
                
            else
                messagebox("Wrong format! The template XML file is not a valid simulation file (check templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "script_template.xml)!", "modal", "error");
                XMLSimulationScriptElement = [];
            end
            
        else
            messagebox("inputSimulationScriptListString does not have necessary number of elements (" + string(sizeNeededInputSimulationScriptListString) + ") but " + string(length(inputSimulationScriptListString)) + "!", "modal", "error");
        end
        
    else
        messagebox(["inputSimulationScriptListString or inputEventListListString is empty list!" ; "inputSimulationScriptListString: " + string(length(inputSimulationScriptListString)) ; "inputEventListListString: " + string(length(inputEventListListString)) ], "modal", "error");
    end
    
endfunction



function [outSimulationScriptListString, outEventListListString]=DecodeSimulationScriptXMLElementToListsString(XMLSimulationScriptDoc)
    
    outSimulationScriptListString = list();
    outEventListListString = list();
    
    global SimulationFilePossibleInputTypesListGlobal;
    SimulationFileDefaultParameterList = list( SetIDinValue(SimulationFilePossibleInputTypesListGlobal(1)), SetIDinValue(SimulationFilePossibleInputTypesListGlobal(2)), SetIDinValue(SimulationFilePossibleInputTypesListGlobal(3)), SetIDinValue(SimulationFilePossibleInputTypesListGlobal(4)), SetIDinValue(SimulationFilePossibleInputTypesListGlobal(5)), SetIDinValue(SimulationFilePossibleInputTypesListGlobal(6)), SetIDinValue(SimulationFilePossibleInputTypesListGlobal(7)) );
    
    //if the root name element of xml simulation object is "runscript", it is valid JSBSim simulation xml definition
    if XMLSimulationScriptDoc.root.name == "runscript" then
        //if the simulation xml object contains any children element
        if length(XMLSimulationScriptDoc.root.children) > 0 then
            
            
            
            //get (or get default) content of description xml element
            xmlDescriptionContentArray = GetXMLContentOrDefault(XMLSimulationScriptDoc.root, "description", SimulationFileDefaultParameterList(1));
            outSimulationScriptListString($+1) = xmlDescriptionContentArray;
            
            
            
            //get use element if exists
            useXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLSimulationScriptDoc.root, "use");
            if useXMLElementIndexes ~= [] then
                
                //get (or get default) value of attributes "aircraft" and "initialize" of use xml element
                outSimulationScriptListString($+1) = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(useXMLElementIndexes(1)), "aircraft", SimulationFileDefaultParameterList(2));
                outSimulationScriptListString($+1) = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(useXMLElementIndexes(1)), "initialize", SimulationFileDefaultParameterList(3));
                
            //otherwise, if does not exist, set default values
            else
                outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(2);
                outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(3);
            end
            
            
            
            //get run element if exists
            runXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLSimulationScriptDoc.root, "run");
            if runXMLElementIndexes ~= [] then
                
                //get (or get default) value of attributes "start", "end", and "dt" of run xml element
                outSimulationScriptListString($+1) = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(runXMLElementIndexes(1)), "start", SimulationFileDefaultParameterList(4));
                outSimulationScriptListString($+1) = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(runXMLElementIndexes(1)), "end", SimulationFileDefaultParameterList(5));
                outSimulationScriptListString($+1) = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(runXMLElementIndexes(1)), "dt", SimulationFileDefaultParameterList(6));
                
            //otherwise, if does not exist, set default values
            else
                outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(4);
                outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(5);
                outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(6);
            end
            
            
            //if "run" xml element was found
            if runXMLElementIndexes ~= [] then
                
                //get run xml element (there has to be only one)
                runXMLElement = XMLSimulationScriptDoc.root.children(runXMLElementIndexes(1));
                
                
                
                //find all children property xml element
                XMLPropertyElementsList = list();
                propertyXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(runXMLElement, "property");
                for i = 1 : 1 : size(propertyXMLElementIndexes, 1)
                    XMLPropertyElementsList($+1) = runXMLElement.children(propertyXMLElementIndexes(i));
                end
                
                //decode list of property XML elements and create property string array
                propertyStringArray = DecodePropertyDefinitionsToStringArray(XMLPropertyElementsList);
                if propertyStringArray ~= [] then
                    outSimulationScriptListString($+1) = propertyStringArray;
                else
                    //if there is no property definition, set it to default value
                    outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(7);
                end
                
                
                
                //find all children event xml element
                XMLEventElementsList = list();
                eventXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(runXMLElement, "event");
                for i = 1 : 1 : size(eventXMLElementIndexes, 1)
                    XMLEventElementsList($+1) = runXMLElement.children(eventXMLElementIndexes(i));
                end
                
                //decode xml event elements and create event arrays and add them to list
                outEventListListString = DecodeEventXMLElementsToListListString(XMLEventElementsList);
                
                
            //otherwise, set default values for property_definition and (outEventStringArrayList was set to empty list already)
            else
                outSimulationScriptListString($+1) = SimulationFileDefaultParameterList(7);
            end
            
        else
            messagebox("Input XMLSimulationScriptDoc does not have any children! The simulation file cannot be empty!", "modal", "error");
        end

    else
        messagebox("Input XMLSimulationScriptDoc is in wrong format! The XML is not a valid simulation file!", "modal", "error");
    end
    
    
endfunction




function [XMLPropertyElementsList, outPropertiesAvailable]=EncodePropertyDefinitionsFromStringArray(inputPropertyDefinitionStringArray, inPropertiesAvailable)
    
    outPropertiesAvailable = inPropertiesAvailable;
    XMLPropertyElementsList = list();
    for i = 1 : 1 : size(inputPropertyDefinitionStringArray, 1)
        //encode string with property definition and if the output XML content is not empty string, add it to the list of XML simulation properties
        [propertyDefinitionsXMLElement, outPropertiesAvailable] = EncodePropertyDefinitionFromString(inputPropertyDefinitionStringArray(i), outPropertiesAvailable);
        if propertyDefinitionsXMLElement.content ~= emptystr() & propertyDefinitionsXMLElement.content ~= [] then
            XMLPropertyElementsList($+1) = propertyDefinitionsXMLElement;
        end
    end
    
endfunction


function [XMLPropertyElement, outPropertiesAvailable]=EncodePropertyDefinitionFromString(inputPropertyDefinitionString, inPropertiesAvailable)
    
    outPropertiesAvailable = inPropertiesAvailable;
    //create empty XML document
    XMLPropertyElement = xmlDocument();
    //add only one child (root) element "property"
    XMLPropertyElement.root = xmlElement(XMLPropertyElement, "property");
    
    propertyDefinitionStringWithoutSpaces = strsubst(inputPropertyDefinitionString, " ", "");
    if propertyDefinitionStringWithoutSpaces ~= emptystr() then
        
        //separate string to two (or more) parts with new unique property on the left side and a value (number) on the right side
        propertyDefinitionParts = tokens(propertyDefinitionStringWithoutSpaces, "=");
        //if there is only one or exactly two parts, the main format of string is correct
        if size(propertyDefinitionParts, 1) == 1 | size(propertyDefinitionParts, 1) == 2 then
            
//            //this part of code was noted because several JSBSim scripts define properties which were already created (e.g. JSBSim properties) and scripts work; thus, it is probably possible to do that without errors
//            //try to find the property name in property list available, if it is not found the new property may be created
//            isFound = FindPropertyInPropertiesAvailable(propertyDefinitionParts(1), outPropertiesAvailable);
//            if isFound == %f then
                XMLPropertyElement.root.content = propertyDefinitionParts(1);
                if size(propertyDefinitionParts, 1) == 2 then
                    
                    isNumber = isnum(propertyDefinitionParts(2));
                    if isNumber then
                        XMLPropertyElement.root.attributes.value = propertyDefinitionParts(2);
                    else
                        messagebox(["Wrong format! The right side of the property definition has to contain number!" ; """" + propertyDefinitionParts(2) + """"], "modal", "error");
                    end
                    
                end
                
                //add new property name to the properties available
                outPropertiesAvailable(size(outPropertiesAvailable, 1) + 1) = XMLPropertyElement.root.content;
                
                
//            else
//                messagebox("The property: """ + propertyDefinitionParts(1) + """ was found in global property definition! (it has been created already and cannot be overrided)", "modal", "error");
//            end
            
        else
            messagebox(["Wrong format! The current line of property definition is not in correct format (too many ''='')!" ; """" + inputPropertyDefinitionString + """"], "modal", "error");
        end
        
    end
    
    XMLPropertyElement = XMLPropertyElement.root;
    
endfunction



function [outPropertyDefinitionStringArray]=DecodePropertyDefinitionsToStringArray(XMLPropertyElementsList)
    
    outPropertyDefinitionStringArray = [];
    for i = 1 : 1 : length(XMLPropertyElementsList)
        outPropertyDefinitionStringArray(size(outPropertyDefinitionStringArray, 1) + 1) = DecodePropertyDefinitionToString(XMLPropertyElementsList(i));
    end
    
endfunction


function [outPropertyDefinitionString]=DecodePropertyDefinitionToString(XMLPropertyElement)
    
    outPropertyDefinitionString = emptystr();
    if XMLPropertyElement.name == "property" then
        outPropertyDefinitionString = strsubst(XMLPropertyElement.content, " ", "");
        if XMLPropertyElement.attributes.value ~= [] then
            
            outPropertyDefinitionString = outPropertyDefinitionString + " = " + XMLPropertyElement.attributes.value;
            
        end
    else
        messagebox(["The decoded xml element is not ""property"" but """ + XMLPropertyElement.name + """"], "modal", "error");
    end
    
endfunction




function [XMLEventElementsList]=EncodeEventXMLElementsFromListListString(inputEventListListString, tableXMLElementsList, propertiesAvailable, showTableDialog)
    
    XMLEventElementsList = list();
    for i = 1 : 1 : length(inputEventListListString)
        //encode xml event element and if the operation was successful, add it to the list
        XMLEventElement = EncodeEventXMLElementFromListString(inputEventListListString(i), tableXMLElementsList, propertiesAvailable, showTableDialog);
        if XMLEventElement ~= [] then
            XMLEventElementsList($+1) = XMLEventElement;
        else
            disp(["Event with index: " + string(i) + " was completely ignored! (index may not match the current label event number depending on user''s deletions and additions)" ; ]);
        end
    end
    
endfunction


function [XMLEventElement]=EncodeEventXMLElementFromListString(inputEventListString, tableXMLElementsList, propertiesAvailable, showTableDialog)
    
    //create empty XML document
    XMLEventElement = xmlDocument();
    //add only one child (root) element "event"
    XMLEventElement.root = xmlElement(XMLEventElement, "event");
    
    
    //add name attribute if not empty
    nameAttributeString = strsubst(inputEventListString(1), " ", "");
    if nameAttributeString ~= emptystr() then
        XMLEventElement.root.attributes.name = inputEventListString(1);
    else
        messagebox(["Event name was not set but it is required - event completely ignored!"], "modal", "error");
        CheckAndDeleteXMLDoc(XMLEventElement);
        XMLEventElement = [];
        return;
    end
    
    
    //add persistent attribute if not empty and in correct format
    persistentAttributeString = strsubst(inputEventListString(2), " ", "");
    if persistentAttributeString ~= emptystr() then
        persistentTrueFalseString = ConvertBooleanStringToTrueFalseString(persistentAttributeString);
        if persistentTrueFalseString ~= persistentAttributeString then
            XMLEventElement.root.attributes.persistent = persistentTrueFalseString;
        else
            disp(["Wrong format of persistent attribute - ignored! (should be ""%f"" or ""%t"" - user has to set ""false"" or ""true"" in text box)" ; persistentAttributeString ;])
        end
    end
    
    
    //add continuous attribute if not empty and in correct format
    continuousAttributeString = strsubst(inputEventListString(3), " ", "");
    if continuousAttributeString ~= emptystr() then
        continuousTrueFalseString = ConvertBooleanStringToTrueFalseString(continuousAttributeString);
        if continuousTrueFalseString ~= continuousAttributeString then
            XMLEventElement.root.attributes.continuous = continuousTrueFalseString;
        else
            disp(["Wrong format of continuous attribute - ignored! (should be ""%f"" or ""%t"" - user has to set ""false"" or ""true"" in text box)" ; continuousAttributeString ;])
        end
    end
    
    
    
    //add description xml element if not empty
    descriptionString = inputEventListString(4);
    for i = 1 : 1 : size(descriptionString, 1)
        if strsubst(descriptionString(i), " ", "") ~= emptystr() then
            descriptionXMLElement = xmlElement(XMLEventElement, "description");
            descriptionXMLElement.content = descriptionString;
            xmlAppend(XMLEventElement.root, descriptionXMLElement);
            break;
        end
    end
//    if descriptionString ~= emptystr() then
//        descriptionXMLElement = xmlElement(XMLEventElement, "description");
//        descriptionXMLElement.content = descriptionString;
//        xmlAppend(XMLEventElement.root, descriptionXMLElement);
//    end
    
    
    
    //encode and add condition xml element if conversion is OK
    conditionString = inputEventListString(5);
    XMLTestElement = EncodeConditionFromString(conditionString, propertiesAvailable);
    //check if conversion was successful
    if XMLTestElement ~= [] then
        //add new XML condition element to the XML simulation event
        xmlAppend(XMLEventElement.root, XMLTestElement.root);
    else
        messagebox(["Condition was not converted properly but it is required - event completely ignored!" ; "(Wrong) Element Value: """ + conditionString + """"], "modal", "error");
        CheckAndDeleteXMLDoc(XMLEventElement);
        XMLEventElement = [];
        return;
    end
    
    
    
    //add delay xml element if not empty and it is a correct number
    delayString = strsubst(inputEventListString(6), " ", "");
    if delayString ~= emptystr() then
        
        //check if the delay string is number
        isNumberDelay = isnum(delayString);
        if isNumberDelay then
            
            //convert delay string to number and check if it is higher than or equal to 0
            delayNumber = strtod(delayString);
            if delayNumber >= 0 then
                //add delay xml element
                delayXMLElement = xmlElement(XMLEventElement, "delay");
                delayXMLElement.content = delayString;
                xmlAppend(XMLEventElement.root, delayXMLElement);
            else
                disp(["Delay number has to be higher than or equal to 0 - ignored!" ; "Converted delay number: " + string(delayNumber) ; "Original delay string: " + delayString ;]);
            end
            
        else
            disp(["Delay string is not number - ignored!" ; delayString ; ]);
        end
        
    end
    
    
    
    //encode and add set xml element if conversion is OK
    setStringArray = inputEventListString(7);
    XMLSetElementsList = EncodeSetDefinitionsFromStringArray(setStringArray, tableXMLElementsList, propertiesAvailable, showTableDialog);
    //check if conversion was successful
    if XMLSetElementsList ~= [] & XMLSetElementsList ~= list() then
        for i = 1 : 1 : length(XMLSetElementsList)
            //add new XML set element to the XML simulation event
            xmlAppend(XMLEventElement.root, XMLSetElementsList(i));
        end
    end
    
    
    
    //encode and add notify xml element if conversion is OK
    notifyStringArray = inputEventListString(8);
    XMLNotifyElement = EncodeNotifyPropertyFromStringArray(notifyStringArray, propertiesAvailable);
    //check if conversion was successful
    if length(XMLNotifyElement.children) > 0 then
        //add new XML notify element to the XML simulation event
        xmlAppend(XMLEventElement.root, XMLNotifyElement);
    end
    
    
    
    XMLEventElement = XMLEventElement.root;
    
endfunction



function [outEventListListString]=DecodeEventXMLElementsToListListString(XMLEventElementsList)
    
    outEventListListString = list();
    for i = 1 : 1 : length(XMLEventElementsList)
        outEventListListString($+1) = DecodeEventXMLElementToListString(XMLEventElementsList(i));
    end
    
endfunction


function [outEventListString]=DecodeEventXMLElementToListString(XMLEventElement)
    
    
    outEventListString = list();
    
    
    global EventPossibleInputTypesListGlobal;
    eventDefaultParameterList = list( SetIDinValue(EventPossibleInputTypesListGlobal(1)), "false", "false", [emptystr() ; emptystr() ; emptystr()], SetIDinValue(EventPossibleInputTypesListGlobal(5)), emptystr(), SetIDinValue(EventPossibleInputTypesListGlobal(7)), SetIDinValue(EventPossibleInputTypesListGlobal(8)) );
    
    
    
    //get (or get default) value of attributes "name", "persistent", and "continuous" of use xml element
    outEventListString($+1) = GetXMLAttributeOrDefault(XMLEventElement, "name", eventDefaultParameterList(1));
    outEventListString($+1) = GetXMLAttributeOrDefault(XMLEventElement, "persistent", eventDefaultParameterList(2));
    outEventListString($+1) = GetXMLAttributeOrDefault(XMLEventElement, "continuous", eventDefaultParameterList(3));
    
    
    
    //get (or get default) content of description xml element
    xmlDescriptionContentArray = GetXMLContentOrDefault(XMLEventElement, "description", eventDefaultParameterList(4));
    outEventListString($+1) = xmlDescriptionContentArray;
    
    
    
    //get condition element if exists
    conditionXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLEventElement, "condition");
    if conditionXMLElementIndexes ~= [] then
        
        //there should be one condition only, convert it and set the result string (or empty string)
        conditionXMLelement = XMLEventElement.children(conditionXMLElementIndexes(1));
        outEventListString($+1) = DecodeConditionToString(conditionXMLelement);
        
    //otherwise, if does not exist, set default values
    else
        outEventListString($+1) = eventDefaultParameterList(5);
    end
    
    
    
    //get (or get default) content of delay xml element
    xmlDelayContent = GetXMLContentOrDefault(XMLEventElement, "delay", eventDefaultParameterList(6));
    outEventListString($+1) = xmlDelayContent;
    
    
    
    //find all set elements if exist
    setXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLEventElement, "set");
    if setXMLElementIndexes ~= [] then
        
        //get all set xml elements and add it to list
        XMLSetElementsList = list();
        for i = 1 : 1 : size(setXMLElementIndexes, 1)
            XMLSetElementsList($+1) = XMLEventElement.children(setXMLElementIndexes(i));
        end
        
        //decode set definitions to string array
        setDefinitionStringArray = DecodeSetDefinitionsToStringArray(XMLSetElementsList);
        //if the string array with set definitions exists, set it
        if setDefinitionStringArray ~= [] then
            outEventListString($+1) = setDefinitionStringArray;
        //otherwise, set default string array
        else
            outEventListString($+1) = eventDefaultParameterList(7);
        end
        
    //otherwise, if does not exist, set default values
    else
        outEventListString($+1) = eventDefaultParameterList(7);
    end
    
    
    
    //find notify element if exists
    notifyXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLEventElement, "notify");
    if notifyXMLElementIndexes ~= [] then
        
        //there should be one notify only, convert it and set the result string array (or default string array)
        notifyXMLelement = XMLEventElement.children(notifyXMLElementIndexes(1));
        notifyPropertyStringArray = DecodeNotifyPropertyToStringArray(notifyXMLelement);
        if notifyPropertyStringArray ~= [] then
            outEventListString($+1) = notifyPropertyStringArray;
        else
            outEventListString($+1) = eventDefaultParameterList(8);
        end
        
    //otherwise, if does not exist, set default values
    else
        outEventListString($+1) = eventDefaultParameterList(8);
    end
    
    
    
endfunction




function [XMLConditionElement]=EncodeConditionFromString(inputConditionString, propertiesAvailable)
    
    XMLConditionElement = StringEquationToXMLTest(inputConditionString, "condition", propertiesAvailable);
    
endfunction


function [outConditionString]=DecodeConditionToString(XMLConditionElement)
    
    outConditionString = XMLTestToStringEquation(XMLConditionElement, "condition");
    
endfunction




function [XMLSetElementsList]=EncodeSetDefinitionsFromStringArray(inputSetDefinitionStringArray, tableXMLElementsList, propertiesAvailable, showTableDialog)
    
    XMLSetElementsList = list();
    for i = 1 : 1 : size(inputSetDefinitionStringArray, 1);
        //encode set definition from string and if the conversion was successful, add it to the list
        XMLSetElement = EncodeSetDefinitionFromString(inputSetDefinitionStringArray(i), tableXMLElementsList, propertiesAvailable, showTableDialog);
        if XMLSetElement ~= [] then
            XMLSetElementsList($+1) = XMLSetElement;
        end
    end
    
endfunction

//set_definition: property = number|property|math_functions [type=value|fg_value|delta|fg_delta ; action=step|fg_step|ramp|fg_ramp|exp|fg_exp ; tc=number]
function [XMLSetElement]=EncodeSetDefinitionFromString(inputSetDefinitionString, tableXMLElementsList, propertiesAvailable, showTableDialog)
    
    
    modifiedSetDefinitionString = inputSetDefinitionString;
    //if the set definition line is empty, end function
    if strsubst(modifiedSetDefinitionString, " ", "") == emptystr() then
        XMLSetElement = [];
        return;
    end
    
    
    
    //create empty XML document
    XMLSetElement = xmlDocument();
    //add only one child (root) element "set"
    XMLSetElement.root = xmlElement(XMLSetElement, "set");
    
    
    
    
    //find '[' char if any which indicate attribute definition
    indexLeftSquareBracket = strindex(modifiedSetDefinitionString, "[");
    indexRightSquareBracket = strindex(modifiedSetDefinitionString, "]");
    
    //if the number of left and right brackets is different, show error message and end this function
    if size(indexLeftSquareBracket, 2) ~= size(indexRightSquareBracket, 2) then
        messagebox(["The number of left and right square brackets don''t match!" ; "Number of left/right brackets: " + string(size(indexLeftSquareBracket, 2)) + "/" + string(size(indexRightSquareBracket, 2)) ], "modal", "error");
        CheckAndDeleteXMLDoc(XMLSetElement);
        XMLSetElement = [];
        return;
    end
    
    
    //if there is at least one left square bracket (and because of the previous if-condition also right square bracket)
    if size(indexLeftSquareBracket, 2) >= 1 then
//    //if there is only one left square bracket (and because of the previous if-condition also right square bracket)
//    if size(indexLeftSquareBracket, 2) == 1 then
        
        //check if the last left square is before the last right square bracket
        if indexLeftSquareBracket(size(indexLeftSquareBracket, 2)) < indexRightSquareBracket(size(indexRightSquareBracket, 2)) then
            
            //get part of the string between the square brackets
            setAttributesDefinition = part(modifiedSetDefinitionString, indexLeftSquareBracket(size(indexLeftSquareBracket, 2))+1:indexRightSquareBracket(size(indexRightSquareBracket, 2))-1);
            //delete the last part with attribute definition in set definition input string
            modifiedSetDefinitionString = part(modifiedSetDefinitionString, 1:indexLeftSquareBracket(size(indexLeftSquareBracket, 2))-1);
            
            if strsubst(setAttributesDefinition, " ", "") ~= emptystr() then
                
                setAttributesTokens = tokens(setAttributesDefinition, ";");
                for i = 1 : 1 : size(setAttributesTokens, 1)
                    
                    if strsubst(setAttributesTokens(i), " ", "") ~= emptystr() then
                        
                        setAttributeToken = tokens(setAttributesTokens(i), "=");
                        //if there are exactly two strings
                        if size(setAttributeToken, 1) == 2 then
                            
                            //get left and right part of attribute definition without spaces and in lower characters
                            leftPart = convstr(strsubst(setAttributeToken(1), " ", ""), 'l');
                            rightPart = convstr(strsubst(setAttributeToken(2), " ", ""), 'l');
                            
                            global SetAttributesPossibleInputTypesListGlobal;
                            //if the left part is "type" attribute, check the value
                            if leftPart == "type" then
                                
                                //check if the value of the attribute "type" is in correct format
                                isCorrect = CheckCorrectValueType(rightPart, SetAttributesPossibleInputTypesListGlobal(1), propertiesAvailable, %f);
                                if isCorrect == %f then
                                    messagebox(["The value of the attribute """ + leftPart + """ can be only: " + SetAttributesPossibleInputTypesListGlobal(1) + "!" ; "The current value: """ + setAttributeToken(2) + """" ], "modal", "error");
                                    CheckAndDeleteXMLDoc(XMLSetElement);
                                    XMLSetElement = [];
                                    return;
                                end
                                
                                //set the "type" attribute
                                XMLSetElement.root.attributes.type = rightPart;
                                
                                
                            //else if the left part is "action" attribute, check the value
                            elseif leftPart == "action" then
                                
                                //check if the value of the attribute "action" is in correct format
                                isCorrect = CheckCorrectValueType(rightPart, SetAttributesPossibleInputTypesListGlobal(2), propertiesAvailable, %f);
                                if isCorrect == %f then
                                    messagebox(["The value of the attribute """ + leftPart + """ can be only: " + SetAttributesPossibleInputTypesListGlobal(2) + "!" ; "The current value: """ + setAttributeToken(2) + """" ], "modal", "error");
                                    CheckAndDeleteXMLDoc(XMLSetElement);
                                    XMLSetElement = [];
                                    return;
                                end
                                
                                //set the "action" attribute
                                XMLSetElement.root.attributes.action = rightPart;
                                
                                
                            //else if the left part is "tc" attribute, check the value
                            elseif leftPart == "tc" then
                                
                                //if the right part is number
                                if isnum(rightPart) then
                                    
                                    //if the number is lower than 0, show errror
                                    rightPartNumber = strtod(rightPart);
                                    if rightPartNumber < 0 then
                                        messagebox(["The value of the attribute """ + leftPart + """ cannot be lower than 0!" ; """" + setAttributeToken(2) + """" ], "modal", "error");
                                        CheckAndDeleteXMLDoc(XMLSetElement);
                                        XMLSetElement = [];
                                        return;
                                    end
                                    
                                    //set the "tc" attribute
                                    XMLSetElement.root.attributes.tc = rightPart;
                                    
                                    
                                else
                                    messagebox(["The value of the attribute """ + leftPart + """ is not number!" ; """" + setAttributeToken(2) + """" ], "modal", "error");
                                    CheckAndDeleteXMLDoc(XMLSetElement);
                                    XMLSetElement = [];
                                    return;
                                end
                                
                                
                            //otherwise, the left part of the attribute definition was not recognized
                            else
                                messagebox(["The left part of the attribute definition is unknown!" ; """" + setAttributeToken(1) + """" ], "modal", "error");
                                CheckAndDeleteXMLDoc(XMLSetElement);
                                XMLSetElement = [];
                                return;
                            end
                            
                            
                        //otherwise, the attribute definition in set definition is not in the correct format
                        else
                            messagebox(["The attribute definition (part in the square brackets) is not in the correct format!" ; setAttributesTokens(i) ], "modal", "error");
                            CheckAndDeleteXMLDoc(XMLSetElement);
                            XMLSetElement = [];
                            return;
                        end
                        
                    end
                    
                end
                
            end
            
            
        //otherwise, the left square bracket is behind the right square bracket, show error message
        else
            messagebox(["The left square bracket is behind the right square bracket!" ; part(modifiedSetDefinitionString, indexRightSquareBracket(size(indexRightSquareBracket, 2)):indexLeftSquareBracket(size(indexLeftSquareBracket, 2))) ], "modal", "error");
            CheckAndDeleteXMLDoc(XMLSetElement);
            XMLSetElement = [];
            return;
        end
        
        
//    //else if there is more than one square bracket, show error message
//    elseif size(indexLeftSquareBracket, 2) > 1 then
//        messagebox(["The number of left square brackets is higher than 1 in the set definition! Only one or none is allowed" ; "Number of left brackets: " + string(size(indexLeftSquareBracket, 2)) ], "modal", "error");
//        CheckAndDeleteXMLDoc(XMLSetElement);
//        XMLSetElement = [];
//        return;
    end
    
    
    
    
    
    //get the left and right part of set definition without the attribute definition
    setDefinitionMain = tokens(modifiedSetDefinitionString, "=");
    
    if size(setDefinitionMain, 1) < 2 then
        messagebox(["The main set definition part doesn''t contain ""="" char!" ; """" + modifiedSetDefinitionString + """" ], "modal", "error");
        CheckAndDeleteXMLDoc(XMLSetElement);
        XMLSetElement = [];
        return;
    elseif size(setDefinitionMain, 1) > 2 then
        messagebox(["The main set definition part contains too many ""="" chars!" ; """" + modifiedSetDefinitionString + """" ], "modal", "error");
        CheckAndDeleteXMLDoc(XMLSetElement);
        XMLSetElement = [];
        return;
    end
    
    
    
    leftSetMainProperty = setDefinitionMain(1);
    rightSetMainPropertyNumberMathFunction = setDefinitionMain(2);
    
    //check if the left part is a property
    isLeftSetMainProperty = CheckCorrectValueType(leftSetMainProperty, "property", propertiesAvailable, %f);
    if isLeftSetMainProperty == %f then
        messagebox(["The left part of the main set definition is not known property (forgotten property definition?)!" ; """" + leftSetMainProperty + """" ], "modal", "error");
        CheckAndDeleteXMLDoc(XMLSetElement);
        XMLSetElement = [];
        return;
    end
    
    //set the "name" attribute (without spaces and with lower cases)
    XMLSetElement.root.attributes.name = convstr(strsubst(leftSetMainProperty, " ", ""), 'l');
    
    
    
    
    tableTag = "table";
    //if the right part of the main set definition contains left or right bracket, or "table" tag, it should be the function definition
    if strindex(rightSetMainPropertyNumberMathFunction, "(") ~= [] | strindex(rightSetMainPropertyNumberMathFunction, ")") ~= [] | strindex(convstr(rightSetMainPropertyNumberMathFunction, 'l'), tableTag) ~= [] then
        
        
        //find the table tag in function if any
        XMLTableElementsList = list();
        //get all table tag strings from string equation if any
        tableStringsList = GetTableStringsFromStringEquation(rightSetMainPropertyNumberMathFunction, tableTag);
        //if any table tag was found, process it
        if length(tableStringsList) > 0 then
            
            //if table dialog should NOT be shown, set default row name to a property which is included in "templates\properties.txt" file
            tablePropertyRowsDefaultName = emptystr();
            if showTableDialog == %f then
                tablePropertyRowsDefaultName = "aero/alpha-deg";    //it may be any property defined in "templates\properties.txt" file
            end
            //decode or create default data from table XML elements
            [tableStringsMatricesList, tableTitleArraysList, tablePropertyRowsList, tablePropertyColumnsList, tablesPropertyTableList] = DecodeOrCreateXMLTables(tableXMLElementsList, tableStringsList, tablePropertyRowsDefaultName);
            
            
            //if all lists have same length, everything is OK
            if length(tableStringsList) == length(tableStringsMatricesList) & length(tableStringsList) == length(tableTitleArraysList) & length(tableStringsList) == length(tablePropertyRowsList) & length(tableStringsList) == length(tablePropertyColumnsList) & length(tableStringsList) == length(tablesPropertyTableList) then
                
                //show table dialogs for all table strings in list with decoded or defaultly created structures
                for x = 1 : 1 : length(tableStringsList)
                    
                    outTableStringMatrices = tableStringsMatricesList(x);
                    outTableTitleArray = tableTitleArraysList(x);
                    outPropertyRow = tablePropertyRowsList(x);
                    outPropertyColumn = tablePropertyColumnsList(x);
                    outPropertyTable = tablesPropertyTableList(x);
                    if showTableDialog == %t then
                        //show table dialog with decoded values
                        [outTableStringMatrices, outTableTitleArray, outPropertyRow, outPropertyColumn, outPropertyTable] = DialogTableOkCancel(tableStringsMatricesList(x), tableTitleArraysList(x), tablePropertyRowsList(x), tablePropertyColumnsList(x), tablesPropertyTableList(x), propertiesAvailable);
                    end
                    
                    //if there is any output
                    if outTableStringMatrices ~= [] & outTableStringMatrices ~= list() then
                        
                        //encode string data from dialog to XML table
                        outXMLTable = EncodeXMLTable(outTableStringMatrices, outTableTitleArray, outPropertyRow, outPropertyColumn, outPropertyTable);
                        //if there is no error
                        if outXMLTable ~= [] then
                            
                            //add table element to the list of XML table elements
                            XMLTableElementsList($+1) = outXMLTable;
                            
                        else
                            messagebox(["Table no. " + string(x) + " was not set properly!" ; "row property: """ + outPropertyRow + """" ; "column property: """ + outPropertyColumn + """" ; "table property: " + outPropertyTable + """" ], "modal", "error");  // ; "Table Titles: " ; outTableTitleArray ; "Table Data: " ; outTableStringMatrices
                        end
                        
                        
                    else
                        //otherwise, cancel was clicked (or some error occured?)
                        CheckAndDeleteXMLDoc(XMLSetElement);
                        XMLSetElement = [];
                        return;
                    end
                    
                    
                end
                
            else
                messagebox(["Tables were not loaded properly!" ; "The number of proposed tables is not equal to the number of decoded/created tables" ; "rows properties: """ + tablePropertyRowsList + """" ; "columns properties: """ + tablePropertyColumnsList + """" ; "tables properties: " + tablesPropertyTableList + """" ; "Tables Titles: " ; tableTitleArraysList ; "Tables Data: " ; tableStringsMatricesList ; ], "modal", "error");
                CheckAndDeleteXMLDoc(XMLSetElement);
                XMLSetElement = [];
                return;
            end
            
            
        end
        
        
        
        
        
        //convert string to XML function element
        XMLMathFunctionsElement = StringEquationToXMLMathFunc(rightSetMainPropertyNumberMathFunction, propertiesAvailable, XMLTableElementsList);
        //check if conversion of function was successful
        if XMLMathFunctionsElement ~= [] then
            



            //add new XML function element to the output XML set element
            xmlAppend(XMLSetElement.root, XMLMathFunctionsElement.root);
            
        else
            
            messagebox(["Function in set definition was not converted properly!" ; "(Wrong) function definition: """ + rightSetMainPropertyNumberMathFunction + """"], "modal", "error");
            CheckAndDeleteXMLDoc(XMLSetElement);
            XMLSetElement = [];
            return;
            
        end
        
    //otherwise, it should be number or property
    else
        
        //check if the right part is a number or property
        isRightSetMainPropertyNumber = CheckCorrectValueType(rightSetMainPropertyNumberMathFunction, "number|property", propertiesAvailable, %f);
        if isRightSetMainPropertyNumber == %f then
            messagebox(["The right part of the main set definition is not number or known property!" ; """" + rightSetMainPropertyNumberMathFunction + """" ], "modal", "error");
            CheckAndDeleteXMLDoc(XMLSetElement);
            XMLSetElement = [];
            return;
        end
        
        //set the "value" attribute (without spaces and with lower cases)
        XMLSetElement.root.attributes.value = convstr(strsubst(rightSetMainPropertyNumberMathFunction, " ", ""), 'l');
        
    end
    
    
    
    XMLSetElement = XMLSetElement.root;
    
endfunction



function [outSetDefinitionStringArray]=DecodeSetDefinitionsToStringArray(XMLSetElementsList)
    
    outSetDefinitionStringArray = [];
    for i = 1 : 1 : length(XMLSetElementsList)
        outSetDefinitionStringArray(size(outSetDefinitionStringArray, 1) + 1) = DecodeSetDefinitionToString(XMLSetElementsList(i));
    end
    
endfunction


function [outSetDefinitionString]=DecodeSetDefinitionToString(XMLSetElement)
    
    outSetDefinitionString = emptystr();
    
    //if there is a xml set element
    if XMLSetElement ~= [] then
        
        
        spaceEqualSpace = " = ";
        spaceSpaceSpace = "   ";
        spaceSemicolonSpace = " ; ";
        
        
        
        //get name attribute if any (it should be) and add it to output set definition string
        nameXMLSetAttribute = XMLSetElement.attributes.name;
        if nameXMLSetAttribute ~= [] then
            outSetDefinitionString = nameXMLSetAttribute;
        else
            outSetDefinitionString = "<property name (name attribute) is missing>";
        end
        outSetDefinitionString = outSetDefinitionString + spaceEqualSpace;
        
        
        
        //get value attribute if any and add it to output set definition string
        valueXMLSetAttribute = XMLSetElement.attributes.value;
        //if a reset file version should be 1
        if valueXMLSetAttribute ~= [] then
            
            outSetDefinitionString = outSetDefinitionString + valueXMLSetAttribute + spaceSpaceSpace;
            
        //otherwise, there should be function xml element only in children
        else
            
            stringFunction = emptystr();
            //get function element if exists
            functionXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLSetElement, "function");
            if functionXMLElementIndexes ~= [] then
                
                //decode XML function element and convert it to string (note: there should be only one index found, i.e. one function element)
                stringFunction = XMLMathFuncToStringEquation(XMLSetElement.children(functionXMLElementIndexes(1)));
                
                //if the output function string is empty, add information about error during conversion
                if stringFunction == emptystr() then
                    stringFunction = "<XML function element was not converted properly! (empty string)>";
                end
                
                
            //otherwise, if does not exist, add information about missing attribute and child element
            else
                stringFunction = "<No value attribute or XML function element was found>";
            end
            
            
            //add string with equation or with error string to the whole set definition string
            outSetDefinitionString = outSetDefinitionString + stringFunction + spaceSpaceSpace;
            
        end
        
        
        
        
        //add left square bracket
        outSetDefinitionString = outSetDefinitionString + "[ ";
        
        //get type attribute if any and add it to output set definition string
        typeXMLSetAttribute = XMLSetElement.attributes.type;
        if typeXMLSetAttribute ~= [] then
            outSetDefinitionString = outSetDefinitionString + "type" + spaceEqualSpace + typeXMLSetAttribute + spaceSemicolonSpace;
        end
        
        
        //get action attribute if any and add it to output set definition string
        actionXMLSetAttribute = XMLSetElement.attributes.action;
        if actionXMLSetAttribute ~= [] then
            outSetDefinitionString = outSetDefinitionString + "action" + spaceEqualSpace + actionXMLSetAttribute + spaceSemicolonSpace;
        end
        
        
        //get tc attribute if any and add it to output set definition string
        tcXMLSetAttribute = XMLSetElement.attributes.tc;
        if tcXMLSetAttribute ~= [] then
            outSetDefinitionString = outSetDefinitionString + "tc" + spaceEqualSpace + tcXMLSetAttribute + spaceSemicolonSpace;
        end
        
        outSetDefinitionString = outSetDefinitionString + "]";
        
        
    end
    
    
endfunction




function [XMLNotifyElement]=EncodeNotifyPropertyFromStringArray(inputNotifyPropertyStringArray, propertiesAvailable)
    
    //create empty XML document
    XMLNotifyElement = xmlDocument();
    //add only one child (root) element "notify"
    XMLNotifyElement.root = xmlElement(XMLNotifyElement, "notify");
    
    for i = 1 : 1 : size(inputNotifyPropertyStringArray, 1)
        
        valueWithoutSpaces = strsubst(inputNotifyPropertyStringArray(i), " ", "");
        if valueWithoutSpaces ~= emptystr() then
            isCorrect = CheckCorrectValueType(valueWithoutSpaces, "property", propertiesAvailable, %t);
            if isCorrect then
                
                //add new element (property)
                newXMLelement = xmlElement(XMLNotifyElement, "property");
                newXMLelement.content = valueWithoutSpaces;
                xmlAppend(XMLNotifyElement.root, newXMLelement);
                
            else
                disp(valueWithoutSpaces + " is not a valid property name - ignored!");
            end
        end
        
    end
    
    XMLNotifyElement = XMLNotifyElement.root;
    
endfunction



function [outNotifyPropertyStringArray]=DecodeNotifyPropertyToStringArray(XMLNotifyElement)
    
    outNotifyPropertyStringArray = [];
    if XMLNotifyElement ~= [] then
        //if the name element is "notify"
        if XMLNotifyElement.name == "notify" then
            for i = 1 : 1 : length(XMLNotifyElement.children)
                
                //if the child element is "property", add the content to string array
                if XMLNotifyElement.children(i).name == "property" then
                    outNotifyPropertyStringArray(size(outNotifyPropertyStringArray, 1) + 1) = strsubst(XMLNotifyElement.children(i).content, " ", "");
                end
                
            end
        else
            disp("Checked xml element is not ""notify"" but """ + XMLNotifyElement.name + """!")
        end
    end
    
endfunction



function [xmlSimulationFilePath, xmlSimulationFileName]=ShowSaveDialogXMLSimulation(xmlSimulation)
    
    //show save dialog for JSBSim simulation file
    [fileNameSave, pathNameSave, filterIndexSave] = uiputfile( ["*.xml","XML files"], "scripts", "Save file with JSBSim simulation definition" );
    
    //check if cancel button was not clicked
    if fileNameSave ~= "" & pathNameSave ~= "" & filterIndexSave ~= 0 then
        
        //check xmlSimulation - whether exists, is in XMLDoc format, and is valid object
        if exists("xmlSimulation") == 1 then
            if typeof(xmlSimulation) == "XMLDoc" then
                if xmlIsValidObject(xmlSimulation) == %t then
                    
                    //set name attribute of the root xml element to the filename without extension
                    xmlSimulation.root.attributes.name = GetFileNameWithoutExtension(fileNameSave, ".xml");
                    xmlSimulationFileName = xmlSimulation.root.attributes.name;
                    
                    //set simulation file path with extension and save xml simulation file
                    extension = GetExtensionForFileIfNecessary(fileNameSave, ".xml");
                    xmlSimulationFilePath = pathNameSave + filesep() + fileNameSave + extension;
                    xmlWrite(xmlSimulation, xmlSimulationFilePath, %t);
                    
                    messagebox("Simulation definition was saved sucessfully!", "modal", "info");
                    
                end
            end
        end
        
    end
    
endfunction



function [aircraftFile, resetFile]=GetAircraftAndResetFileFromSimulationDefinition(XMLSimulationScriptDoc)
    
    aircraftFile = emptystr();
    resetFile = emptystr();
    
    //if the root name element of xml simulation object is "runscript", it is valid JSBSim simulation xml definition
    if XMLSimulationScriptDoc.root.name == "runscript" then
        //if the simulation xml object contains any children element
        if length(XMLSimulationScriptDoc.root.children) > 0 then
            
            //get use element if exists
            useXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLSimulationScriptDoc.root, "use");
            if useXMLElementIndexes ~= [] then
                
                //get (or get default) value of attributes "aircraft" and "initialize" of use xml element
                aircraftFile = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(useXMLElementIndexes(1)), "aircraft", emptystr());
                resetFile = GetXMLAttributeOrDefault(XMLSimulationScriptDoc.root.children(useXMLElementIndexes(1)), "initialize", emptystr());
            
            end
        else
            messagebox("Input XMLSimulationScriptDoc does not have any children! The simulation file cannot be empty!", "modal", "error");
        end

    else
        messagebox("Input XMLSimulationScriptDoc is in wrong format! The XML is not a valid simulation file!", "modal", "error");
    end
    
    
endfunction






//simulation start XML file

function [XMLSimulationStartDoc]=EncodeSimulationStartXMLFromListsString(inputSimulationStartListString, inXmlSimulationFileName, propertiesAvailable)
    
    XMLSimulationStartDoc = [];
    
    scilabTag = "SCILAB_V6";
    flightGearTag = "FLIGHTGEAR"
    if (inputSimulationStartListString ~= [] | inputSimulationStartListString ~= list()) then
        
        sizeNeededInputSimulationStartListString = 15;
        if length(inputSimulationStartListString) == sizeNeededInputSimulationStartListString then
            
            XMLSimulationStartDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "simulation_start_template.xml");
            errorString=ValidateXMLdocument(XMLSimulationStartDoc);
            
            //if the root name element of xml template simulation start file is "simulation_start", it is valid template simulation start file
            if XMLSimulationStartDoc.root.name == "simulation_start" then
                
                
                
                //find and get (or create) description xml element
                descriptionXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationStartDoc, XMLSimulationStartDoc.root, "description");
                if inputSimulationStartListString(1) ~= [] then
                    descriptionXMLElement.content = inputSimulationStartListString(1);
                else
                    descriptionXMLElement.content = emptystr();
                end
                
                
                
                //find and get (or create) script xml element
                scriptXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationStartDoc, XMLSimulationStartDoc.root, "script");
                if inXmlSimulationFileName ~= [] & inXmlSimulationFileName ~= emptystr() then
                    scriptXMLElement.content = inXmlSimulationFileName;
                else
                    messagebox("Filename of simulation definition (script) is empty!", "modal", "error");
                    CheckAndDeleteXMLDoc(XMLSimulationStartDoc);
                    XMLSimulationStartDoc = [];
                    return;
                end
                
                
                
                //find and get (or create) jsbsim_command_options xml element
//                scriptCommandBasic = "--script=" + """" + "scripts" + filesep() + scriptXMLElement.content + """";
                jsbsimCommandOptionsXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationStartDoc, XMLSimulationStartDoc.root, "jsbsim_command_options");
                if inputSimulationStartListString(3) ~= [] then
//                    inputSimulationStartListString(3)(size(inputSimulationStartListString(3), 1) + 1) = scriptCommandBasic;
                    jsbsimCommandOptionsXMLElement.content = inputSimulationStartListString(3);
//                else
//                    jsbsimCommandOptionsXMLElement.content = scriptCommandBasic;
                end
                
                
                
                //find and get (or create) output_processing xml element
                outputProcessingXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationStartDoc, XMLSimulationStartDoc.root, "output_processing");
                if inputSimulationStartListString(8) ~= [] then
                    outputProcessingApplication = strsubst(inputSimulationStartListString(8), " ", "");
                    //if Scilab or FlightGear was selected copy it
                    if convstr(outputProcessingApplication, "u") == flightGearTag then
                        outputProcessingXMLElement.content = flightGearTag;
                    else
                        //otherwise, set default (Scilab)
                        outputProcessingXMLElement.content = scilabTag;
                        
                        //check and set number of graphs in line for Scilab processing purpose
                        isNumberNumberOfGraphsInLine = isnum(inputSimulationStartListString(6));
                        if isNumberNumberOfGraphsInLine then
                            outputProcessingXMLElement.attributes.number_of_graphs_in_line = inputSimulationStartListString(6);
                        else
                            outputProcessingXMLElement.attributes.number_of_graphs_in_line = "4";
                        end
                        
                        //check and set number of graphs in window for Scilab processing purpose
                        isNumberNumberOfGraphsInWindow = isnum(inputSimulationStartListString(7));
                        if isNumberNumberOfGraphsInWindow then
                            outputProcessingXMLElement.attributes.number_of_graphs_in_window = inputSimulationStartListString(7);
                        else
                            outputProcessingXMLElement.attributes.number_of_graphs_in_window = "8";
                        end
                    end
                else
                    //otherwise, set default (Scilab)
                    outputProcessingXMLElement.content = scilabTag;
                    


                    //check and set number of graphs in line for Scilab processing purpose
                    isNumberNumberOfGraphsInLine = isnum(inputSimulationStartListString(6));
                    if isNumberNumberOfGraphsInLine then
                        outputProcessingXMLElement.attributes.number_of_graphs_in_line = inputSimulationStartListString(6);
                    else
                        outputProcessingXMLElement.attributes.number_of_graphs_in_line = "4";
                    end
                    
                    //check and set number of graphs in window for Scilab processing purpose
                    isNumberNumberOfGraphsInWindow = isnum(inputSimulationStartListString(7));
                    if isNumberNumberOfGraphsInWindow then
                        outputProcessingXMLElement.attributes.number_of_graphs_in_window = inputSimulationStartListString(7);
                    else
                        outputProcessingXMLElement.attributes.number_of_graphs_in_window = "8";
                    end
                end
                //set attributes of output processing xml element
                isNumberTimeStart = isnum(inputSimulationStartListString(4));
                if isNumberTimeStart then
                    outputProcessingXMLElement.attributes.time_start = inputSimulationStartListString(4);
                else
                    outputProcessingXMLElement.attributes.time_start = "0";
                end
                isNumberTimeEnd = isnum(inputSimulationStartListString(5));
                if isNumberTimeEnd then
                    outputProcessingXMLElement.attributes.time_end = inputSimulationStartListString(5);
                else
                    outputProcessingXMLElement.attributes.time_end = "%inf";
                end
                
                
                
                //find and get (or create) output xml element
                xmlIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLSimulationStartDoc.root, "output");
                if xmlIndexArray ~= [] then
                    if inputSimulationStartListString(13) ~= [] then
                        XMLSimulationStartDoc.root.children(xmlIndexArray(1)) = inputSimulationStartListString(13);
                    else
                        outputXMLDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_with_defaults.xml");
                        XMLSimulationStartDoc.root.children(xmlIndexArray(1)) = outputXMLDoc.root;
                    end
                else
                    //add new element (with a specific name)
                    newXMLelement = xmlElement(XMLSimulationStartDoc, "output");
                    xmlAppend(XMLSimulationStartDoc.root, newXMLelement);
                    if inputSimulationStartListString(13) ~= [] then
                        XMLSimulationStartDoc.root.children(length(XMLSimulationStartDoc.root.children)) = inputSimulationStartListString(13);
                    else
                        outputXMLDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_with_defaults.xml");
                        XMLSimulationStartDoc.root.children(length(XMLSimulationStartDoc.root.children)) = outputXMLDoc.root;
                    end
                end
                outputXMLElement = XMLSimulationStartDoc.root.children(xmlIndexArray(1));
                //set attributes of output xml element
                //if FlightGear was selected
                if convstr(outputProcessingXMLElement.content, "u") == flightGearTag then
                    
                    outputXMLElement.attributes.type = flightGearTag;
                    outputXMLElement.attributes.name = "localhost";
                    
                    //check if port is number
                    isNumberPort = isnum(inputSimulationStartListString(11));
                    if isNumberPort then
                        outputXMLElement.attributes.port = strsubst(inputSimulationStartListString(11), " ", "");
                    else
                        outputXMLElement.attributes.port = "5500";
                    end
                    
                    //check if protocol is set correctly
                    protocolWithoutSpaces = strsubst(inputSimulationStartListString(12), " ", "");
                    protocolWithoutSpacesLower = convstr(protocolWithoutSpaces, "l");
                    if protocolWithoutSpacesLower == "udp" then
                        outputXMLElement.attributes.protocol = protocolWithoutSpacesLower;
                    else
                        outputXMLElement.attributes.protocol = "tcp";
                    end
                else
                    //otherwise, set default CSV format file
                    outputXMLElement.attributes.type = "CSV";
                    extensionCSV = GetExtensionForFileIfNecessary(inputSimulationStartListString(9), ".csv");
                    outputXMLElement.attributes.name = inputSimulationStartListString(9) + extensionCSV;
                end
                //check if rate is number and set it or set default
                isNumberRate = isnum(inputSimulationStartListString(10));
                if isNumberRate then
                    outputXMLElement.attributes.rate = strsubst(inputSimulationStartListString(10), " ", "");
                else
                    outputXMLElement.attributes.rate = "30";
                end
                
                
                
                //find and get (or create) flightgear_path xml element
                flightGearPathXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationStartDoc, XMLSimulationStartDoc.root, "flightgear_path");
                if convstr(outputProcessingXMLElement.content, "u") == flightGearTag & inputSimulationStartListString(14) ~= [] & inputSimulationStartListString(14) ~= emptystr() then
                    
                    fileFlightGearExecutableExist = fileinfo(inputSimulationStartListString(14));
                    if fileFlightGearExecutableExist == [] then
                        messagebox("The selected FlighGear executable file does not exist! """ + inputSimulationStartListString(14) + """", "modal", "error");
                        CheckAndDeleteXMLDoc(XMLSimulationStartDoc);
                        XMLSimulationStartDoc = [];
                        return;
                    end
                    flightGearPathXMLElement.content = inputSimulationStartListString(14);
                    
                elseif convstr(outputProcessingXMLElement.content, "u") == flightGearTag then
                        //if FlightGear was selected but the path is empty
                        messagebox("File path of FlightGear is empty!", "modal", "error");
                        CheckAndDeleteXMLDoc(XMLSimulationStartDoc);
                        XMLSimulationStartDoc = [];
                        return;
                end
                
                
                
                //find and get (or create) flightgear_command_options xml element if FlightGear was selected
                //if convstr(outputProcessingXMLElement.content, "u") == flightGearTag then
                    
//                    fgCommandBasic = "--native-fdm=socket,in," + outputXMLElement.attributes.rate + ",," + outputXMLElement.attributes.port + "," + outputXMLElement.attributes.protocol + "  --fdm=external";
                flightgearCommandOptionsXMLElement = FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(XMLSimulationStartDoc, XMLSimulationStartDoc.root, "flightgear_command_options");
                if inputSimulationStartListString(15) ~= [] then
//                        inputSimulationStartListString(15)(size(inputSimulationStartListString(15), 1) + 1) = fgCommandBasic;
                    flightgearCommandOptionsXMLElement.content = inputSimulationStartListString(15);
//                    else
//                        flightgearCommandOptionsXMLElement.content = fgCommandBasic;
                end
                    
                //end
                
                
                
            else
                messagebox("Wrong format! The template XML file is not a valid simulation start file (check templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "simulation_start_template.xml)!", "modal", "error");
                CheckAndDeleteXMLDoc(XMLSimulationStartDoc);
                XMLSimulationStartDoc = [];
                return;
            end
            
        else
            messagebox("inputSimulationStartListString does not have necessary number of elements (" + string(sizeNeededInputSimulationStartListString) + ") but " + string(length(inputSimulationStartListString)) + "!", "modal", "error");
        end
        
    else
        messagebox("inputSimulationStartListString is empty list!", "modal", "error");
    end
    
    
endfunction



function [outSimulationStartListString]=DecodeSimulationStartXMLToListsString(XMLSimulationStartDoc)
    
    outSimulationStartListString = list();
    
    
    flightGearTag = "FLIGHTGEAR"
    //if it is valid xml object
    if XMLSimulationStartDoc ~= [] & typeof(XMLSimulationStartDoc) == "XMLDoc" & xmlIsValidObject(XMLSimulationStartDoc) == %t then
        
        //if the root name element of xml simulation start file is "simulation_start", it is valid simulation start file
        if XMLSimulationStartDoc.root.name == "simulation_start" then
            
            
            
            //get (or get default) content of description xml element
            xmlDescriptionContentArray = GetXMLContentOrDefault(XMLSimulationStartDoc.root, "description", emptystr());
            outSimulationStartListString($+1) = xmlDescriptionContentArray;
            
            
            
            //get (or get default) content of script xml element
            xmlScriptContent = GetXMLContentOrDefault(XMLSimulationStartDoc.root, "script", emptystr());    //pwd() + filesep() + "scripts" + filesep());
            outSimulationStartListString($+1) = xmlScriptContent;
            
            
            
            //get (or get default) content of jsbsim_command_options xml element
            xmlJsbsiCommandOptionsContentArray = GetXMLContentOrDefault(XMLSimulationStartDoc.root, "jsbsim_command_options", "--realtime");
            outSimulationStartListString($+1) = xmlJsbsiCommandOptionsContentArray;
            
            
            
            //get output_processing xml element and add each attribute or default
            defaultOutputProcessing = list("0", "%inf", "4", "8", "SCILAB_V6");
            outputProcessingXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(XMLSimulationStartDoc.root, "output_processing");
            if outputProcessingXMLElement ~= [] then
                
                if outputProcessingXMLElement.attributes.time_start ~= [] then
                    outSimulationStartListString($+1) = outputProcessingXMLElement.attributes.time_start;
                else
                    outSimulationStartListString($+1) = defaultOutputProcessing(1);
                end
                
                if outputProcessingXMLElement.attributes.time_end ~= [] then
                    outSimulationStartListString($+1) = outputProcessingXMLElement.attributes.time_end;
                else
                    outSimulationStartListString($+1) = defaultOutputProcessing(2);
                end
                
                if outputProcessingXMLElement.attributes.number_of_graphs_in_line ~= [] then
                    outSimulationStartListString($+1) = outputProcessingXMLElement.attributes.number_of_graphs_in_line;
                else
                    outSimulationStartListString($+1) = defaultOutputProcessing(3);
                end
                
                if outputProcessingXMLElement.attributes.number_of_graphs_in_window ~= [] then
                    outSimulationStartListString($+1) = outputProcessingXMLElement.attributes.number_of_graphs_in_window;
                else
                    outSimulationStartListString($+1) = defaultOutputProcessing(4);
                end
                
                //add the content as the last
                outSimulationStartListString($+1) = strsubst(outputProcessingXMLElement.content, " ", "");
                
            else
                
                outSimulationStartListString($+1) = defaultOutputProcessing(1);
                outSimulationStartListString($+1) = defaultOutputProcessing(2);
                outSimulationStartListString($+1) = defaultOutputProcessing(3);
                outSimulationStartListString($+1) = defaultOutputProcessing(4);
                outSimulationStartListString($+1) = defaultOutputProcessing(5);
                
            end
            
            
            
            //get output xml element and add each attribute or default
            isFlightGearSelected = %f;
            defaultOutput = list("output_Simulation.csv", "30", emptystr(), "tcp");
            //if FlightGear was selected
            if convstr(outSimulationStartListString(length(outSimulationStartListString)), "u") == flightGearTag then
                isFlightGearSelected = %t;
                defaultOutput(1) = "localhost";
                defaultOutput(3) = "5500";
            end
            
            outputXMLElement = FindFirstXMLElementInFirstChildrenOfXMLElement(XMLSimulationStartDoc.root, "output");
            if outputXMLElement ~= [] then
                
                if outputXMLElement.attributes.name ~= [] then
                    outSimulationStartListString($+1) = outputXMLElement.attributes.name;
                else
                    outSimulationStartListString($+1) = defaultOutput(1);
                end
                
                if outputXMLElement.attributes.rate ~= [] then
                    outSimulationStartListString($+1) = outputXMLElement.attributes.rate;
                else
                    outSimulationStartListString($+1) = defaultOutput(2);
                end
                
                if outputXMLElement.attributes.port ~= [] then
                    outSimulationStartListString($+1) = outputXMLElement.attributes.port;
                else
                    outSimulationStartListString($+1) = defaultOutput(3);
                end
                
                if outputXMLElement.attributes.protocol ~= [] then
                    outSimulationStartListString($+1) = outputXMLElement.attributes.protocol;
                else
                    outSimulationStartListString($+1) = defaultOutput(4);
                end
                
                //create output xml elment and add all original children as the last (to delete attributes in xml element)
                outXMLDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_empty.xml");
                outXMLElem = outXMLDoc.root;
                for i = 1 : 1 : length(outputXMLElement.children)
                    xmlAppend(outXMLElem, outputXMLElement.children(i));
                end
                outSimulationStartListString($+1) = outXMLElem;
                
            else
                
                outSimulationStartListString($+1) = defaultOutput(1);
                outSimulationStartListString($+1) = defaultOutput(2);
                outSimulationStartListString($+1) = defaultOutput(3);
                outSimulationStartListString($+1) = defaultOutput(4);
                
                //get output xml elment with default values and add it as the last
                outXMLDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_with_defaults.xml");
                outXMLElem = outXMLDoc.root;
                outSimulationStartListString($+1) = outXMLElem;
                
            end
            
            
            
            //get (or get default) content of flightgear_path xml element
            xmlFlightgearPathContent = GetXMLContentOrDefault(XMLSimulationStartDoc.root, "flightgear_path", emptystr());
            if isFlightGearSelected == %t then
                
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
                                xmlFlightgearPathContent = GetXMLContentOrDefault(XMLSimulationStartDoc.root, "flightgear_path", emptystr());
                            end
                            
                        end
                        
                    end
                    
                    
                elseif OSName == LinuxOSName then
                    
                    if fileFlightGearExecutableExist == [] then
                        
                        //<> <>code for path of FlightGear in Linux distributions
                        
                    end
                    
                end
                
            end
            outSimulationStartListString($+1) = xmlFlightgearPathContent;
            
            
            
            //get (or get default) content of flightgear_command_options xml element
            xmlFlightgearCommandOptionsContent = GetXMLContentOrDefault(XMLSimulationStartDoc.root, "flightgear_command_options", emptystr());
            outSimulationStartListString($+1) = xmlFlightgearCommandOptionsContent;
            
            
            
        else
            messagebox("XMLSimulationStartDoc is in wrong format! The XML is not a valid simulation start file!", "modal", "error");
        end
        
    else
        messagebox("XMLSimulationStartDoc is not valid xml doc object or it is null!", "modal", "error");
    end
    
    
endfunction



function [outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName] = GetSimulationDefinitionFromSimulationStartOrControllerAdjustmentDefinitionXML(XMLSimulationStartOrControllerAdjustmentDefinitionDoc, rootXmlElementName)
    
    outXmlSimulation = [];
    outXmlSimulationFilePath = emptystr();
    outXmlSimulationFileName = emptystr();
    
    //rootSimulationStartName = "simulation_start";
    //rootControllerAdjustmentDefinitionName = "control_design_start";
    
    //if a simulation start / controller adjustment definition file is valid XMLDoc type and valid XML object
    if typeof(XMLSimulationStartOrControllerAdjustmentDefinitionDoc) == "XMLDoc" then
        if xmlIsValidObject(XMLSimulationStartOrControllerAdjustmentDefinitionDoc) == %t then
            
            //if the root name element of the currently edited xml simulation start / controller adjustment definition or file is "simulation_start"/"control_design_start", it is valid simulation start / controller adjustment definition file
            if XMLSimulationStartOrControllerAdjustmentDefinitionDoc.root.name == rootXmlElementName then
                //if the current simulation start / controller adjustment definition file contains any children element
                if length(XMLSimulationStartOrControllerAdjustmentDefinitionDoc.root.children) > 0 then
                    
                    //get content or default value of "script" xml element
                    defaultSimulationDefinitionPath = "templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "script_template_with_defaults.xml";
                    xmlSimulationFileName = GetXMLContentOrDefault(XMLSimulationStartOrControllerAdjustmentDefinitionDoc.root, "script", defaultSimulationDefinitionPath);
                    xmlSimulationPathFile = defaultSimulationDefinitionPath;
                    if xmlSimulationFileName ~= defaultSimulationDefinitionPath then
                        xmlSimulationPathFile = pwd() + filesep() + "scripts" + filesep() + xmlSimulationFileName + ".xml";
                    end
                    
                    if fileinfo(xmlSimulationPathFile) ~= [] then
                        
                        outXmlSimulation = xmlRead(xmlSimulationPathFile);
                        errorString=ValidateXMLdocument(outXmlSimulation);
                        
                        if typeof(outXmlSimulation) ~= "XMLDoc" | xmlIsValidObject(outXmlSimulation) == %f then
                            outXmlSimulation = xmlRead(defaultSimulationDefinitionPath);
                        else
                            outXmlSimulationFilePath = xmlSimulationPathFile;
                            outXmlSimulationFileName = xmlSimulationFileName;
                        end
                        
                    else
                        
                        outXmlSimulation = xmlRead(defaultSimulationDefinitionPath);
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
endfunction



function [outXmlOutputElement]=EncodeJSBSimXMLOutput(labels, values)
    
    outXmlOutputDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_empty.xml");
    outXmlOutputElement = outXmlOutputDoc.root;
    
    for i = 1 : 1 : size(labels, 2)
        
        //if the value contains properties
        if strindex(labels(i), "property;") ~= [] then
            
            //delete spaces and get property names separated by the semicolon (i.e. ";") token
            propertiesWithoutSpaces = strsubst(values(i), " ", "");
            propertyParts = tokens(propertiesWithoutSpaces, ";");
            
            //add property xml element with the specific property name
            for j = 1 : 1 : size(propertyParts, 1)
                xmlProperty = xmlElement(outXmlOutputDoc, "property");
                xmlProperty.content = propertyParts(j);
                xmlAppend(outXmlOutputElement, xmlProperty);
            end
            
        //otherwise, there is some ON/OFF general option
        else
            
            xmlOutputElement = xmlElement(outXmlOutputDoc, labels(i));
            xmlOutputElement.content = ConvertBooleanStringToOnOffString(values(i));
            xmlAppend(outXmlOutputElement, xmlOutputElement);
            
        end
        
    end
    
endfunction



function [labels, values]=DecodeJSBSimXMLOutput(inXmlOutputElement)
    
    labels = [];
    values = [];
    xmlOutputTemplateDoc = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output_with_defaults.xml");
    
    
    separatorWithSpaces = " ; ";
    propertiesString = emptystr();
    for i = 1 : 1 : length(inXmlOutputElement.children)
        
        xmlElementName = inXmlOutputElement.children(i).name;
        if xmlElementName ~= "comment" & xmlElementName ~= "documentation" & xmlElementName ~= "description" & xmlElementName ~= "text" then
            
            if xmlElementName == "property" then
                
                //add property name to string with all properties separated by semicolon (i.e. ";")
                if propertiesString == emptystr() then
                    propertiesString = strsubst(inXmlOutputElement.children(i).content, " ", "");
                else
                    propertiesString = propertiesString + separatorWithSpaces + strsubst(inXmlOutputElement.children(i).content, " ", "");
                end
                
            else
                
                //convert the ON/OFF value to boolean string and add it to value string array
                values(1, size(values, 2) + 1) = ConvertOnOffStringToBooleanString(inXmlOutputElement.children(i).content);
                //add information about input to label
                labels(1, size(labels, 2) + 1) = xmlElementName;
                
            end
            
        end
        
    end
    
    
    //join the template and the decoded xml element to labels and values
    for i = 1 : 1 : length(xmlOutputTemplateDoc.root.children)
        
        outputXmlElementTemplate = xmlOutputTemplateDoc.root.children(i);
        
        if outputXmlElementTemplate.name ~= "comment" & outputXmlElementTemplate.name ~= "documentation" & outputXmlElementTemplate.name ~= "description" & outputXmlElementTemplate.name ~= "text" & FindXMLElementIndexesInFirstChildrenOfXMLElement(inXmlOutputElement, outputXmlElementTemplate.name) == [] then
            
            //convert the template ON/OFF value to boolean string and add it to value string array
            values(1, size(values, 2) + 1) = ConvertOnOffStringToBooleanString(outputXmlElementTemplate.content);
            //add information from template to label
            labels(1, size(labels, 2) + 1) = outputXmlElementTemplate.name;
            
        end
        
    end
    
    
    //create the last "property" label and value
    values(1, size(values, 2) + 1) = propertiesString;
    labels(1, size(labels, 2) + 1) = "property;";
    
    
endfunction



function [outXmlOutputElement]=GetOrLoadDefaultJSBSimXMLOutput(XMLSimulationStartDoc)
    
    outXmlOutputElement = [];
    
    rootSimulationStartName = "simulation_start";
    //if a simulation start file is valid XMLDoc type and valid XML object
    if typeof(XMLSimulationStartDoc) == "XMLDoc" then
        if xmlIsValidObject(XMLSimulationStartDoc) == %t then
            
            //if the root name element of the currently edited xml simulation start file is "simulation_start", it is valid simulation start file
            if XMLSimulationStartDoc.root.name == rootSimulationStartName then
                //if the current simulation start file contains any children element
                if length(XMLSimulationStartDoc.root.children) > 0 then
                    
                    //get output element if exists
                    outputXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(XMLSimulationScriptDoc.root, "output");
                    if outputXMLElementIndexes ~= [] then
                        
                        outXmlOutputElement = XMLSimulationScriptDoc.root.children(outputXMLElementIndexes(1));
                        
                    else
                        
                        //otherwise, load defauult output xml element from file
                        outXmlOutputElement = xmlRead("templates" + filesep() + "Simulation_withoutAttributes" + filesep() + "output.xml");
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
endfunction


function [xmlSimulationStartFilePath, xmlSimulationStartFileName]=ShowSaveDialogXMLSimulationStart(xmlSimulationStart)
    
    //show save dialog for simulation start file
    [fileNameSave, pathNameSave, filterIndexSave] = uiputfile( ["*.xml","XML files"], "simulation", "Save file with simulation start information" );
    
    //check if cancel button was not clicked
    if fileNameSave ~= "" & pathNameSave ~= "" & filterIndexSave ~= 0 then
        
        //check xmlSimulationStart - whether is in XMLDoc format, and is valid object
        if typeof(xmlSimulationStart) == "XMLDoc" then
            if xmlIsValidObject(xmlSimulationStart) == %t then
                
                //get filename without extension
                xmlSimulationStartFileName = GetFileNameWithoutExtension(fileNameSave, ".xml");
                
                //set simulation start file path with extension and save xml simulation start file
                extension = GetExtensionForFileIfNecessary(fileNameSave, ".xml");
                xmlSimulationStartFilePath = pathNameSave + filesep() + fileNameSave + extension;
                xmlWrite(xmlSimulationStart, xmlSimulationStartFilePath, %t);
                
                messagebox("Simulation-start XML-file was saved sucessfully!", "modal", "info");
                
            end
        end
        
    end
    
endfunction






//simulation performing

global aircraftFolderName;
aircraftFolderName = "aircraft";
global backupFolderName;
backupFolderName = "zzzzz_backups";
global systemsFolderName;
systemsFolderName = "Systems";
global scriptsFolderName;
scriptsFolderName = "scripts";
global simulationFolderName;
simulationFolderName = "simulation";
global simulationStartNameDefault;
simulationStartNameDefault = "simulation_start";
global outputFolderName;
outputFolderName = "output";


//create folder into "aircraft" folder with same name as the the aircraft's name (i.e. "aircraft/<aircraft_name>")
function [wasCreated, aircraftPath]=CreateAircraftFolderIfNotExists(aircraftFileName)
    
    wasCreated = %f;
    
    
    //if aircraft folder is not created in the current Scilab working folder, create it
    global aircraftFolderName;
    if isdir(aircraftFolderName) == %f then
        statusCreationDirAircraft = createdir(aircraftFolderName);
        if statusCreationDirAircraft == %f then
            messagebox("Creation of directory failed: """ + aircraftFolderName + """!", "modal", "error");
            return;
        end
    end
    
    
    //if folder with aircraft name is not created inside the "aircraft" folder, create it
    aircraftPath = aircraftFolderName + filesep() + aircraftFileName;
    if isdir(aircraftPath) == %f then
        statusCreationDirAircraftNameFolder = createdir(aircraftFolderName);
        if statusCreationDirAircraftNameFolder == %f then
            messagebox("Creation of directory failed: """ + aircraftPath + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction



//copy the xml aircraft definition into "aircraft" folder and backup the original file
function [wasCopied, outAircraftFilePath]=CopyAircraftDefinitionToAircraftPathAndBackupTheOriginal(aircraftFileName, inAircraftFilePath)
    
    wasCopied = %f;
    
    global aircraftFolderName;
    aircraftPath = aircraftFolderName + filesep() + aircraftFileName;
    outAircraftFilePath = aircraftPath + filesep() + aircraftFileName + ".xml";
    
    //if output aircraft file path exist, backup it
    if isfile(outAircraftFilePath) == %t then
        
        //back up the original file if any
        wasBackedUp = BackupTheOriginalFile(aircraftPath, outAircraftFilePath, aircraftFileName + ".xml", %t, emptystr());
        if wasBackedUp == %t then
            //if absolute output aircraft file path is not same as input aircraft file path, copy it
            if pwd() + filesep() + outAircraftFilePath ~= inAircraftFilePath then
                
                wasCopied = CopyFileToSpecificPath(inAircraftFilePath, outAircraftFilePath);
                
            else
                
                //otherwise, everything is OK, the original file was backed-up and this file is where it should be
                wasCopied = %t;
                
            end
        else
            messagebox(["The original Aircraft file was not backed-up!"; "aircraftPath: " + aircraftPath ; "outAircraftFilePath: " + outAircraftFilePath ; "aircraftFileName: " + aircraftFileName ], "modal", "error");
            return;
        end
        
        
    //otherwise, copy the inputed aircraft file to local folder
    else
        
        wasCopied = CopyFileToSpecificPath(inAircraftFilePath, outAircraftFilePath);
        
    end
    
endfunction



//save the xml reset file into "aircraft" folder
function [wasSaved]=SaveResetFileIntoAircraftFolderAndBackupTheOriginal(xmlReset, xmlResetFileName, aircraftFileName)
    
    wasSaved = %f;
    
    global aircraftFolderName;
    aircraftPath = aircraftFolderName + filesep() + aircraftFileName;
    outXmlResetFilePath = aircraftPath + filesep() + xmlResetFileName + ".xml";
    
    //if output aircraft file path exists, backup it
    if isfile(outXmlResetFilePath) == %t then
        
        //back up the original file if any
        wasBackedUp = BackupTheOriginalFile(aircraftPath, outXmlResetFilePath, xmlResetFileName + ".xml", %f, emptystr());
        if wasBackedUp == %f then
            messagebox(["The original Reset (initial parameters) file was not backed-up!"; "aircraftPath: " + aircraftPath ; "outXmlResetFilePath: " + outXmlResetFilePath ; "xmlResetFileName: " + xmlResetFileName ], "modal", "error");
            return;
        end
        disp(["The original Reset (initial parameters) was sucessfully backed-up!" ; outXmlResetFilePath ; ]);
        
    end
    
    //save opened xml reset file, or show error if failed
    try
        xmlWrite(xmlReset, outXmlResetFilePath, %t);
        disp(["Reset (initial parameters) was sucessfully saved!" ; outXmlResetFilePath ; ]);
        wasSaved = %t;
    catch
        [error_message, error_number] = lasterror(%t);
        messagebox(["Saving of reset file failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "outXmlResetFilePath: " + outXmlResetFilePath ; "xmlResetFileName: " + xmlResetFileName ], "modal", "error");
        return;
    end
    
endfunction



//create "aircraft/<aircraft_name>/system" folder
function [wasCreated, systemFolderPath]=CreateSystemFolderInAircraftFolderIfNotExists(aircraftPath)
    
    wasCreated = %f;
    
    
    //if there is not system folder inside a specific aircraft path
    global systemsFolderName;
    systemFolderPath = aircraftPath + filesep() + systemsFolderName;
    if isdir(systemFolderPath) == %f then
        statusCreationDirSystem = createdir(systemFolderPath);
        if statusCreationDirSystem == %f then
            messagebox("Creation of directory failed: """ + systemFolderPath + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction



//save autopilot xml file in "aircraft/<aircraft_name>/system" folder
function [wasSaved]=SaveAutopilotFileIntoSystemInAircraftFolderAndBackupTheOriginal(xmlAutopilot, xmlAutopilotFileName, aircraftFileName)
    
    wasSaved = %f;
    
    global aircraftFolderName;
    global systemsFolderName;
    aircraftPath = aircraftFolderName + filesep() + aircraftFileName;
    outXmlAutopilotFilePath = aircraftPath + filesep() + systemsFolderName + filesep() + xmlAutopilotFileName + ".xml";
    
    //if output autopilot file path exists, backup it
    if isfile(outXmlAutopilotFilePath) == %t then
        
        //back up the original file if any
        wasBackedUp = BackupTheOriginalFile(aircraftPath, outXmlAutopilotFilePath, xmlAutopilotFileName + ".xml", %f, systemsFolderName);
        if wasBackedUp == %f then
            messagebox(["The original Autopilot file was not backed-up!"; "aircraftPath: " + aircraftPath ; "outXmlAutopilotFilePath: " + outXmlAutopilotFilePath ; "xmlAutopilotFileName: " + xmlAutopilotFileName ], "modal", "error");
            return;
        end
        disp(["The original Autopilot was sucessfully backed-up!" ; outXmlAutopilotFilePath ; ]);
        
    end
    
    //save opened xml autopilot file, or show error if failed
    try
        xmlWrite(xmlAutopilot, outXmlAutopilotFilePath, %t);
        disp(["Autopilot was sucessfully saved!" ; outXmlAutopilotFilePath ; ]);
        wasSaved = %t;
    catch
        [error_message, error_number] = lasterror(%t);
        messagebox(["Saving of autopilot file failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "xmlAutopilotFilePath: " + outXmlAutopilotFilePath ; "xmlAutopilotFileName: " + xmlAutopilotFileName ], "modal", "error");
        return;
    end
    
endfunction



function [wasCreated]=CreateScriptsFolderIfNotExists()
    
    wasCreated = %f;
    
    
    //if scripts folder is not created in the current Scilab working folder, create it
    global scriptsFolderName;
    if isdir(scriptsFolderName) == %f then
        statusCreationDirScripts = createdir(scriptsFolderName);
        if statusCreationDirScripts == %f then
            messagebox("Creation of directory failed: """ + scriptsFolderName + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction



//add or change new output xml element simulation definition
function [addedOrChangedOutputXML]=AddOrChangeOutputXMLElementInSimulationDefinition(xmlSimulation, xmlOutputElement)
    
    addedOrChangedOutputXML = %f;
    
//    //alternative removing of output xml elements
//    //find all output xml element in the simulation definition, and delete them all
//    outputXmlElementsList = xmlXPath(xmlSimulation, "//output");
//    if length(outputXmlElementsList) > 0 then
//        xmlRemove(outputXmlElementsList);
//    end
    //find all output xml element in the simulation definition, and delete them all
    xmlOutputElementIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlSimulation.root, "output");
    for i = size(xmlOutputElementIndexArray, 1) : -1 : 1
        xmlRemove(xmlSimulation.root.children(xmlOutputElementIndexArray(i)));
    end
    
    //if xml output element exists and is of valid type, add it to the root's children
    if xmlOutputElement ~= [] & typeof(xmlOutputElement) == "XMLElem" then
        xmlAppend(xmlSimulation.root, xmlOutputElement);
        addedOrChangedOutputXML = %t;
    end
    
endfunction



//save simulation definition to script folder
function [wasSaved]=SaveSimulationDefinitionIntoScriptFolderAndBackupTheOriginal(xmlSimulation, xmlSimulationFileName)
    
    wasSaved = %f;
    
    global scriptsFolderName;
    outXmlSimulationFilePath = scriptsFolderName + filesep() + xmlSimulationFileName + ".xml";
    
    //if output script (simulation definition) file path exists, backup it
    if isfile(outXmlSimulationFilePath) == %t then
        
        //back up the original file if any
        wasBackedUp = BackupTheOriginalFile(scriptsFolderName, outXmlSimulationFilePath, xmlSimulationFileName + ".xml", %t, emptystr());
        if wasBackedUp == %f then
            messagebox(["The original Simulation Definition file was not backed-up!"; "scriptsFolderName: " + scriptsFolderName ; "outXmlSimulationFilePath: " + outXmlSimulationFilePath ; "xmlSimulationFileName: " + xmlSimulationFileName ], "modal", "error");
            return;
        end
        disp(["The original Simulation Definition was sucessfully backed-up!" ; outXmlSimulationFilePath ; ]);
        
    end
    
    //save opened xml script (simulation definition) file, or show error if failed
    try
        xmlWrite(xmlSimulation, outXmlSimulationFilePath, %t);
        disp(["Simulation Definition was sucessfully saved!" ; outXmlSimulationFilePath ; ]);
        wasSaved = %t;
    catch
        [error_message, error_number] = lasterror(%t);
        messagebox(["Saving of script (simulation definition) file failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "outXmlSimulationFilePath: " + outXmlSimulationFilePath ; "xmlSimulationFileName: " + xmlSimulationFileName ], "modal", "error");
        return;
    end
    
endfunction



function [wasCreated]=CreateSimulationFolderIfNotExists()
    
    wasCreated = %f;
    
    
    //if simulation folder is not created in the current Scilab working folder, create it
    global simulationFolderName;
    if isdir(simulationFolderName) == %f then
        statusCreationDirSimulation = createdir(simulationFolderName);
        if statusCreationDirSimulation == %f then
            messagebox("Creation of directory failed: """ + simulationFolderName + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction




//save simulation start to simulation folder - if the filename of simulation start is not set, use default
function [wasSaved]=SaveSimulationStartIntoSimulationFolderAndBackupTheOriginal(xmlSimulationStart, xmlSimulationStartFileName)
    
    wasSaved = %f;
    
    
    //if the filename of simulation start is not set, use default "simulation_start" tag with date and time information
    outXmlSimulationStartFileName = xmlSimulationStartFileName;
    if outXmlSimulationStartFileName == [] | strsubst(outXmlSimulationStartFileName, " ", "") == emptystr() then
        global simulationStartNameDefault;
        currentTimeAsVector = clock();
        separatorDateTime = "-";
        outXmlSimulationStartFileName = simulationStartNameDefault + "_" + string(currentTimeAsVector(1)) + separatorDateTime + string(currentTimeAsVector(2)) + separatorDateTime + string(currentTimeAsVector(3)) + "_" + string(currentTimeAsVector(4)) + separatorDateTime + string(currentTimeAsVector(5)) + separatorDateTime + string(round(currentTimeAsVector(6)));
    end
    
    
    global simulationFolderName;
    outXmlSimulationStartFilePath = simulationFolderName + filesep() + outXmlSimulationStartFileName + ".xml";
    
    //if output simulation start file path exists, backup it
    if isfile(outXmlSimulationStartFilePath) == %t then
        
        //back up the original file if any
        wasBackedUp = BackupTheOriginalFile(simulationFolderName, outXmlSimulationStartFilePath, outXmlSimulationStartFileName + ".xml", %t, emptystr());
        if wasBackedUp == %f then
            messagebox(["The original Simulation Start file was not backed-up!"; "simulationFolderName: " + simulationFolderName ; "outXmlSimulationStartFilePath: " + outXmlSimulationStartFilePath ; "outXmlSimulationStartFileName: " + outXmlSimulationStartFileName ], "modal", "error");
            return;
        end
        disp(["The original Simulation Start xml was sucessfully backed-up!" ; outXmlSimulationStartFilePath ; ]);
        
    end
    
    //save opened xml simulation start file, or show error if failed
    try
        xmlWrite(xmlSimulationStart, outXmlSimulationStartFilePath, %t);
        disp(["Simulation Start xml was sucessfully saved!" ; outXmlSimulationStartFilePath ; ]);
        wasSaved = %t;
    catch
        [error_message, error_number] = lasterror(%t);
        messagebox(["Saving of simulation start file failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "outXmlSimulationStartFilePath: " + outXmlSimulationStartFilePath ; "outXmlSimulationStartFileName: " + outXmlSimulationStartFileName ], "modal", "error");
        return;
    end
    
endfunction



function [wasCreated]=CreateOutputFolderIfNotExists()
    
    wasCreated = %f;
    
    
    //if output folder is not created in the current Scilab working folder, create it
    global outputFolderName;
    if isdir(outputFolderName) == %f then
        statusCreationDirOutput = createdir(outputFolderName);
        if statusCreationDirOutput == %f then
            messagebox("Creation of directory failed: """ + outputFolderName + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction



//move CSV output to "output" folder but only when the output CSV file is not already there - if exists, backup the original ; if the copy is successful, delete the input output CSV file
function [wasCopied]=MoveOutputCSVToOutputPathAndBackupTheOriginal(outputCSVFileName, inOutputCSVFilePath)
    
    wasCopied = %f;
    
    global outputFolderName;
    //outputCSVFileNameWithExtention = outputCSVFileName + ".csv";
    outOutputCSVFilePath = outputFolderName + filesep() + outputCSVFileName;
    
    //if output output CSV file path exist, backup it
    if isfile(outOutputCSVFilePath) == %t then
        
        //if output output CSV file path is not same as input output CSV file path, backup it and copy it
        if pwd() + filesep() + outOutputCSVFilePath ~= inOutputCSVFilePath then
            
            //back up the original file if any
            wasBackedUp = BackupTheOriginalFile(outputFolderName, outOutputCSVFilePath, outputCSVFileName, %t, emptystr());
            if wasBackedUp == %t then
                
                wasCopied = CopyFileToSpecificPath(inOutputCSVFilePath, outOutputCSVFilePath);
                //if the output CSV file was copied successfully, delete the input output CSV file
                if wasCopied == %t then
                    deletefile(inOutputCSVFilePath);
                end
                
            else
                messagebox(["The original Output CSV file was not backed-up!"; "outputFolderName: " + outputFolderName ; "outOutputCSVFilePath: " + outOutputCSVFilePath ; "outputCSVFileName: " + outputCSVFileName ], "modal", "error");
                return;
            end
            
        else
            
            wasCopied = %t;
            
        end
        
        
    //otherwise, copy the inputed output CSV file to local folder
    else
        
        wasCopied = CopyFileToSpecificPath(inOutputCSVFilePath, outOutputCSVFilePath);
        //if the output CSV file was copied successfully, delete the input output CSV file
        if wasCopied == %t then
            deletefile(inOutputCSVFilePath);
        end
        
    end
    
endfunction




function [wasCopied]=CopyFileToSpecificPath(inFilePath, outFilePath)
    
    wasCopied = %f;
    //if input file exists, copy it to the output file path
    if isfile(inFilePath) == %t then
        
        [statusCopy, messageError] = copyfile(inFilePath, outFilePath);
        //if status of copy is 0, the operation failed
        if statusCopy == 0 then
            messagebox(["Inputed file was not copied to local file path!"; "messageError: " + messageError ; "inFilePath: " + inFilePath ; "outFilePath: " + outFilePath], "modal", "error");
            return;
        else
            //otherwise, everything is OK
            wasCopied = %t;
        end
        
    else
        messagebox("Inputed file path doesn''t exist: """ + inFilePath + """!", "modal", "error");
        return;
    end
    
endfunction



function [wasBackedUp]=BackupTheOriginalFile(localMainPath, filePath, fileName, createNewNumberBackupDirectory, subBackupDirectoryNameIfAny)
    
    wasBackedUp = %f;
    
    
    //check if backup directory under the aircraft directory exist
    global backupFolderName;
    backupFolderPath = localMainPath + filesep() + backupFolderName;
    if isdir(backupFolderPath) == %f then
        statusCreationDirBackup = createdir(backupFolderPath);
        if statusCreationDirBackup == %f then
            messagebox("Creation of directory failed: """ + backupFolderPath + """!", "modal", "error");
            return;
        end
    end
    
    
    //create number of backup, if the folder exist, iterate the number
    numberOfBackup = 1;
    while isdir(backupFolderPath + filesep() + string(numberOfBackup)) == %t
        numberOfBackup = numberOfBackup + 1;
    end
    //if new numbered folder inside backup folder should not be created, use the last number of the created backup folder which exists (if may exist)
    if createNewNumberBackupDirectory == %f & numberOfBackup > 1 then
        numberOfBackup = numberOfBackup - 1;
    end
    backupFolderNumber = backupFolderPath + filesep() + string(numberOfBackup);
    
    //create new backup number directory
    statusCreationDirBackupNumber = createdir(backupFolderNumber);
    if statusCreationDirBackupNumber == %f then
        messagebox("Creation of directory failed: """ + backupFolderNumber + """!", "modal", "error");
        return;
    end
    
    
    backupFolderNumberWithSubIfAny = backupFolderNumber;
    //if there should be sub-folder inside backup numbered folder, create it if it does not exist
    if subBackupDirectoryNameIfAny ~= [] & strsubst(subBackupDirectoryNameIfAny, " ", "") ~= emptystr() then
        backupFolderNumberWithSubIfAny = backupFolderNumber + filesep() + subBackupDirectoryNameIfAny;
        if isdir(backupFolderNumberWithSubIfAny) == %f then
            statusCreationDirSubBackup = createdir(backupFolderNumberWithSubIfAny);
            if statusCreationDirSubBackup == %f then
                messagebox("Creation of directory failed: """ + backupFolderNumberWithSubIfAny + """!", "modal", "error");
                return;
            end
        end
    end
    
    
    backupFilePath = backupFolderNumberWithSubIfAny + filesep() + fileName;
    [statusCopy, messageError] = copyfile(filePath, backupFilePath);
    //if status of copy is 0, the operation failed
    if statusCopy == 0 then
        messagebox(["Inputed file was not copied to local file path!"; "messageError: " + messageError ; "filePath: " + filePath ; "newBackupFilePath: " + backupFilePath], "modal", "error");
    else
        //otherwise, everything is OK
        wasBackedUp = %t;
    end
    
    
endfunction



function [wasCreated]=CreateFolderIfNotExists(inputFolderNameOrPath)
    
    wasCreated = %f;
    
    
    //if inputFolderNameOrPath folder is not created in the current Scilab working folder or an inputed path, create it
    if isdir(inputFolderNameOrPath) == %f then
        statusCreationDirInputFolderNameOrPath = createdir(inputFolderNameOrPath);
        if statusCreationDirInputFolderNameOrPath == %f then
            messagebox("Creation of directory failed: """ + inputFolderNameOrPath + """!", "modal", "error");
            return;
        end
    end
    
    
    wasCreated = %t;
    
endfunction







//JSBSim aircraft file - editation

global autopilotXMLelementInAircraftFile;
autopilotXMLelementInAircraftFile = "autopilot";

//change/add autopilot file path (defined in "autopilot" xml element and "file" attribute) in aircraft xml file
function [fileWasChanged]=FindAndChangeOrAddAutopilotFilePathInAircraftFile(xmlAircraftFilePath, xmlAutopilotFileName)
    
    fileWasChanged = %f;
    
    //read xml file with (maybe) aircraft (fdm_config) information
    xmlAircraftTemp = xmlRead(xmlAircraftFilePath);
    
    //check if the root xml element is "fdm_config"
    if convstr(xmlAircraftTemp.root.name, 'l') == "fdm_config" then
        
        //if an autopilot filename is defined
        if xmlAutopilotFileName ~= [] & xmlAutopilotFileName ~= emptystr() then
            
            
            //define local autopilot file path without extension (from folder with aircraft definition)
            global systemsFolderName;
            autopilotLocalPath = systemsFolderName + filesep() + xmlAutopilotFileName;
            
            global autopilotXMLelementInAircraftFile;
//            //find all autopilot xml element in the aircraft definition, and delete them all
//            autopilotXmlElementsList = xmlXPath(xmlAircraftTemp, "//" + autopilotXMLelementInAircraftFile);
//            if length(autopilotXmlElementsList) > 0 then
//                xmlRemove(autopilotXmlElementsList);
//            end
            //alternative removing of autopilot xml elements
            //find all autopilot xml element in the aircraft definition, change the first and delete all which follow
            xmlAutopilotElementIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlAircraftTemp.root, autopilotXMLelementInAircraftFile);
            //if at least one autopilot xml element was found in aircraft definition
            if size(xmlAutopilotElementIndexArray, 1) > 0 then
                
                //change file attribute of the first autopilot xml element
                xmlAircraftTemp.root.children(xmlAutopilotElementIndexArray(1)).attributes.file = autopilotLocalPath;
                
                //delete every following autopilot xml elements
                //must be from the last to the second because, the deleted xml element changes index of all the following children
                for i = size(xmlAutopilotElementIndexArray, 1) : -1 : 2
                    xmlRemove(xmlAircraftTemp.root.children(xmlAutopilotElementIndexArray(i)));
                end
                
            //otherwise, there is no autopilot xml element, create new one
            else
                
                //add xml autopilot element to the root's children of aircraft definition
                autopilotXMLelement = xmlElement(xmlAircraftTemp, autopilotXMLelementInAircraftFile);
                autopilotXMLelement.attributes.file = autopilotLocalPath;
                xmlAppend(xmlAircraftTemp.root, autopilotXMLelement);
                
            end
            
            //save xml aircraft file
            xmlWrite(xmlAircraftTemp, xmlAircraftFilePath, %t);
            disp(["Autopilot xml element was sucessfully added to Aircraft definition file which was saved!" ; xmlAircraftFilePath ; ]);
            fileWasChanged = %t;
            
            
        else
            
            messagebox(["No autopilot filename is defined!" ; "Autopilot xml element was not added/changed."], "modal", "error");
            
        end
        
        
    else
        
        messagebox(["Wrong format! The XML file is not a valid aircraft (fdm_config) file!" ; "Autopilot xml element was not added/changed."], "modal", "error");
        
    end
    
    CheckAndDeleteXMLDoc(xmlAircraftTemp);
    
    
endfunction



//change output file definition in arcraft: CSV (with path) or FlightGear (with network address and FlightGear execution path - FlightGear has to be installed and has to be executed before JSBSim execution)
function [wasChangedOrAdded]=ChangeOrAddOutputXMLelementInAircraftXMLfile(xmlAircraftFilePath, outputXMLelement)
    
    wasChangedOrAdded = %f;
    
    //read xml file with (maybe) aircraft (fdm_config) information
    xmlAircraftTemp = xmlRead(xmlAircraftFilePath);
    
    //because the code is same, use function for add or change of output xml element in simulation definition
    wasChangedOrAdded = AddOrChangeOutputXMLElementInSimulationDefinition(xmlAircraftTemp, outputXMLelement);
    
    if wasChangedOrAdded == %t then
        //save xml aircraft file
        xmlWrite(xmlAircraftTemp, xmlAircraftFilePath, %t);
        disp(["Output xml element was sucessfully added to Aircraft definition file which was saved!" ; xmlAircraftFilePath ; ]);
    end
     
    CheckAndDeleteXMLDoc(xmlAircraftTemp);
    
endfunction

//delete output file definition in arcraft: CSV (with path) or FlightGear (with network address and FlightGear execution path - FlightGear has to be installed and has to be executed before JSBSim execution)
function [wasDeletedOrNoOutput]=DeleteOutputXMLelementInAircraftXMLfile(xmlAircraftFilePath)
    
    wasDeletedOrNoOutput = %f;
    
    //read xml file with (maybe) aircraft (fdm_config) information
    xmlAircraftTemp = xmlRead(xmlAircraftFilePath);
    
    //find all output xml element in the aircraft definition, and delete them all
    xmlOutputElementIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlAircraftTemp.root, "output");
    if size(xmlOutputElementIndexArray, 1) > 0 then
        
        //delete all output xml elements in aircraft xml
        for i = size(xmlOutputElementIndexArray, 1) : -1 : 1
            xmlRemove(xmlAircraftTemp.root.children(xmlOutputElementIndexArray(i)));
        end
        
        //save xml aircraft file
        xmlWrite(xmlAircraftTemp, xmlAircraftFilePath, %t);
        disp(["Output xml element was sucessfully removed from Aircraft definition file which was saved!" ; xmlAircraftFilePath ; ]);
        
    end
    
    CheckAndDeleteXMLDoc(xmlAircraftTemp);
    
    wasDeletedOrNoOutput = %t;
    
endfunction



//<> <>The following feature was not implemented, user has to change it manually: change pitch (ap/elevator_cmd), roll (ap/aileron_cmd), yaw (ap/rudder_cmd) (,and throttle? (ap/throttle_cmd)) corrections (i.e. fcs/pitch-trim-sum, fcs/roll-trim-sum, fcs/rudder-trim-sum, fcs/throttle-trim-sum) in aircraft (flight_control or fcs xml-element) or system file (system xml-element) due to autopilot properties. (unfortunately, the names of the xml elements may vary; thus it is hard to find them in the xml files - user has to provide the compatibility of autopilot, aircraft, and all system files)




