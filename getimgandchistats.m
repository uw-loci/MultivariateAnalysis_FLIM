%version with time collection
% USER INPUTS
folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\20220830_analysis';
textfilename = 'rho110onlytrial.txt';   %if file name is right but error on run, make sure color coded value files have no space in name
lasercategories = ["L"; "M"; "H"]; %must be in ascending order

doyouwantimages = 0;    % 1 = yes display image, 0 = no

%testinggitupload = 'yes';

% START CODE
info = readtable(strcat(folderlocation, '\', textfilename));

%section out different columns
filenames = info.ImageFile; 
fludye = info.FluorescentDye;
day = info.Day;
roi = info.ROI;
laserpower = info.LaserPower;
binnums = info.BinNumber;
time = info.CollectionTime;

%find the number of files, number of days, and number of dyes
[numfile, infocat] = size(info);
dayvalues = unique(day);
fluvalue = unique(fludye);

%create empty table for data outputs
add = 0;
varTypes = ["cell", "double", "double", "double", "double", "string", "double", "cell", "cell", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
varNames = ["FileName", "FluorescentDye", "Day", "ROI", "LaserPower", "PowerCategory", "BinValue", "Masked Pixel Data", "Masked Chi Vals", "CCV CoV", "CCV Mean", "CCV Median", "CCV STDEV", "CHI Mean", "CHI Median", "CHI STDEV", "Intensity Mean", "Intensity Median", "Intensity STDEV", "Colletion Time (sec)"];
infomeanchi = table('Size', [numfile, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
close all;


temppoccell = zeros([numfile,1]);
table(temppoccell);


%get data for table
for a = 1:numfile

    file = filenames(a,end);
    binnum = binnums(a,end);

    %use "get chi and mean" function to add the statictics to the table
    [imtitle, imavg, immed, imstdev, variation, histdata, chipixels, imgmessage, chiavg, chimed, chistdev, intavg, intmed, intstdev] = getmeanandchi(char(file), folderlocation, binnum, doyouwantimages);
    
    infomeanchi(a,:) = {imtitle, fludye(a), day(a), roi(a), laserpower(a), temppoccell(a), binnums(a), histdata, chipixels, variation, imavg, immed, imstdev, chiavg, chimed, chistdev, intavg, intmed, intstdev, time(a)};
    add = add+1;
    
end 

%creates a table out of the user specified laser categories 
classify = array2table(lasercategories, 'VariableNames', "PowerCategory");

%sort laser powers
classifieddata = table('Size', [0, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);

%identify the different days, dyes, and number of ROIs from the completed
%table with statistics
dayvalue = unique(infomeanchi(:,3));
fluvalue = unique(infomeanchi(:,2));
roivalue = unique(infomeanchi(:,4));

add = 0;

%separate out the ROIs and assign the different laser powers a
%classisfication from the user input
for g = 1:height(fluvalue)
    for h = 1:height(dayvalue)
        %filter by dye and day
            separateflus = infomeanchi(infomeanchi.FluorescentDye == fluvalue.FluorescentDye(g),:);
            separatedays = separateflus(double(separateflus.Day) == dayvalue.Day(h),:);
            
            for b = 1:height(unique(separatedays.ROI))
            add = add +1;
            
            %isolate the unique pockel values, sort them, and add user classification 
            pocvals =  separatedays((separatedays.ROI == roivalue.ROI(b)),:)
            sortedpoc = sortrows(pocvals,"LaserPower");
            laservals = unique(sortedpoc.LaserPower);
            
            for i = 1:height(sortedpoc)
                for j = 1:height(laservals)
                     if height(laservals) ~= height(classify)
                         disp('ERROR: possible mismatch in number of laser powers used and number of laser power categories')
                         return %will stop the code if the user input for laser classification does not have enough categories

                     else if sortedpoc.LaserPower(i) == laservals(j,:)
                        %creates the final output table with statistics and
                        %user classified laser powers 
                        classifieddata = [classifieddata; sortedpoc(i, 1:5), classify(j,:), sortedpoc(i,7:end);];
                     end               
                     end
                end
            end

        end 
    end
end

        
add;
infomeanchi; %table with statistics only (not classified laser powers)

%   OUTPUTS
classifieddata %final table with statistics and laserpower classification column
disp(imgmessage) %tells whether images were printed or not














function  [imagefile, imgmean, imgmedian, standarddev, cov, ccvals, chisquaredvals, imprint, chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev] = getmeanandchi(imagefile, location, bin, imagetoggle)
%THIS FUNCTION IS DESIGNED TO USE THE SPCIMAGE EXPORT FILES (.tif only) AND CREATE
%STATISTICS FOR COLOR CODED VALUE IMAGE, CHI SQUARED, AND INTENSITY IMAGE
%IMPORTANT: filename in folder should have no spaces, use gitbash and asc
%to tif file to change SPCImage output 
%(EX.) "color coded value.asc" should be "colorcodedvalue.tif"

intensityname = strcat(location, '\', imagefile, '_intensity_image.tif');

colorname = strcat(location, '\', imagefile, '_colorcodedvalue.tif'); 
chiname = strcat(location, '\', imagefile, '_chi.tif');

%for each file, calls "get masked pixels" to apply the mask to the images
[ccvals, chisquaredvals, intvals, imprint] = getmaskedpixels(intensityname, colorname, chiname, bin, imagetoggle);

%calculate statistics for each file type
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
intensityseg = double(intensity).*totalmask;


%get nonzero pixel values from segmented color image to use for statistics
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




