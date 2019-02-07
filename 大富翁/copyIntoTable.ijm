path = File.openDialog("");
count = File.length(path);
str = File.openAsString(path); 
lines = split(str,"\n");
Table.create("destiny");
n = 0;
for(i=0;i<lines.length;i++){
    str = lines[i];
    if(str!=""){
        item = "¡¾Ãû³Æ¡¿";
        p= indexOf(str,item);
        if(p!=-1){
            contents = substring(str,lengthOf(item),lengthOf(str));
print(contents);
            Table.set(item, n, contents);
        }
        item = "¡¾½±³Í¡¿";
        p= indexOf(str,item);
        if(p!=-1){
            contents = substring(str,lengthOf(item),lengthOf(str));
print(contents);
            Table.set(item, n, contents);
        }
        item = "¡¾ËµÃ÷¡¿";
        p= indexOf(str,item);
        if(p!=-1){
            contents = substring(str,lengthOf(item),lengthOf(str));
print(contents);
            Table.set(item, n, contents);
n++;            
        }
    }
}


