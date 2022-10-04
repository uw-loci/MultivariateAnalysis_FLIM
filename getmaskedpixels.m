function [pixelvals, chivals, intensityvals, imageprint] = getmaskedpixels(intensityfile, colorcodedfile, chifile, binval, imdis) 
%THIS FUNCTION IS DESIGNED TO APPLY THE MASKS TO THE EXPORTED SPCIMAGE
%FILES

%CREATING MASK
%get intensity image
intensity = bfopen(intensityfile);
intensity = intensity{1}{1};

%flip intensity image to match color coded SPCImage output
flipped = flip(intensity);

%bin based on the corresponding value in the text file for each file

insertbin = [((2*binval)+1), ((2*binval)+1)]; %2n+1 matrix


%spatial binning approximation applied to intensity image
binned = medfilt2(flipped, insertbin);

%segment image 
segmented = binned; 
%filters out intensity pixels outside specified percentile
segmented(segmented > prctile(binned,80,'all')) = 0; %orig 80,20
segmented(segmented < prctile(binned,20,'all')) = 0;
intmask = segmented;


%open chi squared image
chiformask = bfopen(chifile);
chiformask = chiformask{1}{1};
%filter out chi squared outliers
chiformask(chiformask > 2) = 0;
chiformask(chiformask ~= 0) = 1;
chimask = chiformask;
%imshow(chimask);

%option to print number of chi squared outliers being removed
numberofchioutliers = numel(chiformask) - nnz(chiformask); 


%create total mask
totalmask = double(intmask).*double(chimask);
totalmask(totalmask > 0) = 1;

%get color coded image
colorfile = bfopen(colorcodedfile);
colorfile = colorfile{1}{1};

%get chi image
chiimage = bfopen(chifile);
chiimage = chiimage{1}{1};

%convert mask uint16 to double 
totalmask = double(totalmask);

%apply mask to images
colorseg = colorfile.*totalmask;
chiseg = chiimage.*totalmask;
intensityseg = double(flipped).*totalmask;


%get nonzero pixel values from segmented color image to use for statistics
pixelvals = nonzeros(colorseg);
chivals = nonzeros(chiseg);
intensityvals = nonzeros(intensityseg);

<<<<<<< Updated upstream
=======
disp('function used: getmaskedpixels')

%{
figure()
    subplot(2,3,1)
    imshow(intensity)
    title('intensity')
    subplot(2,3,3) 
    imshow(totalmask)
    title('totalmask')
    subplot(2,3,5)
    imshow(intensityseg)
    title('intensityseg')
    subplot(2,3,2)
    imshow(chiimage)
    title('chiimage')
    subplot(2,3,4)
    imshow(colorfile)
    title('colorfile')
    subplot(2,3,6)
    imshow(flipped)
    title('flipped-has mask')
    intensityfile
    return
%}
>>>>>>> Stashed changes

%displays images if needed 
if imdis == 1
        
        figure()
        subplot(3,2,1), imagesc(flipped);
        axis image
        title('flipped intensity image (no bin)')
        colorbar();				   
       
        %set color bar limits
        colortop = max(max(binned)); %based on max documentation
        colorbtm = min(min(binned));
        caxis manual;
        caxis([colorbtm colortop])
                
        subplot(3,2,3), imagesc(binned);
        axis image
        title('binned intensity image')
        colorbar;
        subplot(3,2,5), imagesc(intmask);
        axis image
        title('segmented intensity image')
        caxis manual;
        caxis([colorbtm colortop])
        colorbar;					 
        
        subplot(3,2,2), imagesc(totalmask)
        axis image
        title('total mask of intensity image')
        colorbar;
        
        subplot(3,2,4), imagesc(colorfile);
        axis image
        title('original color coded value image')
        top2 = max(max(colorfile));
        btm2 = min(min(colorfile));
        caxis manual;
        caxis([btm2 top2]);
        colorbar;
        
        subplot(3,2,6), imagesc(colorseg);
        axis image
        title('color coded image with mask')
        caxis manual;
        caxis([btm2 top2]);
        colorbar;
        
        imageprint = ('images displayed');
        
    elseif imdis == 0
        imageprint = ('doyouwantimage = 0, no image display');
    else
        imageprint = ('doyouwantimage ERROR');

end 
end