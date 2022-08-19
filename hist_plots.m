
info = readtable('C:\Users\hwilson23\Documents\UserDataOWS\scrambleddataforcodetesting.txt');
gitupload = 'yes';

doyouwantimages = 1;    % 1 = yes display image, 0 = no
doyouwanthistograms = 1;    % 1 = yes display histograms, 0 = no

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
varTypes = ["cell", "double", "double", "double", "double", "double", "cell"];
varNames = ["FileName", "FluorescentDye", "Day", "ROI", "LaserPower", "BinValue", "HistogramData"];
histtable = table('Size', [numfile, infocat+1],'VariableTypes',varTypes, 'VariableNames',varNames);
close all;

%get data for histogram
for a = 1:numfile

    file = filenames(a,end);
    binnum = binnums(a,end);

    [imtitle, average, stdev, variation, histdata, imgmessage] = getdata(char(file), binnum, doyouwantimages);
    data = [data; string(imtitle), string(average), string(stdev), string(variation)];

    histtable(a,:) = {imtitle, fludye(a), day(a), roi(a), laserpower(a), binnums(a), histdata};
    add = add+1;
    data;
end 
        
add;
data
histtable
disp(imgmessage)

%get histograms
if doyouwanthistograms == 1
    gethist(histtable) %add toggle
    disp('histograms displayed')
elseif doyouwanthistograms == 0
    disp('doyouwanthistogram = 0, no histogram display')
else
    disp('doyouwanthistogram ERROR')
end 






function gethist(allinfo)
[numfile, ~] = size(allinfo);
dayvalue = unique(allinfo(:,3));
fluvalue = unique(allinfo(:,2));
roivalue = unique(allinfo(:,4));
eachtable = [];
sanity = [];


%loop through all permutations (hopefully) and create graphs
for g = 1:height(fluvalue)
    for h = 1:height(dayvalue)
        for i = 1:height(roivalue)
            figure()
            someinfo = allinfo;
            separateflus = someinfo(someinfo.FluorescentDye == fluvalue.FluorescentDye(g),:);
            separatedays = separateflus(double(separateflus.Day) == double(dayvalue.Day(h)),:);
            separaterois = separatedays(separatedays.ROI == roivalue.ROI(i),:);            
            
            sanity = separaterois.FileName;

           %create plot 
               for j = 1:height(cell2table(sanity))
                
                histogram(cell2mat(separaterois.HistogramData(j)),100,'FaceAlpha',0.4,'EdgeColor','none');

                title(strcat(' Day ',string(h), ' Fluorescent Dye ', string(g),' ROI ',string(i)));
                hold on 
               end
			   
           legend(sanity,'Location','bestoutside');
           sanity = [];
           
        end
    end
end


%%old for loop, to separate day and dye (4 plots)
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



function  [imagefile, covmean, covsd, cov, ccvals, imprint] = getdata(imagefile, bin, imagetoggle)
intensityname = strcat('C:\Users\hwilson23\Documents\UserDataOWS\20220816_analysis\', imagefile, '_intensity_image.tif');
colorname = strcat('C:\Users\hwilson23\Documents\UserDataOWS\20220816_analysis\', imagefile, '_colorcodedvalue.tif');

[ccvals, imprint] = getcoloravg(intensityname, colorname, bin, imagetoggle);

covmean = mean(ccvals);
covsd = std(ccvals);
cov = covsd/covmean;

end


function [pixelvals, imageprint] = getcoloravg(intensityfile, colorcodedfile, binval, imdis) 


%get intensity image
intensity = bfopen(intensityfile);
intensity = intensity{1}{1};

%flip intensity image to match color coded SPCImage output
flipped = flip(intensity);

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
    insertbin = 'bin option error';
end

%spatial binning approximation 
binned = medfilt2(flipped, insertbin);

%segment image 
segmented = binned; 
segmented(segmented > prctile(binned,80,'all')) = 0;
segmented(segmented < prctile(binned,20,'all')) = 0;

%create mask
mask = segmented;
mask(mask > 0) = 1;

%get color coded image
colorfile = bfopen(colorcodedfile);
colorfile = colorfile{1}{1};

%convert mask uint16 to double 
mask = double(mask);

%apply mask of intensity image to color coded image
colorseg = colorfile.*mask;

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
        imageprint = ('doyouwantimage = 0, no histogram display');
    else
        imageprint = ('doyouwantimage ERROR');
end 

end 






