//exec XMLfunctions.sci;
//exec DialogsFunctions.sci



function [XMLMathFunctionsElement]=StringEquationToXMLMathFunc(stringEquation, inPropertiesAvailable, XMLTableElementsList)
    
    //create empty XML document
    XMLMathFunctionsElement = xmlDocument();
    
    //add only one child (root) element "function"
    XMLMathFunctionsElement.root = xmlElement(XMLMathFunctionsElement, "function");
    
    //delete spaces in string
    stringEquationWithoutSpaces = strsubst(stringEquation, " ", "");
    
    //find indexes of left brackets, right brackets, and commas
    indexesBracketsLeft = strindex(stringEquationWithoutSpaces, '(');
    indexesBracketsRight = strindex(stringEquationWithoutSpaces, ')');
    indexesCommas = strindex(stringEquationWithoutSpaces, ',');
    
    //check if there are exactly same number of left and right brackets, if no, show error and end function
    if size(indexesBracketsLeft, 2) < size(indexesBracketsRight, 2) then
        
        xmlDelete(XMLMathFunctionsElement);
        XMLMathFunctionsElement = [];
        messagebox("There are LESS left brackets (" + string(size(indexesBracketsLeft, 2)) + ") than right brackets (" + string(size(indexesBracketsRight, 2)) + ") in the function!", "modal", "error");
        return;
        
    elseif size(indexesBracketsLeft, 2) > size(indexesBracketsRight, 2) then
        
        xmlDelete(XMLMathFunctionsElement);
        XMLMathFunctionsElement = [];
        messagebox("There are MORE left brackets (" + string(size(indexesBracketsLeft, 2)) + ") than right brackets (" + string(size(indexesBracketsRight, 2)) + ") in the function!", "modal", "error");
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
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["Left and right brackets are not in the correct format!" ; "The check of the left bracket number: " + string(i) + " of " + string(size(indexesBracketsLeft, 2)) + ", at position: " + string(indexesBracketsLeft(i)) + " of " + string(length(stringEquationWithoutSpaces)) + " failed."], "modal", "error");
            return;
            
        end
        
    end
    
    
    
    //if there is only string, i.e. number, property name, or table
    if size(indexesBracketsLeft, 2) == 0 then
        
        
        //check if there is table tag at the beginning
        if CheckTableTagAtBeginning(stringEquationWithoutSpaces) == %t then
            
            //if there is at least one xml table element (it should be exactly one)
            if length(XMLTableElementsList) > 0 then
                
                //there should be only one xml table element, add it
                xmlAppend(XMLMathFunctionsElement.root, XMLTableElementsList(1).root);
                
            else
                
                xmlDelete(XMLMathFunctionsElement);
                XMLMathFunctionsElement = [];
                messagebox(["Table tag cannot be replaced by XML element!" ; "There is no child XML element in XMLTableElementsList!" ; stringEquationWithoutSpaces ; ], "modal", "error");
                
            end
            
            //end this function
            return;
            
        end
        
        
        //get element name (value or property)
        elementName = GetElementNameForNumberOrProperty(stringEquationWithoutSpaces, inPropertiesAvailable);
        //if empty, show error message and end function
        if elementName == emptystr() then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["Wrong format of the function!" ; "Value or property is not valid." ; stringEquationWithoutSpaces], "modal", "error");
            return;
            
        end
        
        //add new element (value or property)
        newXMLelement = xmlElement(XMLMathFunctionsElement, elementName);
        newXMLelement.content = stringEquationWithoutSpaces;
        xmlAppend(XMLMathFunctionsElement.root, newXMLelement);
        
        
        
    //otherwise, there is at least one function
    else
        
        
        //check if the left bracket is not the first
        minimumIndexOfLeftBracket = 2;
        minimumIndexOfRightBracket = length(stringEquationWithoutSpaces);
        if indexesBracketsLeft(1) < minimumIndexOfLeftBracket then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["Wrong format of the function!" ; "The whole function MUST NOT BEGIN with "'("'" ; "It must begin with name of math operation (see JSBSim manual), name of property or a number."], "modal", "error");
            return;
            
//            
//            //if it is the first, delete everything outside the left and assigned right bracket
//            while indexesPairsBrackets(1)(1) < minimumIndexOfLeftBracket then
//                
//                stringEquationWithoutSpaces = part(stringEquationWithoutSpaces, minimumIndexOfLeftBracket+1:indexesPairsBrackets(1)(2)-1);
//                
//                //if there are no more brackets, check if it is a number, property (or table - which is not included in this noted code)
//                if length(indexesPairsBrackets) == 0 then
//                    
//                    //get element name (value or property)
//                    elementName = GetElementNameForNumberOrProperty(stringEquationWithoutSpaces, inPropertiesAvailable);
//                    //if empty, show error message and end function
//                    if elementName == emptystr() then
//                        
//                        xmlDelete(XMLMathFunctionsElement);
//                        XMLMathFunctionsElement = [];
//                        messagebox(["Wrong format of the function!" ; "Value or property is not valid."], "modal", "error");
//                        return;
//                        
//                    end
//                    
//                    //add new element (value or property)
//                    newXMLelement = xmlElement(XMLMathFunctionsElement, elementName);
//                    xmlAppend(XMLMathFunctionsElement.root, newXMLelement);
//                    
//                    return;
//                    
//                end
//                
//                
//            end
            
            
        //else if the right bracket is not the last character
        elseif indexesBracketsRight(size(indexesBracketsRight, 2)) ~= minimumIndexOfRightBracket then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["Wrong format of the function!" ; "The whole function MUST END with "')"'."], "modal", "error");
            return;
            
        end
        
        
        
        //get first function and create first new element
        operationName = part(stringEquationWithoutSpaces, 1:indexesPairsBrackets(1)(1)-1);
        xmlOperation = LoadOperationFromFile(operationName);
        //if operation was not found in XML template folder, show error message and end the function
        if xmlOperation == [] then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["The operation was not found!" ; "Name of operation: " + operationName ], "modal", "error");
            return;
            
        end
        
        //get number of arguments which are allowed
        numberOfArgumentsList = list();
        argumentsN = GetNumberOfArguments(xmlOperation);
        if argumentsN == [] then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["The XML file with operation information is broken!" ; "Attribute: ""arguments"" was not found."], "modal", "error");
            return;
            
        end
        numberOfArgumentsList($+1) = argumentsN;
        
        
        //add new main element (operation)
        newXMLelement = xmlElement(XMLMathFunctionsElement, operationName);
        xmlAppend(XMLMathFunctionsElement.root, newXMLelement);
        //get new created XML element (operation)
        functionXMLactual = XMLMathFunctionsElement.root.children(length(XMLMathFunctionsElement.root.children));
        
        
        
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
        //get closest index which next operation, value or property should end
        [closestNextIndex, closestNextType, incrementIndexBracketsLeft, incrementIndexBracketsRight, incrementIndexCommas]=GetClosestIndex(nextLeftBracketIndex, nextRightBracketIndex, nextCommaIndex);
        
        
        
        tableNumberIndex = 1;
        
        
        functionsWithZeroArguments = ["random"];    //<>All XML files should be loaded and the operation names with zero arguments attribute should be got here
        
        while closestNextIndex ~= %inf & closestNextType ~= emptystr() //& startIndex ~= %inf
            
            
            //get string between indexes
            nameFunctionOrPropertyOrValue = part(stringEquationWithoutSpaces, startIndex+1 : closestNextIndex-1);
            //if string is empty -> it is possible only if start and end chars are left and right brackets in the "random" function (i.e. "random()") or two right brackets (i.e. "))") or right bracket and comma (i.e. "),")
            if nameFunctionOrPropertyOrValue == emptystr() then
                
                
                //check if it is left and right bracket in "random" function
                if startType == "(" & closestNextType == ")" then
                    
                    //check if the brackets are in zero-argument operation
                    zeroOperationFound = %f;
                    for m = 1 : 1 : size(functionsWithZeroArguments, 1)
                        
                        if operationName == functionsWithZeroArguments(m) then
                            
                            zeroOperationFound = %t;
                            break;
                            
                        end
                        
                    end
                    
                    //if it is not operation with zero arguments, show error and end function
                    if zeroOperationFound == %f then
                        
                        xmlDelete(XMLMathFunctionsElement);
                        XMLMathFunctionsElement = [];
                        messagebox(["There cannot be empty brackets in function (except ""random"" operation)!" ; "Characters at position: " + string(startIndex) + " and " + string(closestNextIndex)], "modal", "error");
                        return;
                        
                        
                    end
                    
                    //get parent XML operation if any (zero-argument operation cannot have any children)
                    functionXMLactual = GetParentXMLoperation(functionXMLactual);
                    
                    
                    
                //check if it is two right brackets
                elseif startType == ")" & closestNextType == ")" then
                    
                    //get parent XML operation if any (there is end of the previous operation)
                    functionXMLactual = GetParentXMLoperation(functionXMLactual);
                    
                    
                    
                //check if it is right bracket and comma (i.e. another operation, value or property follows)
                elseif startType == ")" & closestNextType == "," then
                    
                    //previous operation was ended and new argument of parent operation (of the previous) follows
                    //do nothing
                    
                    
                    
                //otherwise, it is invalid format because other options are not allowed!
                else
                    
                    xmlDelete(XMLMathFunctionsElement);
                    XMLMathFunctionsElement = [];
                    messagebox(["Special characters are in invalid format!" ; "Characters: " + startType + " and " + closestNextType ; "at position: " + string(startIndex) + " and " + string(closestNextIndex)], "modal", "error");
                    return;
                    
                    
                end
                
                
                
            //else there is some string (operation, property or value)
            else
                
                
                //if the string should be value or property
                if closestNextType == "," | closestNextType == ")" then
                    
                    
                    //check if there is table tag at the beginning
                    if CheckTableTagAtBeginning(nameFunctionOrPropertyOrValue) == %t then
                        
                        
                        //if the table number index is lower than or equal to number of xml table elements in list (it should be)
                        if tableNumberIndex <= length(XMLTableElementsList) then
                            
                            //add xml table element from list
                            xmlAppend(functionXMLactual, XMLTableElementsList(tableNumberIndex).root);
                            tableNumberIndex = tableNumberIndex + 1;
                            
                        else
                            
                            xmlDelete(XMLMathFunctionsElement);
                            XMLMathFunctionsElement = [];
                            messagebox(["Table tag cannot be replaced by XML element!" ; "tableNumberIndex is higher than number of xml table elements in XMLTableElementsList!" ; "tableNumberIndex: " + string(tableNumberIndex) ; nameFunctionOrPropertyOrValue ; ], "modal", "error");
                            return;
                            
                        end
                        
                        
                    //otherwise, it is not table but number or property (or nonsense)
                    else
                        
                        
                        //get element name (value or property)
                        elementName = GetElementNameForNumberOrProperty(nameFunctionOrPropertyOrValue, inPropertiesAvailable);
                        //if empty, show error message and end function
                        if elementName == emptystr() then
                            
                            xmlDelete(XMLMathFunctionsElement);
                            XMLMathFunctionsElement = [];
                            messagebox(["Wrong format of the function!" ; "Value or property is not valid." ; nameFunctionOrPropertyOrValue], "modal", "error");
                            return;
                            
                        end
                        
                        //add new element (value or property)
                        newXMLelement = xmlElement(XMLMathFunctionsElement, elementName);
                        newXMLelement.content = nameFunctionOrPropertyOrValue;
                        xmlAppend(functionXMLactual, newXMLelement);
                        
                        
                    end
                    
                    //if it is the end of the current operation, get parent XML operation
                    if closestNextType == ")" then
                        functionXMLactual = GetParentXMLoperation(functionXMLactual);
                    end
                    
                    
                    
                //else if the string should be operation
                elseif closestNextType == "(" then
                    
                    
                    
                    //get first function and create first new element
                    operationName = nameFunctionOrPropertyOrValue;
                    xmlOperation = LoadOperationFromFile(operationName);
                    //if operation was not found in XML template folder, show error message and end the function
                    if xmlOperation == [] then
                        
                        xmlDelete(XMLMathFunctionsElement);
                        XMLMathFunctionsElement = [];
                        messagebox(["The operation was not found!" ; "Name of operation: " + operationName ], "modal", "error");
                        return;
                        
                    end
                    
                    //get number of arguments which are allowed
                    argumentsN = GetNumberOfArguments(xmlOperation);
                    if argumentsN == [] then
                        
                        xmlDelete(XMLMathFunctionsElement);
                        XMLMathFunctionsElement = [];
                        messagebox(["The XML file with operation information is broken!" ; "Attribute: ""arguments"" was not found."], "modal", "error");
                        return;
                        
                    end
                    numberOfArgumentsList($+1) = argumentsN;
                    
                    
                    //add new operation XML element
                    newXMLelement = xmlElement(XMLMathFunctionsElement, operationName);
                    xmlAppend(functionXMLactual, newXMLelement);
                    //get new created operation XML element
                    functionXMLactual = functionXMLactual.children(length(functionXMLactual.children));
                    
                    
                    
                //something is absolutely wrong
                else
                    
                    xmlDelete(XMLMathFunctionsElement);
                    XMLMathFunctionsElement = [];
                    messagebox(["Unknown error!" ; "Operation name: """ + operationName + """" ; "Processed string: """ + nameFunctionOrPropertyOrValue + """" ; "in special characters: " + startType + " and " + closestNextType ; "at position: " + string(startIndex) + " and " + string(closestNextIndex)], "modal", "error");
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
            //get closest index which next operation, value or property should end
            [closestNextIndex, closestNextType, incrementIndexBracketsLeft, incrementIndexBracketsRight, incrementIndexCommas]=GetClosestIndex(nextLeftBracketIndex, nextRightBracketIndex, nextCommaIndex);
            
            
            
        end
        
        
        
        //check if there is more than one main operation (i.e. error)
        if length(XMLMathFunctionsElement.root.children) > 1 then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            messagebox(["There are too many main operations!" ; "There should be one operation only"], "modal", "error");
            return;
            
        end
        
        //check correct number of arguments using created XML tree
        [errorString, indexNumberOfArgumentsList] = RecursiveCheckNumberOfArguments(XMLMathFunctionsElement.root.children(1), numberOfArgumentsList, 1);
        //if there was any error in the number of arguments, show message with error and end function
        if errorString ~= emptystr() then
            
            xmlDelete(XMLMathFunctionsElement);
            XMLMathFunctionsElement = [];
            errorString = tokens(errorString, '$');
            messagebox(["The number of arguments are not correct in the following cases:" ; "" ; errorString], "modal", "error");
            return;
            
        end
        
        
        
    end
    
    
    
endfunction



function [errorString, outIndexNumberOfArgumentsList]=RecursiveCheckNumberOfArguments(inXMLElement, inNumberOfArgumentsList, inIndexNumberOfArgumentsList)
    
    errorString = emptystr();
    outIndexNumberOfArgumentsList = inIndexNumberOfArgumentsList;
    //default separation element
    separateChar = '$';
    
    
    //if the element has no child, the content is empty string (i.e. it should be a function with zero arguments -> e.g. random function)
    //however, in some situations, table may have no children too (e.g. in CheckCorrectValueType function in XMLfunctions.sci), so it is excluded
    if length(inXMLElement.children) == 0 & inXMLElement.name ~= "table" then
        
        if length(inXMLElement.children) ~= inNumberOfArgumentsList(inIndexNumberOfArgumentsList) then
            
            errorString = string(inIndexNumberOfArgumentsList) + ". Operation: """ + inXMLElement.name + """ should have more than 0 arguments. The allowed number of arguments is: " + string(inNumberOfArgumentsList(inIndexNumberOfArgumentsList)) + ".";
            
        end
        
        //function may be ended because there is no children elements
        return;
        
    end
    
    
    
    //if the element has "text" child (i.e. the current XML element is property or value), there is only one child (i.e. there is no operation to check)
    //or if the element is "table", there is no operation to check in this and in children elements
    if inXMLElement.name == "table" | inXMLElement.children(1).name == "text" then
        //decrement index and break the cycle
        outIndexNumberOfArgumentsList = outIndexNumberOfArgumentsList - 1;
        //disp(inXMLElement.name);  //<>debug only
        return;
    end
    
    
    
    //<>debug only
    //disp(["The current operation is: " + inXMLElement.name ; "Length of list with number of arguments: " + string(length(inNumberOfArgumentsList)) ; "Index for list with number of arguments: " + string(inIndexNumberOfArgumentsList) ]); //; "Allowed number of arguments: " + string(inNumberOfArgumentsList(inIndexNumberOfArgumentsList)) ]);
    //if the allowed number of arguments is not infinite (infinite means that there may be any number of arguments between 1 (including) and infinite)
    if inNumberOfArgumentsList(inIndexNumberOfArgumentsList) ~= %inf then
        if length(inXMLElement.children) ~= inNumberOfArgumentsList(inIndexNumberOfArgumentsList) then
            
            errorString = string(inIndexNumberOfArgumentsList) + ". Operation: """ + inXMLElement.name + """ has " + string(length(inXMLElement.children)) + " arguments - however, the allowed number of arguments is: " + string(inNumberOfArgumentsList(inIndexNumberOfArgumentsList)) + ".";
            return;
            
        end
    end
    
    
    
    //check all children in cycle and subchildren recursively
    //the current XML element is any function with more than zero input arguments
    for i = 1 : 1 : length(inXMLElement.children)
        
        //default temporary error string
        errorStringTemp = emptystr();
        //check number of arguments in a child element
        //<>debug only
        //disp(["The current operation is: " + inXMLElement.name ; "The following operation will be checked: " + inXMLElement.children(i).name ; "Index for list with number of arguments: " + string(outIndexNumberOfArgumentsList) ; "Allowed number of arguments: " + string(inNumberOfArgumentsList(outIndexNumberOfArgumentsList)) ]);
        [errorStringTemp, outIndexNumberOfArgumentsList] = RecursiveCheckNumberOfArguments(inXMLElement.children(i), inNumberOfArgumentsList, outIndexNumberOfArgumentsList + 1);
        
        //if there is new error string add it to main error string
        if errorStringTemp ~= emptystr() then
            
            if errorString == emptystr() then
                errorString = errorStringTemp;
            else
                errorString = errorString + separateChar + errorStringTemp;
            end
            
        end
        
    end
    
    
endfunction



function [indexRightBracket]=GetProperIndexOfRightBracket(indexesLeftBrackets, indexesRightBrackets)
    
    indexRightBracket = [];
    if size(indexesLeftBrackets, 2) > 0 then
        
        IndexLeftBracket = indexesLeftBrackets(1);
        
        for j = 1 : 1 : size(indexesRightBrackets, 2)
            
            differenceLeftToRightBrackets = 1;
            
            if IndexLeftBracket < indexesRightBrackets(j) then
                
                
                for i = 2 : 1 : size(indexesLeftBrackets, 2)
                    
                    if indexesLeftBrackets(i) < indexesRightBrackets(j) then
                        
                        differenceLeftToRightBrackets = differenceLeftToRightBrackets + 1;
                        
                    else
                        
                        break;
                        
                    end
                    
                end
                
                
                differenceLeftToRightBrackets = differenceLeftToRightBrackets - j;
                if differenceLeftToRightBrackets == 0 then
                    
                    indexRightBracket = j;
                    break;
                    
                    
                elseif differenceLeftToRightBrackets < 0 then
                    
                    messagebox("At least one right bracket begins before left brackets!", "modal", "error");
                    indexRightBracket = [];
                    return;
                    
                    
                end
                
            end
            
        end
        
    end
    
endfunction



function [closestNextIndex, closestNextType, incrementIndexBracketsLeft, incrementIndexBracketsRight, incrementIndexCommas]=GetClosestIndex(nextLeftBracketIndex, nextRightBracketIndex, nextCommaIndex)
    
    //default closest index (infinite means that there is not another index)
    closestNextIndex = %inf;
    closestNextType = emptystr();
    //default increment indexes
    incrementIndexBracketsLeft = 0;
    incrementIndexBracketsRight = 0;
    incrementIndexCommas = 0;
    
    
    if nextLeftBracketIndex < nextRightBracketIndex then
        
        
        //next left bracket index is the lowest
        if nextLeftBracketIndex < nextCommaIndex then
            
            closestNextIndex = nextLeftBracketIndex;
            closestNextType = "(";
            incrementIndexBracketsLeft = 1;
            
            
        //next comma index is the lowest
        elseif nextLeftBracketIndex > nextCommaIndex
            
            closestNextIndex = nextCommaIndex;
            closestNextType = ",";
            incrementIndexCommas = 1;
            
            
        end
        
        
    //next right bracket index is the lowest
    elseif nextRightBracketIndex < nextCommaIndex then
        
        closestNextIndex = nextRightBracketIndex;
        closestNextType = ")";
        incrementIndexBracketsRight = 1;
        
        
    //next comma index is the lowest
    elseif nextCommaIndex < nextRightBracketIndex
        
        closestNextIndex = nextCommaIndex;
        closestNextType = ",";
        incrementIndexCommas = 1;
        
        
    end
    
endfunction



function [parentXML]=GetParentXMLoperation(xmlOperation)
    
    parentXML = xmlOperation;
    
    //if there is any parent
    if xmlOperation.parent ~= [] then
        
        parentXML = xmlOperation.parent;
        
    end
    
endfunction


function [nextIndex]=GetNextIndexFromIndexes(indexOfIndexes, indexesArray)
    
    //get new next indexes if it is not infinite
    if indexOfIndexes <= size(indexesArray, 2) then
        nextIndex = indexesArray(indexOfIndexes);
    else
        nextIndex = %inf;
    end
    
endfunction



function [xmlOperation]=LoadOperationFromFile(nameFunction)
    
    xmlOperation = [];
    
    functionFileName = "templates" + filesep() + "Math_Functions" + filesep() + nameFunction + ".xml";
    //check if file exists
    fileExist = fileinfo(functionFileName);
    if fileExist ~= [] then
        
        xmlOperation = xmlRead(functionFileName);
        //errorString=ValidateXMLdocument(xmlComponent);
        
    end
    
endfunction


function [numberOfArguments]=GetNumberOfArguments(xmlOperation)
    
    numberOfArguments = []; 
    
    if typeof(xmlOperation) == "XMLDoc" then
        
        if xmlOperation.root.attributes.arguments ~= [] then
            
            argumentsN = xmlOperation.root.attributes.arguments;
            isNumber = isnum(argumentsN);
            if isNumber then
                
                numberOfArguments = strtod(argumentsN);
                
            else
                
                numberOfArguments = %inf;
                
            end
            
        end
        
    end
    
endfunction



function [elementNameNumberOrProperty]=GetElementNameForNumberOrProperty(inString, inPropertiesAvailable)
    
    elementNameNumberOrProperty = emptystr();
    //check if the string can be converted to number
    isNumber = isnum(inString);
    if isNumber then
        
        elementNameNumberOrProperty = "value";
        
    else
        
        //check if the string is name of a property which exists
        isPropertyValid = FindPropertyInPropertiesAvailable(inString, inPropertiesAvailable);
        if isPropertyValid then
            
            elementNameNumberOrProperty = "property";
            
        end
        
    end
    
endfunction





function [stringEquation]=XMLMathFuncToStringEquation(XMLMathFunctionsElement)
    
    stringEquation = emptystr();
    
    if length(XMLMathFunctionsElement.children) == 1 then
        
        nextTableNumber = 1;
        [stringEquation, nextTableNumber] = RecursiveFuncToStringDecode(XMLMathFunctionsElement.children(1), nextTableNumber);
        //disp("complete next table number: " + string(nextTableNumber)); //debug only
        
    else
        
        messagebox("Number of children in function element of fcs_function component is wrong (It should be 1): " + string(length(XMLMathFunctionsElement.children)), "modal", "error");
        
    end
    
endfunction


function [stringEquation, outNextTableNumber]=RecursiveFuncToStringDecode(inXMLElement, inNextTableNumber)
    
    stringEquation = emptystr();
    outNextTableNumber = inNextTableNumber;
    //default separation elements (comma, left bracket, and right bracket)
    bracketLeft = "( ";
    bracketRight = " )";
    commaToSeparate = ", ";
    
    
    
    //if there is a comment, set empty string (for sure) and end the function
    if inXMLElement.name == "comment" then
        
        stringEquation = emptystr();
        return;
        
    //elseif the element has no child, the content is empty string (i.e. it is a function with zero arguments -> e.g. random function)
    //(note: the random function just generates random numbers; it has no input argument (i.e. the content has to be the empty string -> ""))
    elseif length(inXMLElement.children) == 0 & inXMLElement.name ~= "table" then
        
        stringEquation = inXMLElement.name + bracketLeft + inXMLElement.content + bracketRight;
        return;
        
    //else if the element is "table", create substitution name "table_<table no.>" and increase the table number
    elseif inXMLElement.name == "table" then
        
        stringEquation = inXMLElement.name + "_" + string(outNextTableNumber);
        outNextTableNumber = outNextTableNumber + 1;
        return;
        
    end
    
    for i = 1 : 1 : length(inXMLElement.children)
        
        //if the element has "text" child (i.e. the current XML element is property or value), there is only one child
        if inXMLElement.children(i).name == "text" then
            
            //stringEquation = " " + inXMLElement.children(i).content + " ";
            stringEquation = inXMLElement.children(i).content;
            
            
        //else the current XML element is any function with more than zero input arguments
        else
            
            
            //because the JSBSim property names contain '/' and '-' chars, they cannot be simply differentiate from elemental math operations and therefore the following code is omitted; however, it may be used in a future release when a better encoding will be developed (perhaps)
//            //check if the current math operation is elemental or more sophisticated
//            mathOperationChar = GetMathOperationChar(inXMLElement.name);
//            //if the current math operation is elemental (i.e. +, -, *, /, %)
//            if mathOperationChar ~= emptystr() then
//                
//                //if there is only one input argument (the first child is the last child at the same time)
//                if i == 1 & i == length(inXMLElement.children) then
//                    stringEquation = bracketLeft + RecursiveFuncToStringDecode(inXMLElement.children(i)) + bracketRight;
//                //if this is the first argument (but not last)
//                elseif i == 1 then
//                    stringEquation = bracketLeft + RecursiveFuncToStringDecode(inXMLElement.children(i));
//                //if this is the last argument (but not first)
//                elseif i == length(inXMLElement.children) then
//                    stringEquation = stringEquation + mathOperationChar + RecursiveFuncToStringDecode(inXMLElement.children(i)) + bracketRight;
//                //if this is an argument between the first and the last
//                else
//                    stringEquation = stringEquation + mathOperationChar + RecursiveFuncToStringDecode(inXMLElement.children(i));

//                end
//                
//                
//            //otherwise, the current math operation is more sophisticated (i.e. sin, cos, abs, pow, exp, ...)
//            else
                
                //go through all children elements recursively
                [stringEquationRecursivePart, outNextTableNumber] = RecursiveFuncToStringDecode(inXMLElement.children(i), outNextTableNumber);
                if stringEquationRecursivePart ~= emptystr() then
                    //if there is only one input argument (the first child is the last child at the same time)
                    if i == 1 & i == length(inXMLElement.children) then
                        stringEquation = inXMLElement.name + bracketLeft + stringEquationRecursivePart + bracketRight;
                    //if this is the first argument (but not last)
                    elseif i == 1 then
                        stringEquation = inXMLElement.name + bracketLeft + stringEquationRecursivePart;
                    //if this is the last argument (but not first)
                    elseif i == length(inXMLElement.children) then
                        //if the last two characters of complete string equation are NOT left bracket and white space
                        if part(stringEquation, length(stringEquation)-1:length(stringEquation)) ~= bracketLeft then
                            stringEquation = stringEquation + commaToSeparate + stringEquationRecursivePart + bracketRight;
                        else
                            stringEquation = stringEquation + stringEquationRecursivePart + bracketRight;
                        end
                    //if this is an argument between the first and the last
                    else
                        //if the last two characters of complete string equation are NOT left bracket and white space
                        if part(stringEquation, length(stringEquation)-1:length(stringEquation)) ~= bracketLeft then
                            stringEquation = stringEquation + commaToSeparate + stringEquationRecursivePart;
                        else
                            stringEquation = stringEquation + stringEquationRecursivePart;
                        end
                    end
                else
                    //if there is only one input argument (the first child is the last child at the same time)
                    if i == 1 & i == length(inXMLElement.children) then
                        stringEquation = inXMLElement.name + bracketLeft + bracketRight;
                    //if this is the first argument (but not last)
                    elseif i == 1 then
                        stringEquation = inXMLElement.name + bracketLeft;
                    //if this is the last argument (but not first)
                    elseif i == length(inXMLElement.children) then
                        stringEquation = stringEquation + bracketRight;
                    end
                end
//                
//            end
//            
        end
        
    end
    
endfunction


function [mathOperationChar]=GetMathOperationChar(mathOperationName)
    
    //default math operation (if empty, a sophisticated math function is processed, i.e. sin, pow etc.)
    mathOperationChar = emptystr();
    
    //check which elemental math operation is currently processed and select the right operation char
    mathOperationNameLowerCase = convstr(mathOperationName, 'l');
    if mathOperationNameLowerCase == "sum" then
        mathOperationChar = " + ";
    elseif mathOperationNameLowerCase == "difference" then
        mathOperationChar = " - ";
    elseif mathOperationNameLowerCase == "product" then
        mathOperationChar = " * ";
    elseif mathOperationNameLowerCase == "quotient" then
        mathOperationChar = " / ";
    elseif mathOperationNameLowerCase == "mod" then
        mathOperationChar = " % ";
    end
    
endfunction





//functions for tables in function
function [tableStringsList]=GetTableStringsFromStringEquation(stringEquation, tableTag)
    
    
    tableStringsList = list();
    
    
    //delete spaces in string
    stringEquationWithoutSpaces = strsubst(stringEquation, " ", "");
    tableTagIndexes = strindex(stringEquationWithoutSpaces, tableTag);
    if tableTagIndexes ~= [] then
        
        
        //find indexes of left brackets, right brackets, and commas
        indexesBracketsLeft = strindex(stringEquationWithoutSpaces, '(');
        indexesBracketsRight = strindex(stringEquationWithoutSpaces, ')');
        indexesCommas = strindex(stringEquationWithoutSpaces, ',');
        
        lastClosestEndIndex = 0;
        if (size(indexesBracketsLeft, 2) > 0 & size(indexesBracketsRight, 2) > 0) | size(indexesCommas, 2) > 0
            
            for i = 1 : 1 : length(tableTagIndexes)
                
                closestEndIndex = GetClosestEndIndex(tableTagIndexes(i), indexesBracketsLeft, indexesBracketsRight, indexesCommas);
                if closestEndIndex ~= [] & closestEndIndex-1 > tableTagIndexes(i) then
                    
                    //if the last closest index is not the same as the current closest index
                    if lastClosestEndIndex < closestEndIndex then
                        stringTableName = part(stringEquationWithoutSpaces, tableTagIndexes(i):closestEndIndex-1);
                        tableStringsList($+1) = stringTableName;
                        lastClosestEndIndex = closestEndIndex;
                    end
                    
                else
                    disp(["Error during table tag names decoding: " ; "closest end index was not found or is not valid" ; "tableTagIndex: " + string(tableTagIndexes(i)) ; ]);
                    break;
                end
                
            end
            
        //otherwise, there is no left and right brackets and no comma, thus, there should be only one table
        else
            
            //if the start index is the first character, there is only table name
            if tableTagIndexes(1) == 1 then
                tableStringsList($+1) = stringEquationWithoutSpaces;
            else
                //otherwise, there is some nonsense string equation
                disp(["There is no valid table name in string equation: " ; stringEquationWithoutSpaces ; "(note: table name only was set - without brackets, commas and functions)" ;])
            end
            
        end
        
    end
    
    
endfunction



function [isTableTagAtBeginning]=CheckTableTagAtBeginning(tableString)
    
    isTableTagAtBeginning = %f;
    tableTag = "table";
    
    //if the first part of string without spaces is equal to "table" tag
    tableStringWithoutSpaces = strsubst(tableString, " ", "");
    if part(tableStringWithoutSpaces, 1 : length(tableTag)) == tableTag then
        isTableTagAtBeginning = %t;
    end
    
endfunction



function [tableNumber]=DecodeTableNumberFromTableString(tableString)
    
    tableNumber = [];
    
    //if length of string is longer than length of "table" string
    if length(tableString) > length("table") then
        
        //the string should be without spaces and the first text should be "table", so ignore it and get only the last part with number or some string
        tableStringWithoutTag = part(tableString, length("table")+1 : length(tableString));
        
        //delete all underscore chars if any
        tableStringWithoutTag = strsubst(tableStringWithoutTag, "_", "");
        
        //check if the last part of the table name is number and if it is true, convert it to number
        isNumber = isnum(tableStringWithoutTag);
        if isNumber then
            tableNumber = strtod(tableStringWithoutTag);
        end
        
    end
    
endfunction



function [closestEndIndex]=GetClosestEndIndex(tableTagIndex, indexesBracketsLeft, indexesBracketsRight, indexesCommas)
    
    
    closestEndIndex = [];
    
    
    closestBracketsLeftIndex = 0;
    for i = 1 : 1 : size(indexesBracketsLeft, 2)
        if tableTagIndex < indexesBracketsLeft(i) then
            closestBracketsLeftIndex = indexesBracketsLeft(i);
            break;
        end
    end
    
    closestBracketsRightIndex = 0;
    for i = 1 : 1 : size(indexesBracketsRight, 2)
        if tableTagIndex < indexesBracketsRight(i) then
            closestBracketsRightIndex = indexesBracketsRight(i);
            break;
        end
    end
    
    closestBracketsCommasIndex = 0;
    for i = 1 : 1 : size(indexesCommas, 2)
        if tableTagIndex < indexesCommas(i) then
            closestBracketsCommasIndex = indexesCommas(i);
            break;
        end
    end
    
    
    //check all lower values with all valid combinations of indexes
    if closestBracketsLeftIndex > 0 & closestBracketsRightIndex > 0 then
        
        [closestEndIndex, higherValue] = GetLowerAndHigherValue(closestBracketsLeftIndex, closestBracketsRightIndex);
        if closestBracketsCommasIndex > 0 then
            [closestEndIndex, higherValue] = GetLowerAndHigherValue(closestEndIndex, closestBracketsCommasIndex);
        end
        
    elseif closestBracketsLeftIndex > 0 & closestBracketsCommasIndex > 0 then
        
        [closestEndIndex, higherValue] = GetLowerAndHigherValue(closestBracketsLeftIndex, closestBracketsCommasIndex);
        
    elseif closestBracketsRightIndex > 0 & closestBracketsCommasIndex > 0 then
        
        [closestEndIndex, higherValue] = GetLowerAndHigherValue(closestBracketsRightIndex, closestBracketsCommasIndex);
        
    elseif closestBracketsLeftIndex > 0 then
        
        closestEndIndex = closestBracketsLeftIndex;
        
    elseif closestBracketsRightIndex > 0 then
        
        closestEndIndex = closestBracketsRightIndex;
        
    elseif closestBracketsCommasIndex > 0 then
        
        closestEndIndex = closestBracketsCommasIndex;
        
    end
    
    
endfunction



function [lowerValue, higherValue]=GetLowerAndHigherValue(value1, value2)
    
    //if the first value is higher than the second, set it as higher value
    if value1 > value2 then
        lowerValue = value2;
        higherValue = value1;
    //otherwise the first value is set as lower value (including situation when the values are same because it is not problem in our case)
    else
        lowerValue = value1;
        higherValue = value2;
    end
    
endfunction



function [tableXMLElementsList]=GetTablesFromXMLFunctionElement(XMLMathFunctionsElement)
    
    
    tableXMLElementsList = list();
    
    
    if length(XMLMathFunctionsElement.children) == 1 then
        
        //if the first child is not table, find all tables recursively if any
        if XMLMathFunctionsElement.children(1).name ~= "table" then
            tableXMLElementsList = RecursiveGetTablesFromXMLFunctionElement(XMLMathFunctionsElement.children(1), tableXMLElementsList);
        else
            //otherwise, it is only one child which is a table
            tableXMLElementsList($+1) = XMLMathFunctionsElement.children(1);
        end
        
    else
        
        messagebox("Number of children in function element of fcs_function component is wrong (It should be 1): " + string(length(XMLMathFunctionsElement.children)), "modal", "error");
        
    end
    
    
endfunction


function [outTableXMLElementsList]=RecursiveGetTablesFromXMLFunctionElement(inXMLElement, inTableXMLElementsList)
    
    
    outTableXMLElementsList = inTableXMLElementsList;
    
    
    //go through all children xml elements
    for i = 1 : 1 : length(inXMLElement.children)
        
        //if the element has "table" child, one of the tables in xml function element was found and is added to output list
        if inXMLElement.children(i).name == "table" then
            
            outTableXMLElementsList($+1) = inXMLElement.children(i);
            
        //else if the element is not "text" child (i.e. the current XML element is not property or value), the current XML element is any function with more than zero input arguments
        elseif inXMLElement.children(i).name ~= "text" then
            
            outTableXMLElementsList = RecursiveGetTablesFromXMLFunctionElement(inXMLElement.children(i), outTableXMLElementsList);
            
        end
        
    end
    
    
endfunction



function [tableStringsMatricesList, tableTitleArraysList, tablePropertyRowsList, tablePropertyColumnsList, tablesPropertyTableList]=DecodeOrCreateXMLTables(tableXMLElementsList, tableStringsList, tablePropertyRowsDefaultName)
    
    
    tableStringsMatricesList = list();
    tableTitleArraysList = list();
    tablePropertyRowsList = list();
    tablePropertyColumnsList = list();
    tablesPropertyTableList = list();
    
    
    for i = 1 : 1 : length(tableStringsList)
        
        
        //set default data for new empty table
        global defaultTableString;
        tableStringMatrices = list(defaultTableString);
        tableTitleArray = emptystr();
        tablePropertyRow = emptystr();
        tablePropertyColumn = emptystr();
        tablePropertyTable = emptystr();
        
        
        //decode the last part of the "table" tag if any
        tableNumber = DecodeTableNumberFromTableString(tableStringsList(i));
        
        //if the last part of the "table" tag is number
        if tableNumber ~= [] then
            
            //if the number can be used as index to list of xml element tables
            if tableNumber > 0 & tableNumber <= length(tableXMLElementsList) then
                
                //decode data from table XML element list
                [tableStringMatrices, tableTitleArray, tablePropertyRow, tablePropertyColumn, tablePropertyTable] = DecodeXMLTable(tableXMLElementsList(tableNumber));
                
                //if there is no main output
                if tableStringMatrices == [] | tableStringMatrices == list() | tablePropertyRow == emptystr() then
                    
                    //show error message
                    messagebox(["Table was not loaded properly from function!" ; "row property: """ + tablePropertyRow + """" ; "column property: """ + tablePropertyColumn + """" ; "table property: " + tablePropertyTable + """" ; "Table Titles: " ; tableTitleArray ; "Table Data: " ; tableStringMatrices ], "modal", "error");
                    return;
                    
                end
                
            end
            
        end
        
        
        //add all data to the list
        tableStringsMatricesList($+1) = tableStringMatrices;
        tableTitleArraysList($+1) = tableTitleArray;
        //if row property name is empty, set default name of property set as input
        if strsubst(tablePropertyRow, " ", "") == emptystr() then
            tablePropertyRow = tablePropertyRowsDefaultName;
        end
        tablePropertyRowsList($+1) = tablePropertyRow;
        tablePropertyColumnsList($+1) = tablePropertyColumn;
        tablesPropertyTableList($+1) = tablePropertyTable;
        
        
    end
    
    
endfunction



