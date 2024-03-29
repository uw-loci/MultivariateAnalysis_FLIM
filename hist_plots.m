
%USER INPUTS
folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\20220830_analysis';
textfilename = 'rho110onlytrial.txt';
info = readtable(strcat(folderlocation, '\', textfilename));

doyouwantimages = 0;    % 1 = yes display image, 0 = no
doyouwanthistograms = 1;    % 1 = yes display histograms, 0 = no
doyouwantgrouphist = 1; % 1 = yes display grouped histograms, 0 = no

%START CODE
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
data = ["FileName", "Mean", "StandardDeviation", "CoeffOfVariation"];
varTypes = ["cell", "double", "double", "double", "double", "double", "double", "cell"];
varNames = ["FileName", "FluorescentDye", "Day", "ROI", "LaserPower", "BinValue", "CollectionTime", "HistogramData"];
histtable = table('Size', [numfile, infocat+1],'VariableTypes',varTypes, 'VariableNames',varNames);
close all;

%get data for histogram
for a = 1:numfile

    file = filenames(a,end);
    binnum = binnums(a,end);
    
    %use "get data" function to start creating table with statistics and
    %histogram values
    [imtitle, average, stdev, variation, histdata, imgmessage] = getdata(char(file), folderlocation, binnum, doyouwantimages);
    data = [data; string(imtitle), string(average), string(stdev), string(variation)];

    histtable(a,:) = {imtitle, fludye(a), day(a), roi(a), laserpower(a), binnums(a), time(a), histdata};
    add = add+1;
    data;
end 

     
add;




%get separated histograms if desired
if doyouwanthistograms == 1
    %calls gethist function to create the histograms
    gethist(histtable) 
    disp('histograms displayed')
elseif doyouwanthistograms == 0
    disp('doyouwanthistogram = 0, no histogram display')
else
    disp('doyouwanthistogram ERROR')
end 

%get grouped histograms if desired
if doyouwantgrouphist == 1
    %calls getpopulationhist to create group histograms
    getpopulationhist(histtable)  
    disp('group histogram displayed')
elseif doyouwanthistograms == 0
    disp('doyouwanthistogram = 0, no group histogram display')
else
    disp('doyouwantgrouphist ERROR')
end 


%OUTPUTS
data %some statistics (more with getimgandchistats file)
histtable %final table, copy of input with histogram data column showing number of values per file distribution
disp(imgmessage) %tells whether images were printed or not













function gethist(allinfo)
%THIS FUNCTION PUTS THE FILE DATA INTO HISTOGRAMS

%gets number of files, days, dyes, and rois
[numfile, ~] = size(allinfo);
dayvalue = unique(allinfo(:,3));
fluvalue = unique(allinfo(:,2));
roivalue = unique(allinfo(:,4));

%loop through all permutations (hopefully) and create graphs
for g = 1:height(fluvalue)
    for h = 1:height(dayvalue)
        for i = 1:height(roivalue)
            
            %segments the whole table to into specific dyes, days, and rois
            someinfo = allinfo;
            separateflus = someinfo(someinfo.FluorescentDye == fluvalue.FluorescentDye(g),:);
            separatedays = separateflus(double(separateflus.Day) == double(dayvalue.Day(h)),:);
            separaterois = separatedays(separatedays.ROI == roivalue.ROI(i),:);            
            
            %file names for each segmented table, used for legend
            sanityflus = separateflus.FileName;
            sanitydays = separatedays.FileName;
            sanityrois = separaterois.FileName;
           
            figure()

           %create plot separated by day, dye, and ROI
               for j = 1:height(cell2table(sanityrois))
                
                histogram(cell2mat(separaterois.HistogramData(j)),100,'FaceAlpha',0.4,'EdgeColor','none');
                xlim([0 6000]);

                title(strcat(' Fluorescent Dye ', string(g), ' Day ',string(h),' ROI ',string(i)));
               hold on 
               end
               hold off
            
			   
           legrois = legend(sanityrois,'Location','bestoutside','FontSize',6,'NumColumns',1); 
           title(legrois, strcat('Number of files:  ', string(height(cell2table(sanityrois)))));
            
           
           sanityrois = [];
           
        end

            figure()

            %create plot separated by day and dye only
            for k = 1:height(cell2table(sanitydays))
                
                histogram(cell2mat(separatedays.HistogramData(k)),100,'FaceAlpha',0.4,'EdgeColor','none');
                xlim([0 6000]);

                title(strcat(' Fluorescent Dye ', string(g),' Day ',string(h) ,' All ROIs'));
                hold on 
               end
			   hold off
               
           legdays = legend(sanitydays,'Location','bestoutside','FontSize',6,'NumColumns',3); 
           title(legdays, strcat('Number of files:  ', string(height(cell2table(sanitydays)))));
             sanitydays = [];
    end

    figure()
            %create plot separated by dye only
            for l = 1:height(cell2table(sanityflus))
                
                histogram(cell2mat(separateflus.HistogramData(l)),100,'FaceAlpha',0.4,'EdgeColor','none');
                xlim([0 6000]);
                title(strcat(' Fluorescent Dye ', string(g),' All Days ',' All ROIs'));
                hold on 
               end
			   hold off
               legflus = legend(sanityflus,'Location','bestoutside','FontSize',6,'NumColumns',3); 
               title(legflus, strcat('Number of files:  ', string(height(cell2table(sanityflus)))));
           
             sanityflus = [];
end


% OLD VERSION OF FOR LOOP, to separate day and dye (4 plots)
%{
count = 1;
for c = 1:height(fluvalue)
    for d = 1:height(dayvalue)
        figure(count)
        
        for f = 1:numfile
            if allinfo.FluorescentDye(f) == fluvalue.FluorescentDye(c)
                if allinfo.Day(f) == dayvalue.Day(d)
                    eachtable = [eachtable, allinfo.HistogramData(f)]
                    sanity = [sanity; allinfo.FileName(f)]

                    histogram(cell2mat(allinfo.HistogramData(f)),100,'FaceAlpha',0.4,'EdgeColor','none');
                    hold on

                end
            end

            title(strcat('Day ',string(d), 'Fluorescent Dye ', string(c)));
            legend(sanity,'Location','bestoutside');
        end 
        count = count+1;
        sanity = [];
        count;
    end 

end

%} 


end


function getpopulationhist(allinfo)
%THIS FUNCTION CREATES GROUP HISTOGRAMS WITH ONE DISTRIBUTION (DATA
%COMBINED FROM MULTIPLE FILES)

%get day and dye numbers 
dayvalue = unique(allinfo(:,3));
fluvalue = unique(allinfo(:,2));

%loop through all permutations (hopefully) and create graphs
for g = 1:height(fluvalue)
    for h = 1:height(dayvalue)
        
        %creates separate tables
        someinfo = allinfo;
        separateflus = someinfo(someinfo.FluorescentDye == fluvalue.FluorescentDye(g),:);
        separatedays = separateflus(double(separateflus.Day) == double(dayvalue.Day(h)),:);      
        
        %file names in tables, used for legend
        sanityflus = separateflus.FileName;
        sanitydays = separatedays.FileName;
               
        figure()
        allROIs = [];
            %create "population plot" separated by DAY AND DYE 
            % concatenated to show one distribution 

            for k = 1:height(cell2table(sanitydays))
                
                allROIs = [allROIs; cell2mat(separatedays.HistogramData(k))];
            end
            histogram(allROIs,100,'FaceAlpha',0.4,'EdgeColor','none');
            title(strcat(' Fluorescent Dye ', string(g),' Day ',string(h) ,' All ROIs'));
            %xlim([0 6000]);

           %legdays = legend(sanitydays,'Location','bestoutside','FontSize',6,'NumColumns',3); 
           %title(legdays, strcat('Number of files:  ', string(height(cell2table(sanitydays)))));
             sanitydays = [];
    end

        figure()
        alldays = [];
            %create "population plot" separated by DYE ONLY 
            % concatenated to show one distribution
            for k = 1:height(cell2table(sanityflus))
                
                alldays = [alldays; cell2mat(separateflus.HistogramData(k))];
                size(alldays);
            end
            histogram(alldays,100,'FaceAlpha',0.4,'EdgeColor','none');
            title(strcat(' Fluorescent Dye ', string(g),' All Days '));
           
           %legdays = legend(sanityflus,'Location','bestoutside','FontSize',6,'NumColumns',3); 
           %title(legdays, strcat('Number of files:  ', string(height(cell2table(sanityflus)))));
           sanityflus = [];
end
end 


function  [imagefile, covmean, covsd, cov, ccvals, imprint] = getdata(imagefile, location, bin, imagetoggle)
%THIS FUNCTION CALLS getmaskedpixels TO GET THE MASKED DATA AND THEN COMPUTES
%THE STATISTICS FOUND IN THE data OUTPUT TABLE
%IMPORTANT: filename in folder should have no spaces, use gitbash and asc
%to tif file to change SPCImage output

intensityname = strcat(location, '\', imagefile, '_intensity_image.tif');

colorname = strcat(location, '\', imagefile, '_colorcodedvalue.tif');  
chiname = strcat(location, '\', imagefile, '_chi.tif');

[ccvals, chisquaredvals, intvals, imprint] = getmaskedpixels(intensityname, colorname, chiname, bin, imagetoggle);

covmean = mean(ccvals,'all');
covsd = std(ccvals,0,'all'); % w = 0 to normalize by N-1 (default option)
cov = covsd/covmean;

end

%{
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

%} 


