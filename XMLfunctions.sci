exec XMLMath.sci;
exec XMLTest.sci;
exec XMLSimulation.sci;



//global functions

function CheckAndDeleteXMLObjects()
    
    //free memory if xmlObjects exist
    
    global xmlAutopilot;
    if exists("xmlAutopilot") == 1 then
        if typeof(xmlAutopilot) == "XMLDoc" then
            if xmlIsValidObject(xmlAutopilot) == %t then
                //messagebox("XML Deleted");
                xmlDelete(xmlAutopilot);
            end
        end
    end
    
//    global xmlAutopilotFlightGear;
//    if exists("xmlAutopilotFlightGear") == 1 then
//        if typeof(xmlAutopilotFlightGear) == "XMLDoc" then
//            if xmlIsValidObject(xmlAutopilotFlightGear) == %t then
//                //messagebox("XML Deleted");
//                xmlDelete(xmlAutopilotFlightGear);
//            end
//        end
//    end
    
endfunction





//local functions with inputs and outputs

function CheckAndDeleteXMLDoc(xmlDoc)
    
    //free memory if xmlObjects exist
    if typeof(xmlDoc) == "XMLDoc" then
        if xmlIsValidObject(xmlDoc) == %t then
            //messagebox("xmlDoc Deleted");
            xmlDelete(xmlDoc);
        end
    end
    
endfunction


function [errorString]=ValidateXMLdocument(xmlDoc)
    
    // We test if the document is valid
    // If no error the file is valid
    // DTD
    dtd = xmlDTD("SCI/modules/xml/tests/unit_tests/library.dtd");
    errorString = xmlValidate(xmlDoc, dtd);
    // Relax NG
    rng = xmlRelaxNG("SCI/modules/xml/tests/unit_tests/library.rng");
    errorString = xmlValidate(xmlDoc, rng);
    // Schema
    schema = xmlSchema("SCI/modules/xml/tests/unit_tests/library.xsd");
    errorString = xmlValidate(xmlDoc, schema);
    
    // We delete all the open temporary documents
    xmlDelete(dtd, schema, rng);
    
endfunction



function [errorString]=CheckXMLJSBSimFileFormat(xmlJSBSimFilePath, JSBSimGeneralFileTitle, rootXMLName)
    
    errorString = emptystr();
    
    //check if file exists
    fileExist = fileinfo(xmlJSBSimFilePath);
    if fileExist == [] then
        
        errorString = "The selected " + JSBSimGeneralFileTitle + " file does not exist! """ + xmlJSBSimFilePath + """";
        
    else
        
        //check if file is XML and beggins with correct xml element
        XMLJSBSim = [];
        try
            XMLJSBSim = xmlRead(xmlJSBSimFilePath);
        catch
            errorString = "The selected " + JSBSimGeneralFileTitle + " file is not a valid XML file! """ + xmlJSBSimFilePath + """";
            return;
        end
        
        if XMLJSBSim ~= [] then
            //check if the root xml element is same as the innputed root xml element name
            if convstr(XMLJSBSim.root.name, 'l') ~= rootXMLName then
                errorString = "The selected XML file is not a valid " + JSBSimGeneralFileTitle + " JSBSim file! """ + xmlJSBSimFilePath + """";
            end
            CheckAndDeleteXMLDoc(XMLJSBSim);
        end
        
    end
    
endfunction




function [outProperties]=AddPropertiesFromLoadedXMLToPropertiesAvailable(xmlDoc, inProperties)
    
    outProperties = inProperties;
    
    if xmlDoc.root.name == "autopilot" then
            
            children = xmlDoc.root.children;
            
            for i = 1 : 1 : length(children)
                
                //find elements with 'property' tag
                if children.name(i) == "property" then
                    
                    //disp(children(i).content);
                    //add property name (content) of the property to outProperties
                    outProperties(size(outProperties, 1) + 1) = strsubst(children(i).content, " ", "");
                    
                //or find elements with 'channel' tag
                elseif children.name(i) == "channel" then
                    
                    //disp(children(i).attributes.name);
                    //add name of the element channel (the name attribute) to outProperties
                    outProperties(size(outProperties, 1) + 1) = children(i).attributes.name;
                    
                    //if the element has childrens
                    if length(children(i).children) > 0 then
                        
                        childrenOfChildren = children(i).children;
                        
                        for j = 1 : 1 : length(childrenOfChildren)
                            
                            if ((childrenOfChildren.name(j) ~= "property") & (childrenOfChildren.name(j) ~= "comment") & (childrenOfChildren.name(j) ~= "documentation")) then
                                
                                //disp(childrenOfChildren(j).attributes.name);
                                //add name of the element property (the name attribute) to outProperties
                                outProperties(size(outProperties, 1) + 1) = strsubst(childrenOfChildren(j).attributes.name, " ", "");
                                
                            elseif childrenOfChildren.name(j) == "property" then
                                
                                //add property name (content) of the property to outProperties
                                outProperties(size(outProperties, 1) + 1) = strsubst(childrenOfChildren(j).content, " ", "");
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
    end
    
    //disp(outProperties);
    //return outProperties;
    
endfunction



function [isFound]=FindPropertyInPropertiesAvailable(propertyName, inPropertiesAvailable)
    
    isFound = %f;
    
    for i = 1 : 1 : size(inPropertiesAvailable, 1)
        
        if propertyName == inPropertiesAvailable(i) then
            isFound = %t;
            break;
        end
        
    end
    
endfunction




function [isCorrect]=CheckCorrectValuesType(inputValues, possibleInputTypes, inPropertiesAvailable, isOptional, canRepeat)
    
    if canRepeat then
        
        inputValuesList = inputValues;
        //if it is NOT test function (switch component), delete white spaces
        if convstr(possibleInputTypes, 'l') ~= "test_functions" then
            inputValuesList = strsubst(inputValues, " ", "");
        end
        
        inputValuesList = tokens(inputValuesList, ";");
        if size(inputValuesList, 1) > 1 then
            
            isCorrectList = [];
            
            for i = 1 : 1 : size(inputValuesList, 1)
                
                isCorrectList(size(isCorrectList, 1) + 1) = CheckCorrectValueType(inputValuesList(i), possibleInputTypes, inPropertiesAvailable, isOptional);
                
            end
            
            isCorrect = and(isCorrectList);
            
            
        else
            
            isCorrect = CheckCorrectValueType(inputValues, possibleInputTypes, inPropertiesAvailable, isOptional);
            
        end
        
    else
        
        isCorrect = CheckCorrectValueType(inputValues, possibleInputTypes, inPropertiesAvailable, isOptional);
        
    end
    
    
    
endfunction



function [isCorrect]=CheckCorrectValueType(inputValue, possibleInputTypes, inPropertiesAvailable, isOptional)
    
    isCorrect = %f;
    possibleInputTypes = strsubst(possibleInputTypes, " ", "");
    
    if possibleInputTypes ~= emptystr() then
        
        inputValueWithSpaces = inputValue;
        inputValue = strsubst(inputValue, " ", "");
        
        if inputValue ~= emptystr() then
            
            //separate types from string to list using specific token '|' (this token is used in XML template files)
            possibleInputTypesList = tokens(possibleInputTypes, '|');
            
            for i = 1 : 1 : size(possibleInputTypesList, 1)
                
                //convert to lowercase and check if the token is number
                if convstr(possibleInputTypesList(i), 'l') == "number" then
                    
                    //check if the string can be converted to number
                    isCorrect = isnum(inputValue);
                    isCorrect = isCorrect(1);
                    if isCorrect then
                        //disp(inputValue + ' is number');    //<>debug only
                        break;
                    end
                    
                //convert to lowercase and check if the token is property
                elseif convstr(possibleInputTypesList(i), 'l') == "property" | convstr(possibleInputTypesList(i), 'l') == "property_array" then
                    
                    isCorrect = [];
                    //go through all properties in string array (if "property", there is only one property string)
                    for p = 1 : 1 : size(inputValue, 1)
                        
                        //if the property has minus sign (i.e. '-'), delete it
                        inputValueTemp = inputValue(p);
                        if part(inputValue(p), 1) == "-" then
    //                        //check if the original name with minus sign is in the property list
    //                        isCorrect = FindPropertyInPropertiesAvailable(inputValue, inPropertiesAvailable);
    //                        if isCorrect then
    //                            //disp(inputValue + ' was found in properties');  //<>debug only
    //                            break;
    //                        end
                            //delete the minus sign
                            inputValueTemp = part(inputValue(p), 2:length(inputValue(p)));
                        end
                        
                        indexSquareBracketLeft = strindex(inputValueTemp, '[');
                        indexSquareBracketRight = strindex(inputValueTemp, ']');
                        //if a left and right square brackets were found
                        if indexSquareBracketLeft ~= [] & indexSquareBracketRight ~= [] then
    //                    //if the property has ']' char at the end, delete all between '[' and ']'
    //                    if part(inputValueTemp, length(inputValueTemp)) == "]" then
    //
                            //check if the original name with ']' char is in the property list
                            isCorrect(p) = FindPropertyInPropertiesAvailable(inputValueTemp, inPropertiesAvailable);
                            if isCorrect(p) then
                                //disp(inputValue + ' was found in properties');  //<>debug only
                                continue;   //if it is in property list continue with cycle
                            end
                            
                            //get the name without everything between '[' and ']' chars (more precisely, get everything before the first '[' char)
                            inputValueTemp = part(inputValueTemp, 1:indexSquareBracketLeft(1)-1);
                            disp( "Warning, this application is not able to completely check properties with square brackets! Be sure that the following property exists (JSBSim throws error if not): """ + inputValue(p) + """." );
                            disp("");
                        end
                        
                        //check if the name is in property list
                        isCorrect(p) = FindPropertyInPropertiesAvailable(inputValueTemp, inPropertiesAvailable);
                        if isCorrect(p) then
                            //disp(inputValue + ' was found in properties');  //<>debug only
                            continue;   //if it is in property list continue with cycle
                        else
                            break;  //if it is not in property list break the cycle
                        end
                        
                    end
                    if and(isCorrect) then
                        //disp(inputValue + ' was found in properties');  //<>debug only
                        break;  //if all properties are in property list break the main cycle
                    end
                    
                //convert to lowercase and check if the token is true or false
                elseif convstr(possibleInputTypesList(i), 'l') == "true" | convstr(possibleInputTypesList(i), 'l') == "false" then
                    
                    if inputValue == "%t" | inputValue == "%f" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is x, y, or z
                elseif convstr(possibleInputTypesList(i), 'l') == "x" | convstr(possibleInputTypesList(i), 'l') == "y" | convstr(possibleInputTypesList(i), 'l') == "z" then
                    
                    //convert to lowercase and check if the input value is x, y, or z
                    if convstr(inputValue, 'l') == "x" | convstr(inputValue, 'l') == "y" | convstr(inputValue, 'l') == "z" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is and or or :-)
                elseif convstr(possibleInputTypesList(i), 'l') == "and" | convstr(possibleInputTypesList(i), 'l') == "or" then
                    
                    //convert to lowercase and check if the input value is and or or :-)
                    if convstr(inputValue, 'l') == "and" | convstr(inputValue, 'l') == "or" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is percent or absolute
                elseif convstr(possibleInputTypesList(i), 'l') == "percent" | convstr(possibleInputTypesList(i), 'l') == "absolute" then
                    
                    //convert to lowercase and check if the input value is percent or absolute
                    if convstr(inputValue, 'l') == "percent" | convstr(inputValue, 'l') == "absolute" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is uniform or gaussian
                elseif convstr(possibleInputTypesList(i), 'l') == "uniform" | convstr(possibleInputTypesList(i), 'l') == "gaussian" then
                    
                    //convert to lowercase and check if the input value is uniform or gaussian
                    if convstr(inputValue, 'l') == "uniform" | convstr(inputValue, 'l') == "gaussian" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is m or in
                elseif convstr(possibleInputTypesList(i), 'l') == "m" | convstr(possibleInputTypesList(i), 'l') == "in" then
                    
                    //convert to lowercase and check if the input value is m or in
                    if convstr(inputValue, 'l') == "m" | convstr(inputValue, 'l') == "in" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is deg or rad
                elseif convstr(possibleInputTypesList(i), 'l') == "deg" | convstr(possibleInputTypesList(i), 'l') == "rad" then
                    
                    //convert to lowercase and check if the input value is deg or rad
                    if convstr(inputValue, 'l') == "deg" | convstr(inputValue, 'l') == "rad" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is step/fg_step, ramp/fg_ramp, or exp/fg_exp
                elseif convstr(possibleInputTypesList(i), 'l') == "step" | convstr(possibleInputTypesList(i), 'l') == "ramp" | convstr(possibleInputTypesList(i), 'l') == "exp" | convstr(possibleInputTypesList(i), 'l') == "fg_step" | convstr(possibleInputTypesList(i), 'l') == "fg_ramp" | convstr(possibleInputTypesList(i), 'l') == "fg_exp" then
                    
                    //convert to lowercase and check if the input value is step, ramp, or exp
                    if convstr(inputValue, 'l') == "step" | convstr(inputValue, 'l') == "ramp" | convstr(inputValue, 'l') == "exp" | convstr(inputValue, 'l') == "fg_step" | convstr(inputValue, 'l') == "fg_ramp" | convstr(inputValue, 'l') == "fg_exp" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is value or delta
                elseif convstr(possibleInputTypesList(i), 'l') == "value" | convstr(possibleInputTypesList(i), 'l') == "fg_value" | convstr(possibleInputTypesList(i), 'l') == "delta" | convstr(possibleInputTypesList(i), 'l') == "fg_delta" then
                    
                    //convert to lowercase and check if the input value is value or delta
                    if convstr(inputValue, 'l') == "value" | convstr(inputValue, 'l') == "fg_value" | convstr(inputValue, 'l') == "delta" | convstr(inputValue, 'l') == "fg_delta" then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is math_functions
                elseif convstr(possibleInputTypesList(i), 'l') == "math_functions" then
                    
                    //find the "table" tag in function if any
                    tableTag = "table";
                    XMLTableElementsList = list();
                    //get all table tag strings from string equation if any
                    tableStringsList = GetTableStringsFromStringEquation(strsubst(inputValue, " ", ""), tableTag);
                    //if any table tag was found, process it
                    if length(tableStringsList) > 0 then
                        
                        //create empty xml table elements
                        for x = 1 : 1 : length(tableStringsList)
                            //create empty XML document
                            XMLTable = xmlDocument();
                            //add only one child (root) element "table"
                            XMLTable.root = xmlElement(XMLTable, "table");
                            //add table element to the list of XML table elements
                            XMLTableElementsList($+1) = XMLTable;
                        end
                        
                    end
                    
                    //check if the input value can be converted to XML function element
                    XMLMathFunctionsElement = StringEquationToXMLMathFunc(inputValue, inPropertiesAvailable, XMLTableElementsList);
                    if XMLMathFunctionsElement ~= [] then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is conditional
                elseif convstr(possibleInputTypesList(i), 'l') == "conditional" then
                    
                    //check if the input value is one of the conditional chars
                    isCorrect = CheckIfConditional(inputValue);
                    if isCorrect then
                        break;
                    end
                    
                //convert to lowercase and check if the token is test_functions or condition_functions
                elseif convstr(possibleInputTypesList(i), 'l') == "test_functions" | convstr(possibleInputTypesList(i), 'l') == "condition_functions" then
                    
                    //check if the input value can be converted to XML test element
                    XMLTestElement = StringEquationToXMLTest(inputValueWithSpaces, tokens(convstr(possibleInputTypesList(i), 'l'), "_")(1), inPropertiesAvailable);
                    if XMLTestElement ~= [] then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is path to a file
                elseif convstr(possibleInputTypesList(i), 'l') == "path_file" then
                    
                    //check if the file path exists
                    filePathInfo = fileinfo(inputValue);
                    if filePathInfo ~= [] then
                        isCorrect = %t;
                        break;
                    end
                    
                //convert to lowercase and check if the token is set_definition
                elseif convstr(possibleInputTypesList(i), 'l') == "set_definition" then
                    
                    //check if the set_definition contains valid definitions
                    XMLSetElementsList = ConvertSetDefinition(inputValue);
                    if XMLSetElementsList ~= [] then
                        isCorrect = %t;
                        break;
                    end
                    
                //unknown or unsupported type
                else
                    
                    //if one of the possible input types is equal to input value, set it as correct
                    if convstr(possibleInputTypesList(i), 'l') == convstr(inputValue, 'l') then
                        isCorrect = %t;
                        break;
                    else
                        disp("Unknown input type: """ + possibleInputTypesList(i) + """! (in checkCorrectValueType function in XMLfunctions.sci file");
                        continue;
                    end
                    
                end
                
            end
            
            
        //if input is optional, it may be empty
        elseif isOptional then
            
            //disp(inputValue + ' is optional');  //<>debug only
            isCorrect = %t;
            
        end
        
        
    else
        
        //input may be everything but not empty
        if inputValue ~= emptystr() then
            isCorrect = %t;
        end
        
    end
    
    
endfunction



function [PredefinedIDinValue]=SetIDinValue(possibleInputTypes)
    
    ////if the possible input type is test with conditional and properties/numbers
    //if possibleInputTypes == "property conditional property|number" | possibleInputTypes == "property conditional number|property" then
        
    //    PredefinedIDinValue = "ap/...hold == fcs/...|0.0";
    //    return;
    //    return "ap/...hold == fcs/...|0.0";
        
    //end
    
    
    PredefinedIDinValue = emptystr();
    possibleInputTypes = strsubst(possibleInputTypes, " ", "");
    
    if possibleInputTypes ~= emptystr() then
            
        //separate types from string to list using specific token '|' (this token is used in XML template files)
        possibleInputTypesList = tokens(possibleInputTypes, '|');
        
        for i = 1 : 1 : size(possibleInputTypesList, 1)
            
            //convert to lowercase and check if the token is number
            if convstr(possibleInputTypesList(i), 'l') == "number" then
                
                //if it can be a number only
                if size(possibleInputTypesList, 1) == 1 then
                    PredefinedIDinValue = "0";
                else
                    PredefinedIDinValue = emptystr();
                end
                break;
                
            //convert to lowercase and check if the token is property
            elseif convstr(possibleInputTypesList(i), 'l') == "property" then
                
                PredefinedIDinValue = emptystr();
                break;
                
            //convert to lowercase and check if the token is true
            elseif convstr(possibleInputTypesList(i), 'l') == "true" then
                
                PredefinedIDinValue = "%t";
                break;
                
            //convert to lowercase and check if the token is false
            elseif convstr(possibleInputTypesList(i), 'l') == "false" then
                
                PredefinedIDinValue = "%f";
                break;
                
            //convert to lowercase and check if the token is x
            elseif convstr(possibleInputTypesList(i), 'l') == "x" then
                
                PredefinedIDinValue = "X";
                break;
                
            //convert to lowercase and check if the token is y
            elseif convstr(possibleInputTypesList(i), 'l') == "y" then
                
                PredefinedIDinValue = "Y";
                break;
                
            //convert to lowercase and check if the token is z
            elseif convstr(possibleInputTypesList(i), 'l') == "z" then
                
                PredefinedIDinValue = "Z";
                break;
                
            //convert to lowercase and check if the token is and
            elseif convstr(possibleInputTypesList(i), 'l') == "and" then
                
                PredefinedIDinValue = "AND";
                break;
                
            //convert to lowercase and check if the token is or
            elseif convstr(possibleInputTypesList(i), 'l') == "or" then
                
                PredefinedIDinValue = "OR";
                break;
                
            //convert to lowercase and check if the token is percent
            elseif convstr(possibleInputTypesList(i), 'l') == "percent" then
                
                PredefinedIDinValue = "PERCENT";
                break;
                
            //convert to lowercase and check if the token is absolute
            elseif convstr(possibleInputTypesList(i), 'l') == "absolute" then
                
                PredefinedIDinValue = "ABSOLUTE";
                break;
                
            //convert to lowercase and check if the token is uniform
            elseif convstr(possibleInputTypesList(i), 'l') == "uniform" then
                
                PredefinedIDinValue = "UNIFORM";
                break;
                
            //convert to lowercase and check if the token is gaussian
            elseif convstr(possibleInputTypesList(i), 'l') == "gaussian" then
                
                PredefinedIDinValue = "GAUSSIAN";
                break;
                
            //convert to lowercase and check if the token is m
            elseif convstr(possibleInputTypesList(i), 'l') == "m" then
                
                PredefinedIDinValue = "M";
                break;
                
            //convert to lowercase and check if the token is in
            elseif convstr(possibleInputTypesList(i), 'l') == "in" then
                
                PredefinedIDinValue = "IN";
                break;
                
            //convert to lowercase and check if the token is deg
            elseif convstr(possibleInputTypesList(i), 'l') == "deg" then
                
                PredefinedIDinValue = "DEG";
                break;
                
            //convert to lowercase and check if the token is rad
            elseif convstr(possibleInputTypesList(i), 'l') == "rad" then
                
                PredefinedIDinValue = "RAD";
                break;
                
            //convert to lowercase and check if the token is math_functions
            elseif convstr(possibleInputTypesList(i), 'l') == "math_functions" then
                
                PredefinedIDinValue = "sum(  )";
                break;
                
            //convert to lowercase and check if the token is test_functions or condition_functions
            elseif convstr(possibleInputTypesList(i), 'l') == "test_functions" | convstr(possibleInputTypesList(i), 'l') == "condition_functions" then
                
                PredefinedIDinValue = "and(  )";
                break;
                
            //convert to lowercase and check if the token is set_definition
            elseif convstr(possibleInputTypesList(i), 'l') == "set_definition" then
                
                xmlSetDefinition = xmlRead("templates\Simulation\script_event_set_definition.xml");
                PredefinedIDinValue = [ xmlSetDefinition.root.content ; emptystr() ; emptystr()];
                CheckAndDeleteXMLDoc(xmlSetDefinition);
                break;
                
            //convert to lowercase and check if the token is property_array
            elseif convstr(possibleInputTypesList(i), 'l') == "property_array" | convstr(possibleInputTypesList(i), 'l') == "property_definition" | convstr(possibleInputTypesList(i), 'l') == "description" then
                
                PredefinedIDinValue = [emptystr() ; emptystr() ; emptystr()];
                break;
                
            //convert to lowercase and check if the token is path to a file
            elseif convstr(possibleInputTypesList(i), 'l') == "path_file" then
                    
                    PredefinedIDinValue = emptystr();
                    break;
                    
            //unknown unsupported type
            else
                
                disp("Unknown input type: """ + possibleInputTypesList(i) + """! (in SetIDinValue function in XMLfunctions.sci file");
                PredefinedIDinValue = possibleInputTypesList(i);
                break;
                
            end
            
        end
        
    end
    
endfunction




function [TrueFalseString]=ConvertBooleanStringToTrueFalseString(inputBoolean)
    
    if inputBoolean == "%t" then// | inputBoolean == %t then
        TrueFalseString = "true";
    elseif inputBoolean == "%f" then// | inputBoolean == %f then
        TrueFalseString = "false";
    else
        TrueFalseString = inputBoolean;
    end
    
endfunction



function [BooleanString]=ConvertTrueFalseStringToBooleanString(inputTrueFalseString)
    
    stringWithoutSpaces = strsubst(inputTrueFalseString, " ", "");
    lowerStringWithoutSpaces = convstr(stringWithoutSpaces, 'l')
    
    if lowerStringWithoutSpaces == "true" then// | inputBoolean == %t then
        BooleanString = "%t";
    elseif lowerStringWithoutSpaces == "false" then// | inputBoolean == %f then
        BooleanString = "%f";
    else
        BooleanString = inputTrueFalseString;
    end
    
endfunction



function [outCheckBoxUIValue]=ConvertTrueFalseStringToUIControlCheckBoxValue(uiControlCheckBox, inputTrueFalseString)
    
    stringWithoutSpaces = strsubst(inputTrueFalseString, " ", "");
    lowerStringWithoutSpaces = convstr(stringWithoutSpaces, 'l')
    
    if lowerStringWithoutSpaces == "true" then// | inputBoolean == %t then
        outCheckBoxUIValue = uiControlCheckBox.max;
    else
        outCheckBoxUIValue = uiControlCheckBox.min;
    end
    
endfunction



function [outBooleanString]=ConvertUIControlCheckBoxValueToBooleanString(uiControlCheckBox)
    
    outBooleanString = "%f";
    if uiControlCheckBox.value == uiControlCheckBox.max then
        outBooleanString = "%t";
    end
    
endfunction



function [OnOffString]=ConvertBooleanStringToOnOffString(inputBoolean)
    
    if inputBoolean == "%t" then
        OnOffString = "ON";
    else
        OnOffString = "OFF";
    end
    
endfunction



function [BooleanString]=ConvertOnOffStringToBooleanString(inputOnOffString)
    
    stringWithoutSpaces = strsubst(inputOnOffString, " ", "");
    lowerStringWithoutSpaces = convstr(stringWithoutSpaces, 'l')
    
    if lowerStringWithoutSpaces == "on" then
        BooleanString = "%t";
    else
        BooleanString = "%f";
    end
    
endfunction




function [optional, asterisk, canRep, semicolon, contentCanRep, canInclTest]=GetInformationAttributes(attributeNames, xmlAttributes)
    
    //set default output values
    optional = %f;
    asterisk = "*";
    canRep = %f;
    semicolon = "";
    contentCanRep = %f;
    canInclTest = %f;
    
    
    //find and decode the following specific attributes in the element
    fIndex = find(attributeNames == "optional");
    if fIndex ~= [] then
        optional = DecodeInformationAttribute(xmlAttributes(fIndex));
        if optional then
            asterisk = emptystr();
        end
    end

    fIndex = find(attributeNames == "canrepeat");
    if fIndex ~= [] then
        canRep = DecodeInformationAttribute(xmlAttributes(fIndex));
        if canRep then
            semicolon = ";";
        end
    end

    fIndex = find(attributeNames == "contentcanrepeat");
    if fIndex ~= [] then
        contentCanRep = DecodeInformationAttribute(xmlAttributes(fIndex));
    end

    fIndex = find(attributeNames == "canincludetests");
    if fIndex ~= [] then
        canInclTest = DecodeInformationAttribute(xmlAttributes(fIndex));
    end
    
endfunction



function [Yes]=DecodeInformationAttribute(inputValue)
    
    Yes = %f;
    lowerValue = convstr(inputValue, 'l');
    if lowerValue == "yes" | lowerValue == "y" then
        Yes = %t;
    end
    
endfunction




function [xmlElementIndexOut]=FindXMLElementIndexInFirstChildrenOfXMLElement(xmlElementIn, nameType, nameAttributeContent)
    
    xmlElementIndexOut = 0;
    childrenIn = xmlElementIn.children;
    
    for i = 1 : 1 : length(childrenIn)
        
        if convstr(childrenIn(i).name, 'l') == convstr(nameType, 'l') then
            
            //if type of XML element (component) is "property"
            if convstr(nameType, 'l') == "property" then
                
                if childrenIn(i).content == nameAttributeContent then
                    xmlElementIndexOut = i;
                end
                
            else
                
                if childrenIn(i).attributes.name == nameAttributeContent then
                    xmlElementIndexOut = i;
                end
                
            end
            
        end
        
    end
    
endfunction



function [xmlElementIndexArray]=FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementIn, nameType)
    
    xmlElementIndexArray = [];
    childrenIn = xmlElementIn.children;
    
    for i = 1 : 1 : length(childrenIn)
        
        if convstr(childrenIn(i).name, 'l') == convstr(nameType, 'l') then
            
            xmlElementIndexArray(size(xmlElementIndexArray, 1) + 1) = i;
            
        end
        
    end
    
endfunction


function [xmlElementFound]=FindFirstXMLElementInFirstChildrenOfXMLElement(xmlElementIn, nameType)
    
    xmlElementFound = [];
    //find xml element with a specific name
    xmlIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementIn, nameType);
    //if any index was found
    if xmlIndexArray ~= [] then
        //get only first xml element with a specific name
        xmlElementFound = xmlElementIn.children(xmlIndexArray(1));
    end
    
endfunction


function [xmlElementFound]=FindXMLElementInFirstChildrenOfXMLElementOrCreateIt(xmlDocIn, xmlElementIn, nameType)
    
    //find xml element with a specific name
    xmlIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementIn, nameType);
    //if any index was found
    if xmlIndexArray == [] then
        //add new element (with a specific name)
        newXMLelement = xmlElement(xmlDocIn, nameType);
        xmlAppend(xmlElementIn, newXMLelement);
        xmlIndexArray(size(xmlIndexArray, 1) + 1) = length(xmlElementIn.children);
    end
    //get only first xml element with a specific name
    xmlElementFound = xmlElementIn.children(xmlIndexArray(1));
    
endfunction


function [xmlElementsList, xmlElementsIndexesList]=GetAllXMLElementsOfDefinedTypesInChildren(xmlElementIn, nameTypesList)
    
    xmlElementsList = list();
    xmlElementsIndexesList = list();
    
    for i = 1 : 1 : length(nameTypesList)
        
        xmlElementSubIndexArray = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementIn, nameTypesList(i));
        //if any index was found
        if xmlElementSubIndexArray ~= [] then
            
            //get all xml element with the specific name
            for j = 1 : 1 : size(xmlElementSubIndexArray, 1)
                
                //add element to the output lists of xml elements, and their indexes
                xmlElementsList($+1) = xmlElementIn.children(xmlElementSubIndexArray(j));
                xmlElementsIndexesList($+1) = xmlElementSubIndexArray(j);
                
            end
            
        end
        
    end
    
endfunction


function [xmlValueOut]=GetXMLValueOrAttribute(xmlElementIn, nameType, nameAttributeContent)
    

    xmlValueOut = emptystr();
    xmlElementIndex = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementIn, nameType);
    
    //if the element was found
    if xmlElementIndex ~= [] then
        
        //go through all indexes
        for i = 1 : 1 : length(xmlElementIndex)
            
            
            //if it is content of the XML element
            if nameAttributeContent == "-<XMLContentText>" then
                
                //convert "true" and "false" JSBSim string to boolean string version in Scilab, or just copy the input string
                contentOfXMLelement = ConvertTrueFalseStringToBooleanString(xmlElementIn.children(xmlElementIndex(i)).content);
                
                //if there are more values, add semicolon with two white spaces
                xmlValueOut = AddSemicolonWithTwoWhiteSpacesToNotEmptyString(xmlValueOut);
                xmlValueOut = xmlValueOut + contentOfXMLelement;
                continue;
                
            end
            
            //evaluate the string expression to scilab code - check if the attribute of the XML element can be found
            codeToEv = "xmlElementIn.children(xmlElementIndex(i)).attributes." + nameAttributeContent;
            inputValue = evstr(codeToEv);
            //if evaluation of the string expression was successful, it is attribute
            if inputValue ~= [] then
                
                //if there are more values, add semicolon with two white spaces
                xmlValueOut = AddSemicolonWithTwoWhiteSpacesToNotEmptyString(xmlValueOut);
                xmlValueOut = xmlValueOut + inputValue;    //attribute exists
                
                
            //else if it has sub children
            elseif length(xmlElementIn.children(xmlElementIndex(i)).children) > 0 then
                
                //and if it has sub sub children
                if length(xmlElementIn.children(xmlElementIndex(i)).children(1).children) > 0 & xmlElementIn.children(xmlElementIndex(i)).children(1).children(1).name ~= "text" then
                    
                    //got through children of first child of component's children :-)
                    for k = 1 : 1 : length(xmlElementIn.children(xmlElementIndex(i)).children(1).children)
                        
                        if xmlElementIn.children(xmlElementIndex(i)).children(1).children(k).name == nameAttributeContent then
                            
                            //if there are more values, add semicolon with two white spaces
                            xmlValueOut = AddSemicolonWithTwoWhiteSpacesToNotEmptyString(xmlValueOut);
                            xmlValueOut = xmlValueOut + xmlElementIn.children(xmlElementIndex(i)).children(1).children(k).content;
                            
                        end
                        
                    end
                    
                    
                //otherwise it has sub children only
                else
                    
                    for k = 1 : 1 : length(xmlElementIn.children(xmlElementIndex(i)).children)
                            
                            if xmlElementIn.children(xmlElementIndex(i)).children(k).name == nameAttributeContent then
                                
                                //if there are more values, add semicolon with two white spaces
                                xmlValueOut = AddSemicolonWithTwoWhiteSpacesToNotEmptyString(xmlValueOut);
                                xmlValueOut = xmlValueOut + xmlElementIn.children(xmlElementIndex(i)).children(k).content;
                                
                            end
                            
                    end
                    
                    
                end
                
            end
            
        end
        
    end
    
endfunction



function [xmlContentArray]=GetXMLContentOrDefault(xmlElementIn, nameType, defaultContent)
    
    xmlContentArray = [];
    xmlElementIndex = FindXMLElementIndexesInFirstChildrenOfXMLElement(xmlElementIn, nameType);
    
    //if the element was found
    if xmlElementIndex ~= [] then
        
        //go through all indexes
        for i = 1 : 1 : length(xmlElementIndex)
            
            //get content of found xml element
            for j = 1 : 1 : size(xmlElementIn.children(xmlElementIndex(i)).content, 1)
                xmlContentArray(size(xmlContentArray, 1) + 1) = xmlElementIn.children(xmlElementIndex(i)).content(j);
            end
            
        end
        
    else
        //get default content only
        xmlContentArray = defaultContent;
    end
    
endfunction



function [xmlAttributeValue]=GetXMLAttributeOrDefault(xmlElementIn, nameAttribute, defaultAttribute)
    
    xmlAttributeValue = defaultAttribute;
    
    //evaluate the string expression to scilab code - check if the attribute of the XML element can be found
    codeToEv = "xmlElementIn.attributes." + nameAttribute;
    inputValue = evstr(codeToEv);
    //if evaluation of the string expression was successful, there is the attribute with defined name
    if inputValue ~= [] then
        
        //get attribute value of xml element
        xmlAttributeValue = inputValue;
        
    end
    
endfunction



function [outputString]=AddSemicolonWithTwoWhiteSpacesToNotEmptyString(inputString)
    
    //if there are more values (string is not empty), add two white spaces with semicolon in the middle
    semicolonWithWhiteSpaces = " ; ";
    if inputString ~= emptystr() then
        outputString = inputString + semicolonWithWhiteSpaces;
    else
        outputString = inputString;
    end
    
endfunction



//save the xml file into defined path
function [wasSaved]=SaveXMLFileIntoFilePath(xmlDoc, outXmlFilePath, nameOfXmlDoc)
    
    wasSaved = %f;
    
    //save opened xml file, or show error if failed
    try
        xmlWrite(xmlDoc, outXmlFilePath, %t);
        disp(["XML file """ + nameOfXmlDoc + """ was sucessfully saved into """ + outXmlFilePath + """ file path!" ; ]);
        wasSaved = %t;
    catch
        [error_message, error_number] = lasterror(%t);
        messagebox(["Saving of XML file """ + nameOfXmlDoc + """ failed!" ; "error_message: " + error_message ; "error_number: " + string(error_number) ; "outXmlFilePath: " + outXmlFilePath ], "modal", "error");
        return;
    end
    
endfunction



