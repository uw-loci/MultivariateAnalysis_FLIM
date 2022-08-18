
rho110info = readtable('C:\Users\hwilson23\Documents\UserDataOWS\rho110info.txt');
rhobinfo = readtable('C:\Users\hwilson23\Documents\UserDataOWS\rhoBinfo.txt');

filenames = table2array([rho110info(:,5) rhobinfo(:,2)]);
binnums = table2array([rho110info(:,11) rhobinfo(:,4)]);
[numfile, samples] = size(filenames);
add = 0;
data = [];
for a = 1:samples
    for b = 1:numfile
        
        file = filenames(b,a);
        binnum = binnums(b,a);
        [imtitle, average, stdev, variation] = getdata(char(file), binnum);
        data = [data; string(imtitle), string(average), string(stdev), string(variation)];
        
        add = add+1;
        data;
    end 
        
end 
add;
data

%{
figure(3)
[rho110row, rho110col] = size(rho110info);
scatter(rho110info(:,5), double(data(rho110row,2)), 'filled');
errorbar(double(average(rho110row,2)));
%}


function [imagefile, covmean, covsd, cov] = getdata(imagefile, bin)
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
imagesc(flipped);

%bin options
bin2 = [5, 5];
bin3 = [7, 7];
bin5 = [11, 11];
bin6 = [13, 13];
bin8 = [17, 17];

usebin = strcat('bin',string(binval));

if usebin == 'bin2'
    insertbin = bin2;
elseif usebin == 'bin3'
    insertbin = bin3;
elseif usebin == 'bin5'
    insertbin = bin5;
elseif usebin == 'bin6'
    insertbin = bin6;
elseif usebin == 'bin8'
    insertbin = bin8;
else 
    insertbin = 'bin option error'
end
%spatial binning approximation 
binned = medfilt2(flipped, insertbin);
imagesc(binned);
colorbar();

%segment image 
segmented = binned; 
segmented(segmented > prctile(binned,80,'all')) = 0;
segmented(segmented < prctile(binned,20,'all')) = 0;

%set color bar limits
colortop = max(max(binned));
colorbtm = min(min(binned));
caxis manual;
caxis([colorbtm colortop])

figure(1)
subplot(3,1,1), imagesc(binned);
axis image
title('binned intensity image')
colorbar;
subplot(3,1,2), imagesc(segmented);
axis image
title('segmented intensity image')
caxis manual;
caxis([colorbtm colortop])
colorbar;

%create mask
mask = segmented;
subplot(3,1,3)
mask(mask > 0) = 1;
imagesc(mask)
axis image
title('mask of intensity image')
colorbar;

%get color coded image
colorfile = bfopen(colorcodedfile);
colorfile = colorfile{1}{1};

figure(2)
subplot(2,1,1), imagesc(colorfile);
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
subplot(2,1,2), imagesc(colorseg);
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






