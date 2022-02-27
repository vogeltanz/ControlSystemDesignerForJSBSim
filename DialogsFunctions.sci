//include files with functions which are used
exec XMLfunctions.sci;
//exec XMLMath.sci
//exec XMLTest.sci
//exec XMLTable.sci
exec XMLSimulation.sci;
//exec TXTfunctions.sci;
exec ControllerDesignMethods.sci;



//global properties
global defaultTableValue;
defaultTableValue = "0";
global defaultColumnValue;
defaultColumnValue = "0";
global defaultRowValue;
defaultRowValue = "0";
global defaultTableString;
defaultTableString = [[" " ""] ; ["0" "0"]];



//table dialog functions
function [tableStringMatrices, tableTitleArray, outPropertyRow, outPropertyColumn, outPropertyTable]=DialogTableOkCancel(inputTableStringMatrices, inputTableTitleArray, inputPropertyRow, inputPropertyColumn, inputPropertyTable, propertiesAvailable)
    
    
function [tableStringMatrices, tableTitleArray]=TableOK_callback(handles, tabUIcontrol, inputPropertyRow, inputPropertyColumn, inputPropertyTable, propertiesAvailable)
    
    
    //if there is any table in tab uicontrol
    if length(tabUIcontrol.children) > 0 then
        
        //get all tables string matrices
        tableStringMatrices = GetTablesStrings(tabUIcontrol);
        //get all tables titles
        tableTitleArray = GetTableTitles(tabUIcontrol, %t);
        
        //the following inputs don't have to be list but array of strings
        for i = 1 : 1 : length(tableStringMatrices)
            //delete spaces
            tableStringMatrices(i) = strsubst(tableStringMatrices(i), " ", "");
            //change comma (',') to dot ('.')
            tableStringMatrices(i) = strsubst(tableStringMatrices(i), ",", ".");
            //change table data in tab uicontrol
            //<>two list logics
            tabUIcontrol.children(length(tabUIcontrol.children) - (i - 1)).children(1).string = tableStringMatrices(i);   //when new string table elements are added by using (0) to list
            //tabUIcontrol.children(i).children(1).string = tableStringMatrices(i);      //when new string table elements are added by using ($+1) to list
        end
        
        //check if property table has to be set
        propertyTableIsRequired = CheckIfPropertyTableIsRequired(tabUIcontrol);
        //check if property column has to be set
        propertyColumnIsRequired = CheckIfPropertyColumnIsRequired(tableStringMatrices);
        
        //check if all required properties are OK
        [propertyRowError, propertyColumnError, propertyTableError] = CheckTableProperties(inputPropertyRow, inputPropertyColumn, inputPropertyTable, propertiesAvailable, propertyColumnIsRequired, propertyTableIsRequired);
        
        
        //if the properties are set wrongly, show errors in message box and then return
        if propertyRowError ~= list() | propertyColumnError ~= list() | propertyTableError ~= list() then
            
            propertyRowErrorString = [];
            for i = 1 : 1 : length(propertyRowError)
                propertyRowErrorString(size(propertyRowErrorString, 1) + 1) = propertyRowError(i);
            end
        
            propertyColumnErrorString = [];
            for i = 1 : 1 : length(propertyColumnError)
                propertyColumnErrorString(size(propertyColumnErrorString, 1) + 1) = propertyColumnError(i);
            end
            
            propertyTableErrorString = [];
            for i = 1 : 1 : length(propertyTableError)
                propertyTableErrorString(size(propertyTableErrorString, 1) + 1) = propertyTableError(i);
            end
            
            //show message box with all errors
            messagebox(["The following errors have occurred:" ; "" ;  propertyRowErrorString; propertyColumnErrorString; propertyTableErrorString], "Error - Table properties are not valid!", "error");
            
            
            
            //table properties are not OK, so back to parent function with empty outputs
            tableStringMatrices = [];
            tableTitleArray = [];
            
            return;
            
        end
        
        
        
        //check if table data has to be number or will be ignored
        propertyTableHasToBeNumber = CheckIfDataHasToBeNumber(inputPropertyTable, propertyTableIsRequired);
        //check table titles (all values have to be number; table property and table titles may be empty if there is only 1 table)
        errorListTableTitles = CheckTablesTitles(tableTitleArray, propertyTableHasToBeNumber);
        
        //check if column data has to be number or will be ignored
        propertyColumnHasToBeNumber = CheckIfDataHasToBeNumber(inputPropertyColumn, propertyColumnIsRequired);
        //check if all table data are correct (all values have to be number; column property and column titles may be empty if there is only 1 column or 1 table)
        errorListTableString = CheckTablesData(tabUIcontrol, propertyColumnHasToBeNumber);
        
        
        
        //if there are errors in table(s), row(s), or column(s), show them in message box and then return
        if errorListTableString ~= list() | errorListTableTitles ~= list() then
            
            errorListTableStringString = [];
            for i = 1 : 1 : length(errorListTableString)
                errorListTableStringString(size(errorListTableStringString, 1) + 1) = errorListTableString(i);
            end
            
            errorListTableTitlesString = [];
            for i = 1 : 1 : length(errorListTableTitles)
                errorListTableTitlesString(size(errorListTableTitlesString, 1) + 1) = errorListTableTitles(i);
            end
            
            //show message box with all errors
            messagebox(["The following errors have occurred:" ; "" ;  errorListTableStringString; errorListTableTitlesString], "Error - Table format is not valid!", "error");
            
            
            
            //table format is not OK, so back to parent function with empty outputs
            tableStringMatrices = [];
            tableTitleArray = [];
            
            return;
            
            
//        else
//            
//            //change table and column titles when they don't have to be numbers
//            if propertyTableHasToBeNumber == %f then
//                
//                tableTitleArray = [""];
//                
//            end
//            
//            if propertyColumnHasToBeNumber == %f then
//                //<>not used = not completed
//            end
            
            
        end
        
        
    else
        
        tableStringMatrices = [];
        tableTitleArray = [];
        
    end
    
    
    //close the window
    close(gcf());
    
    
endfunction


function [errorList]=CheckTablesData(tabUIcontrol, propertyColumnHasToBeNumber)
    
    errorList = list();
    
    for i = 1 : 1 : length(tabUIcontrol.children)
        
        //only if column property has to be number (if all tables have only one column and column property was not set)
        if propertyColumnHasToBeNumber then
            
            //get column titles only
            columnTitlesData = tabUIcontrol.children(i).children(1).string(1, 2:size(tabUIcontrol.children(i).children(1).string, 2));
            
            //check if column data are numbers
            isColumnNumber = isnum(columnTitlesData);
            if and(isColumnNumber) == %f then
                
                //if column data are not numbers, show error with detail for each
                tableTitle = GetTableTitle(tabUIcontrol, i);
                for j = 1 : 1 : size(isColumnNumber, 2)
                    
                    if isColumnNumber(j) == %f then
                        errorList(0) = "Column title in table: """ + tableTitle + """ at column index: """ + string(j) + """ is not number! (The current title is: """ + columnTitlesData(j) + """)";
                    end
                    
                end
                
            end
            
        end
        
        
        
        //get row titles only
        rowTitlesData = tabUIcontrol.children(i).children(1).string(2:size(tabUIcontrol.children(i).children(1).string, 1), 1);
        
        //check if column data are numbers
        isRowNumber = isnum(rowTitlesData);
        if and(isRowNumber) == %f then
            
            //if column data are not numbers, show error with detail for each
            tableTitle = GetTableTitle(tabUIcontrol, i);
            for j = 1 : 1 : size(isRowNumber, 1)
                
                if isRowNumber(j) == %f then
                    errorList(0) = "Row title in table: """ + tableTitle + """ at row index: """ + string(j) + """ is not number! (The current title is: """ + rowTitlesData(j) + """)";
                end
                
            end
            
        end
        
        
        
        //get data values only
        dataValues = tabUIcontrol.children(i).children(1).string(2:size(tabUIcontrol.children(i).children(1).string, 1), 2:size(tabUIcontrol.children(i).children(1).string, 2));
        
        //check if column data are numbers
        isDataNumber = isnum(dataValues);
        if and(isDataNumber) == %f then
            
            //if column data are not numbers, show error with detail for each
            tableTitle = GetTableTitle(tabUIcontrol, i);
            for j = 1 : 1 : size(isDataNumber, 1)
                for k = 1 : 1 : size(isDataNumber, 2)
                    
                    if isDataNumber(j, k) == %f then
                        errorList(0) = "Value in table: """ + tableTitle + """ at indexes (row, column): """ + string(j) + ", " + string(k) + """ is not number! (The current value is: """ + dataValues(j, k) + """)";
                    end
                    
                end
            end
            
        end
        
        
    end
    
    
endfunction


function [errorList]=CheckTablesTitles(tableTitleArray, propertyTableHasToBeNumber)
    
    errorList = list();
    
    for i = 1 : 1 : size(tableTitleArray,2)
        
        if tableTitleArray(i) == emptystr() & propertyTableHasToBeNumber == %f then
            
            continue;
            
        elseif isnum(tableTitleArray(i)) == %f then
            
            errorList(0) = "Table title: """ + tableTitleArray(i) + """ with index: """ + string(i) + """ has to be valid number!";
            
        end
        
    end
    
endfunction


function [propertyRowError, propertyColumnError, propertyTableError]=CheckTableProperties(inputPropertyRow, inputPropertyColumn, inputPropertyTable, propertiesAvailable, propertyColumnIsRequired, propertyTableIsRequired)
    
    propertyRowError = list();
    propertyColumnError = list();
    propertyTableError = list();
    
    //check if properties are OK
    propertyRowIsOK = CheckIfPropertyIsOK(inputPropertyRow, %t, propertiesAvailable);
    propertyColumnIsOK = CheckIfPropertyIsOK(inputPropertyColumn, propertyColumnIsRequired, propertiesAvailable);
    propertyTableIsOK = CheckIfPropertyIsOK(inputPropertyTable, propertyTableIsRequired, propertiesAvailable);
    
    //if the properties are not valid, return errors
    if propertyRowIsOK == %f then
        propertyRowError(0) = "Row Property: """ + inputPropertyRow + """ was not found in property database! (You can set it in menu: Row -> Property)";
    end
    
    if propertyColumnIsOK == %f then
        mayBeEmptyString = "";
        if propertyColumnIsRequired == %f then
            mayBeEmptyString = " (Info: Property can be empty)";
        end
        propertyColumnError(0) = "Column Property: """ + inputPropertyColumn + """ was not found in property database! (You can set it in menu: Column -> Property)" + mayBeEmptyString;
    end
    
    if propertyTableIsOK == %f then
        mayBeEmptyString = "";
        if propertyTableIsRequired == %f then
            mayBeEmptyString = " (Info: Property can be empty)";
        end
        propertyTableError(0) = "Table Property: """ + inputPropertyTable + """ was not found in property database! (You can set it in menu: Table -> Property)" + mayBeEmptyString;
    end
    
endfunction



function [propertyTableIsRequired]=CheckIfPropertyTableIsRequired(tabUIcontrol)
    
    propertyTableIsRequired = %f;
    if length(tabUIcontrol.children) > 1 then
        propertyTableIsRequired = %t;
    end
    
endfunction



function [hasToBeNumber]=CheckIfDataHasToBeNumber(inputProperty, isRequired)
    
    if isRequired | inputProperty ~= emptystr() then
        hasToBeNumber = %t;
    else
        hasToBeNumber = %f;
    end
    
endfunction


function [tableStringMatrices]=GetTablesStrings(tabUIcontrol)
    
    tableStringMatrices = list();
    for i = 1 : 1 : length(tabUIcontrol.children)
        
        //<>two list logics
        tableStringMatrices(0) = tabUIcontrol.children(i).children(1).string; //add string table at the beginning of the list
        //tableStringMatrices($+1) = tabUIcontrol.children(i).children(1).string; //add string table at the end of the list
        
    end
    
    //if the list is still empty, there are no data
    if tableStringMatrices == list() then
        tableStringMatrices = [];
    end
    
endfunction
    
    
    
function [tableStringMatrices, tableTitleArray]=TableCancel_callback(handles)
    
    //set empty values
    tableStringMatrices = [];
    tableTitleArray = [];
    //close the window
    close(gcf());
    
endfunction



function [outProperty]=PropertySet_callback(handles, inProperty, propertiesAvailable)
    
    outProperty = inProperty;
    //disp(handles);  //<>debug only
    
    propertyFound = %f;
    labelMain = 'Set ' + handles.Tag;
    isRow = %f;
    if strindex(convstr(labelMain, 'l'), "row") then
        isRow = %t;
    end
    while propertyFound == %f then
        
        outParam = x_dialog(labelMain, outProperty);
        
        if outParam ~= [] then
            
            outProperty = outParam(1);
            propertyNameWithoutSpaces = strsubst(outProperty, " ", "");
            //if property name without spaces is not empty
            if propertyNameWithoutSpaces ~= emptystr() | isRow then
                //check if the property name can be found in property database
                propertyFound = FindPropertyInPropertiesAvailable(propertyNameWithoutSpaces, propertiesAvailable);
                if propertyFound then
                    outProperty = propertyNameWithoutSpaces;
                    break;
                else
                    labelMain = ['Set ' + handles.Tag ; "Property does not exist!"];
                end
                
            else
                //no property was set, so break the cycle
                break;
            end
            
        else
            
            outProperty = inProperty;
            break;
            
        end

    end
    
endfunction


function [outTablePart]=GetSpecificPartOfTable(handles, inTable)
    
    outTablePart = [];  //undefined option
    labelMain = handles.Tag;
    //get the correct input values depending on choice
    if strindex(convstr(labelMain, 'l'), "row") then
        
        outTablePart = inTable(2:size(inTable, 1), 1);
        
    elseif strindex(convstr(labelMain, 'l'), "column") then
        
        outTablePart = inTable(1, 2:size(inTable, 2));
        
    elseif strindex(convstr(labelMain, 'l'), "table") then
        
        outTablePart = inTable;
        
    end
    
endfunction

//function [stringTitleArrayForMDialog, indexes]=GetSpecificTitlesForMDialog(handles, inTablePart)
//    
//    stringTitleArrayForMDialog = [];  //undefined option
//    labelMain = handles.Tag;
//    parameterForSize = 0;
//    
//    //get the size number depending on choice
//    if strindex(convstr(labelMain, 'l'), "row") then
//        
//        parameterForSize = 1;
//        
//    elseif strindex(convstr(labelMain, 'l'), "column") | strindex(convstr(labelMain, 'l'), "table") then
//        
//        parameterForSize = 2;
//        
//    end
//    



//    for i = 1 : 1 : size(inTablePart, parameterForSize)
//        
//        stringTitleArrayForMDialog(size(stringTitleArrayForMDialog, parameterForSize) + 1) = inTablePart(i);
//        
//    end
//    
//endfunction

function [stringIndexesArray]=GetSpecificStringIndexesForMDialog(handles, inTablePart)
    
    stringIndexesArray = [];  //undefined option
    labelMain = handles.Tag;
    parameterForSize = 0;
    
    //get the size number depending on choice
    if strindex(convstr(labelMain, 'l'), "row") then
        
        parameterForSize = 1;
        
    elseif strindex(convstr(labelMain, 'l'), "column")
        
        parameterForSize = 2;
        
    elseif strindex(convstr(labelMain, 'l'), "table") then
        
        parameterForSize = 2;
        
    end
    //disp(labelMain + " " + string(parameterForSize));  //<>debug only
    for i = 1 : 1 : size(inTablePart, parameterForSize)
        if parameterForSize == 1 then
            stringIndexesArray(size(stringIndexesArray, parameterForSize) + 1) = string(i);
        elseif parameterForSize == 2 then
            stringIndexesArray(1, size(stringIndexesArray, parameterForSize) + 1) = string(i);
        end
    end
    
endfunction

//function [outElements, outNumberOfDefaultElementToAdd, outAtIndex]=TableElementAdd_callback(handles, numberOfElements)
function [outElements]=TableElementAdd_callback(handles)
    
    outElements = [];
    //outNumberOfDefaultElementToAdd = [];
    //outAtIndex = [];
    //labelMain = [handles.Tag ; "(empty index and out of index mean that the element will be added at the end)"];
    labelMain = [handles.Tag];
    verticalLabel = [""];
    //horizontalLabel = ["number of new elements", "Index of insertion"];
    horizontalLabel = ["number of new elements"];
    //outDialog = ["1", ""];
    outDialog = ["1"];
    
    
    valueOK = %f;
    while valueOK == %f then
        
        //disp([labelMain ; numberOfElements ; outNumberOfDefaultElementToAdd ; outAtIndex])  //<>debug only
        
        //create the dialog depending on choice
        if strindex(convstr(labelMain(1), 'l'), "row") then
            
            outDialog = x_mdialog(labelMain, verticalLabel, horizontalLabel, outDialog);
            
        elseif strindex(convstr(labelMain(1), 'l'), "column") then
            
            outDialog = x_mdialog(labelMain, verticalLabel, horizontalLabel, outDialog);
            
        elseif strindex(convstr(labelMain(1), 'l'), "table") then
            
            outDialog = x_mdialog(labelMain, verticalLabel, horizontalLabel, outDialog);
            
        end
        
        
        if outDialog ~= [] then
            
            //delete spaces
            outDialog = strsubst(outDialog, " ", "");
            //change comma (',') to dot ('.')
            outDialog = strsubst(outDialog, ",", ".");
            
            //check if all values are numbers
            isNumberArray = isnum(outDialog);
            //if (outDialog(2) ~= emptystr() & and(isNumberArray) == %f) | (outDialog(2) == emptystr() & isNumberArray(1) == %f) then
            if and(isNumberArray) == %f then
                
                //if any value is not number show error message and repeat the cycle
                labelMain = [handles.Tag ; "All input values must be numbers!"];
                continue;
                
                
            else
                
                //set output parameters
                outNumberOfDefaultElementToAdd = evstr(outDialog(1));
                //outAtIndex = evstr(outDialog(2));
                
                
                //set the dialog labels depending on choice
                labelMain = [handles.Tag];
                if strindex(convstr(labelMain(1), 'l'), "row") then
                    
                    verticalLabel = emptystr(outNumberOfDefaultElementToAdd, 1);
                    verticalLabel(1:size(verticalLabel, 1), 1) = "Row Title";
                    horizontalLabel = ["Value"];
                    outElements = emptystr(outNumberOfDefaultElementToAdd, 1);
                    
                elseif strindex(convstr(labelMain(1), 'l'), "column") then
                    
                    verticalLabel = ["Value"];
                    horizontalLabel = emptystr(1, outNumberOfDefaultElementToAdd);
                    horizontalLabel(1, 1:size(horizontalLabel, 2)) = "Column Title";
                    outElements = emptystr(1, outNumberOfDefaultElementToAdd);
                    
                elseif strindex(convstr(labelMain(1), 'l'), "table") then
                    
                    verticalLabel = ["Value"];
                    horizontalLabel = emptystr(1, outNumberOfDefaultElementToAdd);
                    horizontalLabel(1, 1:size(horizontalLabel, 2)) = "Table Title";
                    outElements = emptystr(1, outNumberOfDefaultElementToAdd);
                    
                end
                
                //create new dialog and let a user to set specific values
                valueOKSub = %f;
                while valueOKSub == %f then
                    
                    outElements = x_mdialog(labelMain, verticalLabel, horizontalLabel, outElements);
                    
                    if outElements ~= [] then
                        
                        //delete spaces
                        outElements = strsubst(outElements, " ", "");
                        //change comma (',') to dot ('.')
                        outElements = strsubst(outElements, ",", ".");
                        
                        //check if all values are numbers
                        isNumberArray = isnum(outElements);
                        if and(isNumberArray) == %f then
                            //if any value is not number show error message and repeat the cycle
                            labelMain = [handles.Tag ; "All input values must be numbers!"];
                            continue;
                        end
                        
                        //everything should be OK
                        valueOKSub = %t;
                        
                        
                    else
                        
                        //set empty output parameters
                        //outNumberOfDefaultElementToAdd = [];
                        //outAtIndex = [];
                        break;
                        
                    end
                    
                    
                end
                
                
            end
            
            //everything should be OK
            valueOK = %t;
            
        else
            
            break;
            
        end
    
    end
    
    
    
endfunction


function [outTable]=TableElementEdit_callback(handles, inTable)
    
    //disp([inTable])  //<>debug only
    outTable = inTable;
    //outTable = GetSpecificPartOfTable(handles, inTable);
    //disp([outTable])  //<>debug only
    stringIndexes = GetSpecificStringIndexesForMDialog(handles, outTable);
    //disp([stringIndexes])  //<>debug only
    labelMain = handles.Tag;
    
    
    valueOK = %f;
    while valueOK == %f then
        
        //disp([inTable ; outTable ; stringIndexes])  //<>debug only
        
        //create the dialog depending on choice
        if strindex(convstr(labelMain(1), 'l'), "row") then
            
            outTable = x_mdialog(labelMain, stringIndexes, ["Rows"], outTable);
            
        elseif strindex(convstr(labelMain(1), 'l'), "column") then
            
            outTable = x_mdialog(labelMain, ["Columns"], stringIndexes, outTable);
            
        elseif strindex(convstr(labelMain(1), 'l'), "table") then
            
            outTable = x_mdialog(labelMain, ["Tables"], stringIndexes, outTable);
            
        end
        
        
        if outTable ~= [] then
            
            //delete spaces
            outTable = strsubst(outTable, " ", "");
            //change comma (',') to dot ('.')
            outTable = strsubst(outTable, ",", ".");
            
            //check if all values are numbers
            isNumberArray = isnum(outTable);
            if and(isNumberArray) == %f then
                //if any value is not number show error message and repeat the cycle
                labelMain = [handles.Tag ; "All input values must be numbers!"];
                continue;
            end
            
            //everything should be OK
            valueOK = %t;
            
        else
            
            break;
            
        end
    
    end
    
    
    
    
endfunction


function [trueFalseMatrix]=GetDefaultTrueFalseMatrix(row, column)
    
    trueFalseMatrix = [];
    if row > 0 & column > 0 then
        trueFalseMatrix = emptystr(row, column);
        trueFalseMatrix(1:size(trueFalseMatrix, 1), 1:size(trueFalseMatrix, 2)) = "%f";
    end
    
endfunction


function [indexesToDelete]=TableElementDelete_callback(handles, inTable)
    
    indexesToDelete = [];
    //partTable = GetSpecificPartOfTable(handles, inTable);
    stringIndexes = GetSpecificStringIndexesForMDialog(handles, inTable);
    labelsWithIndexAndTitle = "(" + string(stringIndexes(1:size(stringIndexes, 1), 1:size(stringIndexes, 2))) + ") " + inTable(1:size(inTable, 1), 1:size(inTable, 2));
    trueFalseMatrix = GetDefaultTrueFalseMatrix(size(stringIndexes, 1), size(stringIndexes, 2));
    labelMain = handles.Tag;
    
    //disp([inTable ; labelsWithIndexAndTitle ; outTrueFalseMatrix])  //<>debug only
    
    //create the dialog depending on choice
    parameterForSize = 0;
    if strindex(convstr(labelMain(1), 'l'), "row") then
        
        parameterForSize = 1;
        trueFalseMatrix = x_mdialog(labelMain, labelsWithIndexAndTitle, ["Delete Selected Rows"], trueFalseMatrix);
        
    elseif strindex(convstr(labelMain(1), 'l'), "column") then
        
        parameterForSize = 2;
        trueFalseMatrix = x_mdialog(labelMain, ["Delete Selected Columns"], labelsWithIndexAndTitle, trueFalseMatrix);
        
    elseif strindex(convstr(labelMain(1), 'l'), "table") then
        
        parameterForSize = 2;
        trueFalseMatrix = x_mdialog(labelMain, ["Delete Selected Tables"], labelsWithIndexAndTitle, trueFalseMatrix);
        
    end
    
    
    if trueFalseMatrix ~= [] then
        
        //convert true and false string to Scilab booleans
        trueFalseMatrix = evstr(trueFalseMatrix);
        //if there is request to delete a element
        if or(trueFalseMatrix) == %t then
            
            answerMessage = messagebox(["Are you sure?" ; "Warning: The selected elements will be deleted"], "Delete Selected Elements", "question", ["Yes" "No"], "modal");
            if answerMessage == 1 then
                
                for i = 1 : 1 : size(trueFalseMatrix, parameterForSize)
                    
                    if trueFalseMatrix(i) == %t then
                        
                        indexesToDelete(size(indexesToDelete, 1) + 1) = i;
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    
    
endfunction



function [outTableTitleString]=GetTableTitle(tabUIcontrol, indexTable)
    
    outTableTitleString = [];
    if length(tabUIcontrol.children) >= indexTable & indexTable > 0 then
        
        outTableTitleString = tabUIcontrol.children(indexTable).string;
        
    else
        
        //<>debug only
        disp("Out of index in GetTableTitle in DialogsFunctions.sci");
        
    end
    
endfunction

function [outTableTitleArray]=GetTableTitles(tabUIcontrol, getReversed)
    
    outTableTitleArray = [];
    for i = 1 : 1 : length(tabUIcontrol.children)
        
        //<>two list logics
        if getReversed then
            outTableTitleArray(1, size(outTableTitleArray, 2) + 1) = GetTableTitle(tabUIcontrol, length(tabUIcontrol.children) - (i - 1));    //when new string table elements are added by using (0) to list
        else
            outTableTitleArray(1, size(outTableTitleArray, 2) + 1) = GetTableTitle(tabUIcontrol, i); //when new string table elements are added by using ($+1) to list
        end
        
    end
    
endfunction


function SetTableTitle(tabUIcontrol, inputTableTitleString, indexTable)
    
    if length(tabUIcontrol.children) >= indexTable & indexTable > 0 then
        
        tabUIcontrol.children(indexTable).string = inputTableTitleString;
        
    else
        
        //<>debug only
        disp("Out of index in SetTableTitle in DialogsFunctions.sci");
        
    end
    
endfunction

function ChangeAllTableTitles(tabUIcontrol, inputTableTitleArray)
    
    for i = 1 : 1 : length(tabUIcontrol.children)
        
        SetTableTitle(tabUIcontrol, inputTableTitleArray(i), i)
        
    end
    
endfunction


function [isUnique]=IsUniqueFrameTag(tabUIcontrol, inputTag)
    
    isUnique = %t;
    for i = 1 : 1 : length(tabUIcontrol.children)
        
        if tabUIcontrol.children(i) == inputTag then
            isUnique = %f;
        end
        
    end
    
endfunction

function AddTableWithTitle(tabUIcontrol, inputTableTitle, inputTableString)
    
    //create frame tag
    frameTag = "frame_" + inputTableTitle;
    //check if the frame tag is unique, and if not add number at the end of the tag
    count = 1;
    while IsUniqueFrameTag(tabUIcontrol, frameTag) == %f
        count = count + 1;
        frameTag = frameTag + "_" + string(count);
    end
    
    
    frame = uicontrol(tabUIcontrol, "style", "frame", ...
                        "Tag", frameTag,..
                        "string", inputTableTitle,..
                        "layout", "grid");
                        //"constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0.5], "both")
    
    tableTag = frameTag + "_table";
    table = uicontrol(frame, "style", "table",..
                   "Tag", tableTag,..
                   "string", inputTableString,..
                   "tooltipstring", "Data from table: """ + inputTableTitle + """",..
                   "FontSize", 14)
                   //"constraints", createConstraints("gridbag", [1 2 2 1], [1 0], "both"),..
    
endfunction



function [outStringTable]=DeleteRowAtIndex(stringTable, indexRow)
    
    outStringTable = stringTable;
    if size(outStringTable, 1) >= indexRow & indexRow > 0 then
        
        //disp(stringTable(indexRow, 1));   //<>debug only
        outStringTable(indexRow, :) = [];
        
    else
        
        //<>debug only
        disp("Out of index in DeleteRowAtIndex in DialogsFunctions.sci");
        
    end
    
endfunction

function [outStringTable]=DeleteRowsAtIndexes(stringTable, indexRowArray)
    
    outStringTable = stringTable;
    for i = 1 : 1 : size(indexRowArray, 1)
        
        indexSubtraction = 0;
        for j = 1 : 1 : i - 1
            
            if indexRowArray(j) < indexRowArray(i) then
                indexSubtraction = indexSubtraction - 1;
            end
            
        end
        
        
        if size(outStringTable, 1) > 2 then
            outStringTable = DeleteRowAtIndex(outStringTable, indexRowArray(i) + indexSubtraction);
        else
            messagebox("At least one row has to exist!", "Delete Failed!", "error");
        end
        
    end
    
endfunction



function [outStringTable]=DeleteColumnAtIndex(stringTable, indexColumn)
    
    outStringTable = stringTable;
    if size(outStringTable, 2) >= indexColumn & indexColumn > 0 then
        
        //disp(stringTable(1, indexColumn));   //<>debug only
        outStringTable(:, indexColumn) = [];
        
    else









        
        //<>debug only
        disp("Out of index in DeleteColumnAtIndex in DialogsFunctions.sci");
        
    end
    
endfunction

function [outStringTable]=DeleteColumnsAtIndexes(stringTable, indexColumnArray)
    
    outStringTable = stringTable;
    for i = 1 : 1 : size(indexColumnArray, 1)
        
        indexSubtraction = 0;
        for j = 1 : 1 : i - 1
            
            if indexColumnArray(j) < indexColumnArray(i) then
                indexSubtraction = indexSubtraction - 1;
            end
            
        end
        
        
        if size(outStringTable, 2) > 2 then
            outStringTable = DeleteColumnAtIndex(outStringTable, indexColumnArray(i) + indexSubtraction);
        else
            messagebox("At least one column has to exist!", "Delete Failed!", "error");
        end
        
    end
    
endfunction


function DeleteTableAtIndex(tabUIcontrol, indexTable)
    
    if length(tabUIcontrol.children) >= indexTable & indexTable > 0 then
        
        //disp(tabUIcontrol.children(indexTable).string);   //<>debug only
        delete(tabUIcontrol.children(indexTable));
        //if value index of selected table is higher than the deleted table, decrease value index
        if tabUIcontrol.value > length(tabUIcontrol.children) | tabUIcontrol.value > indexTable  then
            tabUIcontrol.value = tabUIcontrol.value - 1;
        end
        
    else
        
        //<>debug only
        disp("Out of index in DeleteTableAtIndex in DialogsFunctions.sci");
        
    end
    
endfunction

function DeleteTablesAtIndexes(tabUIcontrol, indexTableArray)
    
    for i = 1 : 1 : size(indexTableArray, 1)
        
        indexSubtraction = 0;
        for j = 1 : 1 : i - 1
            
            if indexTableArray(j) < indexTableArray(i) then
                indexSubtraction = indexSubtraction - 1;
            end
            
        end
        
        
        if length(tabUIcontrol.children) > 1 then
            DeleteTableAtIndex(tabUIcontrol, indexTableArray(i) + indexSubtraction);
        else
            messagebox("At least one table has to exist!", "Delete Failed!", "error");
        end
    end
    
endfunction

//    
//function Table_callback(handles)
//    
//    xc = -1;
//    yc = -1;
//    ibutton = -1;
//    winId = -1;
//    
//    while ibutton ==-1 do // mouse just moving ...
//        
//        [rep, winId]=xgetmouse();
//        xc = rep(1);
//        yc = rep(2);
//        ibutton = rep(3);
//        disp("Clicked on Table:\nxc: " + string(xc) + "\nyc: " + string(yc) + "\nibutton: " + string(ibutton) + "\nwinId: " + string(winID) + "\n");
//        
//    end
//    
//endfunction
//  
//
//function Mouse_eventhandler(win, x, y, ibut)
//    
//    if ibut==-1000 then
//        return;
//    end
//    
//    [x,y]=xchange(x, y, 'i2f');
//    disp(msprintf('Event code %d at mouse position is (%f,%f)', ibut, x, y));
//      
//endfunction
//
    //set event handler which checks mouse interaction
    //seteventhandler('Mouse_eventhandler');
//    
    
    
    
    tableStringMatrices = inputTableStringMatrices;
    tableTitleArray = inputTableTitleArray;
    outPropertyRow = inputPropertyRow;
    outPropertyColumn = inputPropertyColumn;
    outPropertyTable = inputPropertyTable;
    
    
    
//    //<>debug only
//    tableStringMatrices = [];
//    tableTitleArray = [""];
//    outPropertyRow = "";
//    outPropertyColumn = "";
//    outPropertyTable = "";
//    //include files with functions which we use
//    exec XMLfunctions.sci;
//    exec TXTfunctions.sci;
//    propertiesAvailable = ReadInternalAndCustomProperties();
//    //global properties
//    global defaultColumnValue;
//    defaultColumnValue = "0";
//    global defaultRowValue;
//    defaultRowValue = "0";
//    global defaultTableString;
//    defaultTableString = [[" " ""] ; ["0" "0"]];
//    
//    //<>debug only
//    // Include an editable table into a figure:
//    // Decode table data:
//    params = [" " "Country" "Population [Mh]" "Temp.[°C]" ];
//    towns = ["Mexico" "Paris" "Tokyo" "Singapour"]';
//    country = ["Mexico" "France" "Japan" "Singapour"]';
//    pop  = string([22.41 11.77 33.41 4.24]');
//    temp = string([26 19 22 17]');
//    inputTableStringMatrices = list([params; towns country pop temp ], [params; towns country pop temp ], defaultTableString);
//    //add new row with empty strings to matrix
//    inputTableStringMatrices(2)(size(inputTableStringMatrices(2), 1) + 1, :) = emptystr(1, size(inputTableStringMatrices(2), 2));
//    inputTableStringMatrices(2)(size(inputTableStringMatrices(2), 1), 1) = "novy radek";
//    //add new column with empty strings to matrix
//    inputTableStringMatrices(2)(:, size(inputTableStringMatrices(2), 2) + 1) = emptystr(size(inputTableStringMatrices(2), 1), 1);
//    inputTableStringMatrices(2)(1, size(inputTableStringMatrices(2), 2)) = "novy sloupec";
//    inputTableTitleArray = ["1" "2" "3"];
    
    
    
    rowTitlesTemp = [];
    columnTitlesTemp = [];
    tableTitlesTemp = [];
    
    
    TableDialogID = 88888888;
    figTableDialog = figure(TableDialogID, 'figure_position', [250, 150], "menubar", "none");
    clf(TableDialogID);
    //f.axes_size = [200 200];
    //as = f.axes_size;  // [width height]
    figTableDialog.default_axes = "off";
    figTableDialog.dockable = "off";
    figTableDialog.figure_name = "Table Creation Dialog";
    figTableDialog.infobar_visible = "off";
    figTableDialog.toolbar = "none";
    figTableDialog.toolbar_visible = "off";
    //figTableDialog.resizefcn:    This field can be used to store the name of a Scilab function or a Scilab expression as a character string. This character string will be evaluated whenever the user resizes the figure and when the figure is created.
    //figTableDialog.resize = "off";
    figTableDialog.layout = "gridbag";
    //figTableDialog.layout_options = createLayoutOptions("grid", [2, 2]);
    
    
    
    //show and adjust menu
    figTableDialog.menubar_visible = "on";
    
//    //because of "menubar", "none" property, the menus don't have to be deleted; i.e. there are no menus
//    //delete default menu items
//    delmenu(f.figure_id, 'File');
//    delmenu(f.figure_id, 'Tools');
//    delmenu(f.figure_id, 'Edit');
//    delmenu(f.figure_id, '?');
    
    
    //add main menu items
    RowMenu = uimenu(figTableDialog, 'label', 'Row',  'tag', 'Row');
    ColumnMenu = uimenu(figTableDialog, 'label', 'Column',  'tag', 'Column');
    TableMenu = uimenu(figTableDialog, 'label', 'Table',  'tag', 'Table');
    
    //create items on the menu bars
    //create sub menu for property setting
    RowMenuProperty = uimenu(RowMenu,  'label', 'Property',  'tag', 'Row Property',  'callback', "outPropertyRow=PropertySet_callback(handles, outPropertyRow, propertiesAvailable)");
    ColumnMenuProperty = uimenu(ColumnMenu,  'label', 'Property',  'tag', 'Column Property',  'callback', "outPropertyColumn=PropertySet_callback(handles, outPropertyColumn, propertiesAvailable)");
    TableMenuProperty = uimenu(TableMenu,  'label', 'Property',  'tag', 'Table Property',  'callback', "outPropertyTable=PropertySet_callback(handles, outPropertyTable, propertiesAvailable)");
    
//    RowMenuAdd = uimenu(RowMenu,  'label', 'Add',  'tag', 'Add Row',  'callback', "rowTitlesTemp=TableElementAdd_callback(handles, GetSpecificPartOfTable(handles, tab.children(tab.value).children(1).string))");
//    ColumnMenuAdd = uimenu(ColumnMenu,  'label', 'Add',  'tag', 'Add Column',  'callback', "columnTitlesTemp=TableElementAdd_callback(handles, GetSpecificPartOfTable(handles, tab.children(tab.value).children(1).string))");
//    TableMenuAdd = uimenu(TableMenu,  'label', 'Add',  'tag', 'Add Table',  'callback', "tableTitlesTemp=TableElementAdd_callback(handles, GetTableTitles(tab, %f))");
    RowMenuAdd = uimenu(RowMenu,  'label', 'Add',  'tag', 'Add Row',  'callback', "rowTitlesTemp=TableElementAdd_callback(handles)");
    ColumnMenuAdd = uimenu(ColumnMenu,  'label', 'Add',  'tag', 'Add Column',  'callback', "columnTitlesTemp=TableElementAdd_callback(handles)");
    TableMenuAdd = uimenu(TableMenu,  'label', 'Add',  'tag', 'Add Table',  'callback', "tableTitlesTemp=TableElementAdd_callback(handles)");
    
    RowMenuEdit = uimenu(RowMenu,  'label', 'Edit',  'tag', 'Edit Row Title',  'callback', "rowTitlesTemp=TableElementEdit_callback(handles, GetSpecificPartOfTable(handles, tab.children(tab.value).children(1).string))");
    ColumnMenuEdit = uimenu(ColumnMenu,  'label', 'Edit',  'tag', 'Edit Column Title',  'callback', "columnTitlesTemp=TableElementEdit_callback(handles, GetSpecificPartOfTable(handles, tab.children(tab.value).children(1).string))");
    TableMenuEdit = uimenu(TableMenu,  'label', 'Edit',  'tag', 'Edit Table Title',  'callback', "tableTitlesTemp=TableElementEdit_callback(handles, GetTableTitles(tab, %f))");
    
    RowMenuDel = uimenu(RowMenu,  'label', 'Delete',  'tag', 'Delete Row',  'callback', "rowTitlesTemp=TableElementDelete_callback(handles, GetSpecificPartOfTable(handles, tab.children(tab.value).children(1).string))");
    ColumnMenuDel = uimenu(ColumnMenu,  'label', 'Delete',  'tag', 'Delete Column',  'callback', "columnTitlesTemp=TableElementDelete_callback(handles, GetSpecificPartOfTable(handles, tab.children(tab.value).children(1).string))");
    TableMenuDel = uimenu(TableMenu,  'label', 'Delete',  'tag', 'Delete Table',  'callback', "tableTitlesTemp=TableElementDelete_callback(handles, GetTableTitles(tab, %f))");
    
    
    
    //<>debug only
    //c = get(0);
    //set(c, "ShowHiddenProperties", "on");
    
    //tabStrings = "tab1"//["tab1" "tab2"]';
    tab = uicontrol(figTableDialog, "style", "tab",..
               "Tag", "tab1",..
               "Title_position", "top",..
               "Title_scroll", "on",..
               "constraints", createConstraints("gridbag", [1 1 2 1], [1 1], "both", "center", [0 0]),..
               "FontSize", 12,..
               "tooltipstring", "tabs")
               //"position",[5 5 f.figure_size(1) f.figure_size(2)],..
               //"callback", "Table_callback(handles)", ..
               //"callback", "messagebox(""clicked on tab"")", ..
               //"String", tabStrings,..
               //"String", ["asdf|fsad"],..
               //"Value", 1,..
               //"String", "tabFrame1",..
    
    
    
    //create OK and Cancel button
    OKButton = uicontrol(figTableDialog, "style", "pushbutton", ...
                    "string", "OK", ...
                    "callback", "[tableStringMatrices, tableTitleArray]=TableOK_callback(handles, tab, outPropertyRow, outPropertyColumn, outPropertyTable, propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "OKButton",..
                    "constraints", createConstraints("gridbag", [1 2 1 1], [1 0], "vertical", "right", [0 0]));
                    
    CancelButton = uicontrol(figTableDialog, "style", "pushbutton", ...
                    "string", "Cancel", ...
                    "callback", "[tableStringMatrices, tableTitleArray]=TableCancel_callback(handles)", ...
                    "fontsize", 15, ...
                    "Tag", "CancelButton",..
                    "constraints", createConstraints("gridbag", [2 2 1 1], [1 0], "vertical", "left"));
    
    
    
    //create tables with data and set them to tab
    for i = 1 : 1 : length(inputTableStringMatrices)
        
        AddTableWithTitle(tab, inputTableTitleArray(i), inputTableStringMatrices(i));
        
    end
    
    
    
    //wait until is clicked
    ibutton = -1;
    iwin = -1;
    //while the current window is not closed
    while(ibutton ~= -1000 | iwin ~= figTableDialog.figure_id)
        
        //wait until is clicked
        [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
        
//        //<>debug only
//        disp("Opened window is still alive!");
//        disp(string(ibutton));
//        disp(string(xcoord));
//        disp(string(ycoord));
//        disp(string(iwin));
//        disp(string(cbmenu));
        
        //check if some callback was clicked
        if ibutton == -2 then
            
            
            //if OK was clicked, execute OK callback
            if strindex(cbmenu, OKButton.callback) then
                
                //disp("OK clicked"); //<>debug only
                handles = OKButton;
                execstr(OKButton.callback);
                
                //if there is output with all tables, break this cycle
                if tableStringMatrices ~= [] then
                    break;
                end
                
                
                
            //else if Cancel was clicked, execute Cancel callback
            elseif strindex(cbmenu, CancelButton.callback) then
                
                //disp("Cancel clicked"); //<>debug only
                handles = CancelButton;
                execstr(CancelButton.callback);
                break;
                
                
                
            //else if one of the property change menus was clicked
            elseif strindex(cbmenu, RowMenuProperty.callback) then
                
                //disp("RowMenuProperty clicked"); //<>debug only
                handles = RowMenuProperty;
                execstr(RowMenuProperty.callback);
                
                
            elseif strindex(cbmenu, ColumnMenuProperty.callback) then
                
                //disp("ColumnMenuProperty clicked"); //<>debug only
                handles = ColumnMenuProperty;
                execstr(ColumnMenuProperty.callback);
                
                
            elseif strindex(cbmenu, TableMenuProperty.callback) then
                
                //disp("TableMenuProperty clicked"); //<>debug only
                handles = TableMenuProperty;
                execstr(TableMenuProperty.callback);
                
                
                
            //else if one of the add menus was clicked
            elseif strindex(cbmenu, RowMenuAdd.callback) then
                
                //disp("RowMenuAdd clicked"); //<>debug only
                handles = RowMenuAdd;
                execstr(RowMenuAdd.callback);
                rowTitlesTemp
                if rowTitlesTemp ~= [] then
                    global defaultRowValue;
                    for i = 1 : 1 : size(rowTitlesTemp, 1)
                        //add new row with title and default values to matrix
                        rowAdd = emptystr(1, size( tab.children(tab.value).children(1).string, 2 ));
                        rowAdd(1) = rowTitlesTemp(i);
                        rowAdd(2:size(rowAdd, 1), 1) = defaultRowValue;
                        tab.children(tab.value).children(1).string( size(tab.children(tab.value).children(1).string, 1) + 1, : ) = rowAdd;
                    end
                end
                
                
            elseif strindex(cbmenu, ColumnMenuAdd.callback) then
                
                //disp("ColumnMenuAdd clicked"); //<>debug only
                handles = ColumnMenuAdd;
                execstr(ColumnMenuAdd.callback);
                columnTitlesTemp
                if columnTitlesTemp ~= [] then
                    global defaultColumnValue;
                    for i = 1 : 1 : size(columnTitlesTemp, 2)
                        //add new column with title and default values to matrix
                        columnAdd = emptystr(size( tab.children(tab.value).children(1).string, 1 ), 1);
                        columnAdd(1) = columnTitlesTemp(i);
                        columnAdd(1, 2:size(columnAdd, 2)) = defaultColumnValue;
                        tab.children(tab.value).children(1).string( :, size(tab.children(tab.value).children(1).string, 2) + 1 ) = columnAdd;
                    end
                end
                
                
            elseif strindex(cbmenu, TableMenuAdd.callback) then
                
                //disp("TableMenuAdd clicked"); //<>debug only
                handles = TableMenuAdd;
                execstr(TableMenuAdd.callback);
                
                if tableTitlesTemp ~= [] then
                    global defaultTableString;
                    for i = 1 : 1 : size(tableTitlesTemp, 2)
                        AddTableWithTitle(tab, tableTitlesTemp(i), defaultTableString);
                    end
                end
                
                
                
            //else if one of the edit menus was clicked
            elseif strindex(cbmenu, RowMenuEdit.callback) then
                
                //disp("RowMenuEdit clicked"); //<>debug only
                handles = RowMenuEdit;
                execstr(RowMenuEdit.callback);
                
                if rowTitlesTemp ~= [] then
                    tab.children(tab.value).children(1).string( 2:size( tab.children(tab.value).children(1).string, 1 ), 1 ) = rowTitlesTemp;
                end
                
                
            elseif strindex(cbmenu, ColumnMenuEdit.callback) then
                
                //disp("ColumnMenuEdit clicked"); //<>debug only
                handles = ColumnMenuEdit;
                execstr(ColumnMenuEdit.callback);
                
                if columnTitlesTemp ~= [] then
                    tab.children(tab.value).children(1).string( 1, 2:size( tab.children(tab.value).children(1).string, 2 ) ) = columnTitlesTemp;
                end
                
                
            elseif strindex(cbmenu, TableMenuEdit.callback) then
                
                //disp("TableMenuEdit clicked"); //<>debug only
                handles = TableMenuEdit;
                execstr(TableMenuEdit.callback);
                
                if tableTitlesTemp ~= [] then
                    ChangeAllTableTitles(tab, tableTitlesTemp);
                end
                
                
                
            //else if one of the delete menus was clicked
            elseif strindex(cbmenu, RowMenuDel.callback) then
                
                //disp("RowMenuDel clicked"); //<>debug only
                handles = RowMenuDel;
                execstr(RowMenuDel.callback);
                
                if rowTitlesTemp ~= [] then
                    //increase indexes by 1 because in the dialog, only rows after the first are always displayed
                    rowTitlesTemp = rowTitlesTemp + 1;
                    tab.children(tab.value).children(1).string = DeleteRowsAtIndexes(tab.children(tab.value).children(1).string, rowTitlesTemp);
                end
                
                
            elseif strindex(cbmenu, ColumnMenuDel.callback) then
                
                //disp("ColumnMenuDel clicked"); //<>debug only
                handles = ColumnMenuDel;
                execstr(ColumnMenuDel.callback);
                
                if columnTitlesTemp ~= [] then
                    //increase indexes by 1 because in the dialog, only columns after the first are always displayed
                    columnTitlesTemp = columnTitlesTemp + 1;
                    tab.children(tab.value).children(1).string = DeleteColumnsAtIndexes(tab.children(tab.value).children(1).string, columnTitlesTemp);
                end
                
                
            elseif strindex(cbmenu, TableMenuDel.callback) then
                
                //disp("TableMenuDel clicked"); //<>debug only
                handles = TableMenuDel;
                execstr(TableMenuDel.callback);
                
                if tableTitlesTemp ~= [] then
                    DeleteTablesAtIndexes(tab, tableTitlesTemp);
                end
                
                
                
            end
            
            
            
        //else if the dialog was closed, it is same as when cancel button is clicked
        elseif ibutton == -1000 then
            
            //set empty values
            tableStringMatrices = [];
            tableTitleArray = [];
            outPropertyRow = emptystr();
            outPropertyColumn = emptystr();
            outPropertyTable = emptystr();
            break;
            
            
            
        end
        
    end
    //disp("The correct window was closed!"); //<>debug only
    
    
endfunction




function [propertyColumnIsRequired]=CheckIfPropertyColumnIsRequired(tableStringMatrices)
    
    propertyColumnIsRequired = %f;
    for i = 1 : 1 : length(tableStringMatrices)
    //for i = 1 : 1 : length(tabUIcontrol.children)
        
        //if there is at least one table with more than one column (overall two because the first colum contains row titles)
        if size(tableStringMatrices(i), 2) > 2 then
        //if size(tabUIcontrol.children(i).children(1).string, 2) > 2 then
            //column property is required
            propertyColumnIsRequired = %t;
            break;
        end
        
    end
    
endfunction


function [propertyTableIsRequired]=CheckIfPropertyTableIsRequired2(tableTitleArray)
    
    propertyTableIsRequired = %f;
    if size(tableTitleArray, 2) > 1 then
        propertyTableIsRequired = %t;
    end
    
endfunction



function [propertyIsOK]=CheckIfPropertyIsOK(inputProperty, isRequired, propertiesAvailable)
    
    propertyIsOK = %f;
    propertyNameWithoutSpaces = strsubst(inputProperty, " ", "");
    //if the property is not required, it can be empty
    if propertyNameWithoutSpaces == emptystr() & isRequired == %f then
        
        propertyIsOK = %t;
        
    else
        
        //try to find the property in property database
        propertyFound = FindPropertyInPropertiesAvailable(propertyNameWithoutSpaces, propertiesAvailable);
        if propertyFound then
            
            propertyIsOK = %t;
            
        end
        
    end
    
endfunction



function [isNumber, higherOrEqualValue, outNumber, errorString]=CheckIfNumberHigherOrEqualAndConvert(inputStringNumber, higherOrEqualSwitch, conditionValue)
    
    errorString = emptystr();
    higherOrEqualValue = %f;
    outNumber = [];
    
    //if the input string is number
    isNumber = isnum(inputStringNumber);
    if isNumber then
        
        //convert string to number, if it successful, check value
        convertedNumber = strtod(inputStringNumber);
        if string(convertedNumber) ~= "Nan" then
            
            outNumber = convertedNumber;
            
            if higherOrEqualSwitch == %f then
                if outNumber > conditionValue then
                    higherOrEqualValue = %t;
                else
                    errorString = "The input string has to be higher than """ + string(conditionValue) + """!  """ + inputStringNumber + """" + "  converted value: """ + string(outNumber) + """";
                end
            else
                if outNumber == conditionValue then
                    higherOrEqualValue = %t;
                else
                    errorString = "The input string has to be equal to """ + string(conditionValue) + """!  """ + inputStringNumber + """" + "  converted value: """ + string(outNumber) + """";
                end
            end
            
        elseif (convstr(strsubst(inputStringNumber, " ", ""), "l") == "%inf" & higherOrEqualSwitch == %f)   |   (((convstr(strsubst(inputStringNumber, " ", ""), "l") == "%inf" & conditionValue == %inf)  |  (convstr(strsubst(inputStringNumber, " ", ""), "l") == "-%inf" & conditionValue == -%inf))  &  higherOrEqualSwitch == %t) then
            higherOrEqualValue = %t;
            outNumber = %inf;
            if conditionValue == -%inf then
                outNumber = -%inf;
            end
        else
            errorString = "The input string was not converted properly to number!  """ + inputStringNumber + """";
        end
        
    else
        errorString = "The input string does not contain number! """ + inputStringNumber + """";
    end
    
    
endfunction



function [outEventUItext]=FindUIControlInFrame(frameEvent, tagValue, styleValue)
    
    outEventUItext = [];
    for i = 1 : 1 : length(frameEvent.children)
        if frameEvent.children(i).tag == tagValue & frameEvent.children(i).style == styleValue then
            outEventUItext = frameEvent.children(i);
            //messagebox(["UIControl found!" ; "Tag: " + outEventUItext.tag ; "Style: " + outEventUItext.style ]); //<>debug only
            break;
        end
    end
    
endfunction





//
//function [dialogGUI]=DialogSpecialOkCancelCreate(dialogInputTemplate)
//    
//    f = figure("default_axes", "off", ...
//              "dockable", "off", ...
//               "figure_name", "Sélection", ...
//               "axes_size", [200 200], ...
//               "infobar_visible", "off", ...
//               "menubar_visible", "off", ...
//               "toolbar", "none", ...
//               "toolbar_visible", "off", ...
//               "layout", "gridbag");
//               
//    h1 = uicontrol(f, "style", "text", ...
//                    "string", "Following List :", ...
//                    "fontsize", 15, ...
//                    "constraints", createConstraints("gridbag", [1 1 2 1], [1 0], "both"));
//                    
//    h2 = uicontrol(f, "style", "popupmenu", ...
//                    "string", ["item1"; "item2"; "item3"], ...
//                    "value", 1, ...
//                    "fontsize", 15, ...
//                    "constraints", createConstraints("gridbag", [1 2 2 1], [1 0], "both"), ...
//                    "tag", "selection");
//                    
//    h3 = uicontrol(f, "style", "pushbutton", ...
//                    "string", "OK", ...
//                    "callback", "obj = findobj(""tag"", ""selection""); mprintf(""La valeur sélectionnée est : %s.\n"", obj.string(obj.value)); close(gcf())", ...
//                    "fontsize", 15, ...
//                    "constraints", createConstraints("gridbag", [1 3 1 1], [1 0], "both", "left"));
//                    
//    h4 = uicontrol(f, "style", "pushbutton", ...
//                    "string", "CANCEL", ...
//                    "callback", "close(gcf())", ...
//                    "fontsize", 15, ...
//                    "constraints", createConstraints("gridbag", [2 3 1 1], [1 0], "both", "right"));
//                    
//    saveGui(f, "TMPDIR/foo2.xml");
//    close(f)
//    loadGui("TMPDIR/foo2.xml")
//    
//    
//    
//endfunction
//
//
//
//function [dialogGUI]=DialogOverlapUIcontrolInX_MDialog()
//    
//    //(usecanvas)
//    // Example using GLJPanel (Mixing uicontrols and graphics is available)
//    usecanvas(%F);
//    plot2d();
//    uicontrol("String", "Close the window", "Position", [10 10 100, 25], "Callback", "delete(gcf())");
//    messagebox("You can see the button on the figure.", "Usecanvas example", "info");
//    
//    // Example using GLCanvas (Mixing uicontrols and graphics is not available, uicontrols are not visible)
//    usecanvas(%T);
//    plot2d();
//    uicontrol("String", "Close the window", "Position", [10 10 100, 25], "Callback", "delete(gcf())");
//    messagebox("You can''t see any button on the figure.", "Usecanvas example", "info");
//    
//    
//endfunction
//






////global properties
global EventEventLabel;
EventEventLabel = "event";
global EventNameLabel;
EventNameLabel = "name";
global EventPersistentLabel;
EventPersistentLabel = "persistent";
global EventContinuousLabel;
EventContinuousLabel = "continuous";
global EventDescriptionLabel;
EventDescriptionLabel = "description";
global EventConditionLabel;
EventConditionLabel = "condition";
global EventDelayLabel;
EventDelayLabel = "delay";
global EventSetLabel;
EventSetLabel = "set";
global EventNotifyLabel;
EventNotifyLabel = "notify";

global frameEventBeginningTag;
frameEventBeginningTag = "frame_" + EventEventLabel + "_";


//simulation definition dialog functions
function [outXmlSimulation, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=DialogSimulationDefinitionOkCancel(inXmlSimulation, inXmlResetFilePath, inXmlResetFileName, inXmlAircraftFilePath, inXmlAircraftFileName, propertiesAvailable)
    
    
function [outXmlSimulation]=SimulationDefinitionOK_callback(handles, frameMain, descritionTextMainStringArray, xmlAircraftFilePath, xmlAircraftFileName, xmlResetFilePath, xmlResetFileName, runStartTextStringNumber, runEndTextStringNumber, run_dtTextStringNumber, runPropertyTextStringArray, inTableXMLElementsList, propertiesAvailable)
    
    
    outXmlSimulation = [];
    //error string for all errors which may occur
    errorString = [];
    
    
    
    
    //check if aircraft file exists and is in correct format, if it is not, add aircraft path error string to the main error string
    errorStringAircraft = CheckXMLJSBSimFileFormat(xmlAircraftFilePath, "aircraft", "fdm_config");
    if errorStringAircraft ~= emptystr() then
        errorString(size(errorString, 1) + 1) = errorStringAircraft;
    end
    
    
    
    //check if reset file exists and is in correct format, if it is not, add reset path error string to the main error string
    errorStringReset = CheckXMLJSBSimFileFormat(xmlResetFilePath, "reset", "initialize");
    if errorStringReset ~= emptystr() then
        errorString(size(errorString, 1) + 1) = errorStringReset;
    end
    
    
    
    
    //check start, end, dt values and add error string if necessary
    [isNumberRunStart, higherThanZeroRunStart, outNumberRunStart, errorStringRunStart] = CheckIfNumberHigherOrEqualAndConvert(runStartTextStringNumber, %t, 0);
    if errorStringRunStart ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Run Start: " + errorStringRunStart;
    end
    [isNumberRunEnd, higherThanZeroRunEnd, outNumberRunEnd, errorStringRunEnd] = CheckIfNumberHigherOrEqualAndConvert(runEndTextStringNumber, %f, 0);
    if errorStringRunEnd ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Run End: " + errorStringRunEnd;
    end
    [isNumberRun_dt, higherThanZeroRun_dt, outNumberRun_dt, errorStringRun_dt] = CheckIfNumberHigherOrEqualAndConvert(run_dtTextStringNumber, %f, 0);
    if errorStringRun_dt ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Run dt: " + errorStringRun_dt;
    end
    
    
    //check time numbers and compare with each other
    //check start and end time numbers
    if outNumberRunStart ~= [] & outNumberRunEnd ~= [] then
        if outNumberRunStart >= outNumberRunEnd then
            errorString(size(errorString, 1) + 1) = "Run start time has to be lower than Run end time!  Run start: " + string(outNumberRunStart) + "  Run end: " + string(outNumberRunEnd);
        end
    end
    
    //check dt and end time numbers
    if outNumberRun_dt > outNumberRunEnd then
        errorString(size(errorString, 1) + 1) = "Run dt time has to be lower than or equal to Run end time!  Run dt: " + string(outNumberRun_dt) + "  Run end: " + string(outNumberRunEnd);
    end
    
    
    
    
    
    //check property definition string array, if not correct add error messages
    outPropertiesAvailable = propertiesAvailable;
    for i = 1 : 1 : size(runPropertyTextStringArray, 2)
        
        propertyDefinitionStringWithoutSpaces = strsubst(runPropertyTextStringArray(i), " ", "");
        
        if propertyDefinitionStringWithoutSpaces ~= emptystr() then
            
            //separate string to two (or more) parts with new unique property on the left side and a value (number) on the right side
            propertyDefinitionParts = tokens(propertyDefinitionStringWithoutSpaces, "=");
            //if there is only one or exactly two parts, the main format of string is correct
            if size(propertyDefinitionParts, 1) == 1 | size(propertyDefinitionParts, 1) == 2 then
                
//                //this part of code was noted because several JSBSim scripts define properties which were already created (e.g. JSBSim properties) and scripts work; thus, it is probably possible to do that without errors
//                //try to find the property name in property list available, if it is not found the new property may be created
//                isCorrect = CheckCorrectValueType(propertyDefinitionParts(1), "property", outPropertiesAvailable, %f);
//                //isFound = FindPropertyInPropertiesAvailable(strsubst(propertyDefinitionParts(1), " ", ""), outPropertiesAvailable);
//                if isCorrect == %f then
                    if size(propertyDefinitionParts, 1) == 2 then
                        
                        isNumber = isnum(propertyDefinitionParts(2));
                        if isNumber == %f then
                            errorString(size(errorString, 1) + 1) = "Wrong format! The right side of the property definition has to contain number!  """ + propertyDefinitionParts(2) + """";
                        end
                        
                    end
                    
                    //add new property name to the properties available
                    outPropertiesAvailable(size(outPropertiesAvailable, 1) + 1) = propertyDefinitionParts(1);
                    
                    
//                else
//                    errorString(size(errorString, 1) + 1) = "The property: """ + propertyDefinitionParts(1) + """ was found in global property definition! (it has been created already and cannot be overrided)";
//                end
                
            else
                errorString(size(errorString, 1) + 1) = "Wrong format! The current line of property definition is not in correct format (too many ''='')!  """ + runPropertyTextStringArray(i) + """";
            end
            
        end
        
    end
    
    
    
    
    
    //get all event frames with event uicontrols
    global frameEventBeginningTag;
    frameEventList = list();
    for i = 1 : 1 : length(frameMain.children)
        
        //if the current uicontrol is frame with OK and Cancel button, break the cycle
        if frameMain.children(i).tag == "frameOKCancel" then
            break;
        //else if tag of the uicontrol contains the beggining of the frame event tag
        elseif strindex(frameMain.children(i).tag, frameEventBeginningTag) ~= [] then
            frameEventList($+1) = frameMain.children(i);
        end
        
    end
    
    
    
    
    global EventNameLabel;
    global EventPersistentLabel;
    global EventContinuousLabel;
    global EventDescriptionLabel;
    global EventConditionLabel;
    global EventDelayLabel;
    global EventSetLabel;
    global EventNotifyLabel;
    eventLabelList = list();
    //get event data from uicontrols of the event frame
    eventListListString = list();
    for i = length(frameEventList) : -1 : 1
        
        frameEvent = frameEventList(i);
        eventListString = list();
        
        
        outEventNameUIText = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventNameLabel + "_text", "edit");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventNameUIText, %f);
        
        outEventPersistentUICheckBox = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventPersistentLabel + "_checkbox", "checkbox");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventPersistentUICheckBox, %t);
        
        outEventContinuousUICheckBox = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventContinuousLabel + "_checkbox", "checkbox");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventContinuousUICheckBox, %t);
        
        outEventDescriptionUIText = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventDescriptionLabel + "_text", "edit");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventDescriptionUIText, %f)';
        
        outEventConditionUIText = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventConditionLabel + "_text", "edit");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventConditionUIText, %f);
        
        outEventDelayUIText = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventDelayLabel + "_text", "edit");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventDelayUIText, %f);
        
        outEventSetUIText = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventSetLabel + "_text", "edit");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventSetUIText, %f)';
        
        outEventNotifyUIText = FindUIControlInFrame(frameEvent, frameEvent.Tag + "_" + EventNotifyLabel + "_text", "edit");
        eventListString($+1) = GetStringOrCheckBoxValueFromUIControl(outEventNotifyUIText, %f)';
        
        
        eventListListString($+1) = eventListString;
        
        
        //get event label (it should be the first uicontrol which was added and the last in children list)
        eventLabelList($+1) = frameEvent.children(length(frameEvent.children)).string;
        
        
    end
    
    
    
    
    eventNamesList = list();
    //check validity of all event values
    for i = 1 : 1 : length(eventListListString)
        
        
        frameEvent = eventListListString(i);
        
        
        //check if event name is correctly set
        eventName = frameEvent(1);
        eventNameWithoutSpaces = strsubst(eventName, " ", "");
        if eventNameWithoutSpaces ~= emptystr();
            
            //try to find the event name in list
            eventNameFound = %f;
            for j = 1 : 1 : length(eventNamesList)
                if eventNamesList(j) == eventName then
                    eventNameFound = %t;
                end
            end
            //if the current event name was not found in list, add it
            if eventNameFound == %f then
                eventNamesList($+1) = eventName;
            //otherwise, add error message
            else
                errorString(size(errorString, 1) + 1) = "Wrong event name for " + eventLabelList(i) + "! - The event name """ + eventName + """ is already used in a previous event!";
            end
            
        else
            errorString(size(errorString, 1) + 1) = "Wrong event name for " + eventLabelList(i) + "! - The name cannot be empty string!";
        end
        
        
        
        
        
        //check the format of event condition - encode condition if conversion is not OK, show error message
        eventCondition = frameEvent(5);
        XMLTestElement = EncodeConditionFromString(eventCondition, outPropertiesAvailable);
        //check if conversion was not successful
        if XMLTestElement == [] then
            errorString(size(errorString, 1) + 1) = "Wrong event condition for " + eventLabelList(i) + "! - Condition was not converted properly but it is required! Condition Value: """ + eventCondition + """";
        end
        
        
        
        
        
        //check whether the delay is a correct number if any
        eventDelay = frameEvent(6);
        eventDelayWithoutSpaces = strsubst(eventDelay, " ", "");
        if eventDelayWithoutSpaces ~= emptystr() then
            
            //check if the delay string is number
            isNumberDelay = isnum(eventDelayWithoutSpaces);
            if isNumberDelay then
                
                //convert delay string to number and check if it is lower than 0, if so, add error message
                delayNumber = strtod(eventDelayWithoutSpaces);
                if delayNumber < 0 then
                    errorString(size(errorString, 1) + 1) = "Wrong event delay for " + eventLabelList(i) + "! Delay number has to be higher than or equal to 0! - Original delay string: " + eventDelayWithoutSpaces;
                end
                
            else
                errorString(size(errorString, 1) + 1) = "Wrong event delay for " + eventLabelList(i) + "! Delay string is not number! - Original delay string: " + eventDelayWithoutSpaces;
            end
            
        end
        
        
        
        
        
        //check the format of set definition
        eventSetStringArray = frameEvent(7);

        for j = 1 : 1 : size(eventSetStringArray, 1);
            //encode set definition from string and if the conversion was not successful, add error message
            setString = eventSetStringArray(j);
            if strsubst(setString, " ", "") ~= emptystr() then
                XMLSetElement = EncodeSetDefinitionFromString(setString, inTableXMLElementsList, outPropertiesAvailable, %f);
                if XMLSetElement == [] then
                    errorString(size(errorString, 1) + 1) = "Wrong event set definition for " + eventLabelList(i) + "! Set string is not in a valid format! - """ + setString + """";
                end
            end
        end
        
        
        
        
        
        //check the format of notify definition
        eventNotifyStringArray = frameEvent(8);
        for j = 1 : 1 : size(eventNotifyStringArray, 1)
            
            valueWithoutSpaces = strsubst(eventNotifyStringArray(j), " ", "");
            if valueWithoutSpaces ~= emptystr() then
                isCorrect = CheckCorrectValueType(valueWithoutSpaces, "property", outPropertiesAvailable, %t);
                if isCorrect == %f then
                    errorString(size(errorString, 1) + 1) = "Wrong event notify definition for " + eventLabelList(i) + "! Notify string is not a valid property name! - """ + valueWithoutSpaces + """";
                end
            end
            
        end
        
        
    end
    
    
    
    
    
    //if there is no error in inputs of simulation definition dialog, encode it to xml JSBSim simulation document
    if errorString == [] then
        
        
        outTableXMLElementsList = list();
        numberOfTable = 1;
        //show table dialogs for all tables in events
        for i = 1 : 1 : length(eventListListString)
            
            //get the current event's set string without spaces
            eventListString = eventListListString(i);
            setEventStringArray = eventListString(7);
            
            //find the table tag in function if any
            tableTag = "table";
            for j = 1 : 1 : size(setEventStringArray, 1)
                
                
                setEventStringValueWithoutWhiteSpaces = strsubst(setEventStringArray(j), " ", "");
                if setEventStringValueWithoutWhiteSpaces ~= emptystr() then
                    //get only right side of the set definition - validity was checked before, so it should be in correct format
                    indexEqualSignInSetEventStringArray = strindex(setEventStringValueWithoutWhiteSpaces, "=");
                    if indexEqualSignInSetEventStringArray == [] then
                        indexEqualSignInSetEventStringArray = 0;
                    end
                    indexLeftSquareBracketInSetEventStringArray = strindex(setEventStringValueWithoutWhiteSpaces, "[");
                    if indexLeftSquareBracketInSetEventStringArray == [] then
                        indexLeftSquareBracketInSetEventStringArray = length(setEventStringValueWithoutWhiteSpaces) + 1;
                    end
                    setEventStringValueWithoutWhiteSpacesRightSide = part(setEventStringValueWithoutWhiteSpaces, indexEqualSignInSetEventStringArray(1)+1 : indexLeftSquareBracketInSetEventStringArray(1)-1);
                    
                    
                    //get all table tag strings from string equation if any
                    tableStringsList = GetTableStringsFromStringEquation(setEventStringValueWithoutWhiteSpacesRightSide, tableTag);
                    //if any table tag was found, process it
                    if length(tableStringsList) > 0 then
                        
                        
                        //decode or create default data from table XML elements
                        [tableStringsMatricesList, tableTitleArraysList, tablePropertyRowsList, tablePropertyColumnsList, tablesPropertyTableList] = DecodeOrCreateXMLTables(inTableXMLElementsList, tableStringsList, emptystr());
                        
                        
                        //if all lists have same length, everything is OK
                        if length(tableStringsList) == length(tableStringsMatricesList) & length(tableStringsList) == length(tableTitleArraysList) & length(tableStringsList) == length(tablePropertyRowsList) & length(tableStringsList) == length(tablePropertyColumnsList) & length(tableStringsList) == length(tablesPropertyTableList) then
                            
                            //show table dialogs for all table strings in list with decoded or defaultly created structures
                            for x = 1 : 1 : length(tableStringsList)
                                
                                
                                //show table dialog with decoded values
                                [outTableStringMatrices, outTableTitleArray, outPropertyRow, outPropertyColumn, outPropertyTable] = DialogTableOkCancel(tableStringsMatricesList(x), tableTitleArraysList(x), tablePropertyRowsList(x), tablePropertyColumnsList(x), tablesPropertyTableList(x), outPropertiesAvailable);
                                
                                //if there is any output
                                if outTableStringMatrices ~= [] & outTableStringMatrices ~= list() then
                                    
                                    //encode string data from dialog to XML table
                                    outXMLTable = EncodeXMLTable(outTableStringMatrices, outTableTitleArray, outPropertyRow, outPropertyColumn, outPropertyTable);
                                    //if there is no error
                                    if outXMLTable ~= [] then
                                        
                                        //add table element to the list of XML table elements
                                        outTableXMLElementsList($+1) = outXMLTable.root;
                                        
                                        
                                        //change table string in equation to "table_<table no.>", i.e. "table_" + string(numberOfTable)
                                        //get each part of set definition line
                                        setEventNewStringValueLeftSideWithEqualSign = part(setEventStringValueWithoutWhiteSpaces, 1:indexEqualSignInSetEventStringArray);
                                        setEventNewStringValueRightSide = part(setEventStringValueWithoutWhiteSpaces, indexEqualSignInSetEventStringArray+1:indexLeftSquareBracketInSetEventStringArray-1);
                                        setEventNewStringValueAttributesWithSquareBrackets = part(setEventStringValueWithoutWhiteSpaces, indexLeftSquareBracketInSetEventStringArray:length(setEventStringValueWithoutWhiteSpaces));
                                        
                                        //change only the right side of the set definition line
                                        indexTableString = strindex(setEventNewStringValueRightSide, tableStringsList(x));
                                        if indexTableString ~= [] then
                                            setEventNewSubStringValueRS_Left = part(setEventNewStringValueRightSide, 1:indexTableString(1)-1);
                                            setEventNewSubStringValueRS_Right = part(setEventNewStringValueRightSide, indexTableString(1)+length(tableStringsList(x)) : length(setEventNewStringValueRightSide));
                                            //join the separated parts of the right side and add new table tag with number
                                            setEventNewCompleteStringValueRightSide = setEventNewSubStringValueRS_Left + "table_" + string(numberOfTable) + setEventNewSubStringValueRS_Right;
                                            //join whole set definition line with new table tag back together
                                            eventListListString(i)(7)(j) = setEventNewStringValueLeftSideWithEqualSign + setEventNewCompleteStringValueRightSide + setEventNewStringValueAttributesWithSquareBrackets;
                                        else
                                            messagebox([ "Table: """ + tableStringsList(x) + """ was not found in the right string part: """ + setEventNewStringValueRightSide + """" ; "Complete original set definition without spaces: """ + setEventStringValueWithoutWhiteSpaces + """" ], "modal", "error");
                                        end
                                        
                                        //increment the number of table value
                                        numberOfTable = numberOfTable + 1;
                                        
                                        
                                    else
                                        messagebox(["Table no. " + string(x) + " was not set properly!" ; "row property: """ + outPropertyRow + """" ; "column property: """ + outPropertyColumn + """" ; "table property: " + outPropertyTable + """" ; ], "modal", "error");    // "Table Titles: " ; outTableTitleArray ; "Table Data: " ; outTableStringMatrices
                                        //outXmlSimulation = [];
                                        return;
                                    end
                                    
                                    
                                else
                                    
                                    //otherwise, cancel was clicked (or some error occured?)
                                    //outXmlSimulation = [];
                                    return;
                                    
                                end
                                
                                
                            end
                            
                        else
                            
                            messagebox(["Tables were not loaded properly!" ; "The number of proposed tables is not equal to the number of decoded/created tables" ; "rows properties: """ + tablePropertyRowsList + """" ; "columns properties: """ + tablePropertyColumnsList + """" ; "tables properties: " + tablesPropertyTableList + """" ; "Tables Titles: " ; tableTitleArraysList ; "Tables Data: " ; tableStringsMatricesList ; ], "modal", "error");
                            //outXmlSimulation = [];
                            return;
                            
                        end
                        
                        
                    end
                    
                end
                
            end
            
            
        end
        
        
        
        
        //define simulation script list string
        simulationScriptListString = list( descritionTextMainStringArray', xmlAircraftFileName, xmlResetFileName, runStartTextStringNumber, runEndTextStringNumber, run_dtTextStringNumber, runPropertyTextStringArray' );
        
        
        
        //encode all string data to xml simulation definition file and set them to the output
        outXmlSimulation = EncodeSimulationScriptXMLElementFromListsString(simulationScriptListString, eventListListString, outTableXMLElementsList, propertiesAvailable, %f);
        //if there is no output xml simulation definition, show error and end function
        if outXmlSimulation == [] then
            
            //show message box with error
            messagebox("Error occurred during encoding of simulation definition data to XML format!", "Error - Encoding of Simulation Definition failed!", "modal", "error");
            //outXmlSimulation = [];
            return;
            
        end
        
        
        
        //close the window
        close(handles);
        
        
    //otherwise, if there was any error during check of data validity, show message box with all errors and end function
    else
        
        //show message box with all errors
        messagebox(errorString, "Error - Simulation Definition does not contain valid data!", "error", "OK", "modal");
        //outXmlSimulation = [];
        return;
        
    end
    
    
    
endfunction



function [stringOrCheckBoxBoolValue]=GetStringOrCheckBoxValueFromUIControl(UITextOrCheckBox, textOrCheckBoxSwitch)
    
    stringOrCheckBoxBoolValue = emptystr();
    if UITextOrCheckBox ~= [] then
        
        //if text uicontrol is the input
        if textOrCheckBoxSwitch == %f then
            
            stringOrCheckBoxBoolValue = UITextOrCheckBox.string;
            
        //otherwise, checkbox uicontrol is the input
        else
            
            //convert true/false value from checkbox uicontrol to string
            booleanString = ConvertUIControlCheckBoxValueToBooleanString(UITextOrCheckBox);
//            trueFalseString = ConvertBooleanStringToTrueFalseString(booleanString);
//            //if the input and output strings are not same, it means that the conversion was successful
//            if trueFalseString ~= booleanString then
//                stringOrCheckBoxBoolValue = trueFalseString;
//            end
            
        end
        
    else
        
        disp(["UIControl element is empty in GetStringOrCheckBoxValueFromUIControl function!" ; emptystr() ]);
        
    end
    
endfunction



function [outXmlSimulation, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=SimulationDefinitionCancel_callback(handles)
    
    //set output objects to empty array
    outXmlSimulation = [];
    outXmlResetFilePath = [];
    outXmlResetFileName = [];
    outXmlAircraftFilePath = [];
    outXmlAircraftFileName = [];
    //close the window
    close(handles);
    
endfunction



//callback for aircraft path file selection
function [outXmlAircraftFilePath, outXmlAircraftFileName]=UseAircraftPath_callback(handles, inXmlAircraftFilePath, inXmlAircraftFileName)
    
    outXmlAircraftFilePath = inXmlAircraftFilePath;
    outXmlAircraftFileName = inXmlAircraftFileName;
    
    //show open dialog for aircraft file selection
    [fileName, pathName, filterIndex] = uigetfile( ["*.xml","XML files"], "aircraft", "Select file with aircraft (fdm_config) definition", %f );
    
    //check if cancel button was not clicked
    if fileName ~= "" & pathName ~= "" & filterIndex ~= 0 then
        
        xmlPathFile = pathName + filesep() + fileName;
        //read xml file with (maybe) aircraft (fdm_config) information
        xmlAircraftTemp = xmlRead(xmlPathFile);
        errorString=ValidateXMLdocument(xmlAircraftTemp);
        
        //check if the root xml element is "fdm_config"
        if convstr(xmlAircraftTemp.root.name, 'l') == "fdm_config" then
            
            outXmlAircraftFileName = GetFileNameWithoutExtension(fileName, ".xml");
            outXmlAircraftFilePath = xmlPathFile;
            handles.string = outXmlAircraftFilePath;
            
        else
        
            messagebox("Wrong format! The XML file is not a valid aircraft (fdm_config) file!", "modal", "error");
            
        end
        
        CheckAndDeleteXMLDoc(xmlAircraftTemp);
        
    end
    
endfunction



//callback for reset path file selection
function [outXmlResetFilePath, outXmlResetFileName]=UseResetPath_callback(handles, inXmlResetFilePath, inXmlResetFileName)
    
    outXmlResetFilePath = inXmlResetFilePath;
    outXmlResetFileName = inXmlResetFileName;
    
    //show open dialog for reset file selection
    [fileName, pathName, filterIndex] = uigetfile( ["*.xml","XML files"], "aircraft", "Select file with initial (reset) parameters", %f );
    
    //check if cancel button was not clicked
    if fileName ~= "" & pathName ~= "" & filterIndex ~= 0 then
        
        xmlPathFile = pathName + filesep() + fileName;
        //read xml file with (maybe) reset parameters
        xmlResetTemp = xmlRead(xmlPathFile);
        errorString=ValidateXMLdocument(xmlResetTemp);
        
        //check if the root xml element is "initialize"
        if convstr(xmlResetTemp.root.name, 'l') == "initialize" then

            
            outXmlResetFileName = GetFileNameWithoutExtension(fileName, ".xml");
            outXmlResetFilePath = xmlPathFile;
            handles.string = outXmlResetFilePath;
            
        else
        
            messagebox("Wrong format! The XML file is not a valid reset file!", "modal", "error");
            
        end
        
        CheckAndDeleteXMLDoc(xmlResetTemp);
        
    end
    
endfunction



//callback for button with event add function
function [eventDeleteButton]=SimulationDefinitionEventAdd_callback(handles, frameMain, inEventGridBagLineBeginning)
    
    [indexLastEventChild, indexFirstEventChild, numberOfEvents] = GetNumberOfEventsAndFirstLastIndexesChild(frameMain);
    eventParameterListString = list( SetIDinValue(EventPossibleInputTypesListGlobal(1)) , "false" , "false" , [emptystr() ; emptystr() ; emptystr()] , SetIDinValue(EventPossibleInputTypesListGlobal(5)) , emptystr() , SetIDinValue(EventPossibleInputTypesListGlobal(7)) , SetIDinValue(EventPossibleInputTypesListGlobal(8)) );
    eventDeleteButton = EventInsertFrameAndButtons(frameMain, inEventGridBagLineBeginning, numberOfEvents + 1, eventParameterListString);
    
endfunction


//note: unfortunately, Scilab can change constraints but the uicontrol elements stay at the same gridbag position as was defined during creation, thus the true insert option is not allowed now
//callback for button with event insert function
//function SimulationDefinitionEventInsert_callback(handles, frameMain, inEventGridBagLineBeginning)
//    
//    labelMain = handles.Tag;
//    indexInsertEventGridBagLine = emptystr();
//    valueOK = %f;
//    while valueOK == %f then
//        
//        //show dialog with question about index to insert
//        indexInsertEventGridBagLine = x_mdialog(labelMain, "Set index for insertion", emptystr(), indexInsertEventGridBagLine);
//        
//        //if OK was clicked 
//        if indexInsertEventGridBagLine ~= [] then
//            
//            //delete spaces
//            indexInsertEventGridBagLine = strsubst(indexInsertEventGridBagLine, " ", "");
//            //change comma (',') to dot ('.')
//            indexInsertEventGridBagLine = strsubst(indexInsertEventGridBagLine, ",", ".");
//            
//            //check if all values are numbers
//            isNumberArray = isnum(indexInsertEventGridBagLine);
//            if and(isNumberArray) == %f then
//                //if index is not number show error message and repeat the cycle
//                labelMain = [handles.Tag ; "Index must be number!"];
//                continue;
//            end
//            
//            //convert from string to number and change the number to integer type if it is a decimal number
//            indexInsertEventGridBagLine = int(strtod(indexInsertEventGridBagLine));
//            
//            //everything should be OK
//            valueOK = %t;
//            
//        else
//            
//            break;
//            
//        end
//        
//    end
//    
//    
//    //if an event should be created at a valid index (OK was clicked)
//    if valueOK == %t then
//        
//        //insert frame and buttons of new event at specific index
//        EventInsertFrameAndButtons(frameMain, inEventGridBagLineBeginning, indexInsertEventGridBagLine);
//        
//    end
//    
//    
//endfunction
//

function [eventDeleteButton]=EventInsertFrameAndButtons(frameMain, inEventGridBagLineBeginning, indexInsertEventGridBagLine, eventParameterListString)
    
    
    //check number of elements which is needed in eventParameterListString
    eventParameterListStringNumberOfElementsNeeded = 8;
    if length(eventParameterListString) < eventParameterListStringNumberOfElementsNeeded then
        ("eventParameterListString doesn''t have enough elements! " + string(eventParameterListStringNumberOfElementsNeeded) + " elements needed but there is only " + string(length(eventParameterListString)) + " elements.", "modal", "error");
    end
    
    
    [indexLastEventChild, indexFirstEventChild, numberOfEvents] = GetNumberOfEventsAndFirstLastIndexesChild(frameMain);
    
    
//    //if there is no event
//    if (eventGridBagLineBeginning - 1) * 2 + indexLastEventChild - 1 <= length(frameMain.children) then
//        
//    end
    //if there is an event
    if indexLastEventChild <= indexFirstEventChild then
        
        //check if index is between first and last index event, if not edit it
        if indexInsertEventGridBagLine < 1 then
            indexInsertEventGridBagLine = 1;
        elseif indexInsertEventGridBagLine > numberOfEvents + 1 then
            indexInsertEventGridBagLine = numberOfEvents + 1;
        end
        
    //otherwise, there is no event
    else
        
        indexInsertEventGridBagLine = 1;
        
    end
    
    
    
    //calculate line of new frame with event
    newLineInFrameMainGridBag = inEventGridBagLineBeginning + indexInsertEventGridBagLine - 1;
    //if there is an event, change calculation - get the proper number from constraints of uicontrol (<>this is added because of the issue with no effect of constraints change - after deletion an event, the number of event would be different than the line number in constraints and so would be indexInsertEventGridBagLine)
    if numberOfEvents > 0 then
        newLineInFrameMainGridBag = frameMain.children(1).constraints(2)(2) + 1;
    end
    //create new frame for event uicontrols
    frameEventMain = CreateEventNewChildFrame(frameMain, numberOfEvents, newLineInFrameMainGridBag);
    
    //create new labels, textboxes and checkboxes in the currently created frame
    global EventEventLabel;
    global EventNameLabel;
    global EventDescriptionLabel;
    global EventConditionLabel;
    global EventDelayLabel;
    global EventSetLabel;
    global EventNotifyLabel;
    global EventPossibleInputTypesListGlobal;
    eventDeleteButton = CreateEventUIMainLabelAndDeleteButton(frameEventMain, 1, EventEventLabel + " no." + string(newLineInFrameMainGridBag - inEventGridBagLineBeginning + 1), "Delete " + EventEventLabel);
    CreateEventUILabelTextInFrame(frameEventMain, 2, EventNameLabel, EventNameLabel + "*", eventParameterListString(1), %f);
    CreateEventUICheckBoxesPersistentAndContinuous(frameEventMain, 3, eventParameterListString(2), eventParameterListString(3));
    CreateEventUILabelTextInFrame(frameEventMain, 4, EventDescriptionLabel, EventDescriptionLabel, eventParameterListString(4), %t);
    CreateEventUILabelTextInFrame(frameEventMain, 5, EventConditionLabel, EventConditionLabel + "* (" + EventPossibleInputTypesListGlobal(5) + ")", eventParameterListString(5), %f);
    CreateEventUILabelTextInFrame(frameEventMain, 6, EventDelayLabel, EventDelayLabel + " (" + EventPossibleInputTypesListGlobal(6) + ")", eventParameterListString(6), %f);
    CreateEventUILabelTextInFrame(frameEventMain, 7, EventSetLabel, EventSetLabel + " (" + EventPossibleInputTypesListGlobal(7) + ")", eventParameterListString(7), %t);
    CreateEventUILabelTextInFrame(frameEventMain, 8, EventNotifyLabel, EventNotifyLabel + " (" + EventPossibleInputTypesListGlobal(8) + ")", eventParameterListString(8), %t);
    
    
    //note: unfortunately, Scilab can change constraints but the uicontrol elements stay at the same gridbag position as was defined during creation, thus the true insert option is not allowed now
//    //change constraints of the moved part of the children
//    for i = 2 : 1 : length(frameMain.children)
//        constraintLineCurrent = frameMain.children(i).constraints(2)(2);
//        if constraintLineCurrent >= newLineInFrameMainGridBag then
//            constraintLineChange = constraintLineCurrent + 1;
//            frameMain.children(i).constraints = [];
//            frameMain.children(i).constraints = createConstraints("gridbag", [1 constraintLineChange 2 1], [1 1]);
//        end
//    end
    
    //create constraints of the current event frame and set it to be visible

    //frameEventMain.constraints = createConstraints("gridbag", [1 newLineInFrameMainGridBag 2 1], [1 1]);
    frameEventMain.visible = "on";
    
    
endfunction


function [indexLastEventChild, indexFirstEventChild, numberOfEvents]=GetNumberOfEventsAndFirstLastIndexesChild(frameMain)
    
    indexLastEventChild = 0;
    indexFirstEventChild = -1;
    global frameEventBeginningTag;
    if length(frameMain.children) > 0 then
        
        for i = 1 : 1 : length(frameMain.children)
            
            //if the first frame contains the word specific for frame event tag at the beginning of the tag
            indexFrameTag = strindex(frameMain.children(i).tag, frameEventBeginningTag)
            if indexFrameTag ~= [] then
                if indexFrameTag(1) == 1 then
                    
                    //only for first cycle set last event child index
                    if i == 1 then
                        indexLastEventChild = 1;
                    end
                    
                    //set first event child index
                    indexFirstEventChild = i;
                    
                else
                    break;
                end
            else
                break;
            end
            
        end
        
    end
    numberOfEvents = indexFirstEventChild - indexLastEventChild + 1;
    
endfunction


function [eventDeleteButton]=CreateEventUIMainLabelAndDeleteButton(frameParent, lineInFrameParent, EventLabelValue, DeleteButtonString)
    
    //create main event label
    labelTag = frameParent.Tag + "_" + EventLabelValue + "_label";
    runEventChildLabel = uicontrol(frameParent, "style", "text", ...
                                    "Tag", labelTag,..
                                    "string", EventLabelValue, ...
                                    "constraints", createConstraints("gridbag", [1, lineInFrameParent, 1, 1], [0.5, 1], "horizontal", "center"), ...
                                    "margins", [5 5 5 5], ...
                                    "fontsize", 18, ...
                                    "horizontalAlignment", "left");
    
    
    //create delete button
    pushbuttonTag = frameParent.Tag + "_" + DeleteButtonString + "_pushbutton";
    eventDeleteButton = uicontrol(frameParent, "style", "pushbutton", ...
                    "Tag", pushbuttonTag,..
                    "string", DeleteButtonString, ...
                    "callback", "eventDeleteButtonsList = SimulationDefinitionEventDelete_callback(findobj(""tag"",""" + pushbuttonTag + """), eventDeleteButtonsList)", ... //callback will try to find button depending on the tag
                    "fontsize", 15, ...
                    "constraints", createConstraints("gridbag", [2, lineInFrameParent, 1, 1], [1, 1], "horizontal", "left", [0, 0]));
    
    
endfunction


function CreateEventUILabelTextInFrame(frameParent, lineInFrameParent, eventParameterTag, labelValue, textValue, isMultipleLine)
    
    labelTag = frameParent.Tag + "_" + eventParameterTag + "_label";
    runEventChildLabel = uicontrol(frameParent, "style", "text", ...
                                    "Tag", labelTag,..
                                    "string", labelValue, ...
                                    "constraints", createConstraints("gridbag", [1, lineInFrameParent, 1, 1], [0.5, 1], "horizontal", "left"), ...
                                    "margins", [5 5 5 5], ...
                                    "fontsize", 15, ...
                                    "horizontalAlignment", "left");
    
    
    textTag = frameParent.Tag + "_" + eventParameterTag + "_text";
    runEventChildText = uicontrol(frameParent, "style", "edit", ...
                                    "Tag", textTag,..
                                    "scrollable", "off", ...
                                    "constraints", createConstraints("gridbag", [2, lineInFrameParent, 1, 1], [0.5, 1], "horizontal", "left"), ...
                                    "margins", [5 5 5 5], ...
                                    "fontsize", 15, ...
                                    "horizontalAlignment", "left", ...
                                    "verticalAlignment", "top");
    
    //if edit should support multiline strings
    if isMultipleLine == %t then
        runEventChildText.max = 1000;   //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
        runEventChildText.scrollable = "on";
    end
    //set string attribute (if edit would not be multiline, it could end in error)
    runEventChildText.string = textValue;
    
endfunction


function CreateEventUICheckBoxesPersistentAndContinuous(frameParent, lineInFrameParent, persistentValue, continuousValue)
    
    global EventPersistentLabel;
    checkBoxPersistentTag = frameParent.Tag + "_" + EventPersistentLabel + "_checkbox";
    runEventChildCheckBoxPersistent = uicontrol(frameParent, "style", "checkbox", ...
                    "Tag", checkBoxPersistentTag,..
                    "string", EventPersistentLabel + " event", ...
                    "tooltipstring", "If the event should be executed each time the condition evaluates to true (only when it was false before), set the persistent attribute to true.",...
                    "constraints", createConstraints("gridbag", [1, lineInFrameParent, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    runEventChildCheckBoxPersistent.value = ConvertTrueFalseStringToUIControlCheckBoxValue(runEventChildCheckBoxPersistent, persistentValue);
    
    
    global EventContinuousLabel;
    checkBoxContinuousTag = frameParent.Tag + "_" + EventContinuousLabel + "_checkbox";
    runEventChildCheckBoxContinuous = uicontrol(frameParent, "style", "checkbox", ...
                    "Tag", checkBoxContinuousTag,..
                    "string", EventContinuousLabel + " event", ...
                    "tooltipstring", "If the event should be executed every single frame (while the condition evaluates to true), set the continuous attribute to true.",...
                    "constraints", createConstraints("gridbag", [2, lineInFrameParent, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    runEventChildCheckBoxContinuous.value = ConvertTrueFalseStringToUIControlCheckBoxValue(runEventChildCheckBoxContinuous, continuousValue);
    
endfunction


function [frameEventMain]=CreateEventNewChildFrame(frameMain, numberOfEvents, newLineInFrameMainGridBag)
    
    //create frame tag
    global frameEventBeginningTag;
    count = numberOfEvents + 1;
    frameTag = frameEventBeginningTag + string(count);
    //check if the frame tag is unique, and if not increment number at the end of the tag and try it again
    while IsUniqueFrameTagInFrame(frameMain, frameTag) == %f
        count = count + 1;
        frameTag = frameEventBeginningTag + string(count);
    end
    
    
    //create frame which will be inserted (without constraints)
    frameEventMain = uicontrol(frameMain, "style", "frame", ...
                        "Tag", frameTag,..
                        "string", emptystr(),..
                        "scrollable", "off",...
                        "Title_position", "top",..
                        "Title_scroll", "off",..
                        "layout", "gridbag",..
                        "constraints", createConstraints("gridbag", [1 newLineInFrameMainGridBag 2 1], [1 1]),..
                        "margins", [30 0 20 0], ...
                        "FontSize", 15, ...
                        "visible", "off");
    
endfunction

function [isUnique]=IsUniqueFrameTagInFrame(frameMain, inputTag)
    
    isUnique = %t;
    for i = 1 : 1 : length(frameMain.children)
        
        if frameMain.children(i).tag == inputTag then
            isUnique = %f;
        end
        
    end
    
endfunction



function [outEventDeleteButtonsList]=SimulationDefinitionEventDelete_callback(handles, inEventDeleteButtonsList)
    
    outEventDeleteButtonsList = inEventDeleteButtonsList;
    
    if handles ~= [] then
        
        //get parent event frame
        parentFrame = handles.parent;
        
        //find the delete button in list and delete it
        for i = 1 : 1 : length(outEventDeleteButtonsList)
            if handles == outEventDeleteButtonsList(i) then
                outEventDeleteButtonsList(i) = null();
                break;
            end
        end
        
        //delete parant frame with all uicontrols from main fraim
        delete(parentFrame);
        
    else
        messagebox("Error - Tag of the pushed button was not found!", "Deletion of Event Failed!", "error");
    end
    
endfunction
    
    
    
    
    
    
    outXmlSimulation = inXmlSimulation;
    outXmlResetFilePath = inXmlResetFilePath;
    outXmlResetFileName = inXmlResetFileName;
    outXmlAircraftFilePath = inXmlAircraftFilePath;
    outXmlAircraftFileName = inXmlAircraftFileName;
    
    
    
    //<>debug only
//    outXmlAircraftFilePath = "C:\Users\<user name>\Documents\Scilab";
//    outXmlResetFilePath = "C:\Users\<user name>\Documents\Scilab";
//    //include files with functions which we use
//    exec XMLfunctions.sci;
//    exec TXTfunctions.sci;
//    exec XMLSimulation.sci;
//    propertiesAvailable = ReadInternalAndCustomProperties();
    
    
    //show wait bar
    waitBarHandle = waitbar('Loading Dialog for simulation definition, please wait.');
    
    
    
    //decode simulation script
    [simulationScriptListString, eventStringArrayList] = DecodeSimulationScriptXMLElementToListsString(outXmlSimulation);
    waitbar(0.25, waitBarHandle);
    
    
    
    decodedTableXMLElementsList = list();
    //get the first "run" xml element in root element
    runXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(outXmlSimulation.root, "run");
    if runXMLElementIndexes ~= [] then
        
        runXMLElement = outXmlSimulation.root.children(runXMLElementIndexes(1));
        
        //get all "event" xml elements in run element
        eventXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(runXMLElement, "event");
        if eventXMLElementIndexes ~= [] then
            
            //go through all event xml elements
            for i = 1 : 1 : size(eventXMLElementIndexes, 1)
                
                eventXMLElement = runXMLElement.children(eventXMLElementIndexes(i));
                
                //get all "set" xml elements in event element
                setXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(eventXMLElement, "set");
                //go through all set xml elements
                for j = 1 : 1 : size(setXMLElementIndexes, 1)
                    
                    setXMLElement = eventXMLElement.children(setXMLElementIndexes(j));
                    
                    //get "function" xml element if any
                    functionXMLElementIndexes = FindXMLElementIndexesInFirstChildrenOfXMLElement(setXMLElement, "function");
                    if functionXMLElementIndexes ~= [] then
                        
                        functionXMLElement = setXMLElement.children(functionXMLElementIndexes(1));
                        
                        //get all tables from XML function element 
                        tableXMLElementsList = GetTablesFromXMLFunctionElement(functionXMLElement);
                        //add all tables from xml function to all-table-list list
                        //decodedTableXMLElementsLists($+1) = tableXMLElementsList;
                        for k = 1 : 1 : length(tableXMLElementsList)
                            decodedTableXMLElementsList($+1) = tableXMLElementsList(k);
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    //disp(string(length(decodedTableXMLElementsList)));    //<>debug only
    
    
    //change table tags in functions for set definition line if any
    numberOfTable = 1;
    for i = 1 : 1 : length(eventStringArrayList)
        
        setDefinitionStringArray = eventStringArrayList(i)(7);
        for j = 1 : 1 : size(setDefinitionStringArray, 1)
            
            tableTagWithUnderscore = "table_";
            setDefinition = setDefinitionStringArray(j);
            if strindex(setDefinition, tableTagWithUnderscore) ~= [] then
                
                //get only right part of set definition without attributes
                equalToken = tokens(setDefinition, "=");
                rightPart = equalToken(2);
                indexLeftSquareBracket = strindex(rightPart, "[");
                attributesPart = part(rightPart, indexLeftSquareBracket(1):length(rightPart));
                rightPart = part(rightPart, 1:indexLeftSquareBracket(1)-1);
                indexTables = strindex(rightPart, tableTagWithUnderscore);
                //go through all tables which are defined in function and change the numbers
                rightPartWasChanged = %f;
                for k = 1 : 1 : size(indexTables, 2)
                    
                    rightPartWasChanged = %t;
                    rightPart = strsubst(rightPart, tableTagWithUnderscore + string(k), tableTagWithUnderscore + string(numberOfTable));
                    numberOfTable = numberOfTable + 1;
                    
                end
                //if right part was modified, change the set definition string (put it back together) in the "parent" event string-array list
                if rightPartWasChanged == %t then
                    eventStringArrayList(i)(7)(j) = equalToken(1) + "=" + rightPart + attributesPart;
                end
                
            end
            
        end
        
    end
    
    
    waitbar(0.5, waitBarHandle);
    
    
    
    //get aircraft and reset file paths
    extensionXML = ".xml";
    differentAircraft = %f;
    //if the aircraft file path is empty or the filename is not equal to name of the aircraft filename from xml simulation, set it to the new path
    if outXmlAircraftFilePath == emptystr() | (outXmlAircraftFileName ~= simulationScriptListString(2) & outXmlAircraftFileName ~= simulationScriptListString(2) + extensionXML) then
        //pwd() gets current working directory which has to contain this application (GUI.sce)
        outXmlAircraftFilePath = pwd() + filesep() + "aircraft" + filesep() + simulationScriptListString(2) + filesep() + simulationScriptListString(2) + extensionXML;
        outXmlAircraftFileName = simulationScriptListString(2);
        differentAircraft = %t;
    end
    //if the reset file path is empty or the last part is not equal to name of the reset filename from xml simulation, or it is a different aircraft, set it to the new path
    if outXmlResetFilePath == emptystr() | (outXmlResetFileName ~= simulationScriptListString(3) & outXmlResetFileName ~= simulationScriptListString(3) + extensionXML) | differentAircraft == %t then
        //pwd() gets current working directory which has to contain this application (GUI.sce)
        outXmlResetFilePath = pwd() + filesep() + "aircraft" + filesep() + simulationScriptListString(2) + filesep() + simulationScriptListString(3) + extensionXML;
        outXmlResetFileName = simulationScriptListString(3);
    end
    
    
    
    
    //create new dialog (figure) with all necessary uicontrols
    SimulationDefinitionDialogID = 7777777;
    figSimulationDefinitionDialog = figure(SimulationDefinitionDialogID, 'figure_position', [250, 150],...
                                                                         'figure_size', [1100, 600],...
                                                                         "menubar", "none",...
                                                                         "layout", "grid",...
                                                                         "auto_resize", "on",...
                                                                         "resize", "on",...
                                                                         "visible", "off");
    clf(SimulationDefinitionDialogID);
    //f.axes_size = [200 200];
    //as = f.axes_size;  // [width height]
    figSimulationDefinitionDialog.default_axes = "off";
    figSimulationDefinitionDialog.dockable = "off";
    figSimulationDefinitionDialog.figure_name = "Simulation Definition Dialog";
    figSimulationDefinitionDialog.infobar_visible = "off";
    figSimulationDefinitionDialog.toolbar = "none";
    figSimulationDefinitionDialog.toolbar_visible = "off";
    //figSimulationDefinitionDialog.figure_size = figSimulationDefinitionDialog.axes_size;
    //figSimulationDefinitionDialog.resizefcn:    This field can be used to store the name of a Scilab function or a Scilab expression as a character string. This character string will be evaluated whenever the user resizes the figure and when the figure is created.
    //figSimulationDefinitionDialog.resize = "off";
    //figSimulationDefinitionDialog.layout = "grid";
    //figSimulationDefinitionDialog.layout_options = createLayoutOptions("grid", [2, 2]);
    
    
    
    //<>debug only
    //c = get(0);
    //set(c, "ShowHiddenProperties", "on");
    
    
    frameMain = uicontrol(figSimulationDefinitionDialog, "style", "frame",..
               "Tag", "frameMain",..
               "layout" , "gridbag",...
               "scrollable", "on",...
               "Title_position", "top",..
               "Title_scroll", "on",..
               "FontSize", 15)//,..
               //"tooltipstring", "tabs")
               //"position", [0, 0, figSimulationDefinitionDialog.figure_size(1)-50, figSimulationDefinitionDialog.figure_size(2)-50],...
               //"callback", "SimulationDefinition_callback(handles)", ..
               //"callback", "messagebox(""clicked on tab"")", ..
               //"String", tabStrings,..
               //"String", ["asdf|fsad"],..
               //"string", inputTableTitle,..
               //"Value", 1,..
               //"String", "tabFrame1",..
    
    
    
    descritionLabelMain = uicontrol(frameMain, "style", "text", ...
                    "Tag", "descritionLabelMain",..
                    "string", "Description", ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //editStringDefault = [emptystr(); emptystr(); emptystr()];
    //editStringDefault = emptystr();
    descritionTextMain = uicontrol(frameMain, "style", "edit", ...
                    "Tag", "descritionTextMain",..
                    "string", simulationScriptListString(1), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    useAircraftPathLabel = uicontrol(frameMain, "style", "text", ...
                    "Tag", "useAircraftPathLabel",..
                    "string", "Aircraft file* (path_file)", ...
                    "constraints", createConstraints("gridbag", [1, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    useAircraftPathButton = uicontrol(frameMain, "style", "pushbutton", ...
                    "string", outXmlAircraftFilePath, ...
                    "callback", "[outXmlAircraftFilePath, outXmlAircraftFileName]=UseAircraftPath_callback(useAircraftPathButton, outXmlAircraftFilePath, outXmlAircraftFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "useAircraftPathButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [2, 2, 1, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    useResetPathLabel = uicontrol(frameMain, "style", "text", ...
                    "Tag", "useResetPathLabel",..
                    "string", "Initialize (reset) file* (path_file)", ...
                    "constraints", createConstraints("gridbag", [1, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    useResetPathButton = uicontrol(frameMain, "style", "pushbutton", ...
                    "string", outXmlResetFilePath, ...
                    "callback", "[outXmlResetFilePath, outXmlResetFileName]=UseResetPath_callback(useResetPathButton, outXmlResetFilePath, outXmlResetFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "useResetPathButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [2, 3, 1, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    runStartLabel = uicontrol(frameMain, "style", "text", ...
                    "Tag", "runStartLabel",..
                    "string", "Simulation start [s]* (number)", ...
                    "tooltipstring", "usually set to 0.", ...
                    "constraints", createConstraints("gridbag", [1, 4, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    runStartText = uicontrol(frameMain, "style", "edit", ...
                    "Tag", "runStartText",..
                    "string", simulationScriptListString(4), ...
                    "constraints", createConstraints("gridbag", [2, 4, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    runEndLabel = uicontrol(frameMain, "style", "text", ...
                    "Tag", "runEndLabel",..
                    "string", "Simulation end [s]* (number)", ...
                    "constraints", createConstraints("gridbag", [1, 5, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    runEndText = uicontrol(frameMain, "style", "edit", ...
                    "Tag", "runEndText",..
                    "string", simulationScriptListString(5), ...
                    "constraints", createConstraints("gridbag", [2, 5, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    run_dtLabel = uicontrol(frameMain, "style", "text", ...
                    "Tag", "run_dtLabel",..
                    "string", "Simulation step (dt) [s]* (number)", ...
                    "constraints", createConstraints("gridbag", [1, 6, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    run_dtText = uicontrol(frameMain, "style", "edit", ...
                    "Tag", "run_dtText",..
                    "string", simulationScriptListString(6), ...
                    "constraints", createConstraints("gridbag", [2, 6, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    runPropertyLabel = uicontrol(frameMain, "style", "text", ...
                    "Tag", "runPropertyLabel",..
                    "string", "<html>Property definition<BR>(""new_property_name"" or<BR> ""new_property_name = number"")<BR>(Separated by new line)</html>", ...
                    "constraints", createConstraints("gridbag", [1, 7, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    runPropertyText = uicontrol(frameMain, "style", "edit", ...
                    "Tag", "runPropertyText",..
                    "string", simulationScriptListString(7), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [2, 7, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    
    eventGridBagLineBeginning = 8;
    frameEventAdd = uicontrol(frameMain, "style", "frame",..
               "Tag", "frameEventAdd",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 10008 1 1], [1 1]),.. //because changing of constraints has no effect, the constraints line is set to 10001+7, therefore, position of dialog buttons will work properly only when there will be no more than 10000 events defined by user in a single simulation script.
               "margins", [20 0 10 0], ...
               "FontSize", 15);
    
    //create add and insert event button
    EventAddButton = uicontrol(frameEventAdd, "style", "pushbutton", ...
                    "string", "Add event", ...
                    "callback", "eventDeleteButtonsList($+1) = SimulationDefinitionEventAdd_callback(EventAddButton, frameMain, eventGridBagLineBeginning)", ...
                    "fontsize", 15, ...
                    "Tag", "EventAddButton",..
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "left", [0, 0]));
                    
    //note: unfortunately, Scilab can change constraints but the uicontrol elements stay at the same gridbag position as was defined during creation, thus the true insert option is not allowed now
//    EventInsertButton = uicontrol(frameEventAdd, "style", "pushbutton", ...
//                    "string", "Insert event", ...
//                    "callback", "SimulationDefinitionEventInsert_callback(EventAddButton, frameMain, eventGridBagLineBeginning)", ...
//                    "fontsize", 15, ...
//                    "Tag", "EventInsertButton",..
//                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "left", [0, 0]));
    
    
    
    
    
    
    frameOKCancel = uicontrol(frameMain, "style", "frame",..
               "Tag", "frameOKCancel",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 10009 2 1], [1 1]),.. //because changing of constraints has no effect, the constraints line is set to 10002+7, therefore, position of dialog buttons  will work properly only when there will be no more than 10000 events defined by user in a single simulation script.
               "margins", [20 0 0 0], ...
               "FontSize", 15);
    
    //create OK and Cancel button
    OKButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "OK", ...
                    "callback", "[outXmlSimulation]=SimulationDefinitionOK_callback(figSimulationDefinitionDialog, frameMain, descritionTextMain.string, outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName, runStartText.string, runEndText.string, run_dtText.string, runPropertyText.string, decodedTableXMLElementsList, propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "OKButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "center", [0, 0]));
                    
    CancelButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "Cancel", ...
                    "callback", "[outXmlSimulation, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=SimulationDefinitionCancel_callback(figSimulationDefinitionDialog)", ...
                    "fontsize", 15, ...
                    "Tag", "CancelButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "center"));
    waitbar(0.75, waitBarHandle);
    
    
    
    
    //create list with all delete buttons
    eventDeleteButtonsList = list();
    //add event uicontrols and values
    for i = 1 : 1 : length(eventStringArrayList)
        eventDeleteButtonsList($+1) = EventInsertFrameAndButtons(frameMain, eventGridBagLineBeginning, i, eventStringArrayList(i));
    end
    waitbar(1.0, waitBarHandle);
    
    //turn off auto resize function of figure, disallow manual resize and set it to be visible
    //figSimulationDefinitionDialog.auto_resize = "off";
    //figSimulationDefinitionDialog.resize = "off";
    figSimulationDefinitionDialog.visible = "on";
    
    
    //close wait bar window
    close(waitBarHandle);
    
    
    
    
    //wait until is clicked
    ibutton = -1;
    iwin = -1;
    //while the current window is not closed
    while(ibutton ~= -1000 | iwin ~= figSimulationDefinitionDialog.figure_id)
        
        //wait until is clicked
        [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
        
//        //<>debug only
//        disp("Opened window is still alive!");
//        disp(string(ibutton));
//        disp(string(xcoord));
//        disp(string(ycoord));
//        disp(string(iwin));
//        disp(string(cbmenu));


        
        //check if some callback was clicked
        if ibutton == -2 then
            
            
            //if OK was clicked, execute OK callback
            if strindex(cbmenu, OKButton.callback) then
                
                //disp("OK clicked"); //<>debug only
                //handles = figSimulationDefinitionDialog;
                execstr(OKButton.callback);











                
                //if there is output with xml simulation file, break this cycle
                if outXmlSimulation ~= [] then
                    break;

                end
                
                
                
            //else if Cancel was clicked, execute Cancel callback
            elseif strindex(cbmenu, CancelButton.callback) then
                
                //disp("Cancel clicked"); //<>debug only
                //handles = figSimulationDefinitionDialog;
                execstr(CancelButton.callback);
                break;
                
                
                
            //else if add event button was clicked
            elseif strindex(cbmenu, EventAddButton.callback) then
                
                //disp("EventAddButton clicked"); //<>debug only
                //handles = EventAddButton;
                execstr(EventAddButton.callback);
                
                
                
            //else if button for aircraft path selection was clicked
            elseif strindex(cbmenu, useAircraftPathButton.callback) then
                
                //disp("useAircraftPathButton clicked"); //<>debug only
                //handles = useAircraftPathButton;
                execstr(useAircraftPathButton.callback);
                
                
                
            //else if button for reset file path selection was clicked
            elseif strindex(cbmenu, useResetPathButton.callback) then
                
                //disp("useResetPathButton clicked"); //<>debug only
                //handles = useResetPathButton;
                execstr(useResetPathButton.callback);
                
                
                
            //otherwise, it may be a delete button
            else
                
                //go through all delete buttons
                for i = 1 : 1 : length(eventDeleteButtonsList)
                    
                    //if it a delete button was clicked, execute callback
                    if strindex(cbmenu, eventDeleteButtonsList(i).callback) then
                        execstr(eventDeleteButtonsList(i).callback);
                        break;
                    end
                    
                end
                
                
                
//            //else if the click was on this simulation definition dialog, try to execute cbmenu string (callback of an uicontrol)
//            elseif iwin == figSimulationDefinitionDialog.figure_id then
//                
//                execstr(cbmenu);
//                
            end
            
            
            
        //else if the dialog was closed, it is same as when cancel button is clicked
        elseif ibutton == -1000 then
            
            //set output objects to empty array
            outXmlSimulation = [];
            outXmlResetFilePath = [];
            outXmlResetFileName = [];
            outXmlAircraftFilePath = [];
            outXmlAircraftFileName = [];
            break;
            
            
            
        end
        
    end
    //disp("The correct window was closed!"); //<>debug only
    
    
endfunction








//simulation start dialog functions

function [outXmlSimulationStart, outXmlSimulation, outXmlReset, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=DialogSimulationStartOkCancel(inXmlSimulationStart, inXmlSimulation, inXmlReset, inXmlSimulationFilePath, inXmlSimulationFileName, inXmlResetFilePath, inXmlResetFileName, inXmlAircraftFilePath, inXmlAircraftFileName, propertiesAvailable)
    
    
function [outXmlSimulationStart]=SimulationStartOK_callback(handles, descritionTextMainStringArray, xmlSimulationFilePath, xmlSimulationFileName, jsbsimCommandOptionsTextStringArray, outputProcessingTimeStartTextString, outputProcessingTimeEndTextString, outputProcessingNumberOfGraphsInLineTextString, outputProcessingNumberOfGraphsInWindowTextString, outputProcessingApplicationPopupmenuValue, outputXMLElement, outputNameTextString, outputRateTextString, outputPortTextString, outputProtocolPopupmenuValue, flightGearPath, flightgearCommandOptionsTextStringArray, propertiesAvailable)
    
    
    outXmlSimulationStart = [];
    simulationStartListString = list();
    //error string for all errors which may occur
    errorString = [];
    
    scilabTag = "SCILAB_V6";
    flightGearTag = "FLIGHTGEAR";
    
    
    
    
    //check if script file exists and is in correct format, if it is not, add script path error string to the main error string
    errorStringScript = CheckXMLJSBSimFileFormat(xmlSimulationFilePath, "script", "runscript");
    if errorStringScript ~= emptystr() then
        errorString(size(errorString, 1) + 1) = errorStringScript;
    end
    
    
    
    
    //check output processing start, end, and number of graphs in line values - add error string if necessary
    
    //check if the start value is higher than 0
    [isNumberHigherThanZeroOutputProcessingTimeStart, higherThanZeroOutputProcessingTimeStart, outNumberHigherThanZeroOutputProcessingTimeStart, errorStringHigherThanZeroOutputProcessingTimeStart] = CheckIfNumberHigherOrEqualAndConvert(outputProcessingTimeStartTextString, %f, 0);
    if errorStringHigherThanZeroOutputProcessingTimeStart ~= emptystr() then
        
        [isNumberEqualToZeroOutputProcessingTimeStart, equalToZeroOutputProcessingTimeStart, outNumberEqualToZeroOutputProcessingTimeStart, errorStringEqualToZeroOutputProcessingTimeStart] = CheckIfNumberHigherOrEqualAndConvert(outputProcessingTimeStartTextString, %t, 0);
        if errorStringEqualToZeroOutputProcessingTimeStart ~= emptystr() then
            errorString(size(errorString, 1) + 1) = "Output Processing Time Start: " + "The input string has to be higher than or equal to ""0""!  """ + outputProcessingTimeStartTextString + """" + "  converted value: """ + string(outNumberHigherThanZeroOutputProcessingTimeStart) + """";
        end
        
    end
    
    //check if the end value is higher than 0
    [isNumberOutputProcessingTimeEnd, higherThanZeroOutputProcessingTimeEnd, outNumberOutputProcessingTimeEnd, errorStringOutputProcessingTimeEnd] = CheckIfNumberHigherOrEqualAndConvert(outputProcessingTimeEndTextString, %f, 0);
    if errorStringOutputProcessingTimeEnd ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Processing Time End: " + errorStringOutputProcessingTimeEnd;
    end
    
    //check if the number of graphs in line is higher than 0
    [isNumberOutputProcessingNumberOfGraphsInLine, higherThanZeroOutputProcessingNumberOfGraphsInLine, outNumberOutputProcessingNumberOfGraphsInLine, errorStringOutputProcessingNumberOfGraphsInLine] = CheckIfNumberHigherOrEqualAndConvert(outputProcessingNumberOfGraphsInLineTextString, %f, 0);
    if errorStringOutputProcessingNumberOfGraphsInLine ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Processing Number of Graphs in Line: " + errorStringOutputProcessingNumberOfGraphsInLine;
    end
    
    //check if the number of graphs in window is higher than 0
    [isNumberOutputProcessingNumberOfGraphsInWindow, higherThanZeroOutputProcessingNumberOfGraphsInWindow, outNumberOutputProcessingNumberOfGraphsInWindow, errorStringOutputProcessingNumberOfGraphsInWindow] = CheckIfNumberHigherOrEqualAndConvert(outputProcessingNumberOfGraphsInWindowTextString, %f, 0);
    if errorStringOutputProcessingNumberOfGraphsInWindow ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Processing Number of Graphs in Window: " + errorStringOutputProcessingNumberOfGraphsInWindow;
    end
    
    
    //check time numbers and compare with each other
    //check start and end time numbers
    if outNumberHigherThanZeroOutputProcessingTimeStart ~= [] & outNumberOutputProcessingTimeEnd ~= [] then
        if outNumberHigherThanZeroOutputProcessingTimeStart >= outNumberOutputProcessingTimeEnd then
            errorString(size(errorString, 1) + 1) = "Output processing time start has to be lower than time end!  Time start: " + string(outNumberHigherThanZeroOutputProcessingTimeStart) + "  Time end: " + string(outNumberOutputProcessingTimeEnd);
        end
    end
    
    
    
    
    //check output processing application selection
    outputProcessingApplicationString = scilabTag
    if outputProcessingApplicationPopupmenuValue == 2 then
        outputProcessingApplicationString = flightGearTag;
    elseif outputProcessingApplicationPopupmenuValue ~= 1 then
        disp("Output Processing Application Popupmenu Value is not valid! Only 1 (SCILAB) or 2 (FLIGHTGEAR) are allowed! - Output Processing Application was set to SCILAB as the default");
        disp(emptystr());
    end
    
    
    //check output protocol selection if FlightGear was selected
    outputProtocolString = "tcp";
    if outputProcessingApplicationString == flightGearTag then
        if outputProtocolPopupmenuValue == 2 then
            outputProtocolString = "udp";
        elseif outputProtocolPopupmenuValue ~= 1 then
            disp("Output Protocol Popupmenu Value is not valid! Only 1 (tcp) or 2 (udp) are allowed! - Output Protocol was set to tcp as the default");
            disp(emptystr());
        end
    end
    
    
    
    //if FlightGear was selected
    if outputProcessingApplicationString == flightGearTag then
        
        
        //check if port is number and is higher than 0
        [isNumberOutputPort, higherThanZeroOutputPort, outNumberOutputPort, errorStringOutputPort] = CheckIfNumberHigherOrEqualAndConvert(outputPortTextString, %f, 0);
        if errorStringOutputPort ~= emptystr() then
            errorString(size(errorString, 1) + 1) = "Output Port: " + errorStringOutputPort;
        end
        
        
        //if FlightGear was selected and exists, check FlightGear path
        if flightGearPath ~= [] & flightGearPath ~= emptystr() then
            
            fileFlightGearExecutableExist = fileinfo(flightGearPath);
            if fileFlightGearExecutableExist == [] then
                errorString(size(errorString, 1) + 1) = "The selected FlighGear executable file does not exist! """ + flightGearPath + """";
            end
            
        else
            //if FlightGear was selected but is null or empty
            errorString(size(errorString, 1) + 1) = "File path of FlightGear is empty!";
        end
        
        
    else
        
        //otherwise, check if filename contains forbidden chars in name (windows only)
        outputNameTextStringTemp = strsubst(outputNameTextString, " ", "");
        if strindex(outputNameTextStringTemp, [':', '*', '?', '""', '<', '>', '|']) ~= [] then  //'\', '/', - these chars separate path, so they are acceptable sometimes but be careful
            errorString(size(errorString, 1) + 1) = "Output Name: The filename of output is not valid! (it contains at least one forbidden char: '':'', ''*'', ''?'', ''""'', ''<'', ''>'', ''|'' )";  //''\'', ''/'', 
        elseif outputNameTextStringTemp == emptystr() then
            errorString(size(errorString, 1) + 1) = "Output Name: The filename of output is empty!";
        end
        
    end
    
    //check if rate is number and is higher than 0
    [isNumberOutputRate, higherThanZeroOutputRate, outNumberOutputRate, errorStringOutputRate] = CheckIfNumberHigherOrEqualAndConvert(outputRateTextString, %f, 0);
    if errorStringOutputRate ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Rate: " + errorStringOutputRate;
    end
    
    
    
    
    
    //check all properties in output xml element
    for i = 1 : 1 : length(outputXMLElement.children)
        
        outputChildrenElement = outputXMLElement.children(i);
        
        if outputChildrenElement.name == "property" then
        // & outputChildrenElement.name ~= "comment" & outputChildrenElement.name ~= "documentation" & outputChildrenElement.name ~= "description" & outputChildrenElement.name ~= "text" then
            
            //check if property can be found in properties available database, if not add error string with the property name
            //propertyIsOK = CheckIfPropertyIsOK(outputChildrenElement.content, %t, propertiesAvailable);
            isCorrect = CheckCorrectValuesType(outputChildrenElement.content, "property", propertiesAvailable, %t, %t);
            
            if isCorrect == %f then
                
                errorString(size(errorString, 1) + 1) = "Output XML definition: The following property was not found: """ + strsubst(outputChildrenElement.content, " ", "") + """";
                
            end
            
        end
        
    end
    
    
    
    
    
    //if there is no error in inputs of simulation start dialog, encode it to xml simulation start document
    if errorString == [] then
        
        
        //define simulation start list string
        simulationStartListString = list( descritionTextMainStringArray', xmlSimulationFileName, jsbsimCommandOptionsTextStringArray', outputProcessingTimeStartTextString, outputProcessingTimeEndTextString, outputProcessingNumberOfGraphsInLineTextString, outputProcessingNumberOfGraphsInWindowTextString, outputProcessingApplicationString, outputNameTextString, outputRateTextString, outputPortTextString, outputProtocolString, outputXMLElement, flightGearPath, flightgearCommandOptionsTextStringArray' );
        
        
        //encode all string data to xml simulation start file and set them to the output
        outXmlSimulationStart = EncodeSimulationStartXMLFromListsString(simulationStartListString, xmlSimulationFileName, propertiesAvailable);
        //if there is no output xml simulation start file, show error and end function
        if outXmlSimulationStart == [] then
            
            //show message box with error
            messagebox("Error occurred during encoding of simulation start data to XML format!", "Error - Encoding of Simulation Start XML failed!", "modal", "error");
            return;
            
        end
        
        
        
        //close the window
        close(handles);
        
        
    //otherwise, if there was any error during check of data validity, show message box with all errors and end function
    else
        
        //show message box with all errors
        messagebox(errorString, "Error - Simulation Start does not contain valid data!", "error", "OK", "modal");
        //outXmlSimulationStart = [];
        return;
        
    end
    
    
    
endfunction



function [outXmlSimulationStart, outXmlSimulation, outXmlReset, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=SimulationStartCancel_callback(handles)
    
    //set output objects to empty array
    outXmlSimulationStart = [];
    outXmlSimulation = [];
    outXmlReset = [];
    outXmlSimulationFilePath = [];
    outXmlSimulationFileName = [];
    outXmlResetFilePath = [];
    outXmlResetFileName = [];
    outXmlAircraftFilePath = [];
    outXmlAircraftFileName = [];
    //close the window
    close(handles);
    
endfunction



//<>functions: SimulationDefinitionPath_callback, EditSimulationDefinitionFile_callback, and EditResetFile_callback were moved after the main simulation start dialog function



function [outXmlOutputElement]=EditOutputDefinitionFile_callback(handles, inXmlOutputElement, propertiesAvailable)
    
    outXmlOutputElement = inXmlOutputElement;
    
    
    //decode output xml element and create labels and values for x_mdialog
    [labels, values] = DecodeJSBSimXMLOutput(outXmlOutputElement);
    
    
    labelMain = ['Simulation start definition of ' + outXmlOutputElement.name ; "(; means repeatable - separated by semicolon)"];
    valueOK = %f;
    while valueOK == %f then
        
        //create the dialog with output boolean check boxes and property text
        values = x_mdialog(labelMain, labels, values);
        
        if values ~= [] then
            
            values = values';
            if strsubst(values(size(values, 2)), " ", "") ~= emptystr() then
                
                isCorrect = CheckCorrectValuesType(values(size(values, 2)), "property", propertiesAvailable, %t, %t);
                
                if isCorrect == %f then
                    //if a property name is not correct show error message and repeat the cycle
                    messagebox(["At least one of the property was not found in global property list!" ; "(Do not forget to separate property names by semicolons ("";"") - otherwise check/add property name in/to ""templates\properties_custom.txt"" or ""templates\properties.txt"")"], "modal", "error");
                    continue;
                end
                
            end
            
            //everything should be OK
            valueOK = %t;
            
            //encode labels and values to output xml element
            outXmlOutputElement = EncodeJSBSimXMLOutput(labels, values);
            
            
        else
            
            break;
            
        end
    
    end
    
    
endfunction



function [outFlightGearPath]=FlightGearPath_callback(handles, inFlightGearPath)
    
    outFlightGearPath = inFlightGearPath;
    
    //show open dialog for FlightGear executable file selection (windows only)
    [fileName, pathName, filterIndex] = uigetfile( ["*.exe","executable files"], outFlightGearPath, "Select executable file of FlightGear (fgfs.exe or fgfs)", %f );
    
    //check if cancel button was not clicked
    if fileName ~= "" & pathName ~= "" & filterIndex ~= 0 then
        
        exePathFile = pathName + filesep() + fileName;
        
        //check if the filename is "fgfs.exe" or "fgfs"
        if convstr(fileName, 'l') == "fgfs.exe" | convstr(fileName, 'l') == "fgfs" then
            
            outFlightGearPath = exePathFile;
            handles.string = outFlightGearPath;
            
        else
        
            messagebox("Wrong filename! The executable filename of FlightGear should be ""fgfs.exe"" or ""fgfs""! (depending on OS)", "modal", "error");
            
        end
        
    end
    
endfunction




//<>function: GetCompleteAircraftAndResetFilePathsAndNames was moved after the main simulation start dialog function



    
    
    
    
    
    
    outXmlSimulationStart = inXmlSimulationStart;
    outXmlSimulation = inXmlSimulation;
    outXmlReset = inXmlReset;
    outXmlSimulationFilePath = inXmlSimulationFilePath;
    outXmlSimulationFileName = inXmlSimulationFileName;
    outXmlResetFilePath = inXmlResetFilePath;
    outXmlResetFileName = inXmlResetFileName;
    outXmlAircraftFilePath = inXmlAircraftFilePath;
    outXmlAircraftFileName = inXmlAircraftFileName;
    defaultPathString = "Path is empty";
    
    
    
    //<>debug only
//    outXmlAircraftFilePath = "C:\Users\<user name>\Documents\Scilab";
//    outXmlResetFilePath = "C:\Users\<user name>\Documents\Scilab";
//    //include files with functions which we use
//    exec XMLfunctions.sci;
//    exec TXTfunctions.sci;
//    exec XMLSimulation.sci;
//    propertiesAvailable = ReadInternalAndCustomProperties();
    
    
    //show wait bar
    waitBarHandle = waitbar('Loading Dialog for simulation start, please wait.');
    
    
    
    //decode simulation start xml
    [simulationStartListString] = DecodeSimulationStartXMLToListsString(outXmlSimulationStart);
    
    
    
    waitbar(0.4, waitBarHandle);
    
    
    
    //get simulation definition file from simulation start xml
    [outXmlSimulationTemp, outXmlSimulationFilePathTemp, outXmlSimulationFileNameTemp] = GetSimulationDefinitionFromSimulationStartOrControllerAdjustmentDefinitionXML(outXmlSimulationStart, "simulation_start");
    if outXmlSimulationTemp ~= [] then
        outXmlSimulation = outXmlSimulationTemp;
        outXmlSimulationFilePath = outXmlSimulationFilePathTemp;
        outXmlSimulationFileName = outXmlSimulationFileNameTemp;
    end
    
    
    
    waitbar(0.5, waitBarHandle);
    
    
    
    //get aircraft and reset file from simulation definition
    [aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition] = GetAircraftAndResetFileFromSimulationDefinition(outXmlSimulation);
    
    
    
    waitbar(0.6, waitBarHandle);
    
    
    
//    //get or create default xml JSBSim output
//    [xmlOutputElement] = GetOrLoadDefaultJSBSimXMLOutput(outXmlSimulationStart);
    
    
    
//    waitbar(0.7, waitBarHandle);
    
    
    
    //get complete aircraft and reset file paths and names

    [outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName] = GetCompleteAircraftAndResetFilePathsAndNames(outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName, aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition);
    
    
    
    waitbar(0.75, waitBarHandle);
    
    
    
    //load new xml reset file
    if outXmlResetFileName ~= emptystr() then
        if fileinfo(outXmlResetFilePath) ~= [] then
            try
                xmlResetTemp = xmlRead(outXmlResetFilePath);
                outXmlReset = xmlResetTemp;
            catch
                messagebox(["Loading of new reset file (defined by initialize filename in simulation definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
            end
        else
            messagebox(["Loading of new reset file (defined by initialize filename in simulation definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
        end
    end
    
    
    
    waitbar(0.8, waitBarHandle);
    
    
    
    
    //create new dialog (figure) with all necessary uicontrols
    SimulationStartDialogID = 55555;
    figSimulationStartDialog = figure(SimulationStartDialogID, 'figure_position', [250, 150],...
                                                                    'figure_size',[900, 600],...
                                                                    "menubar", "none",...
                                                                    "layout", "grid",...
                                                                    "auto_resize", "on",...
                                                                    "resize", "on",...
                                                                    "visible", "off");
    clf(SimulationStartDialogID);
    //f.axes_size = [200 200];
    //as = f.axes_size;  // [width height]
    figSimulationStartDialog.default_axes = "off";
    figSimulationStartDialog.dockable = "off";
    figSimulationStartDialog.figure_name = "Simulation Start Dialog";
    figSimulationStartDialog.infobar_visible = "off";
    figSimulationStartDialog.toolbar = "none";
    figSimulationStartDialog.toolbar_visible = "off";
    //figSimulationStartDialog.figure_size = figSimulationStartDialog.axes_size;
    //figSimulationStartDialog.resizefcn:    This field can be used to store the name of a Scilab function or a Scilab expression as a character string. This character string will be evaluated whenever the user resizes the figure and when the figure is created.
    //figSimulationStartDialog.resize = "off";
    //figSimulationStartDialog.layout = "grid";
    //figSimulationStartDialog.layout_options = createLayoutOptions("grid", [2, 2]);
    
    
    
    //<>debug only
    //c = get(0);
    //set(c, "ShowHiddenProperties", "on");
    
    
    frameMainSimStart = uicontrol(figSimulationStartDialog, "style", "frame",..
               "Tag", "frameMain_SimStart",..
               "layout" , "gridbag",...
               "scrollable", "on",...
               "Title_position", "top",..
               "Title_scroll", "on",..
               "FontSize", 15)//,..
               //"tooltipstring", "tabs")
               //"position", [0, 0, figSimulationStartDialog.figure_size(1)-50, figSimulationStartDialog.figure_size(2)-50],...
               //"callback", "SimulationStart_callback(handles)", ..
               //"Value", 1,..
    
    
    
    descritionLabelMainSimStart = uicontrol(frameMainSimStart, "style", "text", ...
                    "Tag", "descritionLabelMain_SimStart",..
                    "string", "Description", ...
                    "constraints", createConstraints("gridbag", [1, 1, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //editStringDefault = [emptystr(); emptystr(); emptystr()];
    //editStringDefault = emptystr();
    descritionTextMainSimStart = uicontrol(frameMainSimStart, "style", "edit", ...
                    "Tag", "descritionTextMain_SimStart",..
                    "string", simulationStartListString(1), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [1, 2, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    simulationDefinitionPathLabel = uicontrol(frameMainSimStart, "style", "text", ...
                    "Tag", "simulationDefinitionPathLabel",..
                    "string", "Simulation Definition (runscript) file* (path_file)", ...
                    "constraints", createConstraints("gridbag", [1, 3, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //if the path is empty, get default string (which is not valid path)
    if outXmlSimulationFilePath == emptystr() then
        outXmlSimulationFilePath = defaultPathString;
    end
    simulationDefinitionPathButton = uicontrol(frameMainSimStart, "style", "pushbutton", ...
                    "string", outXmlSimulationFilePath, ...
                    "callback", "[outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName]=SimulationDefinitionPath_callback(simulationDefinitionPathButton, outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "simulationDefinitionPathButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [1, 4, 2, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    editSimulationDefinitionFileButton = uicontrol(frameMainSimStart, "style", "pushbutton", ...
                    "string", "Edit Simulation Definition file", ...
                    "callback", "[outXmlSimulation, outXmlReset, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=EditSimulationDefinitionFile_callback(editSimulationDefinitionFileButton, outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlReset, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName, propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "editSimulationDefinitionFileButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [1, 5, 1, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    editResetFileButton = uicontrol(frameMainSimStart, "style", "pushbutton", ...
                    "string", "Edit Reset file", ...
                    "callback", "[outXmlReset]=EditResetFile_callback(editResetFileButton, outXmlReset, outXmlResetFilePath, outXmlResetFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "editResetFileButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [2, 5, 1, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    
    waitbar(0.9, waitBarHandle);
    
    jsbsimCommandOptionsLabel = uicontrol(frameMainSimStart, "style", "text", ...
                    "Tag", "jsbsimCommandOptionsLabel",..
                    "string", "JSBSim Command Options", ...
                    "tooltipstring", "you may separate it by whitespace and line end (""--script"" command option is created by application automatically)", ...
                    "constraints", createConstraints("gridbag", [1, 6, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    jsbsimCommandOptionsText = uicontrol(frameMainSimStart, "style", "edit", ...
                    "Tag", "jsbsimCommandOptionsText",..
                    "string", simulationStartListString(3), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [1, 7, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
                    
                    
    frameOutputProcessingProperties = uicontrol(frameMainSimStart, "style", "frame",..
               "Tag", "frameOutputProcessingProperties",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 8 2 1], [1 1]),...
               "margins", [20 0 10 0], ...
               "FontSize", 15);
               
               
               
    outputProcessingLabel = uicontrol(frameOutputProcessingProperties, "style", "text", ...
                    "Tag", "outputProcessingLabel",..
                    "string", "Output processing properties", ...
                    "constraints", createConstraints("gridbag", [1, 1, 5, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 18, ...
                    "horizontalAlignment", "center");
                    
                    
                    
    outputProcessingApplicationLabel = uicontrol(frameOutputProcessingProperties, "style", "text", ...
                    "Tag", "outputProcessingApplicationLabel",..
                    "string", "Application for output processing", ...
                    "constraints", createConstraints("gridbag", [1, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    valueOutputProcessingApplication = 1;
    if convstr(simulationStartListString(8), 'l') ~= "scilab_v6" then
        valueOutputProcessingApplication = 2;
    end
    outputProcessingApplicationPopupmenu = uicontrol(frameOutputProcessingProperties, "style", "popupmenu", ...
                    "Tag", "outputProcessingApplicationPopupmenu",..
                    "string", "SCILAB_V6|FLIGHTGEAR", ...
                    "value", valueOutputProcessingApplication, ...
                    "constraints", createConstraints("gridbag", [1, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
               
               
               
    outputProcessingTimeStartLabel = uicontrol(frameOutputProcessingProperties, "style", "text", ...
                    "Tag", "outputProcessingTimeStartLabel",..
                    "string", "Start time of processing [s]", ...
                    "tooltipstring", "Scilab only!", ...
                    "constraints", createConstraints("gridbag", [2, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputProcessingTimeStartText = uicontrol(frameOutputProcessingProperties, "style", "edit", ...
                    "Tag", "outputProcessingTimeStartText",..
                    "string", simulationStartListString(4), ...
                    "constraints", createConstraints("gridbag", [2, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
               
               
               
    outputProcessingTimeEndLabel = uicontrol(frameOutputProcessingProperties, "style", "text", ...
                    "Tag", "outputProcessingTimeEndLabel",..
                    "string", "End time of processing [s]", ...
                    "tooltipstring", "Scilab only!", ...
                    "constraints", createConstraints("gridbag", [3, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputProcessingTimeEndText = uicontrol(frameOutputProcessingProperties, "style", "edit", ...
                    "Tag", "outputProcessingTimeEndText",..
                    "string", simulationStartListString(5), ...
                    "constraints", createConstraints("gridbag", [3, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
               
               
               
    outputProcessingNumberOfGraphsInLineLabel = uicontrol(frameOutputProcessingProperties, "style", "text", ...
                    "Tag", "outputProcessingNumberOfGraphsInLineLabel",..
                    "string", "Number of graphs in line of processing figure", ...
                    "tooltipstring", "Scilab only!", ...
                    "constraints", createConstraints("gridbag", [4, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputProcessingNumberOfGraphsInLineText = uicontrol(frameOutputProcessingProperties, "style", "edit", ...
                    "Tag", "outputProcessingNumberOfGraphsInLineText",..
                    "string", simulationStartListString(6), ...
                    "constraints", createConstraints("gridbag", [4, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
               
               
               
    outputProcessingNumberOfGraphsInWindowLabel = uicontrol(frameOutputProcessingProperties, "style", "text", ...
                    "Tag", "outputProcessingNumberOfGraphsInWindowLabel",..
                    "string", "Number of graphs in figure window", ...
                    "tooltipstring", "Scilab only!", ...
                    "constraints", createConstraints("gridbag", [5, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputProcessingNumberOfGraphsInWindowText = uicontrol(frameOutputProcessingProperties, "style", "edit", ...
                    "Tag", "outputProcessingNumberOfGraphsInWindowText",..
                    "string", simulationStartListString(7), ...
                    "constraints", createConstraints("gridbag", [5, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    
    
    frameOutputProperties = uicontrol(frameMainSimStart, "style", "frame",..
               "Tag", "frameOutputProperties",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 9 2 1], [1 1]),...
               "margins", [20 0 10 0], ...
               "FontSize", 15);
               
               
               
    editOutputDefinitionButton = uicontrol(frameOutputProperties, "style", "pushbutton", ...
                    "string", "Edit output file definition", ...
                    "callback", "[simulationStartListString(13)]=EditOutputDefinitionFile_callback(editOutputDefinitionButton, simulationStartListString(13), propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "editOutputDefinitionButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [1, 2, 1, 1], [0.5, 1], "horizontal", "center"));
               
               
               
    outputNameLabel = uicontrol(frameOutputProperties, "style", "text", ...
                    "Tag", "outputNameLabel",..
                    "string", "output filename (or localhost for FlightGear)", ...
                    "tooltipstring", "Filename of output cannot contains: '':'', ''*'', ''?'', ''""'', ''<'', ''>'', ''|'' )",...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputNameText = uicontrol(frameOutputProperties, "style", "edit", ...
                    "Tag", "outputNameText",..
                    "string", simulationStartListString(9), ...
                    "constraints", createConstraints("gridbag", [2, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    outputRateLabel = uicontrol(frameOutputProperties, "style", "text", ...
                    "Tag", "outputRateLabel",..
                    "string", "output rate (Hz)", ...
                    "constraints", createConstraints("gridbag", [3, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputRateText = uicontrol(frameOutputProperties, "style", "edit", ...
                    "Tag", "outputRateText",..
                    "string", simulationStartListString(10), ...
                    "constraints", createConstraints("gridbag", [3, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    outputPortLabel = uicontrol(frameOutputProperties, "style", "text", ...
                    "Tag", "outputPortLabel",..
                    "string", "Output port", ...
                    "tooltipstring", "FlightGear only!", ...
                    "constraints", createConstraints("gridbag", [4, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputPortText = uicontrol(frameOutputProperties, "style", "edit", ...
                    "Tag", "outputPortText",..
                    "string", simulationStartListString(11), ...
                    "constraints", createConstraints("gridbag", [4, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    outputProtocolLabel = uicontrol(frameOutputProperties, "style", "text", ...
                    "Tag", "outputProtocolLabel",..
                    "string", "Output protocol", ...
                    "tooltipstring", "FlightGear only!", ...
                    "constraints", createConstraints("gridbag", [5, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    valueOutputProtocol = 2;
    if convstr(simulationStartListString(12), 'l') ~= "udp" then
        valueOutputProtocol = 1;
    end
    outputProtocolPopupmenu = uicontrol(frameOutputProperties, "style", "popupmenu", ...
                    "Tag", "outputProtocolPopupmenu",..
                    "string", "tcp|udp", ...
                    "value", valueOutputProtocol, ...
                    "constraints", createConstraints("gridbag", [5, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    flightgearPathLabel = uicontrol(frameOutputProperties, "style", "text", ...
                    "Tag", "flightgearPathLabel",..
                    "string", "FlightGear executable file path (path_file)", ...
                    "tooltipstring", "FlightGear only!", ...
                    "constraints", createConstraints("gridbag", [1, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //if the path is empty, get default string (which is not valid path)
    if simulationStartListString(14) == emptystr() then
        simulationStartListString(14) = defaultPathString;
    end
    flightgearPathButton = uicontrol(frameOutputProperties, "style", "pushbutton", ...
                    "string", simulationStartListString(14), ...
                    "callback", "[simulationStartListString(14)]=FlightGearPath_callback(flightgearPathButton, simulationStartListString(14))", ...
                    "fontsize", 15, ...
                    "Tag", "flightgearPathButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [2, 3, 4, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    flightgearCommandOptionsLabel = uicontrol(frameMainSimStart, "style", "text", ...
                    "Tag", "flightgearCommandOptionsLabel",..
                    "string", "FlightGear Command Options", ...
                    "tooltipstring", "you may separate it by whitespace and line end (""--native-fdm"" and ""--fdm=external"" command options are created by application automatically)", ...
                    "constraints", createConstraints("gridbag", [1, 10, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    flightgearCommandOptionsText = uicontrol(frameMainSimStart, "style", "edit", ...
                    "Tag", "flightgearCommandOptionsText",..
                    "string", simulationStartListString(15), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [1, 11, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    
    
    
    frameOKCancel = uicontrol(frameMainSimStart, "style", "frame",..
               "Tag", "frameOKCancel",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 10009 2 1], [1 1]),.. //because changing of constraints has no effect, the constraints line is set to 10002+7, therefore, position of dialog buttons  will work properly only when there will be no more than 10000 events defined by user in a single simulation script.
               "margins", [20 0 0 0], ...
               "FontSize", 15);
    
    //create OK and Cancel button
    OKButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "OK", ...
                    "callback", "[outXmlSimulationStart]=SimulationStartOK_callback(figSimulationStartDialog, descritionTextMainSimStart.string, outXmlSimulationFilePath, outXmlSimulationFileName, jsbsimCommandOptionsText.string, outputProcessingTimeStartText.string, outputProcessingTimeEndText.string, outputProcessingNumberOfGraphsInLineText.string, outputProcessingNumberOfGraphsInWindowText.string, outputProcessingApplicationPopupmenu.value, simulationStartListString(13), outputNameText.string, outputRateText.string, outputPortText.string, outputProtocolPopupmenu.value, simulationStartListString(14), flightgearCommandOptionsText.string, propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "OKButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "center", [0, 0]));
                    
    CancelButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "Cancel", ...
                    "callback", "[outXmlSimulationStart, outXmlSimulation, outXmlReset, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=SimulationStartCancel_callback(figSimulationStartDialog)", ...
                    "fontsize", 15, ...
                    "Tag", "CancelButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "center"));
    
    
    
    waitbar(1.0, waitBarHandle);
    
    //turn off auto resize function of figure, disallow manual resize and set it to be visible
    //figSimulationStartDialog.auto_resize = "off";
    //figSimulationStartDialog.resize = "off";
    figSimulationStartDialog.visible = "on";
    
    
    //close wait bar window
    close(waitBarHandle);
    
    
    
    //wait until is clicked
    ibutton = -1;
    iwin = -1;
    //while the current window is not closed
    while(ibutton ~= -1000 | iwin ~= figSimulationStartDialog.figure_id)
        
        //wait until is clicked
        [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
        
//        //<>debug only
//        disp("Opened window is still alive!");
//        disp(string(ibutton));
//        disp(string(xcoord));
//        disp(string(ycoord));
//        disp(string(iwin));
//        disp(string(cbmenu));
        
        //check if some callback was clicked
        if ibutton == -2 then
            
            
            //if OK was clicked, execute OK callback
            if strindex(cbmenu, OKButton.callback) then
                
                //disp("OK clicked"); //<>debug only
                //handles = figSimulationStartDialog;
                execstr(OKButton.callback);
                
                //if there is output with xml simulation start file, break this cycle
                if outXmlSimulationStart ~= [] then
                    break;

                end
                
                
                
            //else if Cancel was clicked, execute Cancel callback
            elseif strindex(cbmenu, CancelButton.callback) then
                
                //disp("Cancel clicked"); //<>debug only
                //handles = figSimulationStartDialog;
                execstr(CancelButton.callback);
                break;
                
                
                
            //else if button for simulation definition path selection was clicked
            elseif strindex(cbmenu, simulationDefinitionPathButton.callback) then
                
                //disp("simulationDefinitionPathButton clicked"); //<>debug only
                //handles = simulationDefinitionPathButton;
                execstr(simulationDefinitionPathButton.callback);
                
                //get aircraft and reset file from simulation definition
                [aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition] = GetAircraftAndResetFileFromSimulationDefinition(outXmlSimulation);
                //get complete aircraft and reset file paths and names
                [outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName] = GetCompleteAircraftAndResetFilePathsAndNames(outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName, aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition);
                //load new xml reset file
                if outXmlResetFileName ~= emptystr() then
                    if fileinfo(outXmlResetFilePath) ~= [] then
                        try
                            xmlResetTemp = xmlRead(outXmlResetFilePath);
                            outXmlReset = xmlResetTemp;
                        catch
                            messagebox(["Loading of new reset file (defined by initialize filename in simulation definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
                        end
                    else
                        messagebox(["Loading of new reset file (defined by initialize filename in simulation definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
                    end
                end
                
                
                
            //else if button for edit of simulation definition was clicked
            elseif strindex(cbmenu, editSimulationDefinitionFileButton.callback) then
                
                //disp("editSimulationDefinitionFileButton clicked"); //<>debug only
                //handles = editSimulationDefinitionFileButton;
                execstr(editSimulationDefinitionFileButton.callback);
                
                
                
            //else if button for edit of reset file was clicked
            elseif strindex(cbmenu, editResetFileButton.callback) then
                
                //disp("editResetFileButton clicked"); //<>debug only
                //handles = editResetFileButton;
                execstr(editResetFileButton.callback);
                
                
                
            //else if button for edit of xml output definition was clicked
            elseif strindex(cbmenu, editOutputDefinitionButton.callback) then
                
                //disp("editOutputDefinitionButton clicked"); //<>debug only
                //handles = editOutputDefinitionButton;
                execstr(editOutputDefinitionButton.callback);
                
                
                
            //else if button for path selection of FlightGear executable was clicked
            elseif strindex(cbmenu, flightgearPathButton.callback) then
                
                //disp("flightgearPathButton clicked"); //<>debug only
                //handles = flightgearPathButton;
                execstr(flightgearPathButton.callback);
                
                
                
            end
            
            
            
        //else if the dialog was closed, it is same as when cancel button is clicked
        elseif ibutton == -1000 then
            
            //set output objects to empty array
            outXmlSimulationStart = [];
            outXmlSimulation = [];
            outXmlReset = [];
            outXmlSimulationFilePath = [];
            outXmlSimulationFileName = [];
            outXmlResetFilePath = [];
            outXmlResetFileName = [];
            outXmlAircraftFilePath = [];
            outXmlAircraftFileName = [];
            break;
            
            
            
        end
        
    end
    //disp("The correct window was closed!"); //<>debug only
    
    
endfunction





//callback for simulation definition path file selection
function [outXmlSimulation, outXmlSimulationDefinitionFilePath, outXmlSimulationDefinitionFileName]=SimulationDefinitionPath_callback(handles, inXmlSimulation, inXmlSimulationDefinitionFilePath, inXmlSimulationDefinitionFileName)
    
    outXmlSimulation = inXmlSimulation;
    outXmlSimulationDefinitionFilePath = inXmlSimulationDefinitionFilePath;
    outXmlSimulationDefinitionFileName = inXmlSimulationDefinitionFileName;
    
    //show open dialog for simulation definition file selection
    [fileName, pathName, filterIndex] = uigetfile( ["*.xml","XML files"], "scripts", "Select file with simulation (runscript) definition", %f );
    
    //check if cancel button was not clicked
    if fileName ~= "" & pathName ~= "" & filterIndex ~= 0 then
        
        xmlPathFile = pathName + filesep() + fileName;
        //read xml file with (maybe) simulation definition (runscript) information
        xmlSimulationDefinitionTemp = xmlRead(xmlPathFile);
        errorString=ValidateXMLdocument(xmlSimulationDefinitionTemp);
        
        //check if the root xml element is "runscript"
        if convstr(xmlSimulationDefinitionTemp.root.name, 'l') == "runscript" then
            
            outXmlSimulationDefinitionFileName = GetFileNameWithoutExtension(fileName, ".xml");
            outXmlSimulationDefinitionFilePath = xmlPathFile;
            handles.string = outXmlSimulationDefinitionFilePath;
            CheckAndDeleteXMLDoc(outXmlSimulation)
            outXmlSimulation = xmlSimulationDefinitionTemp;
            
        else
            
            CheckAndDeleteXMLDoc(xmlSimulationDefinitionTemp);
            messagebox("Wrong format! The XML file is not a valid simulation definition (runscript) file!", "modal", "error");
            
        end
        
    end
    
endfunction



function [outXmlSimulation, outXmlReset, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=EditSimulationDefinitionFile_callback(handles, inXmlSimulation, inXmlSimulationFilePath, inXmlSimulationFileName, inXmlReset, inXmlResetFilePath, inXmlResetFileName, inXmlAircraftFilePath, inXmlAircraftFileName, propertiesAvailable)
    
    outXmlSimulation = inXmlSimulation;
    outXmlReset = inXmlReset;
    outXmlResetFilePath = inXmlResetFilePath;
    outXmlResetFileName = inXmlResetFileName;
    outXmlAircraftFilePath = inXmlAircraftFilePath;
    outXmlAircraftFileName = inXmlAircraftFileName;
    
    
    rootSimulationName = "runscript";
    //if a simulation file path is not empty
    if inXmlSimulationFilePath ~= emptystr() & inXmlSimulationFileName ~= emptystr() then
        
        //if the root name element of the currently opened/edited xml simulation file is "runscript", it is valid JSBSim simulation file
        if outXmlSimulation.root.name == rootSimulationName then
            //if the currently opened simulation file contains any children element
            if length(outXmlSimulation.root.children) > 0 then
                
                //show dialog for simulation definition
                [xmlSimulationTemp, xmlResetFilePathTemp, xmlResetFileNameTemp, xmlAircraftFilePathTemp, xmlAircraftFileNameTemp] = DialogSimulationDefinitionOkCancel(outXmlSimulation, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName, propertiesAvailable);
                
                if xmlSimulationTemp ~= [] then
                    
                    outXmlSimulation = xmlSimulationTemp;
                    outXmlResetFilePath = xmlResetFilePathTemp;
                    outXmlResetFileName = xmlResetFileNameTemp;
                    //load new xml reset file
                    xmlResetTemp = xmlRead(outXmlResetFilePath);
                    if xmlResetTemp ~= [] then
                        outXmlReset = xmlResetTemp;
                    else
                        messagebox(["Loading of new reset file (defined by reset path in simulation dialog) failed!" ; "The original reset file is kept."], "modal", "error");
                    end
                    outXmlAircraftFilePath = xmlAircraftFilePathTemp;
                    outXmlAircraftFileName = xmlAircraftFileNameTemp;
                    
                    //save the simulation file at the path in input parameter
                    if typeof(outXmlSimulation) == "XMLDoc" then
                        if xmlIsValidObject(outXmlSimulation) == %t then
                            
                            //set name attribute of the root xml element to the filename defined by input parameter
                            outXmlSimulation.root.attributes.name = inXmlSimulationFileName;
                            
                            //save xml simulation file
                            xmlWrite(outXmlSimulation, inXmlSimulationFilePath, %t);
                            
                            messagebox("Simulation definition was saved sucessfully!", "modal", "info");
                            
                        end
                    end
                    
                end
                
            else
                messagebox("Wrong format! The currently opened XML simulation file does not contain any children XML elements!", "modal", "error");
            end
        else
            messagebox("Wrong format! The currently opened XML file is not a valid simulation file!", "modal", "error");
        end
        
    else
        messagebox("The current simulation file cannot be loaded - The file path or filename is empty!", "modal", "error");
    end
    
endfunction



//callback for reset path file selection
function [outXmlReset]=EditResetFile_callback(handles, inXmlReset, inXmlResetFilePath, inXmlResetFileName)
    
    outXmlReset = inXmlReset;
    
    
    rootResetName = "initialize";
    //if a reset file path and reset filename are not empty
    if inXmlResetFilePath ~= emptystr() & inXmlResetFileName ~= emptystr() then
        
        //if the root name element of the currently edited xml reset file is "initialize", it is valid JSBSim reset file
        if outXmlReset.root.name == rootResetName then
            
            
                xmlResetTemplate = emptystr();
                xmlResetVersion = outXmlReset.root.attributes.version;
                //if a reset file version should be 1
                if xmlResetVersion == [] | strsubst(xmlResetVersion, " ", "") == "1" then
                    //load template file
                    xmlResetTemplate = xmlRead("templates" + filesep() + "Simulation" + filesep() + "reset-v1.xml");
                //else if a reset file version should be 2
                elseif strsubst(xmlResetVersion, " ", "") == "2" then
                    //load template file
                    xmlResetTemplate = xmlRead("templates" + filesep() + "Simulation" + filesep() + "reset-v2.xml");
                //otherwise, some error occurred because this situation cannot happen
                else
                    messagebox("The choice of new reset file version is not supported!", "modal", "error")
                    return;
                end
                errorString=ValidateXMLdocument(xmlResetTemplate);
                
                
                //if the root name element of xml template reset file is "initialize", it is valid JSBSim template reset file
                if xmlResetTemplate.root.name == rootResetName then
                    //if the template reset file contains any children element
                    if length(xmlResetTemplate.root.children) > 0 then
                        
                        
                        //decode labels and values from template
                        [labelsTemplate, possibleInputTypesList] = DecodeInitialParametersLabelsValues(xmlResetTemplate);
                        //decode labels and values used in edit dialog (from opened file or from data in memory)
                        [labels, values] = DecodeInitialParametersLabelsValues(outXmlReset);
                        
                        //join labels and values to one piece
                        [outLabels, outValues, possibleInputTypesList]=JoinResetFileAndTemplate(labels, values, labelsTemplate, possibleInputTypesList);
                        
                        //include information about possible inputs to labels
                        outLabels = GetLabelsWithPossibleInputInformation(outLabels, possibleInputTypesList);
                        
                        if outLabels ~= [] & outValues ~= [] & possibleInputTypesList ~= [] then
                            
                            //show dialog for editation, check the validity of data content and save the reset file if selected
                            ShowCheckSaveResetParametersDialog(outXmlReset, outLabels, outValues, possibleInputTypesList, inXmlResetFilePath, inXmlResetFileName);
                            
                        else
                            messagebox("Wrong format! No labels, values, or possible input types were found and joined!", "modal", "error");
                        end
                        
                        
                    else
                        messagebox("Wrong format! The template XML reset file does not contain any children XML elements (check templates" + filesep() + "Simulation" + filesep() + "reset-v1.xml and templates" + filesep() + "Simulation" + filesep() + "reset-v2.xml)!", "modal", "error");
                    end
                    
                else
                    messagebox("Wrong format! The template XML file is not a valid reset file (check templates" + filesep() + "Simulation" + filesep() + "reset-v1.xml and templates" + filesep() + "Simulation" + filesep() + "reset-v2.xml)!", "modal", "error");
                end
                
                
                //erase memory with reset template xml file
                CheckAndDeleteXMLDoc(xmlResetTemplate);
                
                
        else
            messagebox("Wrong format! The current XML file is not a valid reset file!", "modal", "error");
        end
        
    else
        messagebox("The current reset file cannot be loaded - The file path or filename is empty!", "modal", "error");
    end
    
endfunction



//get complete aircraft and reset file paths and names
function [outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName]=GetCompleteAircraftAndResetFilePathsAndNames(inXmlAircraftFilePath, inXmlAircraftFileName, inXmlResetFilePath, inXmlResetFileName, newAircraftFileFromSimulationDefinition, newResetFileFromSimulationDefinition)
    
    outXmlAircraftFilePath = inXmlAircraftFilePath;
    outXmlAircraftFileName = inXmlAircraftFileName;
    outXmlResetFilePath = inXmlResetFilePath;
    outXmlResetFileName = inXmlResetFileName;
    
    
    //get complete aircraft and reset file paths and names
    extensionXML = ".xml";
    differentAircraft = %f;
    
    //if the aircraft file path is empty or the filename is not equal to name of the aircraft filename from xml simulation, set it to the new path
    if outXmlAircraftFilePath == emptystr() | (outXmlAircraftFileName ~= newAircraftFileFromSimulationDefinition & outXmlAircraftFileName ~= newAircraftFileFromSimulationDefinition + extensionXML) then
        //pwd() gets current working directory which has to contain this application (GUI.sce)
        outXmlAircraftFilePath = pwd() + filesep() + "aircraft" + filesep() + newAircraftFileFromSimulationDefinition + filesep() + newAircraftFileFromSimulationDefinition + extensionXML;
        outXmlAircraftFileName = newAircraftFileFromSimulationDefinition;
        differentAircraft = %t;
    end
    
    //if the reset file path is empty or the last part is not equal to name of the reset filename from xml simulation, or it is a different aircraft, set it to the new path
    if outXmlResetFilePath == emptystr() | (outXmlResetFileName ~= newResetFileFromSimulationDefinition & outXmlResetFileName ~= newResetFileFromSimulationDefinition + extensionXML) | differentAircraft == %t then
        //pwd() gets current working directory which has to contain this application (GUI.sce)
        outXmlResetFilePath = pwd() + filesep() + "aircraft" + filesep() + newAircraftFileFromSimulationDefinition + filesep() + newResetFileFromSimulationDefinition + extensionXML;
        outXmlResetFileName = newResetFileFromSimulationDefinition;
    end
    
    
endfunction








//FlightGear execute dialog functions
//(<>Scilab bug - created because using "start" command in command line causes parse error or crash after ending of a function or a command and executing another)


//globals with FlightGear figure dialog and a FlightGear command
global flightGearFigureDialog;
flightGearFigureDialog = [];
global flightGearExecutionCommandDialog;
flightGearExecutionCommandDialog = emptystr();

//<>debug only
//CreateFlightGearWindowForExecution("""C:\Program Files\FlightGear\bin\Win64\fgfs.exe"" --native-fdm=socket,in,10,,5500,tcp --fdm=external --fg-root=""C:/Program Files/FlightGear/data"" --fg-aircraft=""C:\Program Files\FlightGear\data\Aircraft"" --aircraft=""V-TS-JSBSim"" --geometry=800x500 --timeofday=noon --disable-clouds3d --shading-flat --notrim --fog-fastest --disable-specular-highlight --disable-random-objects --disable-panel --disable-horizon-effect")
function [flightGearFigure, flightGearFigure_OkButton]=CreateFlightGearWindowForExecution(flightGearExecutionCommand)
    
    
    screenSize_px = get(0, "screensize_px");
    screenWidth_px = screenSize_px(3);
    screenHeight_px = screenSize_px(4);
    figureSizeFlightGearDialog = [220, 130];
    positionFlightGearDialogWidth = screenWidth_px / 2 - figureSizeFlightGearDialog(1) / 2;
    positionFlightGearDialogHeight = screenHeight_px / 2 - figureSizeFlightGearDialog(2) / 2;
    
    //create new dialog (figure) with all necessary uicontrols
    flightGearFigure = figure('figure_position', [positionFlightGearDialogWidth, positionFlightGearDialogHeight],...
                              'figure_size', figureSizeFlightGearDialog,...
                              "menubar", "none",...
                              "layout", "grid",...
                              "auto_resize", "on",...
                              "resize", "off",...
                              "visible", "off");
                              //"closerequestfcn", "FlightGearWindowForExecution_Close_callback()", ...
    flightGearFigure.default_axes = "off";
    flightGearFigure.dockable = "off";
    flightGearFigure.figure_name = "FlightGear Execution Dialog";
    flightGearFigure.infobar_visible = "off";
    flightGearFigure.toolbar = "none";
    flightGearFigure.toolbar_visible = "off";
    
    
    flightGear_frameMain = uicontrol(flightGearFigure, "style", "frame",..
               "Tag", "FlightGearDialog_frameMain",..
               "layout" , "gridbag",...
               "FontSize", 15)//,..
               //"tooltipstring", "tabs")
               //"position", [0, 0, figSimulationStartDialog.figure_size(1)-50, figSimulationStartDialog.figure_size(2)-50],...
               //"callback", "SimulationStart_callback(handles)", ..
               //"Value", 1,..
    
    //create OK and Cancel button
    flightGearFigure_OkButton = uicontrol(flightGear_frameMain, "style", "pushbutton", ...
                    "string", "Run FlightGear", ...
                    "callback", "FlightGearWindowForExecution_FlightGearExecutionOK_callback()", ...
                    "fontsize", 21, ...
                    "Tag", "FlightGearDialog_OKButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "center", [0, 0]));
    
    //set figure to be visible
    flightGearFigure.visible = "on";
    
    
    //set the globals
    global flightGearFigureDialog;
    flightGearFigureDialog = flightGearFigure;
    global flightGearExecutionCommandDialog;
    flightGearExecutionCommandDialog = flightGearExecutionCommand;
    
    
endfunction

function FlightGearWindowForExecution_FlightGearExecutionOK_callback()
    
    global flightGearFigureDialog;
    global flightGearExecutionCommandDialog;
    
    if flightGearFigureDialog ~= [] then
        
        //set the figure to be invisibile
        flightGearFigureDialog.visible = "off";
        flightGearFigureDialog.user_data = 1;
        
        if strsubst(flightGearExecutionCommandDialog, " ", "") ~= emptystr() then
            //run FlightGear (the code is written to run FlightGear subsequently due to the Scilab bug)
            dos(flightGearExecutionCommandDialog);
        end
        
        //close the invisible figure
        close(flightGearFigureDialog);
        
        //set default value to global FlightGear dialog properties
        flightGearFigureDialog = [];
        flightGearExecutionCommandDialog = emptystr();
        
    end
    
endfunction








//Dialog for Controller Adjustment Definition

function [outXmlControllerAdjustmentDefinition, outXmlSimulation, outXmlReset, outXmlAutopilot, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName, outXmlAutopilotFilePath, outXmlAutopilotFileName]=DialogControllerAdjustmentDefinitionOkCancel(inXmlControllerAdjustmentDefinition, inXmlSimulation, inXmlReset, inXmlAutopilot, inXmlSimulationFilePath, inXmlSimulationFileName, inXmlResetFilePath, inXmlResetFileName, inXmlAircraftFilePath, inXmlAircraftFileName, inXmlAutopilotFilePath, inXmlAutopilotFileName, propertiesAvailable)
    
    
function [outXmlControllerAdjustmentDefinition]=ControllerAdjustmentDefinitionOK_callback(handles, descritionTextMainStringArray, xmlSimulationFilePath, xmlSimulationFileName, xmlAutopilotFilePath, xmlAutopilotFileName, autopilotAdjustableComponentPopupmenuValue, xmlAutopilotAdjustableComponentsListList, outputNameTextString, outputRateTextString, outputPropertyTextString, outputAnalysisTimeStartTextString, outputAnalysisTimeEndTextString, outputAnalysisMethodPopupmenuValue, methodParametersXMLElement, jsbsimCommandOptionsTextStringArray, propertiesAvailable)
    
    
    outXmlControllerAdjustmentDefinition = [];
    controllerAdjustmentDefinitionListString = list();
    //error string for all errors which may occur
    errorString = [];
    
    zieglerNichols_CriticalGainTag = "ZIEGLER_NICHOLS-CRITICAL_GAIN";
    geneticAlgorithmTag = "GENETIC_ALGORITHM";
    
    
    
    
    //check if script file exists and is in correct format, if it is not, add script path error string to the main error string
    errorStringScript = CheckXMLJSBSimFileFormat(xmlSimulationFilePath, "script", "runscript");
    if errorStringScript ~= emptystr() then
        errorString(size(errorString, 1) + 1) = errorStringScript;
    end
    
    
    
    //check if autopilot file exists and is in correct format, if it is not, add autopilot path error string to the main error string
    errorStringAutopilot = CheckXMLJSBSimFileFormat(xmlAutopilotFilePath, "autopilot", "autopilot");
    if errorStringAutopilot ~= emptystr() then
        errorString(size(errorString, 1) + 1) = errorStringAutopilot;
    end
    
    
    
    
    //get autopilot_adjustable_component
    xmlAutopilotAdjustableComponent = GetAutopilotAdjustableComponentFromPopupValue(autopilotAdjustableComponentPopupmenuValue, xmlAutopilotAdjustableComponentsListList);
    //check if the xml component is supported for adjustment
    if xmlAutopilotAdjustableComponent ~= [] then
        
        if xmlAutopilotAdjustableComponent.name ~= "pid" & xmlAutopilotAdjustableComponent.name ~= "pure_gain" then
            errorString(size(errorString, 1) + 1) = "Selected autopilot adjustable component with name: """ + xmlAutopilotAdjustableComponent.attributes.name + """ and JSBSim type: " + xmlAutopilotAdjustableComponent.name + """ is not supported JSBSim type of component; only ""pid"", and ""pure_gain"" types are supported!";
        end
        
    else
        errorString(size(errorString, 1) + 1) = "Selected autopilot adjustable component was not found in the xml autopilot definition";
    end
    
    
    
    
    //check if filename contains forbidden chars in name (windows only)
    outputNameTextStringTemp = strsubst(outputNameTextString, " ", "");
    if strindex(outputNameTextStringTemp, ['\', '/', ':', '*', '?', '""', '<', '>', '|']) ~= [] then
        errorString(size(errorString, 1) + 1) = "Output Name: The filename of output is not valid! (it contains at least one forbidden char: ''\'', ''/'', '':'', ''*'', ''?'', ''""'', ''<'', ''>'', ''|'' )";
    elseif outputNameTextStringTemp == emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Name: The filename of output is empty!";
    end
    
    
    //check if rate is number and is higher than 0
    [isNumberOutputRate, higherThanZeroOutputRate, outNumberOutputRate, errorStringOutputRate] = CheckIfNumberHigherOrEqualAndConvert(outputRateTextString, %f, 0);
    if errorStringOutputRate ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Rate: " + errorStringOutputRate;
    end
    
    
    
    //check if output property is in properties available database
    outputPropertyTextStringWithoutSpaces = strsubst(outputPropertyTextString, " ", "");
    outputPropertyFound = FindPropertyInPropertiesAvailable(outputPropertyTextStringWithoutSpaces, propertiesAvailable);
    if outputPropertyFound == %f then
        errorString(size(errorString, 1) + 1) = "Output Property: Property """ + outputPropertyTextStringWithoutSpaces + """ does not exist in propertiesAvailable database!";
    end
    
    
    
    
    
    //check output analysis start and end values - add error string if necessary
    
    //check if the start value is higher than 0
    [isNumberHigherThanZeroOutputAnalysisTimeStart, higherThanZeroOutputAnalysisTimeStart, outNumberHigherThanZeroOutputAnalysisTimeStart, errorStringHigherThanZeroOutputAnalysisTimeStart] = CheckIfNumberHigherOrEqualAndConvert(outputAnalysisTimeStartTextString, %f, 0);
    if errorStringHigherThanZeroOutputAnalysisTimeStart ~= emptystr() then
        
        [isNumberEqualToZeroOutputAnalysisTimeStart, equalToZeroOutputAnalysisTimeStart, outNumberEqualToZeroOutputAnalysisTimeStart, errorStringEqualToZeroOutputAnalysisTimeStart] = CheckIfNumberHigherOrEqualAndConvert(outputAnalysisTimeStartTextString, %t, 0);
        if errorStringEqualToZeroOutputAnalysisTimeStart ~= emptystr() then
            errorString(size(errorString, 1) + 1) = "Output Analysis Time Start: " + "The input string has to be higher than or equal to ""0""!  """ + outputAnalysisTimeStartTextString + """" + "  converted value: """ + string(outNumberHigherThanZeroOutputAnalysisTimeStart) + """";
        end
        
    end
    
    //check if the end value is higher than 0
    [isNumberOutputAnalysisTimeEnd, higherThanZeroOutputAnalysisTimeEnd, outNumberOutputAnalysisTimeEnd, errorStringOutputAnalysisTimeEnd] = CheckIfNumberHigherOrEqualAndConvert(outputAnalysisTimeEndTextString, %f, 0);
    if errorStringOutputAnalysisTimeEnd ~= emptystr() then
        errorString(size(errorString, 1) + 1) = "Output Analysis Time End: " + errorStringOutputAnalysisTimeEnd;
    end
    
    
    //check time numbers and compare with each other
    //check start and end time numbers
    if outNumberHigherThanZeroOutputAnalysisTimeStart ~= [] & outNumberOutputAnalysisTimeEnd ~= [] then
        if outNumberHigherThanZeroOutputAnalysisTimeStart >= outNumberOutputAnalysisTimeEnd then
            errorString(size(errorString, 1) + 1) = "Output analysis time start has to be lower than time end!  Time start: " + string(outNumberHigherThanZeroOutputAnalysisTimeStart) + "  Time end: " + string(outNumberOutputAnalysisTimeEnd);
        end
    end
    
    
    
    //check output analysis method selection
    outputAnalysisMethodString = zieglerNichols_CriticalGainTag;
    if outputAnalysisMethodPopupmenuValue == 2 then
        outputAnalysisMethodString = geneticAlgorithmTag;
    elseif outputAnalysisMethodPopupmenuValue ~= 1 then
        errorString(size(errorString, 1) + 1) = "Output Analysis Method Popupmenu Value is not valid! Only 1 (ZIEGLER_NICHOLS-CRITICAL_GAIN) or 2 (GENETIC_ALGORITHM) are allowed!";
    end
    
    
    
    
    
    //decode method parameters xml element and create labels and values
    [labelsXmlMethodParameters, valuesXmlMethodParameters] = DecodeXmlMethodParameters(methodParametersXMLElement, outputAnalysisMethodPopupmenuValue);
    //check all options in method parameters xml element depending on selected controller adjustment method
    [isCorrectXmlMethodParameters, errorMessageXmlMethodParameters] = CheckCorrectXmlMethodParameters(valuesXmlMethodParameters, outputAnalysisMethodPopupmenuValue, labelsXmlMethodParameters);
    if isCorrectXmlMethodParameters == %f then
        errorString(size(errorString, 1) + 1) = "Method Parameters error: " + errorMessageXmlMethodParameters;
    end
    
    
    
    
    
    //if there is no error in inputs of controller adjustment definition dialog, encode it to xml controller adjustment definition document
    if errorString == [] then
        
        
        //define controller adjustment definition list string
        controllerAdjustmentDefinitionListString = list( descritionTextMainStringArray', xmlSimulationFileName, xmlAutopilotFileName, xmlAutopilotAdjustableComponent, outputNameTextString, outputRateTextString, outputPropertyTextStringWithoutSpaces, outputAnalysisTimeStartTextString, outputAnalysisTimeEndTextString, outputAnalysisMethodString, methodParametersXMLElement, jsbsimCommandOptionsTextStringArray' );
        
        
        //encode all string data to xml controller adjustment definition file and set them to the output
        outXmlControllerAdjustmentDefinition = EncodeControllerAdjustmentDefinitionXMLFromListsString(controllerAdjustmentDefinitionListString, xmlSimulationFileName, xmlAutopilotFileName, propertiesAvailable);
        //if there is no output xml controller adjustment definition, show error and end function
        if outXmlControllerAdjustmentDefinition == [] then
            
            //show message box with error
            messagebox("Error occurred during encoding of controller adjustment definition data to XML format!", "Error - Encoding of Controller Adjustment Definition XML failed!", "modal", "error");
            return;
            
        end
        
        
        
        //close the window
        close(handles);
        
        
    //otherwise, if there was any error during check of data validity, show message box with all errors and end function
    else
        
        //show message box with all errors
        messagebox(errorString, "Error - Controller Adjustment Definition does not contain valid data!", "error", "OK", "modal");
        //outXmlControllerAdjustmentDefinition = [];
        return;
        
    end
    
    
    
endfunction



function [outXmlControllerAdjustmentDefinition, outXmlSimulation, outXmlReset, outXmlAutopilot, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName, outXmlAutopilotFilePath, outXmlAutopilotFileName]=ControllerAdjustmentDefinitionCancel_callback(handles)
    
    //set output objects to empty array
    outXmlControllerAdjustmentDefinition = [];
    outXmlSimulation = [];
    outXmlReset = [];
    outXmlAutopilot = [];
    outXmlSimulationFilePath = [];
    outXmlSimulationFileName = [];
    outXmlResetFilePath = [];
    outXmlResetFileName = [];
    outXmlAircraftFilePath = [];
    outXmlAircraftFileName = [];
    outXmlAutopilotFilePath = [];
    outXmlAutopilotFileName = [];
    //close the window
    close(handles);
    
endfunction



//<>functions: SimulationDefinitionPath_callback, EditSimulationDefinitionFile_callback, and EditResetFile_callback can be found after the main simulation start dialog function




//callback for autopilot path file selection
function [outXmlAutopilot, outXmlAutopilotFilePath, outXmlAutopilotFileName]=AutopilotPath_callback(handles, inXmlAutopilot, inXmlAutopilotFilePath, inXmlAutopilotFileName)
    
    outXmlAutopilot = inXmlAutopilot;
    outXmlAutopilotFilePath = inXmlAutopilotFilePath;
    outXmlAutopilotFileName = inXmlAutopilotFileName;
    
    //show open dialog for autopilot file selection
    [fileName, pathName, filterIndex] = uigetfile( ["*.xml","XML files"], outXmlAutopilotFilePath, "Select file with autopilot definition", %f );
    
    //check if cancel button was not clicked
    if fileName ~= "" & pathName ~= "" & filterIndex ~= 0 then
        
        xmlPathFile = pathName + filesep() + fileName;
        //read xml file with (maybe) autopilot definition
        xmlAutopilotTemp = xmlRead(xmlPathFile);
        errorString=ValidateXMLdocument(xmlAutopilotTemp);
        
        //check if the root xml element is "autopilot"
        if convstr(xmlAutopilotTemp.root.name, 'l') == "autopilot" then
            
            outXmlAutopilotFileName = GetFileNameWithoutExtension(fileName, ".xml");
            outXmlAutopilotFilePath = xmlPathFile;
            handles.string = outXmlAutopilotFilePath;
            CheckAndDeleteXMLDoc(outXmlAutopilot)
            outXmlAutopilot = xmlAutopilotTemp;
            
        else
            
            CheckAndDeleteXMLDoc(xmlAutopilotTemp);
            messagebox("Wrong format! The XML file is not a valid autopilot file!", "modal", "error");
            
        end
        
    end
    
endfunction



function [outXmlMethodParametersElement]=EditMethodParameters_callback(inXmlControllerAdjustmentDefinition, inXmlMethodParametersElement, outputAnalysisMethodPopupmenuValue)
    
    outXmlMethodParametersElement = inXmlMethodParametersElement;
    
    
    //decode method parameters xml element and create labels and values for x_mdialog
    [labels, values] = DecodeXmlMethodParameters(outXmlMethodParametersElement, outputAnalysisMethodPopupmenuValue);
    
    
    labelMain = ['Controller adjustment definition of ' + outXmlMethodParametersElement.name];
    valueOK = %f;
    while valueOK == %f then
        
        //create the dialog with method parameters labels and text boxes
        values = x_mdialog(labelMain, labels, values);
        
        if values ~= [] then
            
            values = values';
            //check values of parameters depending on selected controller adjustment method
            [isCorrect, errorMessage] = CheckCorrectXmlMethodParameters(values, outputAnalysisMethodPopupmenuValue, labels);
            if isCorrect == %f then
                messagebox(errorMessage, "modal", "error");
                continue;
            end
            
            //everything should be OK
            valueOK = %t;
            
            //encode labels and values to method parameters xml element
            outXmlMethodParametersElement = EncodeXmlMethodParameters(labels, values, inXmlControllerAdjustmentDefinition, outXmlMethodParametersElement, outputAnalysisMethodPopupmenuValue);
            
            
        else
            
            break;
            
        end
        
    end
    
    
endfunction



//<>functions: CreatePopupmenuStringsFromAutopilotAdjustableComponents, and GetAutopilotAdjustableComponentFromPopupValue can be found after the main controller adjustment definition dialog function



function [valueAutopilotAdjustableComponent]=FindPopupmenuValueForAutopilotAdjustableComponent(xmlAutopilotAdjustableComponentsListList, AutopilotAdjustableComponent)
    
    valueAutopilotAdjustableComponent = 0;
    
    if AutopilotAdjustableComponent ~= [] then
        
        for i = 1 : 1 : length(xmlAutopilotAdjustableComponentsListList)
            
            for j = 1 : 1 : length(xmlAutopilotAdjustableComponentsListList(i))
                
                //increment value of popupmenu
                valueAutopilotAdjustableComponent = valueAutopilotAdjustableComponent + 1;
                //if names of the component and the component types are same, return with output value of popupmenu
                if xmlAutopilotAdjustableComponentsListList(i)(j).attributes.name == AutopilotAdjustableComponent.attributes.name & xmlAutopilotAdjustableComponentsListList(i)(j).name == AutopilotAdjustableComponent.name then
                    
                    return;
                    
                end
                
            end
            
        end
        
    end
    
    valueAutopilotAdjustableComponent = 0;
    
endfunction
    
    
    
    
    
    
    
    
    outXmlControllerAdjustmentDefinition = inXmlControllerAdjustmentDefinition;
    outXmlSimulation = inXmlSimulation;
    outXmlReset = inXmlReset;
    outXmlAutopilot = inXmlAutopilot;
    outXmlSimulationFilePath = inXmlSimulationFilePath;
    outXmlSimulationFileName = inXmlSimulationFileName;
    outXmlResetFilePath = inXmlResetFilePath;
    outXmlResetFileName = inXmlResetFileName;
    outXmlAircraftFilePath = inXmlAircraftFilePath;
    outXmlAircraftFileName = inXmlAircraftFileName;
    outXmlAutopilotFilePath = inXmlAutopilotFilePath;
    outXmlAutopilotFileName = inXmlAutopilotFileName;
    defaultPathString = "Path is empty";
    rootControllerAdjustmentDefinitionName = "control_design_start";
    
    
    
    //<>debug only
//    outXmlResetFilePath = "C:\Users\<user name>\Documents\Scilab";
//    outXmlAutopilotFilePath = "C:\Users\<user name>\Documents\Scilab";
//    outXmlAircraftFilePath = "C:\Users\<user name>\Documents\Scilab";
//    //include files with functions which we use
//    exec XMLfunctions.sci;
//    exec TXTfunctions.sci;
//    exec XMLSimulation.sci;
//    propertiesAvailable = ReadInternalAndCustomProperties();
    
    
    //show wait bar
    waitBarHandle = waitbar('Loading Dialog for Controller Adjustment Definition, please wait.');
    
    
    
    //decode controller adjustment definition xml
    [controllerAdjustmentDefinitionListString] = DecodeControllerAdjustmentDefinitionXMLToListsString(outXmlControllerAdjustmentDefinition);
    
    
    
    waitbar(0.3, waitBarHandle);
    
    
    
    //get simulation definition file from controller adjustment definition xml
    [outXmlSimulationTemp, outXmlSimulationFilePathTemp, outXmlSimulationFileNameTemp] = GetSimulationDefinitionFromSimulationStartOrControllerAdjustmentDefinitionXML(outXmlControllerAdjustmentDefinition, rootControllerAdjustmentDefinitionName);
    if outXmlSimulationTemp ~= [] then
        outXmlSimulation = outXmlSimulationTemp;
        outXmlSimulationFilePath = outXmlSimulationFilePathTemp;
        outXmlSimulationFileName = outXmlSimulationFileNameTemp;
    end
    
    
    
    waitbar(0.4, waitBarHandle);
    
    
    
    //get aircraft and reset file from simulation definition
    [aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition] = GetAircraftAndResetFileFromSimulationDefinition(outXmlSimulation);
    
    
    
    waitbar(0.5, waitBarHandle);
    
    
    
    //get complete aircraft and reset file paths and names
    [outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName] = GetCompleteAircraftAndResetFilePathsAndNames(outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName, aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition);
    
    
    
    waitbar(0.6, waitBarHandle);
    
    
    
    //load new xml reset file
    if outXmlResetFileName ~= emptystr() then
        if fileinfo(outXmlResetFilePath) ~= [] then
            try
                xmlResetTemp = xmlRead(outXmlResetFilePath);
                outXmlReset = xmlResetTemp;
            catch
                messagebox(["Loading of new reset file (defined by initialize filename in controller adjustment definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
            end
        else
            messagebox(["Loading of new reset file (defined by initialize filename in controller adjustment definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
        end
    end
    
    
    
    waitbar(0.7, waitBarHandle);
    
    
    
    //get autopilot file from controller adjustment definition xml
    [outXmlAutopilotTemp, outXmlAutopilotFilePathTemp, outXmlAutopilotFileNameTemp] = GetAutopilotDefinitionFromControllerAdjustmentDefinitionXML(outXmlControllerAdjustmentDefinition, rootControllerAdjustmentDefinitionName, outXmlAircraftFileName);
    if outXmlAutopilotTemp ~= [] then
        outXmlAutopilot = outXmlAutopilotTemp;
        outXmlAutopilotFilePath = outXmlAutopilotFilePathTemp;
        outXmlAutopilotFileName = outXmlAutopilotFileNameTemp;
    end
    
    
    
    waitbar(0.8, waitBarHandle);
    
    
    
    
    //create new dialog (figure) with all necessary uicontrols
    ControllerAdjustmentDefinitionDialogID = 4444;
    figControllerAdjustmentDefinitionDialog = figure(ControllerAdjustmentDefinitionDialogID, 'figure_position', [250, 150],...
                                                                                             'figure_size',[900, 600],...
                                                                                             "menubar", "none",...
                                                                                             "layout", "grid",...
                                                                                             "auto_resize", "on",...
                                                                                             "resize", "on",...
                                                                                             "visible", "off");
    clf(ControllerAdjustmentDefinitionDialogID);
    figControllerAdjustmentDefinitionDialog.default_axes = "off";
    figControllerAdjustmentDefinitionDialog.dockable = "off";
    figControllerAdjustmentDefinitionDialog.figure_name = "Controller Adjustment Definition Dialog";
    figControllerAdjustmentDefinitionDialog.infobar_visible = "off";
    figControllerAdjustmentDefinitionDialog.toolbar = "none";
    figControllerAdjustmentDefinitionDialog.toolbar_visible = "off";
    
    
    
    
    frameMainControllerAdjustmentDefinition = uicontrol(figControllerAdjustmentDefinitionDialog, "style", "frame",..
               "Tag", "frameMain_ControllerAdjustmentDefinition",..
               "layout" , "gridbag",...
               "scrollable", "on",...
               "Title_position", "top",..
               "Title_scroll", "on",..
               "FontSize", 15)
    
    
    
    descritionLabelMainControllerAdjustmentDefinition = uicontrol(frameMainControllerAdjustmentDefinition, "style", "text", ...
                    "Tag", "descritionLabelMain_ControllerAdjustmentDefinition",..
                    "string", "Description", ...
                    "constraints", createConstraints("gridbag", [1, 1, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //editStringDefault = [emptystr(); emptystr(); emptystr()];
    //editStringDefault = emptystr();
    descritionTextMainControllerAdjustmentDefinition = uicontrol(frameMainControllerAdjustmentDefinition, "style", "edit", ...
                    "Tag", "descritionTextMain_ControllerAdjustmentDefinition",..
                    "string", controllerAdjustmentDefinitionListString(1), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [1, 2, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    simulationDefinitionPathLabel = uicontrol(frameMainControllerAdjustmentDefinition, "style", "text", ...
                    "Tag", "simulationDefinitionPathLabel_ControllerAdjustmentDefinition",..
                    "string", "Simulation Definition (runscript) file* (path_file)", ...
                    "constraints", createConstraints("gridbag", [1, 3, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //if the path is empty, get default string (which is not valid path)
    if outXmlSimulationFilePath == emptystr() then
        outXmlSimulationFilePath = defaultPathString;
    end
    simulationDefinitionPathButton = uicontrol(frameMainControllerAdjustmentDefinition, "style", "pushbutton", ...
                    "string", outXmlSimulationFilePath, ...
                    "callback", "[outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName]=SimulationDefinitionPath_callback(simulationDefinitionPathButton, outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "simulationDefinitionPathButton_ControllerAdjustmentDefinition",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [1, 4, 2, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    editSimulationDefinitionFileButton = uicontrol(frameMainControllerAdjustmentDefinition, "style", "pushbutton", ...
                    "string", "Edit Simulation Definition file", ...
                    "callback", "[outXmlSimulation, outXmlReset, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName]=EditSimulationDefinitionFile_callback(editSimulationDefinitionFileButton, outXmlSimulation, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlReset, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName, propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "editSimulationDefinitionFileButton_ControllerAdjustmentDefinition",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [1, 5, 1, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    editResetFileButton = uicontrol(frameMainControllerAdjustmentDefinition, "style", "pushbutton", ...
                    "string", "Edit Reset file", ...
                    "callback", "[outXmlReset]=EditResetFile_callback(editResetFileButton, outXmlReset, outXmlResetFilePath, outXmlResetFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "editResetFileButton_ControllerAdjustmentDefinition",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [2, 5, 1, 1], [0.5, 1], "horizontal", "center"));
    
    
    
    autopilotPathLabel = uicontrol(frameMainControllerAdjustmentDefinition, "style", "text", ...
                    "Tag", "autopilotPathLabel",..
                    "string", "Autopilot file* (path_file)", ...
                    "constraints", createConstraints("gridbag", [1, 6, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //if the path is empty, get default string (which is not valid path)
    if outXmlAutopilotFilePath == emptystr() then
        outXmlAutopilotFilePath = defaultPathString;
    end
    autopilotPathButton = uicontrol(frameMainControllerAdjustmentDefinition, "style", "pushbutton", ...
                    "string", outXmlAutopilotFilePath, ...
                    "callback", "[outXmlAutopilot, outXmlAutopilotFilePath, outXmlAutopilotFileName]=AutopilotPath_callback(autopilotPathButton, outXmlAutopilot, outXmlAutopilotFilePath, outXmlAutopilotFileName)", ...
                    "fontsize", 15, ...
                    "Tag", "autopilotPathButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [2, 6, 1, 1], [0.5, 1], "horizontal", "center"));
    
    

    
    waitbar(0.85, waitBarHandle);
    
    
    
    autopilotAdjustableComponentLabel = uicontrol(frameMainControllerAdjustmentDefinition, "style", "text", ...
                    "Tag", "autopilotAdjustableComponentLabel",..
                    "string", "Select autopilot component which should be adjusted", ...
                    "tooltipstring", "Currently only ""pid"" and ""pure_gain"" JSBSim xml components are supported", ...
                    "constraints", createConstraints("gridbag", [1, 7, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //get all adjustable components from autopilot
    [xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList, xmlAutopilotAdjustableComponentsIndexesListList] = GetAllAdjustableComponentsFromAutopilot(outXmlAutopilot);
    
    //create popupmenu string
    [popmenuAutopilotAdjustableComponentsString, numberOfAutopilotAdjustableComponents] = CreatePopupmenuStringsFromAutopilotAdjustableComponents(outXmlAutopilot.root, xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList);
    
    //get value for popupmenu from autopilot components or set default
    valueAutopilotAdjustableComponent = 1;
    if numberOfAutopilotAdjustableComponents > 0 then
        if controllerAdjustmentDefinitionListString(4) ~= [] & controllerAdjustmentDefinitionListString(4).children ~= [] & length(controllerAdjustmentDefinitionListString(4).children) > 0 then
            valueAutopilotAdjustableComponent = FindPopupmenuValueForAutopilotAdjustableComponent(xmlAutopilotAdjustableComponentsListList, controllerAdjustmentDefinitionListString(4).children(1));
        end
    end
    
    autopilotAdjustableComponentPopupmenu = uicontrol(frameMainControllerAdjustmentDefinition, "style", "popupmenu", ...
                    "Tag", "autopilotAdjustableComponentPopupmenu",..
                    "string", popmenuAutopilotAdjustableComponentsString, ...
                    "value", valueAutopilotAdjustableComponent, ...
                    "constraints", createConstraints("gridbag", [2, 7, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    waitbar(0.9, waitBarHandle);
    
    
    
    frameOutputOptions = uicontrol(frameMainControllerAdjustmentDefinition, "style", "frame",..
               "Tag", "frameOutputOptions",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 8 2 1], [1 1]),...
               "margins", [20 0 10 0], ...
               "FontSize", 15);
               
               
               
    outputNameLabel = uicontrol(frameOutputOptions, "style", "text", ...
                    "Tag", "outputNameLabel_ControllerAdjustmentDefinition",..
                    "string", "output filename", ...
                    "tooltipstring", "Filename of output cannot contains: '':'', ''*'', ''?'', ''""'', ''<'', ''>'', ''|'', ''\'', ''/'' )",...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputNameText = uicontrol(frameOutputOptions, "style", "edit", ...
                    "Tag", "outputNameText_ControllerAdjustmentDefinition",..
                    "string", controllerAdjustmentDefinitionListString(5), ...
                    "constraints", createConstraints("gridbag", [1, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    outputRateLabel = uicontrol(frameOutputOptions, "style", "text", ...
                    "Tag", "outputRateLabel_ControllerAdjustmentDefinition",..
                    "string", "output rate (Hz)", ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputRateText = uicontrol(frameOutputOptions, "style", "edit", ...
                    "Tag", "outputRateText_ControllerAdjustmentDefinition",..
                    "string", controllerAdjustmentDefinitionListString(6), ...
                    "constraints", createConstraints("gridbag", [2, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    outputPropertyLabel = uicontrol(frameOutputOptions, "style", "text", ...
                    "Tag", "outputPropertyLabel_ControllerAdjustmentDefinition",..
                    "string", "output property (property name)", ...
                    "constraints", createConstraints("gridbag", [3, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputPropertyText = uicontrol(frameOutputOptions, "style", "edit", ...
                    "Tag", "outputPropertyText_ControllerAdjustmentDefinition",..
                    "string", controllerAdjustmentDefinitionListString(7), ...
                    "constraints", createConstraints("gridbag", [3, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
                    
                    
    frameOutputAnalysisOptions = uicontrol(frameMainControllerAdjustmentDefinition, "style", "frame",..
               "Tag", "frameOutputAnalysisOptions",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 9 2 1], [1 1]),...
               "margins", [20 0 10 0], ...
               "FontSize", 15);
               
               
               
    outputAnalysisLabel = uicontrol(frameOutputAnalysisOptions, "style", "text", ...
                    "Tag", "outputAnalysisLabel",..
                    "string", "Output analysis options", ...
                    "constraints", createConstraints("gridbag", [1, 1, 4, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 18, ...
                    "horizontalAlignment", "center");
                    
                    
                    
    outputAnalysisTimeStartLabel = uicontrol(frameOutputAnalysisOptions, "style", "text", ...
                    "Tag", "outputAnalysisTimeStartLabel",..
                    "string", "Start time of analysis [s]", ...
                    "tooltipstring", "It defines time period in output data FROM which the analysis will be performed", ...
                    "constraints", createConstraints("gridbag", [1, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputAnalysisTimeStartText = uicontrol(frameOutputAnalysisOptions, "style", "edit", ...
                    "Tag", "outputAnalysisTimeStartText",..
                    "string", controllerAdjustmentDefinitionListString(8), ...
                    "constraints", createConstraints("gridbag", [1, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
               
               
               
    outputAnalysisTimeEndLabel = uicontrol(frameOutputAnalysisOptions, "style", "text", ...
                    "Tag", "outputAnalysisTimeEndLabel",..
                    "string", "End time of analysis [s]", ...
                    "tooltipstring", "It defines time period in output data TO which the analysis will be performed", ...
                    "constraints", createConstraints("gridbag", [2, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    outputAnalysisTimeEndText = uicontrol(frameOutputAnalysisOptions, "style", "edit", ...
                    "Tag", "outputAnalysisTimeEndText",..
                    "string", controllerAdjustmentDefinitionListString(9), ...
                    "constraints", createConstraints("gridbag", [2, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
                    
                    
                    
    outputAnalysisMethodLabel = uicontrol(frameOutputAnalysisOptions, "style", "text", ...
                    "Tag", "outputAnalysisMethodLabel",..
                    "string", "Method for controller adjustment", ...
                    "constraints", createConstraints("gridbag", [3, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    valueOutputAnalysisMethod = 1;
    if convstr(controllerAdjustmentDefinitionListString(10), 'l') ~= "ziegler_nichols-critical_gain" then
        valueOutputAnalysisMethod = 2;
    end
    outputAnalysisMethodPopupmenu = uicontrol(frameOutputAnalysisOptions, "style", "popupmenu", ...
                    "Tag", "outputAnalysisMethodPopupmenu",..
                    "string", "ZIEGLER_NICHOLS-CRITICAL_GAIN|GENETIC_ALGORITHM", ...
                    "value", valueOutputAnalysisMethod, ...
                    "constraints", createConstraints("gridbag", [3, 3, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
               
               
               
    editMethodParametersButton = uicontrol(frameOutputAnalysisOptions, "style", "pushbutton", ...
                    "string", "Edit parameters of selected method", ...
                    "callback", "[controllerAdjustmentDefinitionListString(11)]=EditMethodParameters_callback(outXmlControllerAdjustmentDefinition, controllerAdjustmentDefinitionListString(11), outputAnalysisMethodPopupmenu.value)", ...
                    "fontsize", 15, ...
                    "Tag", "editMethodParametersButton",..
                    "margins", [5 5 5 5], ...
                    "constraints", createConstraints("gridbag",  [4, 3, 1, 1], [0.5, 1], "horizontal", "center"));
                    
                    
                    
    waitbar(0.95, waitBarHandle);
                    
                    
                    
    jsbsimCommandOptionsLabel = uicontrol(frameMainControllerAdjustmentDefinition, "style", "text", ...
                    "Tag", "jsbsimCommandOptionsLabel_ControllerAdjustmentDefinition",..
                    "string", "JSBSim Command Options", ...
                    "tooltipstring", "you may separate it by whitespace and line end (""--script"" command option is created by application automatically)", ...
                    "constraints", createConstraints("gridbag", [1, 10, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    jsbsimCommandOptionsText = uicontrol(frameMainControllerAdjustmentDefinition, "style", "edit", ...
                    "Tag", "jsbsimCommandOptionsText_ControllerAdjustmentDefinition",..
                    "string", controllerAdjustmentDefinitionListString(12), ...
                    "max", 1000, ... //note: edit uicontrols: if (Max-Min)>1 the edit allows multiple line editing
                    "scrollable", "on", ...
                    "constraints", createConstraints("gridbag", [1, 11, 2, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    
    
    
    frameOKCancel = uicontrol(frameMainControllerAdjustmentDefinition, "style", "frame",..
               "Tag", "frameOKCancel",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 112 2 1], [1 1]),..
               "margins", [20 0 0 0], ...
               "FontSize", 15);
    
    //create OK and Cancel button
    OKButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "OK", ...
                    "callback", "[outXmlControllerAdjustmentDefinition]=ControllerAdjustmentDefinitionOK_callback(figControllerAdjustmentDefinitionDialog, descritionTextMainControllerAdjustmentDefinition.string, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlAutopilotFilePath, outXmlAutopilotFileName, autopilotAdjustableComponentPopupmenu.value, xmlAutopilotAdjustableComponentsListList, outputNameText.string, outputRateText.string, outputPropertyText.string, outputAnalysisTimeStartText.string, outputAnalysisTimeEndText.string, outputAnalysisMethodPopupmenu.value, controllerAdjustmentDefinitionListString(11), jsbsimCommandOptionsText.string, propertiesAvailable)", ...
                    "fontsize", 15, ...
                    "Tag", "OKButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "center", [0, 0]));
                    
    CancelButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "Cancel", ...
                    "callback", "[outXmlControllerAdjustmentDefinition, outXmlSimulation, outXmlReset, outXmlAutopilot, outXmlSimulationFilePath, outXmlSimulationFileName, outXmlResetFilePath, outXmlResetFileName, outXmlAircraftFilePath, outXmlAircraftFileName, outXmlAutopilotFilePath, outXmlAutopilotFileName]=ControllerAdjustmentDefinitionCancel_callback(figControllerAdjustmentDefinitionDialog)", ...
                    "fontsize", 15, ...
                    "Tag", "CancelButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "center"));
    
    
    
    waitbar(1.0, waitBarHandle);
    
    //turn off auto resize function of figure, disallow manual resize and set it to be visible
    //figControllerAdjustmentDefinitionDialog.auto_resize = "off";
    //figControllerAdjustmentDefinitionDialog.resize = "off";
    figControllerAdjustmentDefinitionDialog.visible = "on";
    
    
    //close wait bar window
    close(waitBarHandle);
    
    
    
    //wait until is clicked
    ibutton = -1;
    iwin = -1;
    //while the current window is not closed
    while(ibutton ~= -1000 | iwin ~= figControllerAdjustmentDefinitionDialog.figure_id)
        
        //wait until is clicked
        [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
        
//        //<>debug only
//        disp("Opened window is still alive!");
//        disp(string(ibutton));
//        disp(string(xcoord));
//        disp(string(ycoord));
//        disp(string(iwin));
//        disp(string(cbmenu));
        
        //check if some callback was clicked
        if ibutton == -2 then
            
            
            //if OK was clicked, execute OK callback
            if strindex(cbmenu, OKButton.callback) then
                
                //disp("OK clicked"); //<>debug only
                execstr(OKButton.callback);
                
                //if there is output with xml controller adjustment definition file, break this cycle
                if outXmlControllerAdjustmentDefinition ~= [] then
                    break;

                end
                
                
                
            //else if Cancel was clicked, execute Cancel callback
            elseif strindex(cbmenu, CancelButton.callback) then
                
                //disp("Cancel clicked"); //<>debug only
                execstr(CancelButton.callback);
                break;
                
                
                
            //else if button for simulation definition path selection was clicked
            elseif strindex(cbmenu, simulationDefinitionPathButton.callback) then
                
                //disp("simulationDefinitionPathButton clicked"); //<>debug only
                //handles = simulationDefinitionPathButton;
                execstr(simulationDefinitionPathButton.callback);
                
                //get aircraft and reset file from simulation definition
                [aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition] = GetAircraftAndResetFileFromSimulationDefinition(outXmlSimulation);
                //get complete aircraft and reset file paths and names
                [outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName] = GetCompleteAircraftAndResetFilePathsAndNames(outXmlAircraftFilePath, outXmlAircraftFileName, outXmlResetFilePath, outXmlResetFileName, aircraftFileFromSimulationDefinition, resetFileFromSimulationDefinition);
                //load new xml reset file
                if outXmlResetFileName ~= emptystr() then
                    if fileinfo(outXmlResetFilePath) ~= [] then
                        try
                            xmlResetTemp = xmlRead(outXmlResetFilePath);
                            outXmlReset = xmlResetTemp;
                        catch
                            messagebox(["Loading of new reset file (defined by initialize filename in simulation definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
                        end
                    else
                        messagebox(["Loading of new reset file (defined by initialize filename in simulation definition file) failed!" ; "The original reset file is kept but the new reset path will be used for saving!"], "modal", "error");
                    end
                end
                
                
                
            //else if button for edit of simulation definition was clicked
            elseif strindex(cbmenu, editSimulationDefinitionFileButton.callback) then
                
                //disp("editSimulationDefinitionFileButton clicked"); //<>debug only
                //handles = editSimulationDefinitionFileButton;
                execstr(editSimulationDefinitionFileButton.callback);
                
                
                
            //else if button for edit of reset file was clicked
            elseif strindex(cbmenu, editResetFileButton.callback) then
                
                //disp("editResetFileButton clicked"); //<>debug only
                //handles = editResetFileButton;
                execstr(editResetFileButton.callback);
                
                
                
            //else if button for autopilot path selection was clicked
            elseif strindex(cbmenu, autopilotPathButton.callback) then
                
                //disp("autopilotPathButton clicked"); //<>debug only
                //handles = autopilotPathButton;
                execstr(autopilotPathButton.callback);
                
                //get all adjustable components from autopilot
                [xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList, xmlAutopilotAdjustableComponentsIndexesListList] = GetAllAdjustableComponentsFromAutopilot(outXmlAutopilot);
                
                //create popupmenu string
                [popmenuAutopilotAdjustableComponentsString, numberOfAutopilotAdjustableComponents] = CreatePopupmenuStringsFromAutopilotAdjustableComponents(outXmlAutopilot.root, xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList);
                
                //set default value for popupmenu
                valueAutopilotAdjustableComponent = 1;
                
                //set created string and default value to popupmenu
                autopilotAdjustableComponentPopupmenu.string = popmenuAutopilotAdjustableComponentsString;
                autopilotAdjustableComponentPopupmenu.value = valueAutopilotAdjustableComponent;
                
                
                
            //else if button for edit of (selected) method parameters was clicked
            elseif strindex(cbmenu, editMethodParametersButton.callback) then
                
                //disp("editMethodParametersButton clicked"); //<>debug only
                //handles = editMethodParametersButton;
                execstr(editMethodParametersButton.callback);
                
                
                
            end
            
            
            
        //else if the dialog was closed, it is same as when cancel button is clicked
        elseif ibutton == -1000 then
            
            //set output objects to empty array
            outXmlControllerAdjustmentDefinition = [];
            outXmlSimulation = [];
            outXmlReset = [];
            outXmlAutopilot = [];
            outXmlSimulationFilePath = [];
            outXmlSimulationFileName = [];
            outXmlResetFilePath = [];
            outXmlResetFileName = [];
            outXmlAircraftFilePath = [];
            outXmlAircraftFileName = [];
            outXmlAutopilotFilePath = [];
            outXmlAutopilotFileName = [];
            break;
            
            
            
        end
        
    end
    //disp("The correct window was closed!"); //<>debug only
    
    
endfunction





function [popmenuAutopilotAdjustableComponentsString, numberOfAutopilotAdjustableComponents]=CreatePopupmenuStringsFromAutopilotAdjustableComponents(xmlAutopilotRoot, xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList)
    
    popmenuAutopilotAdjustableComponentsString = emptystr();
    numberOfAutopilotAdjustableComponents = 0;
    popupSeparator = "|";
    
    for i = 1 : 1 : length(xmlAutopilotAdjustableComponentsListList)
        
        channelXmlElement = xmlAutopilotRoot.children(xmlChannelChildrenIndexArray(i));
        for j = 1 : 1 : length(xmlAutopilotAdjustableComponentsListList(i))
            
            if popmenuAutopilotAdjustableComponentsString ~= emptystr()
                popmenuAutopilotAdjustableComponentsString = popmenuAutopilotAdjustableComponentsString + popupSeparator;
            end
            
            popmenuAutopilotAdjustableComponentsString = popmenuAutopilotAdjustableComponentsString + xmlAutopilotAdjustableComponentsListList(i)(j).attributes.name + " <" + xmlAutopilotAdjustableComponentsListList(i)(j).name + "> channel name: """ + channelXmlElement.attributes.name + """";
            numberOfAutopilotAdjustableComponents = numberOfAutopilotAdjustableComponents + 1;
            
        end
        
    end
    
endfunction



function [xmlAutopilotAdjustableComponent]=GetAutopilotAdjustableComponentFromPopupValue(autopilotAdjustableComponentPopupmenuValue, xmlAutopilotAdjustableComponentsListList)
    

    xmlAutopilotAdjustableComponent = [];
    
    valueAutopilotAdjustableComponent = 0;
    if autopilotAdjustableComponentPopupmenuValue > 0 then
        
        for i = 1 : 1 : length(xmlAutopilotAdjustableComponentsListList)
            
            for j = 1 : 1 : length(xmlAutopilotAdjustableComponentsListList(i))
                
                //increment current value of component
                valueAutopilotAdjustableComponent = valueAutopilotAdjustableComponent + 1;
                //if names of the component and the component types are same, set the xml autopilot adjustable component and return
                if valueAutopilotAdjustableComponent == autopilotAdjustableComponentPopupmenuValue then
                    
                    xmlAutopilotAdjustableComponent = xmlAutopilotAdjustableComponentsListList(i)(j);
                    return;
                    
                end
                
            end
            
        end
        
    end
    
endfunction








//Dialog for Selection of Adjustable Control Component

function [xmlAutopilotAdjustableComponent]=DialogSelectAdjustableControlComponentOkCancel(xmlAutopilot)
    
    
function [xmlAutopilotAdjustableComponent]=SelectAdjustableControlComponentOK_callback(handles, autopilotAdjustableComponentPopupmenuValue, xmlAutopilotAdjustableComponentsListList)
    
    xmlAutopilotAdjustableComponent = [];
    
    //get autopilot_adjustable_component
    xmlAutopilotAdjustableComponent = GetAutopilotAdjustableComponentFromPopupValue(autopilotAdjustableComponentPopupmenuValue, xmlAutopilotAdjustableComponentsListList);
    //check if the xml component is supported for adjustment
    if xmlAutopilotAdjustableComponent ~= [] then
        
        if xmlAutopilotAdjustableComponent.name ~= "pid" & xmlAutopilotAdjustableComponent.name ~= "pure_gain" then
            xmlAutopilotAdjustableComponent = [];
            //show message box with error
            messagebox("Selected autopilot adjustable component with name: """ + xmlAutopilotAdjustableComponent.attributes.name + """ and JSBSim type: " + xmlAutopilotAdjustableComponent.name + """ is not supported JSBSim type of component; only ""pid"", and ""pure_gain"" types are supported!", "modal", "error");
            return;
        end
        
    else
        //show message box with error
        messagebox("Selected autopilot adjustable component was not found in the xml autopilot definition!", "Error!", "modal", "error");
        return;
    end
    
    close(handles);
    
endfunction



function [xmlAutopilotAdjustableComponent]=SelectAdjustableControlComponentCancel_callback(handles)
    
    //set output object to empty array
    xmlAutopilotAdjustableComponent = [];
    //close the window
    close(handles);
    
endfunction
    
    
    
    
    
    
    
    xmlAutopilotAdjustableComponent = [];
    
    
    
    
    
    //show wait bar
    waitBarHandle = waitbar('Loading Dialog for Selection of Adjustable Control Component, please wait.');
    
    
    
    
    //create new dialog (figure) with all necessary uicontrols
    figSelectAdjustableControlComponentDialog = figure('figure_position', [250, 150],...
                                                     "menubar", "none",...
                                                     "layout", "grid",...
                                                     "auto_resize", "on",...
                                                     "resize", "on",...
                                                     "visible", "off");
                                                     //'figure_size',[900, 600],...
    figSelectAdjustableControlComponentDialog.default_axes = "off";
    figSelectAdjustableControlComponentDialog.dockable = "off";
    figSelectAdjustableControlComponentDialog.figure_name = "Dialog for Selection of Adjustable Control Component";
    figSelectAdjustableControlComponentDialog.infobar_visible = "off";
    figSelectAdjustableControlComponentDialog.toolbar = "none";
    figSelectAdjustableControlComponentDialog.toolbar_visible = "off";
    
    
    
    
    frameMainSelectAdjustableControlComponentDialog = uicontrol(figSelectAdjustableControlComponentDialog, "style", "frame",..
               "Tag", "frameMain_SelectAdjustableControlComponentDialog",..
               "layout" , "gridbag",...
               "scrollable", "on",...
               "Title_position", "top",..
               "Title_scroll", "on",..
               "FontSize", 15)
                
                
                
    autopilotAdjustableComponentLabel = uicontrol(frameMainSelectAdjustableControlComponentDialog, "style", "text", ...
                    "Tag", "autopilotAdjustableComponentLabel",..
                    "string", "Select autopilot control component", ...
                    "tooltipstring", "Currently only ""pid"" and ""pure_gain"" JSBSim xml components are supported", ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    //get all adjustable components from autopilot
    [xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList, xmlAutopilotAdjustableComponentsIndexesListList] = GetAllAdjustableComponentsFromAutopilot(xmlAutopilot);
    
    //create popupmenu string
    [popmenuAutopilotAdjustableComponentsString, numberOfAutopilotAdjustableComponents] = CreatePopupmenuStringsFromAutopilotAdjustableComponents(xmlAutopilot.root, xmlChannelChildrenIndexArray, xmlAutopilotAdjustableComponentsListList);
    
    //set default value for popupmenu
    autopilotAdjustableComponentPopupmenu = uicontrol(frameMainSelectAdjustableControlComponentDialog, "style", "popupmenu", ...
                    "Tag", "autopilotAdjustableComponentPopupmenu",..
                    "string", popmenuAutopilotAdjustableComponentsString, ...
                    "value", 1, ...
                    "constraints", createConstraints("gridbag", [1, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    
    
    frameOKCancel = uicontrol(frameMainSelectAdjustableControlComponentDialog, "style", "frame",..
               "Tag", "frameOKCancel",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 112 2 1], [1 1]),..
               "margins", [20 0 0 0], ...
               "FontSize", 15);
    
    //create OK and Cancel button
    OKButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "OK", ...
                    "callback", "[xmlAutopilotAdjustableComponent]=SelectAdjustableControlComponentOK_callback(figSelectAdjustableControlComponentDialog, autopilotAdjustableComponentPopupmenu.value, xmlAutopilotAdjustableComponentsListList)", ...
                    "fontsize", 15, ...
                    "Tag", "OKButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "center", [0, 0]));
                    
    CancelButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "Cancel", ...
                    "callback", "[xmlAutopilotAdjustableComponent]=SelectAdjustableControlComponentCancel_callback(figSelectAdjustableControlComponentDialog)", ...
                    "fontsize", 15, ...
                    "Tag", "CancelButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "center"));
    
    
    
    waitbar(1.0, waitBarHandle);
    
    //turn off auto resize function of figure, disallow manual resize and set it to be visible
    //figSelectAdjustableControlComponentDialog.auto_resize = "off";
    //figSelectAdjustableControlComponentDialog.resize = "off";
    figSelectAdjustableControlComponentDialog.visible = "on";
    
    
    //close wait bar window
    close(waitBarHandle);
    
    
    
    
    
    //wait until is clicked
    ibutton = -1;
    iwin = -1;
    //while the current window is not closed
    while(ibutton ~= -1000 | iwin ~= figSelectAdjustableControlComponentDialog.figure_id)
        
        //wait until is clicked
        [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
        
//        //<>debug only
//        disp("Opened window is still alive!");
//        disp(string(ibutton));
//        disp(string(xcoord));
//        disp(string(ycoord));
//        disp(string(iwin));
//        disp(string(cbmenu));
        
        //check if some callback was clicked
        if ibutton == -2 then
            
            
            //if OK was clicked, execute OK callback
            if strindex(cbmenu, OKButton.callback) then
                
                //disp("OK clicked"); //<>debug only
                execstr(OKButton.callback);
                
                //if there is a xml autopilot adjustable component, break this cycle
                if xmlAutopilotAdjustableComponent ~= [] then
                    break;
                end
                
                
                
            //else if Cancel was clicked, execute Cancel callback
            elseif strindex(cbmenu, CancelButton.callback) then
                
                //disp("Cancel clicked"); //<>debug only
                execstr(CancelButton.callback);
                break;
                
                
                
            end
            
            
            
        //else if the dialog was closed, it is same as when cancel button is clicked
        elseif ibutton == -1000 then
            
            //set output object to empty array
            xmlAutopilotAdjustableComponent = [];
            break;
            
            
            
        end
        
    end
    //disp("The correct window was closed!"); //<>debug only
    
    
endfunction








//Dialog for Ziegler Nichols Critical Parameters Tables

function [zieglerNicholsRuleName]=DialogZieglerNicholsCriticalParametersTablesOkCancel()
    
    
function [zieglerNicholsRuleName]=ZieglerNicholsCriticalParametersTablesOK_callback(handles, selectedZieglerNicholsCriticalParametersRulePopupmenuValue)
    
    zieglerNicholsRuleName = [];
    global zieglerNicholsRulesNames;
    if selectedZieglerNicholsCriticalParametersRulePopupmenuValue <= length(zieglerNicholsRulesNames) then
        zieglerNicholsRuleName = zieglerNicholsRulesNames(selectedZieglerNicholsCriticalParametersRulePopupmenuValue);
        close(handles);
    end
    
endfunction



function [zieglerNicholsRuleName]=ZieglerNicholsCriticalParametersTablesCancel_callback(handles)
    
    //set output object to empty array
    zieglerNicholsRuleName = [];
    //close the window
    close(handles);
    
endfunction
    
    
    
    
    
    
    
    zieglerNicholsRuleName = [];
    global zieglerNicholsRulesNames;
    
    
    
    
    
    //show wait bar
    waitBarHandle = waitbar('Loading Dialog with Rules of Ziegler-Nichols Critical Parameters, please wait.');
    
    
    
    
    //create new dialog (figure) with all necessary uicontrols
    figZieglerNicholsCriticalParametersTablesDialog = figure('figure_position', [250, 150],...
                                                     "menubar", "none",...
                                                     "layout", "grid",...
                                                     "auto_resize", "on",...
                                                     "resize", "on",...
                                                     "visible", "off");
                                                     //'figure_size',[900, 600],...
    figZieglerNicholsCriticalParametersTablesDialog.default_axes = "off";
    figZieglerNicholsCriticalParametersTablesDialog.dockable = "off";
    figZieglerNicholsCriticalParametersTablesDialog.figure_name = "Dialog with Rules of Ziegler-Nichols Critical Parameters";
    figZieglerNicholsCriticalParametersTablesDialog.infobar_visible = "off";
    figZieglerNicholsCriticalParametersTablesDialog.toolbar = "none";
    figZieglerNicholsCriticalParametersTablesDialog.toolbar_visible = "off";
    
    
    
    
    frameMainZieglerNicholsCriticalParametersTables = uicontrol(figZieglerNicholsCriticalParametersTablesDialog, "style", "frame",..
               "Tag", "frameMain_ZieglerNicholsCriticalParametersTables",..
               "layout" , "gridbag",...
               "scrollable", "on",...
               "Title_position", "top",..
               "Title_scroll", "on",..
               "FontSize", 15)
                
                
                
    ZieglerNicholsCriticalParametersRuleLabel = uicontrol(frameMainZieglerNicholsCriticalParametersTables, "style", "text", ...
                    "Tag", "ZieglerNicholsCriticalParametersRuleLabel",..
                    "string", "Select Rule for Ziegler-Nichols method with Critical Parameters", ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left");
    
    ZieglerNicholsCriticalParametersRuleString = emptystr();
    if length(zieglerNicholsRulesNames) > 0 then
        ZieglerNicholsCriticalParametersRuleString = zieglerNicholsRulesNames(1);
    else
        messagebox("List with Ziegler-Nichols method rules was not loaded properly, check ""templates\Control_Design\ziegler_nichols_rules.xml"" file with the rules!", "modal", "error");
        return;
    end
    for i = 2 : 1 : length(zieglerNicholsRulesNames)
        ZieglerNicholsCriticalParametersRuleString = ZieglerNicholsCriticalParametersRuleString + "|" + zieglerNicholsRulesNames(i);
    end
    ZieglerNicholsCriticalParametersRulePopupmenu = uicontrol(frameMainZieglerNicholsCriticalParametersTables, "style", "popupmenu", ...
                    "Tag", "ZieglerNicholsCriticalParametersRulePopupmenu",..
                    "string", ZieglerNicholsCriticalParametersRuleString, ...
                    "value", 1, ...
                    "constraints", createConstraints("gridbag", [1, 2, 1, 1], [0.5, 1], "horizontal", "center"), ...
                    "margins", [5 5 5 5], ...
                    "fontsize", 15, ...
                    "horizontalAlignment", "left", ...
                    "verticalAlignment", "top");
    
    
    
    
    
    frameOKCancel = uicontrol(frameMainZieglerNicholsCriticalParametersTables, "style", "frame",..
               "Tag", "frameOKCancel",..
               "layout" , "gridbag",...
               "scrollable", "off",...
               "Title_position", "top",..
               "Title_scroll", "off",..
               "constraints", createConstraints("gridbag", [1 112 2 1], [1 1]),..
               "margins", [20 0 0 0], ...
               "FontSize", 15);
    
    //create OK and Cancel button
    OKButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "OK", ...
                    "callback", "[zieglerNicholsRuleName]=ZieglerNicholsCriticalParametersTablesOK_callback(figZieglerNicholsCriticalParametersTablesDialog, ZieglerNicholsCriticalParametersRulePopupmenu.value)", ...
                    "fontsize", 15, ...
                    "Tag", "OKButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [1, 1, 1, 1], [1, 0], "horizontal", "center", [0, 0]));
                    
    CancelButton = uicontrol(frameOKCancel, "style", "pushbutton", ...
                    "string", "Cancel", ...
                    "callback", "[zieglerNicholsRuleName]=ZieglerNicholsCriticalParametersTablesCancel_callback(figZieglerNicholsCriticalParametersTablesDialog)", ...
                    "fontsize", 15, ...
                    "Tag", "CancelButton",..
                    "margins", [0 0 10 0], ...
                    "constraints", createConstraints("gridbag", [2, 1, 1, 1], [1, 0], "horizontal", "center"));
    
    
    
    waitbar(1.0, waitBarHandle);
    
    //turn off auto resize function of figure, disallow manual resize and set it to be visible
    //figZieglerNicholsCriticalParametersTablesDialog.auto_resize = "off";
    //figZieglerNicholsCriticalParametersTablesDialog.resize = "off";
    figZieglerNicholsCriticalParametersTablesDialog.visible = "on";
    
    
    //close wait bar window
    close(waitBarHandle);
    
    
    
    
    
    //wait until is clicked
    ibutton = -1;
    iwin = -1;
    //while the current window is not closed
    while(ibutton ~= -1000 | iwin ~= figZieglerNicholsCriticalParametersTablesDialog.figure_id)
        
        //wait until is clicked
        [ibutton,xcoord,ycoord,iwin,cbmenu] = xclick();
        
//        //<>debug only
//        disp("Opened window is still alive!");
//        disp(string(ibutton));
//        disp(string(xcoord));
//        disp(string(ycoord));
//        disp(string(iwin));
//        disp(string(cbmenu));
        
        //check if some callback was clicked
        if ibutton == -2 then
            
            
            //if OK was clicked, execute OK callback
            if strindex(cbmenu, OKButton.callback) then
                
                //disp("OK clicked"); //<>debug only
                execstr(OKButton.callback);
                
                //if there is output with ziegler nichols rule name, break this cycle
                if zieglerNicholsRuleName ~= [] then
                    break;
                end
                
                
                
            //else if Cancel was clicked, execute Cancel callback
            elseif strindex(cbmenu, CancelButton.callback) then
                
                //disp("Cancel clicked"); //<>debug only
                execstr(CancelButton.callback);
                break;
                
                
                
            end
            
            
            
        //else if the dialog was closed, it is same as when cancel button is clicked
        elseif ibutton == -1000 then
            
            //set output object to empty array
            zieglerNicholsRuleName = [];
            break;
            
            
            
        end
        
    end
    //disp("The correct window was closed!"); //<>debug only
    
    
endfunction








