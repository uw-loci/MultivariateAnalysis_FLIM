
% USER INPUTS
folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\allanalysisdata';
textfilename = 'fourdaystwodyes.txt';
doyouwantimages = 0;    % 1 = yes display image, 0 = no


% START CODE
info = readtable(strcat(folderlocation, '\', textfilename));

filenames = info.ImageFile; 
fludye = info.FluorescentDye;
day = info.Day;
roi = info.ROI;
laserpower = info.LaserPower;
binnums = info.BinNumber;
time = info.CollectionTime;


[numfile, infocat] = size(info);
dayvalues = unique(day);
fluvalue = unique(fludye);


add = 0;
varTypes = ["cell", "double", "double", "double", "double", "string", "double", "cell", "cell", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
varNames = ["FileName", "FluorescentDye", "Day", "ROI", "LaserPower", "PowerCategory", "BinValue", "Masked Pixel Data", "Masked Chi Vals", "CCV CoV", "CCV Mean", "CCV Median", "CCV STDEV", "CHI Mean", "CHI Median", "CHI STDEV", "Intensity Mean", "Intensity Median", "Intensity STDEV", "Colletion Time (sec)"];
infomeanchi = table('Size', [numfile, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
close all;


temppoccell = zeros([numfile,1]);
table(temppoccell);


%get data for histogram
for a = 1:numfile

    file = filenames(a,end);
    binnum = binnums(a,end);

    [imtitle, imavg, immed, imstdev, variation, histdata, chipixels, imgmessage, chiavg, chimed, chistdev, intavg, intmed, intstdev] = getmeanandchi(char(file), folderlocation, binnum, doyouwantimages);
    
    infomeanchi(a,:) = {imtitle, fludye(a), day(a), roi(a), laserpower(a), temppoccell(a), binnums(a), histdata, chipixels, variation, imavg, immed, imstdev, chiavg, chimed, chistdev, intavg, intmed, intstdev, time(a)};
    add = add+1;
    
end 

classify = array2table(["Lo"; "Me"; "HI"], 'VariableNames', "PowerCategory");
%sort laser powers
classifieddata = table('Size', [0, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);

dayvalue = unique(infomeanchi(:,3));
fluvalue = unique(infomeanchi(:,2));
roivalue = unique(infomeanchi(:,4));

add = 0;

for g = 1:height(fluvalue)
    for h = 1:height(dayvalue)
        %filter by dye and day
            separateflus = infomeanchi(infomeanchi.FluorescentDye == fluvalue.FluorescentDye(g),:);
            separatedays = separateflus(double(separateflus.Day) == dayvalue.Day(h),:);
            
            for b = 1:height(unique(separatedays.ROI))
            add = add +1;
            

            %isolate 3 pockel values and add column classifiying high,
            %medium, low 
            pocvals =  separatedays((separatedays.ROI == roivalue.ROI(b)),:);
            sortedpoc = sortrows(pocvals,"LaserPower");
            classifieddata = [classifieddata; sortedpoc(:, 1:5), classify, sortedpoc(:,7:end);];
        end 
    end
end

        
add;
infomeanchi;

%   OUTPUTS
classifieddata
disp(imgmessage)














function  [imagefile, imgmean, imgmedian, standarddev, cov, ccvals, chisquaredvals, imprint, chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev] = getmeanandchi(imagefile, location, bin, imagetoggle)

intensityname = strcat(location, '\', imagefile, '_intensity_image.tif');
%IMPORTANT: filename in folder should have no spaces, use gitbash and asc
%to tif file to change SPCImage output
colorname = strcat(location, '\', imagefile, '_colorcodedvalue.tif'); 
chiname = strcat(location, '\', imagefile, '_chi.tif');

[ccvals, chisquaredvals, intvals, imprint] = getmaskedpixels(intensityname, colorname, chiname, bin, imagetoggle);

imgmean = mean(ccvals,'all');  %check for single value
imgmedian = median(ccvals,'all');
standarddev = std(ccvals,0, 'all');        % w = 0 to normalize by N-1 (default option)
cov = standarddev/imgmean;

chimean = mean(chisquaredvals, 'all');
chimedian = median(chisquaredvals, 'all');
chistandarddev = std(chisquaredvals, 0, 'all');     % w = 0 to normalize by N-1 (default option)

intmean = mean(intvals, 'all');
intmedian = median(intvals,'all');
intstandarddev = std(intvals,0,'all');


end

function [pixelvals, chivals, intensityvals, imageprint] = getmaskedpixels(intensityfile, colorcodedfile, chifile, binval, imdis) 

%get intensity image
intensity = bfopen(intensityfile);
intensity = intensity{1}{1};

%flip intensity image to match color coded SPCImage output
flipped = flip(intensity);

%bin options

insertbin = [((2*binval)+1), ((2*binval)+1)]; %2n+1 matrix


%spatial binning approximation 
binned = medfilt2(flipped, insertbin);

%segment image 
segmented = binned; 
segmented(segmented > prctile(binned,80,'all')) = 0; %orig 80,20
segmented(segmented < prctile(binned,20,'all')) = 0;

%create mask
mask = segmented;
mask(mask > 0) = 1;

%get color coded image
colorfile = bfopen(colorcodedfile);
colorfile = colorfile{1}{1};

%get chi squared image
chiimage = bfopen(chifile);
chiimage = chiimage{1}{1};

%convert mask uint16 to double 
mask = double(mask);

%apply mask of intensity image to images
colorseg = colorfile.*mask;
chiseg = chiimage.*mask;
intensityseg = double(intensity).*mask;


%get nonzero pixel values from segmented color image
pixelvals = nonzeros(colorseg);
chivals = nonzeros(chiseg);
intensityvals = nonzeros(intensityseg);


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
        subplot(3,2,5), imagesc(segmented);
        axis image
        title('segmented intensity image')
        caxis manual;
        caxis([colorbtm colortop])
        colorbar;					 
        
        subplot(3,2,2), imagesc(mask)
        axis image
        title('mask of intensity image')
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




