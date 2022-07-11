%repair invalid version json files
url = 'https://nhi-fyd.nin.knaw.nl/logVandC.html';
html = webread(url);

Rec = regexp(html,'(?<=Error invalid version: null , ").+?(?=" <br>)', 'match')';


for i = 1:length(Rec)
    fprintf(['Processing json file ' num2str(i) '/' ...
        num2str(length(Rec)) '\n']);
    
    str = Rec{i};
    
    % change the path to something sensible
    str = replace(str,...
        '/mnt/VS03/VS03-VandC-2','/media/NETDISKS/VS03_2');
    %str = replace(str, '/', '\');
    %str = replace(str, '\mnt', '\');

    fid = fopen(str , 'r');
    txt = fread(fid, '*char')';
    fclose(fid);
    json = jsondecode(txt);
  
    %first copy to include noncompulsory
    jsonNw = json;
    jsonNw.version = '1.0';
    try jsonNw.project = json.project.title; catch; end
    try jsonNw.dataset = json.dataset.name; catch; end
    try jsonNw.date = json.session.date; catch; end
    if isfield(json.session, 'animalId')
        try jsonNw.subject = json.session.animalId; catch; end
    elseif isfield(json.session, 'subjectId')
        try jsonNw.subject = json.session.subjectId; catch; end
    end
    try jsonNw.condition = json.session.group; catch; end
    try jsonNw.setup = json.session.setup; catch; end
    try jsonNw.stimulus = json.session.stimulus; catch; end
    try jsonNw.investigator = json.session.investigator; catch; end
    
    if isfield(json.session, 'logfile')
        try jsonNw.logfile = json.session.logfile; catch; end
    elseif isfield(json.session, 'logfolder')
        try jsonNw.logfile = json.session.logfolder; catch; end
    else
        try jsonNw.logfile = 'none'; catch; end
    end
    
    %add any additional stuff
    if isfield(json.session, 'display')
        try jsonNw.display = json.session.display; catch; end
    end
    if isfield(json.project, 'method')
        try jsonNw.method = json.project.method; catch; end
    end
    
    txtO = jsonencode(jsonNw);
    fid = fopen(str , 'w');
    fwrite(fid, txtO);
    fclose(fid);
    
end  