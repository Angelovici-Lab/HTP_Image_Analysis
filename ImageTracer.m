classdef ImageTracer < handle
    properties(Access=private)
        directory = '';
        seperator = '';
        sortedFileListTop = {};
        fileListTop = {};
        fileListTopIncompleted = {};
        fileListSide = {};
        fileListSideIncompleted = {};
        directoryContents = [];
    end
    properties(Constant, Hidden=true)
        extList={'jpg'};
        imgTag={'_top'};
    end
    methods(Access=private)
    end
    methods
        % constructor
        function obj = ImageTracer(directory)
            obj.directory = directory;
            if(strcmpi(computer,'PCWIN') || strcmpi(computer,'PCWIN64'))
                obj.seperator='\';
            elseif(strcmpi(computer,'GLNX86') || strcmpi(computer,'GLNXA86'))
                obj.seperator='/';
            elseif(strcmpi(computer,'MACI64')) 
                obj.seperator='/';
            end
            obj.fileListTop={};
            obj.fileListTopIncompleted = {};
            obj.fileListSide = {};
            obj.fileListSideIncompleted = {};
        end
        % destructor
        function delete(obj)
        end
        % set directory
        function obj = setDirectory(obj, directory)
            obj.directory = directory;
            obj.fileListTop={};
            obj.fileListTopIncompleted = {};
            obj.fileListSide = {};
            obj.fileListSideIncompleted = {};
        end
        % get directory
        function original_directory = getDirectory(obj)
            original_directory = obj.directory;
        end
        % trace all top images
        function file_list = traceAllTopImages(obj, fileDirectory)
            file_list = {};
            fileDirectoryContents=dir(fileDirectory);
            for i=1:numel(fileDirectoryContents)
                if(~(strcmpi(fileDirectoryContents(i).name,'.') || strcmpi(fileDirectoryContents(i).name,'..')))
                    if(~fileDirectoryContents(i).isdir)
                        extension=fileDirectoryContents(i).name(end-2:end);
                        if(numel(find(strcmpi(extension,obj.extList)))~=0)
                            tempFileString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                            if(numel(find(strcmpi(tempFileString(end-7:end-4), obj.imgTag)))==1)
                                file_list = [file_list; tempFileString];
                            end
                        end
                    else
                        tempFolderString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                        getFolderList=obj.traceAllTopImages(tempFolderString);
                        file_list = [file_list; getFolderList];
                    end
                end
            end
            obj.fileListTop = {};
            obj.fileListTop = file_list;
        end
        % trace all unparse top images
        function file_list = traceIncompletedTopImages(obj, fileDirectory)
            file_list = {};
            fileDirectoryContents=dir(fileDirectory);
            match=0;
            for i=1:numel(fileDirectoryContents)
                if(~(strcmpi(fileDirectoryContents(i).name,'.') || strcmpi(fileDirectoryContents(i).name,'..')))
                    if(~fileDirectoryContents(i).isdir)
                        extension=fileDirectoryContents(i).name(end-2:end);
                        if(numel(find(strcmpi(extension,obj.extList)))~=0)
                            for c=1:numel(fileDirectoryContents)
                                if(~(strcmpi(fileDirectoryContents(c).name,'.') || strcmpi(fileDirectoryContents(c).name,'..')))
                                    if(fileDirectoryContents(c).isdir)
                                        if(strcmpi(fileDirectoryContents(c).name, fileDirectoryContents(i).name(1:end-4))==1)
                                            match=1;
                                        end
                                    end
                                end
                            end
                            if(match==0)
                                tempFileString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                                if(numel(find(strcmpi(tempFileString(end-7:end-4), obj.imgTag)))==1)
                                    file_list = [file_list; tempFileString];
                                end
                            end
                            match=0;
                        end
                    else
                        tempFolderString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                        getFolderList=obj.traceIncompletedTopImages(tempFolderString);                        
                        file_list = [file_list; getFolderList];
                    end
                end
            end
            obj.fileListTopIncompleted = {};
            obj.fileListTopIncompleted = file_list;
        end
        % trace all side images
        function file_list = traceAllSideImages(obj, fileDirectory)
            file_list = {};
            fileDirectoryContents=dir(fileDirectory);
            for i=1:numel(fileDirectoryContents)
                if(~(strcmpi(fileDirectoryContents(i).name,'.') || strcmpi(fileDirectoryContents(i).name,'..')))
                    if(~fileDirectoryContents(i).isdir)
                        extension=fileDirectoryContents(i).name(end-2:end);
                        if(numel(find(strcmpi(extension,obj.extList)))~=0)
                            tempFileString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                            if(numel(find(strcmpi(tempFileString(end-7:end-4), obj.imgTag)))==0)
                                file_list = [file_list; tempFileString];
                            end
                        end
                    else
                        tempFolderString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                        getFolderList=obj.traceAllSideImages(tempFolderString);
                        file_list = [file_list; getFolderList];
                    end
                end
            end
            obj.fileListSide = {};
            obj.fileListSide = file_list;
        end
        % trace all unparse side images
        function file_list = traceIncompletedSideImages(obj, fileDirectory)
            file_list = {};
            fileDirectoryContents=dir(fileDirectory);
            match=0;
            for i=1:numel(fileDirectoryContents)
                if(~(strcmpi(fileDirectoryContents(i).name,'.') || strcmpi(fileDirectoryContents(i).name,'..')))
                    if(~fileDirectoryContents(i).isdir)
                        extension=fileDirectoryContents(i).name(end-2:end);
                        if(numel(find(strcmpi(extension,obj.extList)))~=0)
                            for c=1:numel(fileDirectoryContents)
                                if(~(strcmpi(fileDirectoryContents(c).name,'.') || strcmpi(fileDirectoryContents(c).name,'..')))
                                    if(fileDirectoryContents(c).isdir)
                                        if(strcmpi(fileDirectoryContents(c).name, fileDirectoryContents(i).name(1:end-4))==1)
                                            match=1;
                                        end
                                    end
                                end
                            end
                            if(match==0)
                                tempFileString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                                if(numel(find(strcmpi(tempFileString(end-7:end-4), obj.imgTag)))==0)
                                    file_list = [file_list; tempFileString];
                                end
                            end
                            match=0;
                        end
                    else
                        tempFolderString = [fileDirectoryContents(i).folder, obj.seperator, fileDirectoryContents(i).name];
                        getFolderList=obj.traceIncompletedSideImages(tempFolderString);                        
                        file_list = [file_list; getFolderList];
                    end
                end
            end
            obj.fileListSideIncompleted = {};
            obj.fileListSideIncompleted = file_list;
        end
        %% Sorting
        % Sort by CS Number
        function sorted_file_list = sortImages(obj, filePath)
            tempFileList = filePath;
            sorted_file_list = {};
            rep_list = {};
            cs_list = {};
            cs_count = 1;
            rep_count = 1;
            count = 0;
            reference = [];
            for i = 1:size(tempFileList, 1)
                dirComponents = strsplit(tempFileList{i}, '\');
                for j = 1:size(dirComponents, 2)
                    tempDirComponent = dirComponents{j};
                    if(length(tempDirComponent)>2)
                        if(strcmpi(tempDirComponent(1:2), "CS") == 1)
                            cs_list = [cs_list; tempDirComponent];
                        end
                        if(strcmpi(tempDirComponent(1:3), "Rep") == 1)
                            rep_list = [rep_list; tempDirComponent];
                        end
                    end
                end
            end
            for i = 1:size(cs_list, 1)-1
                if(strcmpi(cs_list{i}, cs_list{i+1})==0)
                    cs_count = cs_count + 1;
                end
            end
            for i = 1:size(rep_list, 1)-1
                if(strcmpi(rep_list{i}, rep_list{i+1})==0)
                    rep_count = rep_count + 1;
                end
            end
            count = cs_count / rep_count;
            if(isempty(sorted_file_list)==1)
                sorted_file_list = [sorted_file_list; tempFileList{1}];
                reference = cs_list{1};
                cs_list{1} = [];
            end
            for i = 1:count+1
                for j = 1:size(tempFileList, 1)
                    if(isempty(cs_list{j})==0 && strcmpi(cs_list{j}, reference)==1)
                        sorted_file_list = [sorted_file_list; tempFileList{j}];
                        cs_list{j} = [];
                    end
                end
                for k = 1:size(cs_list, 1)
                    if(isempty(cs_list{k})==0)
                        sorted_file_list = [sorted_file_list; tempFileList{k}];
                        reference = cs_list{k};
                        cs_list{k} = [];
                        break;
                    end
                end
            end
            obj.sortedFileListTop = {};
            obj.sortedFileListTop = sorted_file_list;
        end
    end
end
