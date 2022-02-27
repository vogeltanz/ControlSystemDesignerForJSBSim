function peaks=peak_detect(signal,threshold)

// This function detect the peaks of a signal : 
// --------------------------------------------
// For an input row vector "signal" , the function return 
// the position of the peaks of the signal.
//
// The ouput "peaks" is a row vector (size = number of peaks),
// "peaks" =[] if no peak is found.
//
// Optional argument "threshold" eliminates the peaks under
// the threshold value (noise floor). 
//
// Clipped peaks (more than 2 samples of the signal at the same value)
// are not detected.
// -------------------------------------------------------------------
//     Jean-Luc GOUDIER      11-2011
// -------------------------------------------------------------------

[nargout,nargin] = argn(0);
if nargin==2 then ts=threshold;
end;
if nargin==1 then ts=min(signal);
end;

[r c]=size(signal);
Ct=getlanguage();
if Ct=="fr_FR" then
     Msg="Erreur : le signal n''est pas un vecteur colonne";
else
     Msg="Error : signal is not a row vector";
end
if r>1 then
    error(Msg);
end;

Lg=c-1;
if Lg > 0 then
    
    d_s=diff(signal); 
    dd_s=[d_s(1),d_s(1,:)];               // diff first shift
    d_s=[d_s(1,:),d_s(Lg)];               // diff size correction
    ddd_s=[dd_s(1),dd_s(1,1:Lg)];         // diff second shift
    Z=d_s.*dd_s;                          // diff zeros
    
    peaks=find(((Z<0 & d_s<0)|(Z==0 & d_s<0 & ddd_s>0)) & signal>ts);
    
else
    peaks = [];
    disp(Lg)
    error("Error in peak_detect - Lg is not higher than 0 ->> signal is empty");
end

endfunction


