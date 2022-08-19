
info = readtable('C:\Users\hwilson23\Documents\UserDataOWS\scrambleddataforcodetesting.txt');
gitupload = 'yes';

filenames = info.ImageFile; %change to equal correct title
fludye = info.FluorescentDye;
day = info.Day;
roi = info.ROI;
laserpower = info.LaserPower;
binnums = info.BinNumber;


[numfile, infocat] = size(info);
dayvalues = unique(day);
fluvalue = unique(fludye);

add = 0;
data = ["FileName", "Mean", "StandardDeviation", "CoeffOfVariation"];
close all;

%gets data, no histogram function
for a = 1:numfile
    
    file = filenames(a,end);
    binnum = binnums(a,end);
    [imtitle, average, stdev, variation] = getdata(char(file), binnum);
    data = [data; string(imtitle), string(average), string(stdev), string(variation)];

    add = add+1;
    data;
    
end 
add;
data


function [imagefile, covmean, covsd, cov, ccvals] = getdata(imagefile, bin)
intensityname = strcat('C:\Users\hwilson23\Documents\UserDataOWS\20220816_analysis\', imagefile, '_intensity_image.tif');
colorname = strcat('C:\Users\hwilson23\Documents\UserDataOWS\20220816_analysis\', imagefile, '_colorcodedvalue.tif');

ccvals = getcoloravg(intensityname, colorname, bin);

covmean = mean(ccvals);
covsd = std(ccvals);
cov = covsd/covmean;

end


function pixelvals = getcoloravg(intensityfile, colorcodedfile, binval) 

%get intensity image
intensity = bfopen(intensityfile);
intensity = intensity{1}{1};

%flip intensity image to match color coded SPCImage output
flipped = flip(intensity);

figure()
subplot(3,2,1), imagesc(flipped);
axis image
colorbar();
title('flipped intensity image');

%bin options
bin2 = [5, 5]; % 2n+1
bin3 = [7, 7];
bin5 = [11, 11];
bin6 = [13, 13];
bin8 = [17, 17];

usebin = strcat('bin',string(binval));

if strcmpi(usebin,'bin2')== 1
    insertbin = bin2;
elseif strcmpi(usebin,'bin3')== 1
    insertbin = bin3;
elseif strcmpi(usebin,'bin5')== 1
    insertbin = bin5;
elseif strcmpi(usebin,'bin6')== 1
    insertbin = bin6;
elseif strcmpi(usebin,'bin8')== 1
    insertbin = bin8;
else 
    insertbin = 'bin option error'
end

%spatial binning approximation 
binned = medfilt2(flipped, insertbin);

%segment image 
segmented = binned; 
segmented(segmented > prctile(binned,80,'all')) = 0;
segmented(segmented < prctile(binned,20,'all')) = 0;

%set color bar limits
colortop = max(max(binned)); %based on max documentation
colorbtm = min(min(binned));
caxis manual;
caxis([colorbtm colortop])

subplot(3,2,3), imagesc(binned);
axis image
title('binned intensity image')
colorbar;
subplot(3,2,5), imagesc(segmented);
axis image
title('segmented intensity image')
caxis manual;
caxis([colorbtm colortop])
colorbar;

%create mask
mask = segmented;

mask(mask > 0) = 1;
subplot(3,2,2), imagesc(mask)
axis image
title('mask of intensity image')
colorbar;

%get color coded image
colorfile = bfopen(colorcodedfile);
colorfile = colorfile{1}{1};

subplot(3,2,4), imagesc(colorfile);
axis image
title('original color coded value image')
top2 = max(max(colorfile));
btm2 = min(min(colorfile));
caxis manual;
caxis([btm2 top2]);
colorbar;

%convert mask uint16 to double 
mask = double(mask);

%apply mask of intensity image to color coded image
colorseg = colorfile.*mask;
subplot(3,2,6), imagesc(colorseg);
axis image
title('color coded image with mask')
caxis manual;
caxis([btm2 top2]);
colorbar;

%get nonzero pixel values from segmented color image
pixelvals = nonzeros(colorseg);

%{
%specify number of elements to average
n = 1000;

%find remainder 
[pixelrow pixelcol] = size(pixelvals)
r = rem(pixelrow,n)

%get averages as distribution
maxele = pixelrow - r; %max element number based on remainder

averagethese = pixelvals([1:maxele],:);
avgmatrix = reshape(averagethese, [], n) %specified number of columns
avg = mean(avgmatrix); %averages the values in the rows
avg = avg'; %transpose averages for concatenation 
remavg = mean(pixelvals([maxele+1:pixelrow],:)); %avg of remainder
coloravgdis = [avg; remavg]; %complete average distribution for segmented color coded values

%}

end 






