%repair invalid version json files
url = 'https://nhi-fyd.nin.knaw.nl/logVandC.html';
html = webread(url);

Rec = regexp(html,'(?<=Error invalid version: null , ").+?(?=" <br>)', 'match')';


for i = 1:length(Rec)
    str = Rec{i};
    str = replace(str, '/', '\');
    str = replace(str, '\mnt', '\');


    fid = fopen(str , 'r');
    txt = fread(fid, '*char')';
    fclose(fid);
    json = jsondecode(txt);
  
    %first copy to include noncompulsory
    jsonNw = json;
    jsonNw.version = '1.0';
    jsonNw.project = json.project.title;
    jsonNw.dataset = json.dataset.name;
    jsonNw.date = json.session.date;
    if isfield(json.session, 'animalId')
        jsonNw.subject = json.session.animalId;
    elseif isfield(json.session, 'subjectId')
        jsonNw.subject = json.session.subjectId;
    end
    jsonNw.condition = json.session.group;
    jsonNw.setup = json.session.setup;
    jsonNw.stimulus = json.session.stimulus;
    jsonNw.investigator = json.session.investigator;
    jsonNw.logfile = json.session.logfile;
    
    %add any additional stuff
    if isfield(json.session, 'display')
        jsonNw.display = json.session.display;
    end
    if isfield(json.project, 'method')
        jsonNw.method = json.project.method;
    end
    
    txtO = jsonencode(jsonNw);
    fid = fopen(str , 'w');
    fwrite(fid, txtO);
    fclose(fid);
    
end  