//exec XMLfunctions.sci;
exec XMLMath.sci;



function [XMLTestElement]=StringEquationToXMLTest(stringTest, testOrConditionElementName, inPropertiesAvailable)
    
    //create empty XML document
    XMLTestElement = xmlDocument();
    
    //add only one child (root) element "test" or "condition"
    XMLTestElement.root = xmlElement(XMLTestElement, testOrConditionElementName);
    
    //delete spaces in string
    stringTestWithoutSpaces = strsubst(stringTest, " ", "");
    
    //find indexes of left brackets, right brackets, and commas
    indexesBracketsLeft = strindex(stringTestWithoutSpaces, '(');
    indexesBracketsRight = strindex(stringTestWithoutSpaces, ')');
    indexesCommas = strindex(stringTestWithoutSpaces, ',');
    
    //find indexes of left brackets, right brackets, and commas for original string test
    indexesBLeftOriginal = strindex(stringTest, '(');
    indexesBRightOriginal = strindex(stringTest, ')');
    indexesCommasOriginal = strindex(stringTest, ',');
    
    //<>debug only
    //disp([string(indexesBracketsLeft) ; string(indexesBLeftOriginal) ; string(indexesBracketsRight) ; string(indexesBRightOriginal) ; string(indexesCommas) ; string(indexesCommasOriginal)]);
    
    
    //check if there are exactly same number of left and right brackets, if no, show error and end function
    if size(indexesBracketsLeft, 2) < size(indexesBracketsRight, 2) then
        
        xmlDelete(XMLTestElement);
        XMLTestElement = [];
        messagebox("There are LESS left brackets (" + string(size(indexesBracketsLeft, 2)) + ") than right brackets (" + string(size(indexesBracketsRight, 2)) + ") in the test!", "modal", "error");
        return;
        
    elseif size(indexesBracketsLeft, 2) > size(indexesBracketsRight, 2) then
        
        xmlDelete(XMLTestElement);
        XMLTestElement = [];
        messagebox("There are MORE left brackets (" + string(size(indexesBracketsLeft, 2)) + ") than right brackets (" + string(size(indexesBracketsRight, 2)) + ") in the test!", "modal", "error");
        return;
        
    end
    
    
    //get pairs of left and right brackets (i.e. in which place each operation begins and ends)
    indexesPairsBrackets = list();
    indexesBracketsRightTemp = indexesBracketsRight;
    for i = 1 : 1 : size(indexesBracketsLeft, 2)
        
        indexRightBracket = GetProperIndexOfRightBracket(indexesBracketsLeft(1, i:size(indexesBracketsLeft, 2)), indexesBracketsRightTemp);
        if indexRightBracket ~= [] then
            
            indexesPairsBrackets($+1) = [indexesBracketsLeft(i), indexesBracketsRightTemp(indexRightBracket)];
            indexesBracketsRightTemp(indexRightBracket) = [];
            
        else
            
            xmlDelete(XMLTestElement);
            XMLTestElement = [];
            messagebox(["Left and right brackets are not in the correct format!" ; "The check of the left bracket number: " + string(i) + " of " + string(size(indexesBracketsLeft, 2)) + ", at position: " + string(indexesBracketsLeft(i)) + " of " + string(length(stringTestWithoutSpaces)) + " failed."], "modal", "error");
            return;
            
        end
        
    end
    
    
    
    //if there is only string, i.e. there is no test (it is not possible in test element, including situation when there is only one condition)
    if size(indexesBracketsLeft, 2) == 0 then
        
        xmlDelete(XMLTestElement);
        XMLTestElement = [];
        messagebox(["Wrong format of the test!" ; "There has to be at least one ""and"" or ""or"" logic function (including the situation when there is only one condition)." ; stringTestWithoutSpaces], "modal", "error");
        return;
        
        
        
    //otherwise, there is at least one test
    else
        
        
        //check if the left bracket is not the first
        minimumIndexOfLeftBracket = 2;
        minimumIndexOfRightBracket = length(stringTestWithoutSpaces);
        if indexesBracketsLeft(1) < minimumIndexOfLeftBracket then
            
            xmlDelete(XMLTestElement);
            XMLTestElement = [];
            messagebox(["Wrong format of the test!" ; "The whole test MUST NOT BEGIN with "'("'" ; "It must begin with name of logic function (""and"" or ""or"")."], "modal", "error");
            return;
            
            
        //else if the right bracket is not the last character
        elseif indexesBracketsRight(size(indexesBracketsRight, 2)) ~= minimumIndexOfRightBracket then
            
            xmlDelete(XMLTestElement);
            XMLTestElement = [];
            messagebox(["Wrong format of the test!" ; "The whole test MUST END with "')"'."], "modal", "error");
            return;
            
        end
        
        
        
        //get first test logic function name and create first new logic attribute
        testLogicFunctionName = part(stringTestWithoutSpaces, 1:indexesPairsBrackets(1)(1)-1);
        testLogicFunctionName = CheckAndProcessTestLogicFunctionName(testLogicFunctionName);
        //if test logic function is not supported, show error message and end the function
        if testLogicFunctionName == [] then
            
            xmlDelete(XMLTestElement);
            XMLTestElement = [];
            messagebox(["The test logic function is not supported!" ; "Name of test logic function: " + testLogicFunctionName ], "modal", "error");
            return;
            
        end
        
        
        //get main element (test)
        functionXMLactual = XMLTestElement.root;
        //add new logic attribute (logic function type) in main element
        xmlSetAttributes(functionXMLactual, ["logic" convstr(testLogicFunctionName, 'u')]);
        
        
        
        //get indexes of all special characters or set infinite when they are out of the range
        indexOfIndexesBracketsLeft = 2;
        indexOfIndexesBracketsRight = 1;
        indexOfIndexesCommas = 1;
        //get index of left bracket if any
        nextLeftBracketIndex = GetNextIndexFromIndexes(indexOfIndexesBracketsLeft, indexesBracketsLeft);
        //get index of right bracket (note: if there is at least one bracket, there must be at least one right bracket)
        nextRightBracketIndex = indexesBracketsRight(indexOfIndexesBracketsRight);
        //get index of comma if any
        nextCommaIndex = GetNextIndexFromIndexes(indexOfIndexesCommas, indexesCommas);
        
        
        startIndex = indexesPairsBrackets(1)(1);
        startType = "(";
        //get closest index which next logic function or condition should end
        [closestNextIndex, closestNextType, incrementIndexBracketsLeft, incrementIndexBracketsRight, incrementIndexCommas] = GetClosestIndex(nextLeftBracketIndex, nextRightBracketIndex, nextCommaIndex);
        
        
        
        //set start and closest index for original string
        //get indexes of all special characters or set infinite when they are out of the range
        indexOfIndexesBLeftOriginal = 2;
        indexOfIndexesBRightOriginal = 1;
        indexOfIndexesCommasOriginal = 1;
        //get index of original left bracket if any
        nextLeftBracketIndexOriginal = GetNextIndexFromIndexes(indexOfIndexesBLeftOriginal, indexesBLeftOriginal);
        //get index of original right bracket (note: if there is at least one bracket, there must be at least one right bracket)
        nextRightBracketIndexOriginal = indexesBRightOriginal(indexOfIndexesBRightOriginal);
        //get index of original comma if any
        nextCommaIndexOriginal = GetNextIndexFromIndexes(indexOfIndexesCommasOriginal, indexesCommasOriginal);
        
        
        startIndexOriginal = indexesBLeftOriginal(1);
        //get closest next index from original string
        [closestNextIndexOriginal, closestNextTypeOriginal, incrementIndexBLeftOriginal, incrementIndexBRightOriginal, incrementIndexCommasOriginal] = GetClosestIndex(nextLeftBracketIndexOriginal, nextRightBracketIndexOriginal, nextCommaIndexOriginal);
        
        
        
        
        while closestNextIndex ~= %inf & closestNextType ~= emptystr() //& startIndex ~= %inf
            
            
            //get string between indexes
            nameFunctionOrCondition = part(stringTestWithoutSpaces, startIndex+1 : closestNextIndex-1);
            //if string is empty -> it is possible only if start and end chars are two right brackets (i.e. "))") or right bracket and comma (i.e. "),")
            if nameFunctionOrCondition == emptystr() then
                
                
                //check if it is left and right bracket
                //test cannot have zero arguments, show error and end function
                if startType == "(" & closestNextType == ")" then
                    
                    xmlDelete(XMLTestElement);
                    XMLTestElement = [];
                    messagebox(["There cannot be empty brackets in test!" ; "Characters at position: " + string(startIndex) + " and " + string(closestNextIndex)], "modal", "error");
                    return;
                    
                    
                    
                //check if it is two right brackets
                elseif startType == ")" & closestNextType == ")" then
                    
                    //get parent XML test if any (there is end of the previous test)
                    functionXMLactual = GetParentXMLoperation(functionXMLactual);
                    
                    
                    
                //check if it is right bracket and comma (i.e. another test or condition follows
                elseif startType == ")" & closestNextType == "," then
                    
                    //previous operation was ended and new argument of parent operation (of the previous) follows
                    //do nothing
                    
                    
                    
                //otherwise, it is invalid format because other options are not allowed!
                else
                    
                    xmlDelete(XMLTestElement);
                    XMLTestElement = [];
                    messagebox(["Special characters are in invalid format!" ; "Characters: " + startType + " and " + closestNextType ; "at position: " + string(startIndex) + " and " + string(closestNextIndex)], "modal", "error");
                    return;
                    
                    
                end
                
                
                
                
            //else there is some string (test or condition)
            else
                
                
                //if the string should be condition
                if closestNextType == "," | closestNextType == ")" then
                    
                    //get condition with spaces
                    condition = part(stringTest, startIndexOriginal+1 : closestNextIndexOriginal-1);
                    //separate condition to array by spaces
                    conditionArray = tokens(condition, " ");
                    
                    //if condition is not composed of 3 strings
                    if size(conditionArray, 1) ~= 3 then
                        
                        xmlDelete(XMLTestElement);
                        XMLTestElement = [];
                        messagebox(["Wrong format of the test!" ; "The condition has to be composed of 3 strings separated by white spaces (i.e. "" "")." ; "The current condition: """ + condition + """ is composed of: " + string(size(conditionArray, 1)) + " strings."], "modal", "error");
                        return;
                        
                    end
                    
                    //check the whole current condition
                    isCorrectFirstProperty = CheckCorrectValueType(conditionArray(1), "property", inPropertiesAvailable, %f);
                    isCorrectConditional = CheckCorrectValueType(conditionArray(2), "conditional", inPropertiesAvailable, %f);
                    isCorrectLastPropertyOrNumber = CheckCorrectValueType(conditionArray(3), "property|number", inPropertiesAvailable, %f);
                    
                    //if condition is not in correct format show error with more details
                    if isCorrectFirstProperty == %f | isCorrectConditional == %f | isCorrectLastPropertyOrNumber == %f then
                        
                        firstPropertyValidation = "valid";
                        conditionalValidation = "valid";
                        lastPropertyOrNumberValidation = "valid";
                        if isCorrectFirstProperty == %f then
                            firstPropertyValidation = "INVALID"
                        end
                        if isCorrectConditional == %f then
                            conditionalValidation = "INVALID";
                        end
                        if isCorrectLastPropertyOrNumber == %f then
                            lastPropertyOrNumberValidation = "INVALID";
                        end
                        
                        
                        xmlDelete(XMLTestElement);
                        XMLTestElement = [];
                        messagebox(["Wrong format of the condition: """ + condition + """." ; conditionArray(1) + " " + firstPropertyValidation ; conditionArray(2) + " " + conditionalValidation ; conditionArray(3) + " " + lastPropertyOrNumberValidation ; "Check JSBSim manual for more information about conditions." ], "modal", "error");
                        return;
                        
                    end
                    
                    
                    //add new text element as specific child or as new part of content
                    numberOfChildren = length(functionXMLactual.children);
                    if numberOfChildren == 0 then
                        functionXMLactual.children(1) = ascii(10) + condition + ascii(10);  //ascii(10) is newline char
                    elseif numberOfChildren > 0 then
                        if functionXMLactual.children(numberOfChildren).name == "text" then
                            functionXMLactual.children(numberOfChildren).content( size(functionXMLactual.children(numberOfChildren).content, 1) + 1 ) = condition + ascii(10);
                        else
                            functionXMLactual.children(numberOfChildren + 1) = ascii(10) + condition + ascii(10);
                        end
                    end
                    
                    //if it is the end of the current operation, get parent XML operation
                    if closestNextType == ")" then
                        functionXMLactual = GetParentXMLoperation(functionXMLactual);
                    end
                    
                    
                    
                //else if the string should be test
                elseif closestNextType == "(" then
                    
                    
                    //check logic function and create new element
                    testLogicFunctionName = nameFunctionOrCondition;
                    testLogicFunctionName = CheckAndProcessTestLogicFunctionName(testLogicFunctionName);
                    //if operation was not found in XML template folder, show error message and end the function
                    if testLogicFunctionName == [] then
                        
                        xmlDelete(XMLTestElement);
                        XMLTestElement = [];
                        messagebox(["The test logic function is not supported!" ; "Name of test logic function: " + testLogicFunctionName ], "modal", "error");
                        return;
                        
                    end
                    
                    
                    //create new test XML element
                    newXMLelement = xmlElement(XMLTestElement, testOrConditionElementName);
                    //add new logic attribute (logic function type) in main element
                    xmlSetAttributes(newXMLelement, ["logic" convstr(testLogicFunctionName, 'u')]);
                    xmlAppend(functionXMLactual, newXMLelement);
                    //get new created operation XML element
                    functionXMLactual = functionXMLactual.children(length(functionXMLactual.children));
                    
                    
                    
                //something is absolutely wrong
                else
                    
                    xmlDelete(XMLTestElement);
                    XMLTestElement = [];
                    messagebox(["Unknown error!" ; "test logic function name: """ + testLogicFunctionName + """" ; "Processed string: """ + nameFunctionOrCondition + """" ; "in special characters: " + startType + " and " + closestNextType ; "at position: " + string(startIndex) + " and " + string(closestNextIndex)], "modal", "error");
                    return;
                    
                    
                end
                
                
                
            end
            
            
            
            //increment indexes (there may be 0 increment)
            indexOfIndexesBracketsLeft = indexOfIndexesBracketsLeft + incrementIndexBracketsLeft;
            indexOfIndexesBracketsRight = indexOfIndexesBracketsRight + incrementIndexBracketsRight;
            indexOfIndexesCommas = indexOfIndexesCommas + incrementIndexCommas;
            //get new next indexes or infinite
            nextLeftBracketIndex = GetNextIndexFromIndexes(indexOfIndexesBracketsLeft, indexesBracketsLeft);
            nextRightBracketIndex = GetNextIndexFromIndexes(indexOfIndexesBracketsRight, indexesBracketsRight);
            nextCommaIndex = GetNextIndexFromIndexes(indexOfIndexesCommas, indexesCommas);
            
            
            //set new start index and type
            startIndex = closestNextIndex;
            startType = closestNextType;
            //get closest index which next test or condition should end
            [closestNextIndex, closestNextType, incrementIndexBracketsLeft, incrementIndexBracketsRight, incrementIndexCommas] = GetClosestIndex(nextLeftBracketIndex, nextRightBracketIndex, nextCommaIndex);
            
            
            
            //increment original indexes (there may be 0 increment)
            indexOfIndexesBLeftOriginal = indexOfIndexesBLeftOriginal + incrementIndexBLeftOriginal;
            indexOfIndexesBRightOriginal = indexOfIndexesBRightOriginal + incrementIndexBRightOriginal;
            indexOfIndexesCommasOriginal = indexOfIndexesCommasOriginal + incrementIndexCommasOriginal;
            //get new original next indexes or infinite
            nextLeftBracketIndexOriginal = GetNextIndexFromIndexes(indexOfIndexesBLeftOriginal, indexesBLeftOriginal);
            nextRightBracketIndexOriginal = GetNextIndexFromIndexes(indexOfIndexesBRightOriginal, indexesBRightOriginal);
            nextCommaIndexOriginal = GetNextIndexFromIndexes(indexOfIndexesCommasOriginal, indexesCommasOriginal);
            
            
            //set new original start index
            startIndexOriginal = closestNextIndexOriginal;
            //get closest next index from original string
            [closestNextIndexOriginal, closestNextTypeOriginal, incrementIndexBLeftOriginal, incrementIndexBRightOriginal, incrementIndexCommasOriginal] = GetClosestIndex(nextLeftBracketIndexOriginal, nextRightBracketIndexOriginal, nextCommaIndexOriginal);
            
            
            
        end
        
        
        
    end
    
    
    
endfunction


function [correctedLogicFunction]=CheckAndProcessTestLogicFunctionName(testLogicFunctionName)
    
    correctedLogicFunction = [];
    
    testLogicFunctionNameWithoutSpacesLower = strsubst(testLogicFunctionName, " ", "");
    testLogicFunctionNameWithoutSpacesLower = strsubst(testLogicFunctionNameWithoutSpacesLower, ascii(9), "");
    testLogicFunctionNameWithoutSpacesLower = convstr(testLogicFunctionNameWithoutSpacesLower, 'l');
    
    if testLogicFunctionName == "and" | testLogicFunctionName == "or" then
        
        correctedLogicFunction = testLogicFunctionName;
        
    end
    
endfunction



function [isCorrectNumberOfValuesAndTests]=CheckTestNValuesNTests(stringValues, stringTests)
    
    //get strings separated by semicolon token
    stringValuesWithoutSpaces = strsubst(stringValues, " ", "");
    stringValuesArray = tokens(stringValuesWithoutSpaces, ";");
    stringTestsWithoutSpaces = strsubst(stringTests, " ", "");
    stringTestsArray = tokens(stringTestsWithoutSpaces, ";");
    
    //check if the string arrays has same number
    if size(stringValuesArray, 1) == size(stringTestsArray, 1) then
        isCorrectNumberOfValuesAndTests = %t;
    else
        isCorrectNumberOfValuesAndTests = %f;
    end
    
endfunction





function [stringTest]=XMLTestToStringEquation(XMLTestElement, testOrConditionElementName)
    
    stringTest = emptystr();
    
    if XMLTestElement.name == testOrConditionElementName then
        
        if length(XMLTestElement.children) > 0 then
            
            stringTest = RecursiveTestToStringDecode(XMLTestElement, testOrConditionElementName);
            
        else
            
            messagebox("Number of children in test/condition element of switch component is wrong (It should be higher than 0): " + string(length(XMLTestElement.children)), "modal", "error");
            
        end
        
    else
        
        messagebox("Main test/condition xml element is not """ + testOrConditionElementName + """ but """ + XMLTestElement.name + ".", "modal", "error");
        
    end
    
    
endfunction


function [stringTest]=RecursiveTestToStringDecode(inXMLElement, testOrConditionElementName)
    
    
    stringTest = emptystr();
    //default separation elements (comma, left bracket, and right bracket)
    bracketLeft = "( ";
    bracketRight = " )";
    commaToSeparate = ", ";
    andTag = "and";
    orTag = "or"
    
    //if the element has no child, the content is empty string or the current element is text (i.e. series of "property conditional property|number" lines)
    //(note: test element cannot be empty)
    if length(inXMLElement.children) == 0 & inXMLElement.name == testOrConditionElementName then
        disp(testOrConditionElementName + " element cannot be empty!");
        //messagebox("Test/Condition element cannot be empty!", "modal", "error");
        return;
    elseif length(inXMLElement.children) == 0 & (convstr(inXMLElement.name, 'l') == andTag | convstr(inXMLElement.name, 'l') == orTag) then
        disp(inXMLElement.name + " element cannot be empty!");
        //messagebox(inXMLElement.name + " element cannot be empty!", "modal", "error");
        return;
    end
    
    //get logic operator string from xml element name or logic attribute if any
    logicOperatorString = emptystr();
    if convstr(inXMLElement.name, 'l') == andTag | convstr(inXMLElement.name, 'l') == orTag then
        logicOperatorString = convstr(inXMLElement.name, 'l');
    else
        logicOperatorString = GetLogicOperatorStringFromXMLAttribute(inXMLElement);
    end
    for i = 1 : 1 : length(inXMLElement.children)
        
        
        //if the current child XML element is text (i.e. the current child XML element is condition or array of conditions)
        if inXMLElement.children(i).name == "text" then
            
            
            conditions = inXMLElement.children(i).content;
            //change white spaces and tabs to empty strings
            conditionsWithoutSpacesAndTabs = strsubst(conditions, " ", "");
            conditionsWithoutSpacesAndTabs = strsubst(conditionsWithoutSpacesAndTabs, ascii(9), "");
            //delete all empty string lines
            for j = 1 : 1 : size(conditionsWithoutSpacesAndTabs, 1)
                if conditionsWithoutSpacesAndTabs(j) == emptystr() then
                    conditions(j) = [];
                end
            end
            //if there are no conditions add right bracket (or display message to Scilab? - unfortunately, there may be empty strings in content, so this is not always obvious if it is error or not)
            if size(conditions, 1) == 0 & i == length(inXMLElement.children) then
                stringTest = stringTest + bracketRight;
            elseif size(conditions, 1) == 0
                disp("There are no conditions in test XML element, number: " + string(i) + ". Is it OK?");
            end
            
            
            //go through all conditions and add them to the output string
            for j = 1 : 1 : size(conditions, 1)
                
                conditionStringArray = GetTokensFromCondition(conditions(j))
                stringConditionSmooth = PutTogetherConditionFromTokenArray(conditionStringArray);
                
                //if there is only one input argument (the first child is the last child at the same time)
                if i == 1 & i == length(inXMLElement.children) & j == 1 & j == size(conditions, 1) then
                    stringTest = logicOperatorString + bracketLeft + stringConditionSmooth + bracketRight;
                //if this is the absolutely first argument (but not last)
                elseif i == 1 & j == 1 then
                    stringTest = logicOperatorString + bracketLeft + stringConditionSmooth;
                //if this is the absolutely last argument (but not first)
                elseif i == length(inXMLElement.children) & j == size(conditions, 1) then
                    stringTest = stringTest + commaToSeparate + stringConditionSmooth + bracketRight;
                //if this is an argument between the absolutely first and the absolutely last
                else
                    stringTest = stringTest + commaToSeparate + stringConditionSmooth;
                end
                
            end
            
            
            
        //else if the current child XML element is test
        elseif inXMLElement.children(i).name == testOrConditionElementName | convstr(inXMLElement.children(i).name, 'l') == andTag | convstr(inXMLElement.children(i).name, 'l') == orTag then
            
            
            //if there is only one input argument (the first child is the last child at the same time)
            if i == 1 & i == length(inXMLElement.children) then
                stringTest = logicOperatorString + bracketLeft + RecursiveTestToStringDecode(inXMLElement.children(i), testOrConditionElementName) + bracketRight;
            //if this is the first argument (but not last)
            elseif i == 1 then
                stringTest = logicOperatorString + bracketLeft + RecursiveTestToStringDecode(inXMLElement.children(i), testOrConditionElementName);
            //if this is the last argument (but not first)
            elseif i == length(inXMLElement.children) then
                stringTest = stringTest + commaToSeparate + RecursiveTestToStringDecode(inXMLElement.children(i), testOrConditionElementName) + bracketRight;
            //if this is an argument between the first and the last
            else
                stringTest = stringTest + commaToSeparate + RecursiveTestToStringDecode(inXMLElement.children(i), testOrConditionElementName);
            end
            
            
            
        //otherwise, the current element is not supported
        else
            
            disp("The current xml element in " + testOrConditionElementName + " is not supported (only text|test|condition|and|or xml elements are allowed): " + inXMLElement.children(i).name);
            disp(emptystr());
            //messagebox("The current element in test is not supported (only text and test are allowed): " + inXMLElement.children(i).name, "modal", "error");
            
            
        end
        
        
    end
    
endfunction


function [conditionStringArray]=GetTokensFromCondition(stringCondition)
    
    //get string separated by white spaces and tabs
    conditionStringArray = tokens(stringCondition, [" ", ascii(9)]);
    
endfunction


function [stringConditionSmooth]=PutTogetherConditionFromTokenArray(conditionStringArray)
    
    stringConditionSmooth = emptystr();
    
    //get string separated by white spaces and tabs
    for i = 1 : 1 : size(conditionStringArray, 1)
        
        if i == 1 then
            stringConditionSmooth = conditionStringArray(i);
        else
            stringConditionSmooth = stringConditionSmooth + " " + conditionStringArray(i);
        end
        
    end
    
endfunction


function [logicOperatorString]=GetLogicOperatorStringFromXMLAttribute(xmlTestElement)
    
    //default logic operator is "and" (&) for JSBSim
    logicOperatorString = "and";
    
    if xmlTestElement.attributes.logic ~= [] then
        
        logicOperatorString = xmlTestElement.attributes.logic;
        
        //delete spaces. tabs and convert to lower cases
        logicOperatorString = strsubst(logicOperatorString, " ", "");
        logicOperatorString = strsubst(logicOperatorString, ascii(9), "");
        logicOperatorString = convstr(logicOperatorString, 'l');
        
        //if the logic operator is not supported show error message
        if logicOperatorString ~= "and" & logicOperatorString ~= "or" then
            
            disp("Unknown logic operator in test XML element (only ""and"" and ""or"" logic is allowed): " + logicOperatorString);
            disp(emptystr());
            //messagebox("Unknown logic operator in test XML element (only ""and"" and ""or"" logic is allowed): " + logicOperatorString, "modal", "error");
            
        end
        
    end
    
endfunction


function [logicOperationChar]=GetLogicOperationChar(logicOperationName)
    
    //default logic operation (if empty, "and" logic operation is processed)
    logicOperationChar = emptystr();
    
    //check which elemental logic operation is currently processed and select the right operation char
    logicOperationNameLowerCase = convstr(logicOperationName, 'l');
    if logicOperationNameLowerCase == "and" | logicOperationNameLowerCase == emptystr() then
        logicOperationChar = " & ";
    elseif logicOperationNameLowerCase == "or" then
        logicOperationChar = " | ";
    end
    
endfunction


function [isConditional]=CheckIfConditional(inputValue)
    
    isConditional = %f;
    inputValueWithoutSpacesLower = strsubst(inputValue, " ", "");
    inputValueWithoutSpacesLower = convstr(inputValueWithoutSpacesLower, 'l');
    
    
    if inputValueWithoutSpacesLower == "eq" | inputValueWithoutSpacesLower == "==" ...
     | inputValueWithoutSpacesLower == "ne" | inputValueWithoutSpacesLower == "!=" ...
     | inputValueWithoutSpacesLower == "lt" | inputValueWithoutSpacesLower == "<" ...
     | inputValueWithoutSpacesLower == "le" | inputValueWithoutSpacesLower == "<=" ...
     | inputValueWithoutSpacesLower == "gt" | inputValueWithoutSpacesLower == ">" ...
     | inputValueWithoutSpacesLower == "ge" | inputValueWithoutSpacesLower == ">=" then
        
        isConditional = %t;
        
    end
    
endfunction

