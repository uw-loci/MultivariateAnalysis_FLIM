function [out] = statsfromfilenamesonly(folder, ccvlist, chilist, intensitylist) 
%THIS FUNCTION IS DESIGNED TO APPLY ONLY THE CHI SQ MASK TO THE EXPORTED SPCIMAGE
%FILES AND RETURN STATISTICS FOR EACH FILE. WORKS WITHOUT THE TEXT FILE
%INPUTS BUT HAS NO SORTING OF THE DATA

%Check to make sure same number of files

if length(ccvlist) == length (chilist) && length (intensitylist) == length(ccvlist)
    disp(["Number of files: CCV ", length(ccvlist), " , Chi ",length(chilist), " , Photons ",length(intensitylist)])
else
    disp("ERROR: Lengths of file lists may differ for each type of file.")
    disp(["File numbers: CCV ", length(ccvlist), " , Chi ",length(chilist), " , Photons ",length(intensitylist)])
    
    return
end 


%loop creates mask and get statistics for each file, displays images if
%needed
varTypes = ["string", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
varNames = ["CCVFileName", "CHIFileName", "INTFileName", "CCVCoV", "CCVMean", "CCVMedian", "CCVSTDEV", "CHIMean", "CHIMedian", "CHISTDEV", "PhotonsMean", "PhotonsMedian", "PhotonsSTDEV"];
out = table('Size', [length(ccvlist), length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);

add = 0;
for num = 1:length(ccvlist)
    add = add+1

    %CREATING MASK
    %get intensity image
    intensity = dlmread(string(strcat(folder, '\',intensitylist(num))));
    %intensity = intensity{1}{1};
    
    %flip intensity image to match color coded SPCImage output
    flipped = flip(intensity);
    
  
    %open chi squared image
    chiformask = dlmread(strcat(folder, '\',chilist(num)));
    %chiformask = chiformask{1}{1};
    %filter out chi squared outliers
    chiformask(chiformask > 2) = 0;
    chiformask(chiformask ~= 0) = 1;
    chimask = chiformask;

    
    %create total mask - this function uses chi squared values only
    totalmask = double(chimask);
    totalmask(totalmask > 0) = 1;
    
    %get color coded image
    colorfile = dlmread(strcat(folder, '\',ccvlist(num)));
    % colorfile = colorfile{1}{1};
    
    %get chi image
    chiimage = dlmread(strcat(folder, '\',chilist(num)));
    %chiimage = chiimage{1}{1};
    
    %convert mask uint16 to double 
    totalmask = double(totalmask);
    
    %apply mask to images
    colorseg = colorfile.*totalmask;
    chiseg = chiimage.*totalmask;
    
    intensityseg = double(intensity).*totalmask;
    
    %{
    figure()
    subplot(2,3,1)
    imshow(intensity)
    title('intensity-mask')
    subplot(2,3,3) 
    imshow(totalmask)
    title('totalmask')
    subplot(2,3,5)
    imshow(intensityseg)
    title('intensityseg-has mask')
    subplot(2,3,2)
    imshow(chiimage)
    title('chiimage')
    subplot(2,3,4)
    imshow(colorfile)
    title('colorfile')

    figure()
    imshow(chiimage)
    colorbar()
    %}
    
    %get nonzero pixel values from segmented color image to use for statistics
    ccvals = nonzeros(colorseg);
    chivals = nonzeros(chiseg);
    intvals = nonzeros(intensityseg);
    

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

    out(num,:) = {ccvlist(num), chilist(num), intensitylist(num), cov, imgmean, imgmedian, standarddev, chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev};
    disp('function used: statsfromfilenamesonly')

    
    end 
   

end