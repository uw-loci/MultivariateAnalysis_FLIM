% Script to analyze dye files - streamlined

%input - folder location and the name of the text file if data sorting
%desired

% USER INPUTS
%folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\allanalysisdata';
%folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\fluorescein_analysis';
folderlocation = 'C:\Users\hwilson23\Documents\Projects\Fluorescein_Quenching\fluorescein_analysis';
textfilename = 'blank';   %if file name is "blank," code works with google drive folder download, ELSE specify a text file name (make sure color coded value files have no space in name)
segmentorcrop = 0;    % DETERMINES IF THRESHOLDED OR CROPPED STATISTICS 1 = SEGMENT, 0 = CROPPED

if ~(isfolder(folderlocation))
    folderlocation = 'C:\Users\lociu\Documents\MATLAB\data';
end
 
 
 % START CODE

if strcmp(textfilename, 'blank') == 0 
        lasercategories = [1;2;3]; %must be in ascending order
        
        
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
        varNames = ["FileName", "FluorescentDye", "Day", "ROI", "LaserPower", "PowerCategory", "BinValue", "MaskedPixelData", "MaskedChiVals", "CCVCoV", "CCVMean", "CCVMedian", "CCVSTDEV", "CHIMean", "CHIMedian", "CHISTDEV", "IntensityMean", "IntensityMedian", "IntensitySTDEV", "ColletionTime(sec)"];
        infomeanchi = table('Size', [numfile, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
        close all;
        
        
        temppoccell = zeros([numfile,1]);
        table(temppoccell);
        
        
        %get data for table
        for a = 1:numfile
        
            file = filenames(a,end);
            binnum = binnums(a,end);
        
            %use "get mean and chi" function to add the statictics to the table
            [imtitle, imavg, immed, imstdev, variation, histdata, chipixels, imgmessage, chiavg, chimed, chistdev, intavg, intmed, intstdev] = getmeanandchi(char(file), folderlocation, binnum, doyouwantimages);
            
            infomeanchi(a,:) = {imtitle, fludye(a), day(a), roi(a), laserpower(a), temppoccell(a), binnums(a), histdata, chipixels, variation, imavg, immed, imstdev, chiavg, chimed, chistdev, intavg, intmed, intstdev, time(a)};
            add = add+1;
            
        end 
        
        %creates a table out of the user specified laser categories 
        classify = array2table(lasercategories, 'VariableNames', "PowerCategory");
        
        %sort laser powers
        outputdata = table('Size', [0, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
        
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
                    pocvals =  separatedays((separatedays.ROI == roivalue.ROI(b)),:);
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
                                outputdata = [outputdata; sortedpoc(i, 1:5), classify(j,:), sortedpoc(i,7:end);];
                             end               
                             end
                        end
                    end
        
                end 
            end
        end
        
       
        %%
        %perform anova (on CCV medium) for each dye, with variables of Power, Day, ROI
        % , as specified in eachdyeanova function 
        anovaoutput = {"AnovaName", "AnovaResults"};
        for k = 1:height(fluvalue)
            anovaname = strcat('annovafordye',string(k));
            results = eachdyeanova(outputdata, k);
            anovaoutput = [anovaoutput; {anovaname}, {results}];
        
        end 
        
        %   OUTPUTS
        outputdata ;%final table with statistics and laserpower classification column
        disp(imgmessage) %tells whether images were printed or not

        %%
    %this will get statistics from the files without the text file data -
    %NO SORTING AND NO ANOVA
elseif strcmp(textfilename, 'blank') == 1
       filenamelist = ls(folderlocation)

        ccvfiles = [];
        chifiles = [];
        intensityfiles = [];
       for temp = 1:height(filenamelist)
           
           ccvlist = contains(filenamelist(temp,:),"value.asc");
           chilist = contains(filenamelist(temp,:),"chi.asc");
           intensitylist = contains(filenamelist(temp,:),"photons.asc");

           if ccvlist == 1
               ccvfiles = [ccvfiles; string(strtrim(filenamelist(temp,:)))];
           elseif chilist == 1
               chifiles = [chifiles; string(strtrim(filenamelist(temp,:)))];
           elseif  intensitylist ==1
               intensityfiles = [intensityfiles; string(strtrim(filenamelist(temp,:)))];
           end 

       end 
       ccvfiles;

       %%%add if statement to call crop if crop desired 

       if segmentorcrop == 1
            outputdata = statsfromfilenamesonly(folderlocation, ccvfiles, chifiles, intensityfiles)
       elseif segmentorcrop == 0
            outputdata = statsfromcrop(folderlocation, ccvfiles, chifiles, intensityfiles)
       
       end
           

else
    disp("Error with textfilename or segmentorcrop")
end





%%


function  [imagefile, imgmean, imgmedian, standarddev, cov, ccvals, chisquaredvals, imprint, chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev] = getmeanandchi(imagefile, location, bin, imagetoggle)
%THIS FUNCTION IS DESIGNED TO USE THE SPCIMAGE EXPORT FILES (.tif only) AND CREATE
%STATISTICS FOR COLOR CODED VALUE IMAGE, CHI SQUARED, AND INTENSITY IMAGE
%IMPORTANT: filename in folder should have no spaces, use gitbash and asc
%to tif file to change SPCImage output 
%(EX.) "color coded value.asc" should be "colorcodedvalue.tif"

intensityname = strcat(location, '\', imagefile, '_intensity_image.tif')

colorname = strcat(location, '\', imagefile, '_colorcodedvalue.tif') 
chiname = strcat(location, '\', imagefile, '_chi.tif')

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





