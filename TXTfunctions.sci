

//read internal and custom properties from two text files and returns all properties in one array (matrix?)
function [propertiesStringArray]=ReadInternalAndCustomProperties()
    
    propertiesStringArray = [];
    
    //read internal properties from text file
    fd=mopen('templates' + filesep() + 'properties.txt','r');
    propertiesStringArray=mgetl(fd);
    mclose(fd);
    
    //read custom properties from text file
    fd=mopen('templates' + filesep() + 'properties_custom.txt','r');
    b=mgetl(fd);
    mclose(fd);
    
    //join all properties to one array (matrix?)
    for i = 1 : 1 : size(b,1)
        
        propertiesStringArray(size(propertiesStringArray, 1) + 1, 1) = b(i);
        
    end
    
endfunction



function [filterFunctionText]=GetFilterFunctionText(inputComponentName)
    
    filterFunctionText = "";
    
    if inputComponentName == "lag_filter" then
        
        filterFunctionText = " -> (C1) / (s + C1)";
        
    elseif inputComponentName == "lead_lag_filter" then
        
        filterFunctionText = " -> (C1s + C2) / (C3s + C4)";
        
    elseif inputComponentName == "washout_filter" then
        
        filterFunctionText = " -> (s) / (s + C1)";
        
    elseif inputComponentName == "second_order_filter" then
        
        filterFunctionText = " -> (C1s^2 + C2s + C3) / (C4s^2 + C5s + C6)";
        
    elseif inputComponentName == "integrator" then
        
        filterFunctionText = " -> (C1) / (s)";
        
    end
    
    
endfunction





//functions for filename processing
function [extension]=GetExtensionForFileIfNecessary(fileName, possibleExtension)
    
    extension = emptystr();
    if length(fileName) <= 4 then
        extension = possibleExtension;
    elseif length(fileName) > 4 then
        if convstr(part(fileName, length(fileName)-3:length(fileName)), 'l') ~= possibleExtension then
            extension = possibleExtension;
        end
    end
    
endfunction



function [outFileName]=GetFileNameWithoutExtension(inFileName, extension)
    
    outFileName = inFileName;
    if length(inFileName) > 4 then
        if convstr(part(inFileName, length(inFileName)-3:length(inFileName)), 'l') == extension then
            outFileName = part(inFileName, 1:length(inFileName)-4);
        end
    end
    
endfunction



function WriteControlDesignMethodInformationToTXT(messageInfoStringArray, txtPath)
    
    //open a file as text for writing
    fd_w = mopen(txtPath, 'wt');
    for i = 1 : 1 : size(messageInfoStringArray, 1)
        // write a line in text file from string array
        mputl(messageInfoStringArray(i), fd_w);
    end
    mclose(fd_w);
    
endfunction



