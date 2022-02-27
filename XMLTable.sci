exec DialogsFunctions.sci;



function [tableStringMatrices, tableTitleArray, outPropertyRow, outPropertyColumn, outPropertyTable]=DecodeXMLTable(inXMLTable)
    
    //get and decode properties
    outPropertyRow = GetIndependentVar(inXMLTable, "row");
    outPropertyColumn = GetIndependentVar(inXMLTable, "column");
    outPropertyTable = GetIndependentVar(inXMLTable, "table");
    
    //check if column property exists (it influences table string decoding)
    columnPropertyExists = %f;
    if outPropertyColumn ~= emptystr() then
        columnPropertyExists = %t;
    end
    //get and decode table data and titles
    [tableStringMatrices, tableTitleArray] = GetTableStringMatricesAndTableTitleArray(inXMLTable, columnPropertyExists);
    
endfunction



function [outXMLTable]=EncodeXMLTable(inputTableStringMatrices, inputTableTitleArray, inputPropertyRow, inputPropertyColumn, inputPropertyTable)
    
    //create empty XML document
    outXMLTable = xmlDocument();
    
    //add only one child (root) element "table"
    outXMLTable.root = xmlElement(outXMLTable, "table");
    table = outXMLTable.root;
    
    //add independent variable for row to table element
    independentVarRow = xmlElement(outXMLTable, "independentVar");
    xmlSetAttributes(independentVarRow, ["lookup" "row"]);
    if inputPropertyRow ~= emptystr() then
        independentVarRow.content = inputPropertyRow;
        xmlAppend(outXMLTable.root, independentVarRow);
    else
        outXMLTable = [];
        disp("Property for row is empty but it is required! (EncodeXMLTable in XMLTable.sci)");
        return;
    end
    
    //add independent variable for column to table element
    if inputPropertyColumn ~= emptystr() then
        independentVarColumn = xmlElement(outXMLTable, "independentVar");
        xmlSetAttributes(independentVarColumn, ["lookup" "column"]);
        independentVarColumn.content = inputPropertyColumn;
        xmlAppend(outXMLTable.root, independentVarColumn);
    else
        if CheckIfPropertyColumnIsRequired(inputTableStringMatrices) then
            disp("Property for column is empty but it is required! (EncodeXMLTable in XMLTable.sci)");
            return;
        end
    end
    
    //add independent variable for table to table element
    if inputPropertyTable ~= emptystr() then
        independentVarTable = xmlElement(outXMLTable, "independentVar");
        xmlSetAttributes(independentVarTable, ["lookup" "table"]);
        independentVarTable.content = inputPropertyTable;
        xmlAppend(outXMLTable.root, independentVarTable);
    else
        if CheckIfPropertyTableIsRequired2(inputTableTitleArray) then
            disp("Property for table is empty but it is required! (EncodeXMLTable in XMLTable.sci)");
            return;
        end
    end
    
    
    
    //only row property is set => one table, first column with row titles and one column with data
    if inputPropertyColumn == emptystr() & inputPropertyTable == emptystr() then
        
        //delete first row (there should be only unnecessary data)
        arrayStringTable = inputTableStringMatrices(1)(2:size(inputTableStringMatrices(1), 1), 1:size(inputTableStringMatrices(1), 2));
        stringTable = ArrayStringTableToStringTable(arrayStringTable);
        
        //create new XML element with table data
        tableData = xmlElement(outXMLTable, "tableData");
        tableData.content = stringTable;
        xmlAppend(outXMLTable.root, tableData);
        
        
        
    //else if row and column properties are set => one table, first column with row titles and <N> columns with data
    elseif inputPropertyColumn ~= emptystr() & inputPropertyTable == emptystr() then
        
        firstStringTableLine = GetFirstStringTableLine(inputTableStringMatrices(1));
        //delete first row (there should be only unnecessary data)
        arrayStringTable = inputTableStringMatrices(1)(2:size(inputTableStringMatrices(1), 1), 1:size(inputTableStringMatrices(1), 2));
        stringTable = ArrayStringTableToStringTable(arrayStringTable);
        
        //create new XML element with table data
        tableData = xmlElement(outXMLTable, "tableData");
        tableData.content = [firstStringTableLine ; stringTable];
        xmlAppend(outXMLTable.root, tableData);
        
        
        
    //else if row, column, and table properties are set => <N> tables, first column with row titles and <N_2> columns with data
    elseif inputPropertyColumn ~= emptystr() & inputPropertyTable ~= emptystr() then
        
        //for each table create XML element with table breakpoint (title) and table data
        for i = 1 : 1 : length(inputTableStringMatrices)
            
            firstStringTableLine = GetFirstStringTableLine(inputTableStringMatrices(i));
            //delete first row (there should be only unnecessary data)
            arrayStringTable = inputTableStringMatrices(i)(2:size(inputTableStringMatrices(i), 1), 1:size(inputTableStringMatrices(i), 2));
            stringTable = ArrayStringTableToStringTable(arrayStringTable);
            
            //create new XML element with table data
            tableData = xmlElement(outXMLTable, "tableData");
            xmlSetAttributes(tableData, ["breakpoint" inputTableTitleArray(i)]); //another option: tableData.attributes.breakpoint = inputTableTitleArray(i);
            tableData.content = [firstStringTableLine ; stringTable];
            xmlAppend(outXMLTable.root, tableData);
            
        end
        
        
        
    //else if row and table properties are set => <N> tables, first column with row titles and one column with data (probably not supported in JSBSim - not tried)
    elseif inputPropertyColumn == emptystr() & inputPropertyTable ~= emptystr() then
        
        outXMLTable = [];
        disp("Property for column is empty but property for table is set! (this option is probably not supported in JSBSim)! (EncodeXMLTable in XMLTable.sci)");
        return;
        
        
    //suspicious option - it should not happen 
    else
        
        outXMLTable = [];
        disp("This situation should never happen! Suspecious behaviour - FunTom of the Blue Screen? (EncodeXMLTable in XMLTable.sci)");
        return;
        
        
    end
    
    
    
endfunction




function [tableStringMatrices, tableTitleArray]=GetTableStringMatricesAndTableTitleArray(inXMLTable, columnPropertyExists)
    
    tableStringMatrices = list();
    tableTitleArray = [];
    
    for i = 1 : 1 : length(inXMLTable.children)
        
        //find table part with table data
        if inXMLTable.children(i).name == "tableData" then
            
            //add decoded table data to table string matrices
            tableStringMatrices($+1) = StringTableToArrayStringTable(inXMLTable.children(i).content, columnPropertyExists);
            
            //check if attribute "breakpoint" exists
            if inXMLTable.children(i).attributes.breakpoint ~= [] then
                
                tableTitleArray(1, size(tableTitleArray, 2) + 1) = inXMLTable.children(i).attributes.breakpoint;
                
            end
            
        end
        
    end
    
    
    //if there is more than one table
    if length(tableStringMatrices) > 1 then
        
        //if length of the list of string matrices differs from size of array with table titles, some breakpoint is missing
        if length(tableStringMatrices) ~= size(tableTitleArray, 2) then
            
            disp("There are more tables than table titles (i.e. breakpoint attributes) in the loaded table element!");
            
        end
        
    //if there is only one table
    elseif length(tableStringMatrices) == 1 then
        
        //title will be empty string
        tableTitleArray = [emptystr()];
        
    end
    
    
endfunction



function [outArrayStringTable]=StringTableToArrayStringTable(inStringTable, columnPropertyExists)
    
    outArrayStringTable = [];
    
    for i = 1 : 1 : size(inStringTable, 1)
        
        //first string array is special
        if i == 1 then
            
            //if column property is set
            if columnPropertyExists then
                
                //get values separated by spaces and "tab" chars and continue in cycle
                firstRow = tokens(inStringTable(i) , [" ", ascii(9)]);
                firstRow = [" " ; firstRow]';
                outArrayStringTable(size(outArrayStringTable, 1) + 1, 1:size(firstRow, 2)) = firstRow;
                continue;
                
                
            //otherwise, the column property is not set and the first row is data only
            else
                
                //add space and empty strings to first row (there are always two columns only)
                firstRowWithoutColumn = [" ", ""];
                outArrayStringTable(size(outArrayStringTable, 1) + 1, 1:size(firstRowWithoutColumn, 2)) = firstRowWithoutColumn;
                
            end
            
        end
        
        //get values separated by spaces and "tab" chars
        row = tokens(inStringTable(i) , [" ", ascii(9)]);
        outArrayStringTable(size(outArrayStringTable, 1) + 1, 1:size(row', 2)) = row';
        
    end
    
endfunction



function [propertyName]=GetIndependentVar(inXMLTable, propertyType)
    
    propertyName = emptystr();
    
    for i = 1 : 1 : length(inXMLTable.children)
        
        if inXMLTable.children(i).name == "independentVar" then
            
            if inXMLTable.children(i).attributes.lookup == propertyType then
                
                propertyName = strsubst(inXMLTable.children(i).content, " ", "");
                break;
                
            end
            
        end
        
    end
    
    
endfunction




function [firstStringTableLine]=GetFirstStringTableLine(inArrayStringTable)
    
    //ascii(9) = tab char
    firstStringTableLine = ascii(9) + " ";
    firstArrayStringTableLine = inArrayStringTable(1, 2:size(inArrayStringTable, 2));
    
    for j = 1 : 1 : size(firstArrayStringTableLine, 2)
        firstStringTableLine = firstStringTableLine + "    " + firstArrayStringTableLine(j);
    end
    
endfunction


function [outStringTable]=ArrayStringTableToStringTable(inArrayStringTable)
    
    outStringTable = [];
    for i = 1 : 1 : size(inArrayStringTable, 1)
        
        //ascii(9) = tab char
        outStringTable(i) = ascii(9) + inArrayStringTable(i, 1);
        
        for j = 2 : size(inArrayStringTable, 2)
            
            //ascii(10) = new line char (if necessary)
            outStringTable(i) = outStringTable(i) + "    " + inArrayStringTable(i, j);
            
        end
        
    end
    
endfunction



