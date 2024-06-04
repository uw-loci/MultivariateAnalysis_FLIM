% Script to analyze dye files - streamlined

%input - folder location and the name of the text file 

% USER INPUTS

folderlocation = 'H:\Projects\Fluorescein_Quenching\slimdata_analysis';

textfilename = 'H:\Projects\Fluorescein_Quenching\slimdata_analysis\slim_fludata_zposNOTmoved.txt'

segmentorcrop = 0;    % DETERMINES IF THRESHOLDED OR CROPPED STATISTICS 1 = SEGMENT, 0 = CROPPED

%plotting requries gramm fucnctions
addpath('C:\Users\hwilson23\Documents\MATLAB\gramm-master\gramm-master')

 % START CODE

  
infotbl = readtable(textfilename);

%section out different columns
filenames = infotbl.ImageFile; 
fludye = infotbl.FluorescentDye;
binnums = infotbl.BinNumber;
time = infotbl.CollectionTime;

%find the number of files, number of days, and number of dyes
[numfile, infocat] = size(infotbl);
        
%create empty table for data outputs
add = 0;
varTypes = ["cell", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
varNames = ["FileName", "FluorescentDyeAnalyzed", "BinValue", "CCVCoV", "CCVMean", "CCVMedian", "CCVSTDEV", "CHIMean", "CHIMedian", "CHISTDEV", "PhotonsMean", "PhotonsMedian", "PhotonsSTDEV", "ColletionTime"];
infomeanchi = table('Size', [numfile, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
close all;

%get data for table
for a = 1:numfile

    file = filenames(a,end);
    binnum = binnums(a,end);

    %use "get mean and chi" function to add the statictics to the table
    char(file)
    [imtitle, imavg, immed, imstdev, variation, histdata, chipixels, chiavg, chimed, chistdev, intavg, intmed, intstdev] = getmeanandchi(char(file), folderlocation, binnum);
   
    infomeanchi(a,:) = {file, fludye(a), binnums(a), variation, imavg, immed, imstdev, chiavg, chimed, chistdev, intavg, intmed, intstdev, time(a)};
    add = add+1;
    
end 

outputdata = table('Size', [0, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);


%   OUTPUTS
outputdata = [infotbl infomeanchi];
filename = 'outputdata.xlsx';
outputdata; %final table 
                
filename = 'outputdata.xlsx';
writetable(outputdata,filename , 'Sheet', 1, 'FileType', 'spreadsheet');


%%
%graphing

figure()
gr = gramm('x', (outputdata.CCVMean)/1000, 'y', outputdata.CCVCoV)
% Set appropriate names for legends
gr.set_names('x','Average Lifetime (ns)','y','CV')
gr.geom_point()
gr.set_text_options('base_size', 20)
gr.draw()

%newtable = outputdata(string(outputdata.ManualCFDClass) == 'h' & outputdata.Day > 20221111 & outputdata.CollectionTime >= 45 & outputdata.CollectionTime <= 180,:)

figure()
gr = gramm('x', outputdata.CHIMean, 'y', outputdata.CCVCoV, 'color',round((outputdata.CCVMean)./1000,2))
% Set appropriate names for legends
gr.set_names('x','Chi-Squared value ','y','CV')
gr.geom_point()
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.CCVMean, 'y', outputdata.CCVCoV)
% Set appropriate names for legends
gr.set_names('x','Lifetime Mean ','y','CV')
gr.geom_point()
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', outputdata.PhotonsMean, 'y', outputdata.CCVCoV, 'color',round((outputdata.CCVMean)./1000,2))
% Set appropriate names for legends
gr.set_names('x','Average Photons per Pixel','y','CV')
gr.geom_point()
gr.set_text_options('base_size', 20)
gr.draw()

figure()
gr = gramm('x', (outputdata.CCVMean)./1000,'y', outputdata.KIConcen)
gr.geom_point()
% Set appropriate names for legends
gr.set_names('x','Average Lifetime (ns)','y','KI Concentration (M)')
gr.set_text_options('base_size', 20)
gr.draw()
%%
figure()
gr = gramm('x', (outputdata.KIConcen), 'y', outputdata.CCVCoV)
% Set appropriate names for legends
gr.set_names('x','KI Concentration (M)','y','CV')
gr.stat_boxplot()
gr.geom_point()
gr.set_text_options('base_size', 20)
gr.draw()

%%
figure()
scatter3(outputdata.CCVMean, outputdata.PhotonsMean, outputdata.CCVCoV)
xlabel('CCVMean')
ylabel('PhotonsMean')
zlabel('CCVCoV')


function  [imagefile, imgmean, imgmedian, standarddev, cov, ccvals, chisquaredvals,  chimean, chimedian, chistandarddev, intmean, intmedian, intstandarddev] = getmeanandchi(imagefile, location, bin)
    %THIS FUNCTION IS DESIGNED TO USE THE SPCIMAGE EXPORT FILES AND CREATE
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
        
    intcornersums = [nnz(inttopleft), nnz(inttopright), nnz(intbtmleft), nnz(intbtmright)];
    
    [~,I] = min(intcornersums, [], 'all', 'linear');
    
    
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
    %offset = strcat(location,'\',imagefile,'_offset.asc');
    %offset = dlmread(offset);
    %offset = im2double(offset);
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
        %corneroffset = offset(22:122,22:122)
        r = [22 22 100 100];
        
        
    elseif corner == 2 
        cornerint = intensity(22:122,135:235);
        cornerchi = chi(22:122,135:235);
        cornerccv = ccv(22:122,135:235);
        %corneroffset = offset(22:122,135:235);
        r = [135 22 100 100];
        
    elseif corner == 3
        cornerint = intensity(135:235,22:122);
        cornerchi = chi(135:235,22:122);
        cornerccv = ccv(135:235,22:122);
        %corneroffset = offset(135:235,22:122);
        r = [22 135 100 100];
        
    elseif corner == 4
        cornerint = intensity(135:235, 135:235);
        cornerchi = chi(135:235, 135:235);
        cornerccv = ccv(135:235, 135:235);
        %corneroffset = offset(135:235, 135:235);
        r = [135 135 100 100];
                
    else 
        disp("ERROR: Issue with selecting brightest corner")
    end
    
    
    boximg = cornerint;       
    %{
    figure()
    
    tiledlayout(2,1,'TileSpacing','compact');
    nexttile
    imagesc(cornerccv)
    clim([2800,3800]);
    colorbar();
    title(imagefile)
    axis square;
    nexttile
    histogram(cornerccv,'BinLimits',[2800,3800]);
    xlim([2800,3800]);
     axis square;
     fontsize(14, "points");
    %saveas(gcf,strcat(location, '\', imagefile, 'crop_matlab','_ccv'),'svg');
    disp(imagefile)
    disp(mean(cornerint,'all'))
    disp(mean(cornerchi,'all'))
    %disp(mean(corneroffset,'all'))
    %}
    
    %get nonzero pixel values from cropped image to use for statistics
    
    ccvals = nonzeros(cornerccv);
    chisquaredvals = nonzeros(cornerchi);
    intvals = nonzeros(cornerint);
    
    %remove outliers in tm and chi values
    ccvals(ccvals > 8000) = [];
    ccvals(chisquaredvals>4) = [];

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






