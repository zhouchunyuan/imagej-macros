leftButton=16;
rightButton=4;
player_icon_size = 30;
house_icon_size = 30;
move_sizex = 56;
move_sizey = 56;
numberOfStop = 40;

/****************************/
go_to_prison = 30;
var a_was_in_prison = 0;
var b_was_in_prison = 0;

path = getDirectory("macros");
/******** load map **********/
//open("map.jpg");
open("map2.jpg");
rename("map.jpg");
player_icon_size = getWidth()/30;
house_icon_size = getWidth()/30;
move_sizex = getWidth()/12;
move_sizey = getHeight()/12;
Overlay.clear

/********* load player ************/
open("a.JPG");
run("Size...", "width="+player_icon_size+" height="+player_icon_size+" constrain average interpolation=Bilinear");
open("b.JPG");
run("Size...", "width="+player_icon_size+" height="+player_icon_size+" constrain average interpolation=Bilinear");

/********* load house *************/
open("housea.JPG");
run("Size...", "width="+house_icon_size+" height="+house_icon_size+" average interpolation=Bilinear");
open("houseb.JPG");
run("Size...", "width="+house_icon_size+" height="+house_icon_size+" average interpolation=Bilinear");

/********** add image overlays *************/
selectWindow("map.jpg");
run("Add Image...", "image=a.JPG x=0 y=0 opacity=100");
run("Add Image...", "image=b.JPG x=0 y=0 opacity=100");


close("b.JPG");
close("a.JPG");

var n1 = 0;
var n2 = 0;
move_to(0,n1);
move_to(1,n2);

setOption("DisablePopupMenu", true);

x2=-1; y2=-1; z2=-1; flags2=-1;
while(1){
    getCursorLoc(x, y, z, flags);
    if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
        if (flags&leftButton!=0){
            Overlay.activateSelection(0);
            if(Roi.contains(x, y)){
                start = n1;
                stop = n1+dice();
                for(i=start;i<=stop;i++){
                    move_to(0,i%numberOfStop );
                    wait(100);
                }
                n1 = stop%numberOfStop ;
                check_events(0,start,stop);
            }

            Overlay.activateSelection(1);
            if(Roi.contains(x, y)){
                start = n2;
                stop = n2+dice();
                for(i=start;i<=stop;i++){
                    move_to(1,i%numberOfStop );
                    wait(100);
                }
                n2 = stop%numberOfStop ;
                check_events(1,start,stop);
            }
        }
        if (flags&rightButton!=0){

            Overlay.activateSelection(0);
            if(Roi.contains(x, y)){
                open_dialog(0);
            }
            Overlay.activateSelection(1);
            if(Roi.contains(x, y)){
                open_dialog(1);
            }
        }
        selectWindow("map.jpg");
        run("Select None");
        x2=x; y2=y; z2=z; flags2=flags;
        wait(10);
    }
}

function move_to(index,number){
   run("Select None");
    cx = getWidth()/2;
    cy = getHeight()/2;

    side = floor(number/10);
    if(side == 0){
        col = number%10;
        row = 10+0.5;
    }
    if(side == 1){
        col = 10+0.5;
        row = 10-number%10;
    }
    if(side == 2){
        col = 10-number%10;
        row = 0-0.5;
    }
    if(side == 3){
        col = 0-0.5;
        row = number%10;
    }
    Overlay.moveSelection(index, 
                           cx-player_icon_size+index*player_icon_size/2+(5-col)*move_sizex, 
                           cy-player_icon_size/2+(row-5)*move_sizey);
}

function build_house(index,number){
   run("Select None");
    cx = getWidth()/2;
    cy = getHeight()/2;

    side = floor(number/10);
    if(side == 0){
        col = number%10;
        row = 10-0.5;
    }
    if(side == 1){
        col = 10-0.5;
        row = 10-number%10;
    }
    if(side == 2){
        col = 10-number%10;
        row = 0+0.5;
    }
    if(side == 3){
        col = 0+0.5;
        row = number%10;
    }
    if(index == 0)houseName = "housea.JPG";
    if(index == 1)houseName = "houseb.JPG";
    x0 = cx-player_icon_size+index*player_icon_size/2+(5-col)*move_sizex;
    y0 = cy-player_icon_size/2+(row-5)*move_sizey;
    run("Add Image...", "image=&houseName x=&x0 y=&y0 opacity=100");
}

function remove_house(index,number){
   run("Select None");
    cx = getWidth()/2;
    cy = getHeight()/2;

    side = floor(number/10);
    if(side == 0){
        col = number%10;
        row = 10-0.5;
    }
    if(side == 1){
        col = 10-0.5;
        row = 10-number%10;
    }
    if(side == 2){
        col = 10-number%10;
        row = 0+0.5;
    }
    if(side == 3){
        col = 0+0.5;
        row = number%10;
    }
    if(index == 0)houseName = "housea.JPG";
    if(index == 1)houseName = "houseb.JPG";
    x0 = cx-player_icon_size+index*player_icon_size/2+(5-col)*move_sizex;
    y0 = cy-player_icon_size/2+(row-5)*move_sizey;
    for(i=2;i<Overlay.size;i++){
        Overlay.activateSelection(i);
        if(Roi.contains(x0, y0)){
            Overlay.removeSelection(i);
            break;
        }
    }
}

function open_dialog(userID){
    Dialog.create("choices");
    items = newArray("Build House", "Sell House", "Nothing");
    Dialog.addRadioButtonGroup("Action", items, 2, 2, "Build House");
    Dialog.show();
    type = Dialog.getRadioButton;
    if(userID == 0)position = n1;
    if(userID == 1)position = n2;
    if(type == "Build House"){
        build_house(userID,position); 
    }
    if(type == "Sell House"){
        remove_house(userID,position);
    }
}

function check_events(userID,start,stop){
    if(userID == 0) position = n1;
    if(userID == 1) position = n2;
    prison_number = 10;
    if(position == go_to_prison){
        
        move_to(userID, prison_number);
        if(userID == 0){ 
            n1 = prison_number;
            a_was_in_prison = 1;
        }
        if(userID == 1){
            n2 = prison_number;
            b_was_in_prison = 1;
        } 
    }
    if(start<numberOfStop && stop >numberOfStop ){
        if(userID == 0 && a_was_in_prison == 0){
            showMessage("user a get 2000 dolar!!");
        }else{
            a_was_in_prison = 0;
        }
        if(userID == 1 && b_was_in_prison == 0){
            showMessage("user b get 2000 dolar!!");
        }else{
            b_was_in_prison = 0;
        }
        
        
    }
 
}

function dice(){
    //return 1;
    return floor(1+random*12);
}

