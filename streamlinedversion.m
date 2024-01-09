% Script to analyze dye files - streamlined

%input - folder location and the name of the text file if data sorting
%desired

% USER INPUTS
%folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\allanalysisdata';
%folderlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\fluorescein_analysis';
%folderlocation = 'C:\Users\hwilson23\Documents\Projects\Fluorescein_Quenching\slimdata_analysis';

%folderlocation = 'H:\Projects\Fluorescein_Quenching\flu_re_bin';
folderlocation = 'H:\Projects\Fluorescein_Quenching\slimdata_analysis';
%textfilename = 'blank';   %if file name is "blank," code works with google drive folder download, ELSE specify a text file name (make sure color coded value files have no space in name)
textfilename = 'slim_fludata_zposNOTmoved.txt'
segmentorcrop = 0;    % DETERMINES IF THRESHOLDED OR CROPPED STATISTICS 1 = SEGMENT, 0 = CROPPED
textfilename
addpath('C:\Users\hwilson23\Documents\MATLAB\gramm-master\gramm-master')
if ~(isfolder(folderlocation))
    folderlocation = 'C:\Users\lociu\Documents\MATLAB\data';
end
 

 % START CODE

if strcmp(textfilename, 'blank') == 0 
    disp('text file entered')    
    lasercategories = ["0";"1";"2";"3"]; %must be in ascending order
        
        
        infotbl = readtable(strcat(folderlocation, '\', textfilename));
        
        %section out different columns
        filenames = infotbl.ImageFile; 
        fludye = infotbl.FluorescentDye;
        day = infotbl.Day;
        roi = infotbl.ROI;
        laserpower = infotbl.LaserPower;
        binnums = infotbl.BinNumber;
        time = infotbl.CollectionTime;
        
        %find the number of files, number of days, and number of dyes
        [numfile, infocat] = size(infotbl);
        dayvalues = unique(day);
        fluvalue = unique(fludye);
        
        %create empty table for data outputs
        add = 0;
        varTypes = ["cell", "double", "double", "double", "double", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
        varNames = ["FileName", "FluorescentDyeAnalyzed", "DayAnalyzed", "ROIAnalyzed", "LaserPowerAnalyzed", "PowerCategory", "BinValue", "CCVCoV", "CCVMean", "CCVMedian", "CCVSTDEV", "CHIMean", "CHIMedian", "CHISTDEV", "PhotonsMean", "PhotonsMedian", "PhotonsSTDEV", "ColletionTime"];
        infomeanchi = table('Size', [numfile, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
        close all;
        
        
        temppoccell = zeros([numfile,1]);
        table(temppoccell);
        
        
        %get data for table
        for a = 1:numfile
        
            file = filenames(a,end);
            binnum = binnums(a,end);
        
            %use "get mean and chi" function to add the statictics to the table
            char(file)
            [imtitle, imavg, immed, imstdev, variation, histdata, chipixels, chiavg, chimed, chistdev, intavg, intmed, intstdev] = getmeanandchi(char(file), folderlocation, binnum);
           
            infomeanchi(a,:) = {file, fludye(a), day(a), roi(a), laserpower(a), temppoccell(a), binnums(a), variation, imavg, immed, imstdev, chiavg, chimed, chistdev, intavg, intmed, intstdev, time(a)};
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
          %{
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
                            height(laservals)
                            laservals
                            height(classify)
                            classify
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
        %}
        %   OUTPUTS
        outputdata = [infotbl infomeanchi];
        filename = 'outputdata.xlsx';
        outputdata ;%final table with statistics and laserpower classification column
       

        %%
    %this will get statistics from the files without the text file data -
    %NO SORTING AND NO ANOVA
elseif strcmp(textfilename, 'blank') == 1
       filenamelist = ls(folderlocation);

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
            
        else
            disp("error with segmentorcrop")
        end
        
           

else
    disp("Error with textfilename or segmentorcrop")
end
filename = 'outputdata.xlsx';
writetable(outputdata,filename , 'Sheet', 1, 'FileType', 'spreadsheet');


%%
%graphing

figure()
gr = gramm('x', outputdata.KIConcen, 'y', outputdata.CCVCoV,'color',outputdata.BinValue,'subset', string(outputdata.ManualCFDClass) == 'h' & outputdata.Day > 20221111 & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 45)
% Set appropriate names for legends
gr.set_names('x','KI Concentration (M)','y','CV')
gr.set_title('KIConcen vs CV, high photon rate, 45-180sec files')
gr.stat_boxplot()
%gr.stat_violin('half', false,'fill','transparent', 'normalization','width')
gr.geom_point()
gr.stat_glm('disp_fit', true)
%gr.set_color_options('chroma',10,'lightness',40)
gr.set_text_options('base_size', 20)
gr.draw()

newtable = outputdata(string(outputdata.ManualCFDClass) == 'h' & outputdata.Day > 20221111 & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180,:)
mdl = fitlm(newtable.KIConcen, newtable.PhotonsMean)

figure()
gr = gramm('x', outputdata.CHIMean, 'y', outputdata.CCVCoV, 'color',outputdata.BinValue,'subset', outputdata.Day > 20221111 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 45)
% Set appropriate names for legends
gr.set_names('x','CHI value ','y','CV')
gr.set_title('CHIMean vs CV, high photon rate, 45-180sec files')
gr.geom_point()
%gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.CCVMean, 'y', outputdata.CCVCoV, 'color',outputdata.BinValue,'subset', outputdata.Day > 20221111 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 45)
% Set appropriate names for legends
gr.set_names('x','Lifetime Mean ','y','CV')
gr.set_title('CCVMean vs CV, high photon rate, 45-180sec files')
gr.geom_point()
%gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.PhotonsMean, 'y', outputdata.CCVCoV, 'color',outputdata.KIConcen,'subset', outputdata.Day > 20221111 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 45)
% Set appropriate names for legends
gr.set_names('x','Average Photons per Pixel','y','CV')
gr.set_title('Average Photons per Pixel vs CV, high photon rate, 45-180sec files')
gr.geom_point()
%gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.KIConcen,'y', outputdata.CCVMean, 'color',outputdata.BinValue,'subset', outputdata.Day > 20221111 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 45)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','KI Concentration (M)','y','Average Lifetime (ps)')
%Set figure title
gr.set_title('time vs photons, only20230626 fluorescein data with 45-180sec files')
%gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

%%
figure()
scatter3(outputdata.CCVMean, outputdata.PhotonsMean, outputdata.CCVCoV)
xlabel('CCVMean')
ylabel('PhotonsMean')
zlabel('CCVCoV')

%%
%did i do this backwards??? 
independent = [outputdata.CCVMean, outputdata.PhotonsMean]; %%these are not independent and are slightly linearlly correlated? can i use mvregress

[R,p] = corrcoef(outputdata.CCVMean, outputdata.PhotonsMean)
y = outputdata.CCVCoV;
%statsout = mvregress(independent, y) i think this is wrong
statsout = regress(y, independent)

%%might be testing that cv doesn't change with KI? full rank issue - y may
%%need to be more than 1?



%%
%{
figure()
gr = gramm('x', outputdata.KIConcen, 'y', outputdata.CCVCoV,'subset', string(outputdata.ManualCFDClass) == 'h' & outputdata.Day > 20230625 & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
% Set appropriate names for legends
gr.set_names('x','KI Concentration (M)','y','CV')
gr.set_title('KIConcen vs CV, high photon rate, 45-180sec files')
gr.stat_boxplot()
%gr.stat_violin('half', false,'fill','transparent', 'normalization','width')
gr.geom_point()
gr.stat_glm('disp_fit', true)
gr.set_color_options('chroma',10,'lightness',40)
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.CHIMean, 'y', outputdata.CCVCoV,'subset', outputdata.Day > 20230625 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
% Set appropriate names for legends
gr.set_names('x','KI Concentration  (M)','y','CHI')
gr.set_title('CHIMean vs CV, high photon rate, 45-180sec files')
gr.geom_point()
gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.PhotonsMean, 'y', outputdata.CCVCoV, 'color',outputdata.KIConcen,'subset', outputdata.Day > 20230625 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
% Set appropriate names for legends
gr.set_names('x','Average Photons per Pixel','y','CV')
gr.set_title('Average Photons per Pixel vs CV, high photon rate, 45-180sec files')
gr.geom_point()
%gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.KIConcen,'y', outputdata.CCVMean, 'subset', outputdata.Day > 20230625 & string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','KI Concentration (M)','y','Average Lifetime (ps)')
%Set figure title
gr.set_title('time vs photons, only20230626 fluorescein data with 45-180sec files')
gr.set_color_options('chroma',0,'lightness',0)
gr.set_text_options('base_size', 20)
gr.draw()

%}

%%
%{
figure()
gr = gramm('x', outputdata.KIConcen, 'y', outputdata.CCVCoV,'subset', string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
% Set appropriate names for legends
gr.set_names('x','KIConcen','y','CV')
gr.set_title('KIConcen vs CV, high photon rate, 45-180sec files')
gr.stat_boxplot()
gr.draw()

figure()
gr = gramm('x', outputdata.KIConcen, 'y', outputdata.CCVCoV,'color', outputdata.Day, 'subset', string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
% Set appropriate names for legends
gr.set_names('x','KIConcen','y','CV')
gr.set_title('KIConcen vs CV, high photon rate, 45-180sec files')
gr.geom_point()
gr.draw()

figure()
gr = gramm('x', outputdata.KIConcen, 'y', outputdata.CCVCoV,'color', outputdata.PhotonsMean, 'subset', string(outputdata.ManualCFDClass) == 'h' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180 & outputdata.Day == 20230621 | outputdata.Day ==20230626)
% Set appropriate names for legends
gr.set_names('x','KIConcen','y','CV')
gr.set_title('20230621&0626 only, KIConcen vs CV, color photon rate, high photon rate, 45-180sec files')
gr.geom_point()
gr.draw()

figure()
gr = gramm('x', outputdata.LaserPower,'y', outputdata.CCVCoV,'subset', string(outputdata.KIValue) == 'none' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','LaserPower','y','CV')
%Set figure title
gr.set_title('Laser Power vs CV, fluorescein unquenched, 45-180sec files')
gr.draw()

figure()
gr = gramm('x', outputdata.LaserPower,'y', outputdata.CCVCoV,'subset', outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','LaserPower','y','CV')
%Set figure title
gr.set_title('Laser Power vs CV, all fluorescein data with 45-180sec files')
gr.draw()

figure()
gr = gramm('x', outputdata.PhotonsMedian,'y', outputdata.CCVCoV,'subset', string(outputdata.KIValue) == 'none' & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','PhotonsMedian','y','CV')
%Set figure title
gr.set_title('PhotonsMedian vs CV, fluorescein unquenched, 45-180sec files')
gr.draw()

figure()
gr = gramm('x', outputdata.PhotonsMedian,'y', outputdata.CCVCoV,'color',outputdata.KIConcen,'subset', outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','PhotonsMedian','y','CV')
%Set figure title
gr.set_title('PhotonsMedian vs CV, all fluorescein data with 45-180sec files')
gr.draw()

figure()
gr = gramm('x', outputdata.CHIMean,'y', outputdata.CCVCoV,'subset', outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','Chi Mean','y','CV')
%Set figure title
gr.set_title('Chi Mean vs CV, all fluorescein data with 45-180sec files')
gr.draw()

figure()
gr = gramm('y', outputdata.CHIMean,'x', outputdata.PhotonsMean, 'color', outputdata.CCVCoV, 'subset', outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('y','Chi Mean','x','Photons Mean')
%Set figure title
gr.set_title('Chi Mean vs Photons Mean, all fluorescein data with 45-180sec files')
gr.draw()

figure()
gr = gramm('x', outputdata.KIConcen,'y', outputdata.CHIMean,'subset', outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.stat_boxplot()
% Set appropriate names for legends
gr.set_names('x','KI Concentration','y','Chi Mean')
%Set figure title
gr.set_title('KI Concen vs Chi Mean, all fluorescein data with 45-180sec files')
gr.draw()

figure()
gr = gramm('x', outputdata.CCVMean,'y', outputdata.CCVCoV,'color',outputdata.KIConcen, 'subset', outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','Lifetime Mean','y','CV')
%Set figure title
gr.set_title('Lifetime Mean vs CV, all fluorescein data with 45-180sec files')
gr.draw()
%}
%%


function  [imagefile, imgmean, imgmedian, standarddev, cov, ccvals, chisquaredvals,  chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev] = getmeanandchi(imagefile, location, bin)
%THIS FUNCTION IS DESIGNED TO USE THE SPCIMAGE EXPORT FILES (.tif only) AND CREATE
%STATISTICS FOR COLOR CODED VALUE IMAGE, CHI SQUARED, AND INTENSITY IMAGE
%IMPORTANT: filename in folder should have no spaces, use gitbash and asc
%to tif file to change SPCImage output 
%(EX.) "color coded value.asc" should be "colorcodedvalue.tif"

intensityname = strcat(location, '\', imagefile, '_photons.asc');

colorname = strcat(location, '\', imagefile, '_colorcodedvalue.tif') ;
chiname = strcat(location, '\', imagefile, '_chi.tif');
intensityname;
intensity = dlmread(intensityname);
intensity = im2double(intensity);
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
    
    ccvname = strcat(location, '\', imagefile, '_colorcodedvalue.asc');
    chiname =strcat(location, '\', imagefile, '_chi.asc');
    ccv = dlmread(ccvname);
    ccv = im2double(ccv);
    chi = dlmread(chiname);
    chi = im2double(chi);
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
    chisquaredvals = nonzeros(cornerchi);
    intvals = nonzeros(cornerint);
    
    %remove outliers in tm and chi values
    ccvals(ccvals > 8000) = [];
    ccvals(chisquaredvals>4) = [];

%OLD VERSIONfor each file, calls "get masked pixels" to apply the mask to the images
%[ccvals, chisquaredvals, intvals] = getmaskedpixels(intensityname, colorname, chiname, bin);

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


%h = kstest(ccvals,'Alpha', 0.1)

%figure()
%hist(ccvals)
%hold on


end






