%%Script designed to input a text file and folder location and 
%%return edited file names

%directions to files
filelocation = 'C:\Users\hwilson23\Documents\UserDataOWS\fitFilesHelen';
newfolder = 'C:\Users\hwilson23\Documents\UserDataOWS\neweditednames';
textlocation = 'C:\Users\hwilson23\Documents\UserDataOWS\allanalysisdata';
if isfolder(textlocation)
    textfilename = 'fivedaystwodyes.txt';   
else
    filelocation = 'J:\.shortcut-targets-by-id\1lKaqvovu-XhFoeJiDWfI36ZYJFMMZx_v\Fluroescent dye variability\Data\fitFilesHelen';
    newfolder = 'C:\Users\lociu\Documents\temp';
    textlocation = 'J:\.shortcut-targets-by-id\1lKaqvovu-XhFoeJiDWfI36ZYJFMMZx_v\Fluroescent dye variability';
    textfilename = 'matlab_text_output.txt';
end

%open files
info = readtable(strcat(textlocation, '\', textfilename));
        
%section out different columns to add parameters
filenames = info.ImageFile; 
fludye = info.FluorescentDye;
day = info.Day;
roi = info.ROI;
laserpower = info.LaserPower;
binnums = info.BinNumber;
time = info.CollectionTime;

%get list of current file names
filenamelist = ls(filelocation);
        ccvfiles = [];
        chifiles = [];
        intensityfiles = [];
        
       for temp = 1:length(filenamelist)
           ccvlist = contains(filenamelist(temp,:),"value.asc");
           chilist = contains(filenamelist(temp,:),"chi.asc");
           intensitylist = contains(filenamelist(temp,:),"photons.asc");
           
           if chilist == 1
               chifiles = [chifiles; string(strtrim(filenamelist(temp,:)))];
            elseif ccvlist == 1
               ccvfiles = [ccvfiles; string(strtrim(filenamelist(temp,:)))];
           elseif  intensitylist ==1
               intensityfiles = [intensityfiles; string(strtrim(filenamelist(temp,:)))];
           end 

       end 
      
%to decide laser category 
lasercategories = ["L"; "M"; "H"]; %must be in ascending order
%creates a table out of the user specified laser categories 
        classify = array2table(lasercategories, 'VariableNames', "PowerCategory");
        varTypes = ["cell", "double", "double", "double", "double", "string", "double", "double"];
        varNames = ["FileName", "FluorescentDye", "Day", "ROI", "LaserPower", "PowerCategory", "BinValue", "ColletionTime(sec)"];
        datatable = table('Size', [length(filenames), length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);

        temppoccell = zeros([length(filenames),1]);
        table(temppoccell);

        for num = 1:length(filenames)
        datatable(num,:) = {filenames(num), fludye(num), day(num), roi(num), laserpower(num), temppoccell(num), binnums(num), time(num)};
        end

        %sort laser powers
        outputdata = table('Size', [0, length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);
        
        %identify the different days, dyes, and number of ROIs from the completed
        %table with statistics
        
        dayvalue = unique(datatable(:,3));
        fluvalue = unique(datatable(:,2));
        roivalue = unique(datatable(:,4));
        
        add = 0;
        
        %separate out the ROIs and assign the different laser powers a
        %classisfication from the user input
        
        for g = 1:height(fluvalue)
            for h = 1:height(dayvalue)
                %filter by dye and day
                    separateflus = datatable(datatable.FluorescentDye == fluvalue.FluorescentDye(g),:);
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

 laserlevel = outputdata.PowerCategory;

%create blank variables
editedccv = [];
editedchi = [];
editedint = [];


%look for the plain file name in the file list and add the corresponding
%value onto end and save as new file name list
for a = 1:length(filenames)
    rindex = find(contains(ccvfiles, filenames(a)))
    levelindex = find(contains(outputdata.FileName,filenames(a)))
    splitccv = strsplit(ccvfiles(rindex), '_');
    editedccv = [editedccv; strcat(splitccv(1), '_', string(laserpower(a)), '_', laserlevel(levelindex), '_', splitccv(2), '_', splitccv(3), '_', splitccv(4))];
end

for b = 1:length(filenames)
    rindex = find(contains(chifiles, filenames(b)));
    levelindex = find(contains(outputdata.FileName,filenames(b)))
    splitchi = strsplit(chifiles(rindex), '_');
    editedchi = [editedchi; strcat(splitchi(1), '_', string(laserpower(b)), '_', laserlevel(levelindex), '_', splitchi(2), '_', splitchi(3), '_', splitchi(4))];

end

for c = 1:length(filenames)
    rindex = find(contains(intensityfiles, filenames(c)));
    levelindex = find(contains(outputdata.FileName,filenames(c)));
    splitint = strsplit(intensityfiles(rindex), '_');
    editedint = [editedint; strcat(splitint(1), '_', string(laserpower(c)), '_', laserlevel(levelindex), '_', splitint(2), '_', splitint(3), '_', splitint(4))];
end

%length(editedccv)
%length(editedchi)
%length(editedint)

editedccv
editedchi
editedint

for i = 1:length(filenames)
    %find where ccvfiles contains the correct filename
    rindex = find(contains(ccvfiles, filenames(i)));
    %make the current file location
    ccvcurrent = fullfile(filelocation, ccvfiles(rindex));
    %find where the edited names has the current file name and make new
    %file 
    ccvnew = fullfile(newfolder, editedccv(find(contains(editedccv, filenames(i)))));
    %disp(rindex)

    rindex = find(contains(chifiles, filenames(i)));
    %disp(rindex)
    chicurrent = fullfile(filelocation, chifiles(rindex));
    chinew_ = editedchi(find(contains(editedchi, filenames(i))));
    chinew = fullfile(newfolder, chinew_);
    %disp([chifiles(i), "--",chinew_]);

    rindex = find(contains(intensityfiles, filenames(i)));
    intcurrent = fullfile(filelocation, intensityfiles(rindex));
    intnew = fullfile(newfolder, editedint(find(contains(editedint, filenames(i)))));


    %%%need to redownload from google drive and find function that renames
    %%%but keeps originals 
    copyfile(ccvcurrent, ccvnew)
    copyfile(chicurrent, chinew)
    copyfile(intcurrent, intnew)

end 






