function [out] = statscroppedfiles(folder, ccvlist, chilist, intensitylist) 


%THIS FUNCTION IS DESIGNED TO USE CROPPED SEGMENTS OF THE IMAGE AND
% RETURN STATISTICS FOR EACH FILE. WORKS WITHOUT THE TEXT FILE
%INPUTS, BUT HAS NO SORTING OF THE DATA

%Check to make sure same number of files

if length(ccvlist) == length (chilist) && length (intensitylist) == length(ccvlist)
    disp(["Number of files: CCV ", length(ccvlist), " , Chi ",length(chilist), " , Photons ",length(intensitylist)])
else
    disp("ERROR: Lengths of file lists may differ for each type of file.")
    disp(["File numbers: CCV ", length(ccvlist), " , Chi ",length(chilist), " , Photons ",length(intensitylist)])
    ccvlist
    chilist
    
    return
end 


add = 0;
varTypes = ["string","string", "string", "string","double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
varNames = ["OriginalFileName","CCVFileName", "CHIFileName", "INTFileName","CFD", "CCVCoV", "CCVMean", "CCVMedian", "CCVSTDEV", "CHIMean", "CHIMedian", "CHISTDEV", "PhotonsMean", "PhotonsMedian", "PhotonsSTDEV"];
out = table('Size', [length(ccvlist), length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
for num = 1:length(ccvlist)
    add = add+1

    intensity = dlmread(string(strcat(folder, '\',intensitylist(num))));
    size(intensity);
    inttopleft = intensity(1:128,1:128);
    
    inttopright = intensity(1:128, 129:end);
    intbtmleft = intensity(129:end, 1:128);
    intbtmright = intensity(129:end, 129:end);
    
    size(inttopleft);
    size(inttopright);
    size(intbtmleft);
    size(intbtmright);
    
    %find brightest corner in intensity image
    %not working because brightest pixels are on edge?? \
    
    intcornersums = [nnz(inttopleft), nnz(inttopright), nnz(intbtmleft), nnz(intbtmright)];
    
    [M,I] = min(intcornersums, [], 'all', 'linear');
    
    
    if I == 1
        corner = 4;
    elseif I == 2
        corner = 3;
    elseif I == 3
        corner = 2;
    elseif I == 4
        corner = 1;
    else 
        disp("ERROR: something wrong with intcornersums")
    end 
    

    ccv = dlmread(string(strcat(folder, '\',ccvlist(num))));
    chi = dlmread(string(strcat(folder, '\',chilist(num))));
    
    %SELECT CROP
    %assuming max bin of 10, move 21 pixels away from the edges
    if corner == 1
        cornerint = intensity(22:122,22:122);
        cornerchi = chi(22:122,22:122);
        cornerccv = ccv(22:122,22:122);
        r = [22 22 100 100];
        
        
    elseif corner == 2 
        cornerint = intensity(22:122,135:235);
        cornerchi = chi(22:122,135:235);
        cornerccv = ccv(22:122,135:235);
        r = [135 22 100 100];
        
    elseif corner == 3
        cornerint = intensity(135:235,22:122);
        cornerchi = chi(135:235,22:122);
        cornerccv = ccv(135:235,22:122);
        r = [22 135 100 100];
        
    elseif corner == 4
        cornerint = intensity(135:235, 135:235);
        cornerchi = chi(135:235, 135:235);
        cornerccv = ccv(135:235, 135:235);
        r = [135 135 100 100];
                
    else 
        disp("ERROR: Issue with selecting brightest corner")
    end
    
    
    boximg = cornerint;       %sanity check for box location??
    
    %get nonzero pixel values from cropped image to use for statistics
    
    ccvals = nonzeros(cornerccv);
    chivals = nonzeros(cornerchi);
    intvals = nonzeros(cornerint);
    
    %remove outliers in tm and chi values
    ccvals(ccvals > 8000) = [];
    ccvals(chivals>4) = [];
  
    %size(cornerccv)
    %size(ccvals)
    
    %calculate statistics for each file type
    imgmean = mean(ccvals,'all');  %check for single value
    imgmedian = median(ccvals,'all');
    standarddev = std(ccvals,0, 'all');        % w = 0 to normalize by N-1 (default option)
    cov = standarddev/imgmean;
    
    chimean = mean(chivals, 'all');
    chimedian = median(chivals, 'all');
    chistandarddev = std(chivals, 0, 'all');     % w = 0 to normalize by N-1 (default option)
    
    intmean = mean(intvals, 'all');
    intmedian = median(intvals,'all');
    intstandarddev = std(intvals,0,'all');

    %get regular file name
    %filenamewhole = strsplit(ccvlist(num),'_');
    %filename = strcat(filenamewhole(4),'_', filenamewhole(5));
    %cfd = filenamewhole(2);
    filename = ccvlist(num);
    cfd = "null"
    out(num,:) = {filename, ccvlist(num), chilist(num), intensitylist(num), cfd, cov, imgmean, imgmedian, standarddev, chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev};
    disp('function used: statsfromcrop')
   

end 
out
end 


