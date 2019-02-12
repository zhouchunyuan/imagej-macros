IDX=0;NAME=1;PIC=2;POS=3;MNY=4;PRISON=5;SKP=6;DO=7;ROOM=8;KEY=9;FAIL=10;//player=(NAME,POS,MNY,PRISON)
var INIT_MONEY = 20000;
var IN_PRISON = true;
var IN_SKIP = true;
var PLAY_SOUND = false;

var NAMES = newArray("��","��","��","��");
var player0 = newArray(0,NAMES[0],"a.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,true,0,0,0);//(name,current postion, money,in_prison,in_skip)
var player1 = newArray(1,NAMES[1],"b.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false,0,0,0);
var player2 = newArray(2,NAMES[2],"c.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false,0,0,0);
var player3 = newArray(3,NAMES[3],"d.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false,0,0,0);
var player_number = 4;



mapWidth = 1300;
mapHeight = 768;
totalBlocks = 40;
eqBlockNum = 9+2*sqrt(2);
colornames = newArray("��","��","��","��","��","��","��","��");
colorcodes = newArray("#ffcccc","#cccc00","#9900ff","#cc2200","red","blue","#eeaa55","green");
colorcodes2 = newArray("#eeaaaa","yellow","#ff00ff","#ff8800","#ffaaaa","#aaaabb","#aa8822","#aaffaa");

var chances_name;
var chances_cost;
var chances_text;
var destiny_name;
var destiny_cost;
var destiny_text;

cityWidth = mapHeight/eqBlockNum;
cityHeight = cityWidth*sqrt(2);
cornerWidth = cityWidth*sqrt(2);
cornerHeight = cityHeight;
fontHeight = cityWidth/5;
player_icon_size = cityWidth/2;
house_icon_size = cityWidth/2;

Choose_Players();
load_chances_and_destiny();
open("station_list.csv");
Table.rename("Results","city list");
title = Table.title;// new table is activated after this line.

drawMap();
load_players();
mainloop();

/***********************************************************/
function set_player_idx(idx,order){
    if(order==0)player0[IDX]=idx;
    if(order==1)player1[IDX]=idx;
    if(order==2)player2[IDX]=idx;
    if(order==3)player3[IDX]=idx;
}
function Choose_Players(){
    Dialog.create("Choose players");
    defaults = newArray(NAMES.length);
    for(i=0;i<NAMES.length;i++){
        defaults[i]=true;
    }
    Dialog.addCheckboxGroup(4,1,NAMES,defaults); 
    Dialog.addCheckbox("play sound",PLAY_SOUND);
    Dialog.show();

    idx = 0;
    for(i=0;i<NAMES.length;i++){
        yes = Dialog.getCheckbox();
        if(yes){
            set_player_idx(idx,i);
            idx++;
        }else{
            NAMES[i]="";
            set_player_idx(-1,i);
        }
    }
    player_number = idx;
    PLAY_SOUND = Dialog.getCheckbox();
}
function get_player_by_name(name){
    if(name==NAMES[0])return player0;
    if(name==NAMES[1])return player1;
    if(name==NAMES[2])return player2;
    if(name==NAMES[3])return player3;
}
function get_player_by_idx(idx){
    /* type of mix array will change dynamicly */

    if(parseInt(player0[IDX])==parseInt(idx))return player0;
    if(parseInt(player1[IDX])==parseInt(idx))return player1;
    if(parseInt(player2[IDX])==parseInt(idx))return player2;
    if(parseInt(player3[IDX])==parseInt(idx))return player3;
}
function load_players(){
    
    for(i=0;i<player_number;i++){
        /********* load player ************/
        player = get_player_by_idx(i);
        add_img_overlay(player[PIC],0,0,player_icon_size,player_icon_size);
        move_player_to(player,0);
    }
    show_player_info();
}
function move_player_to(player,position){
    p = get_block_position(position);
    x=p[0];y=p[1];w=p[2];h=p[3];
    run("Select None");
    idx = player[IDX];
    x_ = x+w/2-(idx%2)*player_icon_size;
    y_ = y+h/2-floor(idx/2)*player_icon_size;
    Overlay.moveSelection(idx,x_,y_);
    player[POS]=position;
}
function activate_player(index){
    for(i=0;i<player_number;i++){
        player = get_player_by_idx(i);
        player[DO]=(i==index);
    }
}
function flash_player(player){
    p = get_block_position(player[POS]);
    x=p[0];y=p[1];w=p[2];h=p[3];
    x_ = x+w/2-(player[IDX]%2)*player_icon_size;
    y_ = y+h/2-floor(player[IDX]/2)*player_icon_size;
    time = getTime()%200;
    if(time>100){
        makeRectangle(x,y,w,h);
    }else{
        makeRectangle(x_,y_,player_icon_size,player_icon_size);
    }
}
function load_chances_and_destiny(){
    open("chances.csv");
    chances_name = Table.getColumn("�����ơ�");
    chances_cost = Table.getColumn("�����͡�");
    chances_text = Table.getColumn("��˵����");
    open("destiny.csv");
    destiny_name = Table.getColumn("�����ơ�");
    destiny_cost = Table.getColumn("�����͡�");
    destiny_text = Table.getColumn("��˵����");
    close("Results");
}
function mainloop(){
    leftButton=16;
    rightButton=4;

    setOption("DisablePopupMenu", true);

    x2=-1; y2=-1; z2=-1; flags2=-1;
    loop = floor(random*player_number);
    activate_player(loop);
    show_player_info();
    while(1){
        getCursorLoc(x, y, z, flags);
        if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {

            if (flags&leftButton!=0){
                //activate_player(loop);
                for(i=0;i<NAMES.length;i++){
                    player = get_player_by_name(NAMES[i]);
                    name = NAMES[i];

                    if(name!=""){
                        res = check_player_click(player,x,y);
                        if(res){
                            loop = (loop+1)%player_number;
                            activate_player(loop);
                            show_player_info();
                        }
                    }
                }
            }
            if (flags&rightButton!=0){
                for(i=0;i<NAMES.length;i++){
                    player = get_player_by_name(NAMES[i]);
                    name = NAMES[i];
                    if(name!="")
                        ret = open_dialog(player);
                }
            }
            selectWindow("����");
            run("Select None");
            x2=x; y2=y; z2=z; flags2=flags;
            wait(10);

      /************ auto skip **************/
            player = get_player_by_idx(loop);

            if(player[FAIL]){
                loop=(loop+1)%player_number;
                activate_player(loop);
                show_player_info();
            }
            if(player[SKP]){
                show_message(player[NAME]," skip once !");
                player[SKP] = false;
                loop = (loop+1)%player_number;
                activate_player(loop);
                show_player_info();                
            }
            
        }
        for(i=0;i<player_number;i++){
            player = get_player_by_idx(i);
            if(player[DO])flash_player(player);
        }
    }
}
function check_player_click(player,x,y){
    ret = false;
    selectionIndex = player[IDX];
    Overlay.activateSelection(selectionIndex );
    wait(10);
    if(Roi.contains(x, y)){
        if(player[DO]){
            if(player[SKP]){
                player[SKP]=false;
                ret = true;
            }else{
                start = player[POS];
                stop = start+dice();
                for(i=start;i<=stop;i++){
                    move_player_to(player,i%totalBlocks  );
                    wait(100);
                }
                player[POS] = stop%totalBlocks ;
                show_area_info(player[POS]);
play_sound("dice");
                ret = check_events(player,start,stop);
            }
        }else{
            show_message("wrong player","It is not your turn !");
        }
    }
    return ret;
    
}
function show_area_info(n){
    color=getValue("color.foreground");

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius*0.6;
    setColor("white");
    fillOval(xc-radius, yc-radius, radius*2, radius*2);
    
    setColor("black");    
    run("Select None");
    type= get_item("���",n);
    str0 = get_item("����",n);

    if(type=="�̳�"){
        str0 += " $"+get_item("���",n);
        str1 = "��·�ѡ���";
        str2 = "�յ�\nһ������\n��������\n��������\n�Ĵ�����\nһ���ù�";
        str2 +="\n���ݽ����� ÿ��\n�ùݽ����� ÿ��";
        str3 = get_item("��·��",n);
        str3 +="\n"+get_item("��·��1",n);
        str3 +="\n"+get_item("��·��2",n);
        str3 +="\n"+get_item("��·��3",n);
        str3 +="\n"+get_item("��·��4",n);
        str3 +="\n"+get_item("��·��5",n);
        str3 +="\n"+get_item("������",n);
        str3 +="\n"+get_item("���ù�",n);
        offsetx = xc-getStringWidth(str2)/5/2;
        offsety = yc-radius+2*fontHeight;
        drawString(str0,xc,offsety);
        setJustification("right");
        drawString(str1,offsetx,offsety+3*fontHeight);
        setJustification("left");
        drawString(str2,offsetx,offsety+3*fontHeight);
        setJustification("right");
        drawString(str3,offsetx+getStringWidth(str2)/3,offsety+3*fontHeight);
    }
    if(type=="ˮ��"){
        str0 += " $"+get_item("���",n);
        str1 = "��ӵ�е�����ˮ�繫˾�ߣ����\n·�ѵ���ȡ��תת����֮ʮ����";
        str2 = "��ӵ�е�����˾������ˮ��˾�ߣ���\n��·�ѵ���ȡ��תת����֮һ�ٱ���";

        offsetx = xc;
        offsety = yc-radius+2*fontHeight;
        drawString(str0,xc,offsety);
        
        drawString(str1,offsetx,offsety+3*fontHeight);
        drawString(str2,offsetx,offsety+6*fontHeight);

    }
    if(type=="��վ"){
        str0 += " $"+get_item("���",n);
        str1 = "��·�ѡ���";
        str2 = "�繺��һ����վ\n�繺��һ����վ\n�繺��һ����վ\n�繺��һ����վ";
        str3 = get_item("��·��",n);
        str3 +="\n"+get_item("��·��1",n);
        str3 +="\n"+get_item("��·��2",n);
        str3 +="\n"+get_item("��·��3",n);

        offsetx = xc-getStringWidth(str2)/5/2;
        offsety = yc-radius+2*fontHeight;
        drawString(str0,xc,offsety);
        setJustification("right");
        drawString(str1,offsetx,offsety+3*fontHeight);
        setJustification("left");
        drawString(str2,offsetx,offsety+3*fontHeight);
        setJustification("right");
        drawString(str3,offsetx+getStringWidth(str2)/2,offsety+3*fontHeight);

    }
    setJustification("center");
    setColor(color);
}
function get_home_points(index){
    play_area_width = eqBlockNum * cityWidth;
    info_area_width = (mapWidth-play_area_width)/2;
    x_left = info_area_width/2;
    x_right = mapWidth - info_area_width/2;

    txtHeight = 3*fontHeight;
    if(index == 0){x=x_left;y=txtHeight;}
    if(index == 1){x=x_right;y=txtHeight;}
    if(index == 2){x=x_left;y=mapHeight/2+txtHeight;} 
    if(index == 3){x=x_right;y=mapHeight/2+txtHeight;}
    nameWidth = getStringWidth(NAMES[index]);
    return newArray(x+nameWidth,y-txtHeight);
}
function get_choice(title,lines){
    leftButton=16;
    rightButton=4;

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;

    x1 = xc+radius;
    x2 = xc-radius-cityWidth;
    y1 = yc+radius;

    setColor("#eeaaaa");
    fillRect(xc-radius, y1, radius*2, fontHeight*3);

    yes_overlay_index=Overlay.size;
    makeRectangle(x1,y1,cityWidth,fontHeight*3);
    Overlay.addSelection("gray");
    color = getValue("color.foreground");
    setColor("blue");
    drawString("YES",x1+cityWidth/2,y1+fontHeight*2);

    no_overlay_index=Overlay.size;
    makeRectangle(x2,y1,cityWidth,fontHeight*3);
    Overlay.addSelection("gray");
    color = getValue("color.foreground");
    setColor("blue");
    drawString("NO",x2+cityWidth/2,y1+fontHeight*2);

    txtHeight = fontHeight*1.5;
    setFont("SansSerif", txtHeight);
    setJustification("left");
    drawString(title+":",xc-radius,y1+1.5*txtHeight);
    drawString(lines,xc-radius+getStringWidth(title+":"),y1+1.5*txtHeight);

    ans="";str = "           "+str + "    ^_^     ";
    x2=-1; y2=-1; z2=-1; flags2=-1;
    while(ans==""){
        getCursorLoc(x, y, z, flags);
        if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
            if (flags&leftButton!=0){
                wait(100);
                Overlay.activateSelection(yes_overlay_index);
                wait(10);
                if(Roi.contains(x, y)){ans = "yes";}
                Overlay.activateSelection(no_overlay_index);
                wait(10);
                if(Roi.contains(x, y)){ans = "no";}
            }
        }
        x2=x; y2=y; z2=z; flags2=flags;
    }
    Overlay.removeSelection(no_overlay_index);
    Overlay.removeSelection(yes_overlay_index);
    setColor("white");
    makeRectangle(xc-radius-cityWidth,y1,2*radius+2*cityWidth,fontHeight*3);
    fill();
    setJustification("center");
    run("Select None");

    return ans;
}
function show_message(title,lines){
    leftButton=16;
    rightButton=4;

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;

    x1 = xc+radius;
    y1 = yc+radius;

    setColor("#eeaaaa");
    fillRect(xc-radius, y1, radius*2, fontHeight*3);

    button_overlay_index=Overlay.size;
    makeRectangle(x1,y1,cityWidth,fontHeight*3);
    Overlay.addSelection("gray");
    color = getValue("color.foreground");
    setColor("blue");
    drawString("OK",x1+cityWidth/2,y1+fontHeight*2);


    txtHeight = fontHeight*1.5;
    setFont("SansSerif", txtHeight);
    setJustification("left");
    drawString(title+":",xc-radius,y1+1.5*txtHeight);
    drawString(lines,xc-radius+getStringWidth(title+":"),y1+1.5*txtHeight);

    ans="";str = "           "+str + "    ^_^     ";
    x2=-1; y2=-1; z2=-1; flags2=-1;
    while(ans==""){
        getCursorLoc(x, y, z, flags);
        if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
            if (flags&leftButton!=0){
                wait(100);
                Overlay.activateSelection(button_overlay_index);
                wait(10);
                if(Roi.contains(x, y)){ans = "OK";}
                ret = true;
            }
        }
        x2=x; y2=y; z2=z; flags2=flags;
    }
    Overlay.removeSelection(button_overlay_index);
    setColor("white");
    makeRectangle(xc-radius,y1,2*radius+cityWidth,fontHeight*3);
    fill();
    setJustification("center");
    run("Select None");

    return ret;
}
function show_player_info(){

    play_area_width = eqBlockNum * cityWidth;
    info_area_width = (mapWidth-play_area_width)/2;
    x_left = info_area_width/2;
    x_right = mapWidth - info_area_width/2;

    txtHeight = 3*fontHeight;
    setFont("SansSerif",txtHeight );

    for(i=0;i<player_number;i++){
        player = get_player_by_idx(i);
        if(i == 0){x=x_left;y=txtHeight;}
        if(i == 1){x=x_right;y=txtHeight;}
        if(i == 2){x=x_left;y=mapHeight/2+txtHeight;} 
        if(i == 3){x=x_right;y=mapHeight/2+txtHeight;}
        name = player[NAME];
        money = ""+player[MNY];
  
        setColor("white");
        fillRect(x-info_area_width/2, 
             y-txtHeight, 
             info_area_width, 
             mapHeight/2);

        setColor("black");
        drawString(name,x,y);
        drawString(money,x,y+txtHeight);
        r = txtHeight/2;
        if(player[DO]==true)fillOval(x-r,y+2*txtHeight,2*r,2*r);
        x_key = x+getStringWidth(name);
        y_key = y-txtHeight;
        if(player[KEY]==1){
            add_img("key.JPG",x_key,y_key,txtHeight,txtHeight);
        }else{
            setColor("white");
            fillRect(x_key,y_key,txtHeight,txtHeight);
        }
    }

    setFont("SansSerif",fontHeight);
}
function add_img(name,x,y,w,h){
    open(name);
    wi= parseInt(w);
    hi= parseInt(h);
    run("Size...", "width=&wi height=&hi average interpolation=Bilinear");
    run("Select All");
    run("Copy");
    selectWindow("����");
    makeRectangle(x,y,wi,hi);
    run("Paste");
    close(name);  
}
function add_img_overlay(name,x,y,w,h){
    open(name);
    run("Size...", "width=&w height=&h average interpolation=Bilinear");
    run("Add Image...", "image=&name x=&x y=&y opacity=100");
    close(name);
    return (Overlay.size-1);
}
function drawMap(){
    newImage("����", "RGB white", mapWidth , mapHeight , 1);
    for(i=0;i<Table.size;i++){
        draw_block(i);
        draw_captions(i);
        draw_icons(i);
    }
    draw_dice();

}
function draw_block(n){
    p = get_block_position(n);
    x=p[0];y=p[1];w=p[2];h=p[3];

    colorcode = get_block_color(get_item("��ɫ",n));
    setColor( colorcode );
    /**** out frame ****/
    drawRect(x,y,w,h);

    /**** arrow sign ****/
    side = floor(n/10);
    type = get_item("���",n);
    if(type=="�̳�"){
        if(side==0)makePolygon(x, y, x+w, y, 
                                   x, y+h/8,x+w,y+h/4,
                                   x,y+h/4);
        if(side==1)makePolygon(x+w, y, x+w, y+h, 
                                   x+w-w/8, y,x+w-w/4,y+h,
                                   x+w-w/4,y);
        if(side==2)makePolygon(x, y+h, x+w, y+h, 
                                   x+w, y+h-h/4,x,y+h-h/4,
                                   x+w,y+h-h/8);
        if(side==3)makePolygon(x, y, x, y+h, 
                                   x+w/4, y+h,x+w/4,y,
                                   x+w/8,y+h);
        fill();run("Select None");

        colorcode = get_block_color2(get_item("��ɫ",n));
        setColor( colorcode );
            
        if(side==0)makePolygon(x, y+h/8, x+w, y,x+w,y+h/4,x,y+h/8); 
        if(side==1)makePolygon(x+w-w/8, y, x+w, y+h,x+w-w/4,y+h,x+w-w/8, y); 
        if(side==2)makePolygon(x, y+h, x+w, y+h-h/8,x,y+h-h/4,x,y+h); 
        if(side==3)makePolygon(x, y, x+w/8, y+h,x+w/4,y,x,y); 
        fill();run("Select None");

    }
}

function draw_captions(n){
    p = get_block_position(n);
    x=p[0];y=p[1];w=p[2];h=p[3];

    setFont("SansSerif",fontHeight );
    setJustification("center");
    drawString(get_item("����",n), x+w/2, y+h/2+fontHeight);
    price = parseInt(get_item("���",n));
    if(price != 0)drawString("$"+price, x+w/2, y+h/2+fontHeight*2 );
}

function draw_icons(n){
    p = get_block_position(i);
    x=p[0];y=p[1];w=p[2];h=p[3];
    type = get_item("���",n);
    name = get_item("����",n);
    if(type == "��վ")pasteIcon(x+w/2-cityWidth/4,y+2,"train.jpg");
    if(type == "����")pasteIcon(x+w/2-cityWidth/4,y+2,"chance.jpg");
    if(type == "����")pasteIcon(x+w/2-cityWidth/4,y+2,"destiny.jpg");
    if(name == "������˾")pasteIcon(x+w/2-cityWidth/4,y+2,"powerplant.jpg");
    if(name == "����ˮ��˾")pasteIcon(x+w/2-cityWidth/4,y+2,"water.jpg");
    if(name == "����˰")pasteIcon(x+w/2-cityWidth/4,y+2,"tax2.jpg");
    if(name == "�Ʋ�˰")pasteIcon(x+w/2-cityWidth/4,y+2,"tax1.jpg");
}
function get_position_from_xy(x,y){
    mapCenterX = mapWidth/2;mapCenterY = mapHeight/2;
    w = cityWidth*sqrt(2);h=w;

    n=-1;

    x3 = mapCenterX+cityWidth*eqBlockNum/2;
    x2 = x3 -w;
    x0 = mapCenterX-cityWidth*eqBlockNum/2;
    x1 = x0 +w;

    y3 = mapCenterY+cityWidth*eqBlockNum/2;
    y2 = y3-h;
    y0 = mapCenterY-cityWidth*eqBlockNum/2;
    y1 = y0+h;
    if((x> x2) && (x< x3)){
        n = floor(35+(y-mapCenterY+cityWidth/2)/cityWidth);
    }else if((x> x0) && (x< x1)){
        n = floor(15-(y-mapCenterY-cityWidth/2)/cityWidth);
    }else if((y> y0) && (y< y1) && (x>x0) && (x<x3)){
        n = floor(25+(x-mapCenterX+cityWidth/2)/cityWidth);
    }else if((y> y2) && (y< y3) && (x>x0) && (x<x3)){
        n = floor(5-(x-mapCenterX-cityWidth/2)/cityWidth);
    }

    return n%40;
}
function get_block_position(n){

    side = floor(n/10);
    mapCenterX = mapWidth/2;mapCenterY = mapHeight/2;
    
    if(n==0 || n==10 || n==20 || n==30){
        w = cityWidth*sqrt(2);h=w;
        if(n==0){
            x = mapCenterX+cityWidth*eqBlockNum /2-w;
            y = mapCenterY+cityWidth*eqBlockNum /2-h;
        }
        if(n==10){
            x = mapCenterX-cityWidth*eqBlockNum /2;
            y = mapCenterY+cityWidth*eqBlockNum /2-h;
        }
        if(n==20){
            x = mapCenterX-cityWidth*eqBlockNum /2;
            y = mapCenterY-cityWidth*eqBlockNum /2;
        }
        if(n==30){
            x = mapCenterX+cityWidth*eqBlockNum /2-w;
            y = mapCenterY-cityWidth*eqBlockNum /2;
        }
    }else{
        if(side == 0 || side == 2){w=cityWidth;h=cityHeight;}
        if(side == 1 || side == 3){h=cityWidth;w=cityHeight;}
        if(side==0){
            x = mapCenterX+cityWidth*eqBlockNum /2-cityWidth*sqrt(2)-w*(n%10);
            y = mapCenterY+cityWidth*eqBlockNum /2-h;
        }
        if(side==1){
            x = mapCenterX-cityWidth*eqBlockNum /2;
            y = mapCenterY+cityWidth*eqBlockNum /2-cityWidth*sqrt(2)-h*(n%10);
        }
        if(side==2){
            x = mapCenterX-cityWidth*eqBlockNum /2+cityWidth*sqrt(2)+w*(n%10-1);
            y = mapCenterY-cityWidth*eqBlockNum /2;
        }
        if(side==3){
            x = mapCenterX+cityWidth*eqBlockNum /2-w;
            y = mapCenterY-cityWidth*eqBlockNum /2+cityWidth*sqrt(2)+h*(n%10-1);
        }
    }
    return newArray(x,y,w,h);
}
function get_block_color( colorname ){
    for(i=0;i<colornames.length;i++){
        if(colorname == colornames[i]){
            return colorcodes[i];
        }
    }
    return "black";//default to black
}

function get_block_color2( colorname ){
    for(i=0;i<colornames.length;i++){
        if(colorname == colornames[i]){
            return colorcodes2[i];
        }
    }
    return "black";//default to black
}

function pasteIcon(x,y,file){
    open(file);
    w=cityWidth/2;h=cityHeight/3;
    run("Size...", "width=&w height=&h average interpolation=Bilinear");
    makeRectangle(0, 0, w, h);    
    run("Copy");
    selectWindow("����");
    makeRectangle(x, y, w, h);
    run("Paste");

    close(file);
}
function remove_house(position){
    p = get_block_position(position);
    x=p[0];y=p[1];w=p[2];h=p[3];
    room_num = parseInt(get_item("������",n));
    player = get_player_by_name(get_item("����",n));
    if(room_num >0){
        room_num = room_num-1;
        Table.set("������",n,room_num);
        Table.update;
        player[ROOM]=player[ROOM]-1;
        if(room_num==0){
            for(i=player_number;i<Overlay.size;i++){
                Overlay.activateSelection(i);
                wait(1);
                Roi.getBounds(x0, y0, width, height);
                if(abs(x-x0)<2 && abs(y-y0)<2){
                    Overlay.removeSelection(i);
                }
            }
        }else{
            setJustification("left");
            setFont("SansSerif", fontHeight);
            if(room_num==1){
                str = "     ";
            }else{
                str = "x"+num_house;
            }
            run("Select None");
            setForegroundColor(255,255,255);
            makeRectangle(x+house_icon_size,y,getStringWidth(str),fontHeight);
            fill();
            setColor("black");
            drawString(str,x+house_icon_size,y+fontHeight);
            setJustification("center");
        }
        add_img_overlay("digger.jpg",x,y,w,h);
        wait(1000);
        Overlay.removeSelection(Overlay.size-1);
    } 
  
}
function build_house(player,n,free){
    ret = false;
    position = n;
    p = get_block_position(position);
    x=p[0];y=p[1];w=p[2];h=p[3];
    owner_name = Table.getString("����",position);
    
    if( owner_name!=player[NAME] ){
        show_message("Can not build","It does not belong to you !");
        return ret;
    }
    type = get_item("���",position);
    if(type=="�̳�"){
        done=false;
        while(!done){
            price = parseInt(get_item("������",position));
            currentMoney = player[MNY];
            if(currentMoney > price || free){
                run("Select None");
                num_house = parseInt(get_item("������",position));
                if(isNaN(num_house))num_house=0;
                if(num_house<4){
                    player_name = player[NAME];

                    num_house=num_house+1;
                    Table.set("������",position,num_house);
                    Table.update;
                    player[ROOM]=parseInt(player[ROOM])+1;
                    if(!free)player[MNY]=currentMoney - price;
                
                    if(num_house==1){
                        if(player_name== NAMES[0])houseName = "housea.JPG";
                        if(player_name== NAMES[1])houseName = "houseb.JPG";
                        if(player_name== NAMES[2])houseName = "housec.JPG";
                        if(player_name== NAMES[3])houseName = "housed.JPG";
                        add_img_overlay(houseName,x,y,house_icon_size,house_icon_size);
                    }else{
                        setJustification("left");
                        setFont("SansSerif", fontHeight);
                        str = "x"+num_house;
                        run("Select None");
                        setForegroundColor(255,255,255);
                        makeRectangle(x+house_icon_size,y,getStringWidth(str),fontHeight);
                        fill();
                        setColor("black");
                        drawString(str,x+house_icon_size,y+fontHeight);
                        setJustification("center");
                    }
                    ret = true;
                    done = true;

                }else{
                    show_message("Can't build here","Maximum house number is 4 !");
                    done = true;
                }

                //show_player_info();
            }else{
                ans = get_choice("Not enough money","Do you want to sell area?");
                if(ans=="yes"){
                    blockNumber = sell_area(player);
                    if(blockNumber == position){
                        show_message("Sorry"," You sold the current area!");
                        done = true;
                    }else if(blockNumber == -1){
                        show_message��"No area sold","Give up building.");
                        done = true;
                    }else{
                        done = false;
                    }
                }
                if(ans=="no"){
                    done = true;
                }
            }
        }
    }else{
        show_message("Impossible","It is NOT an area for buildings!");
    }
    return ret;
}
function buy_area(player){
    ret = false;
    position = player[POS];
    type = get_item("���",position);
    if(type == "�̳�"   || 
       type == "��վ" ||
       type == "ˮ��" ){
        owner_name = get_item("����",position);
        if( !is_occupied(position) ){
            price = parseInt(get_item("���",position));
            currentMoney = player[MNY];
            if(currentMoney >= price){
                player[MNY]=currentMoney - price;
                name=player[NAME];
                Table.set("����",position,name);
                Table.update;
                draw_mark(position,player);
                //show_player_info();
                ret = true;
            }else{
                show_message("Can't buy","Not enough money!");
                ret = true;
            }
        }else{
            show_message("Impossible","Occupied already!");
        }
    }else{
        show_message("error","Area NOT for sale !");
    }
    return ret;
}


function display_at_center_area(str,strcolor,time){
    color=getValue("color.foreground");
    fontSize = getValue("font.size");

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius*0.6;
    setColor("white");
    fillOval(xc-radius, yc-radius, radius*2, radius*2);

    setColor(strcolor);    
    //run("Select None");
    setFont("SansSerif",2*fontHeight);
    w = getStringWidth(str);
    if(w<radius*2){
        drawString(str,xc,yc);
    }else{
        setJustification("right");
        x = xc+radius-5;y=yc;
        l = lengthOf(str);
        for(i=l-1;i>0;i--){
            w=getStringWidth( substring(str,0,i) );
            if(w<radius*2)break;
        }
        if(time%(l+i)<=i)
        {
            start = 0;
            end = time%i;
        }else{
            setJustification("left");
            x = xc-radius;
            start = time%(l+i)-i;
            end = start+i;
            if(end>l-1)end=l-1;
        }

        drawString(substring(str,start,end),x,y);
        
    }

    setJustification("center");
    setColor(color);
    setFont(getInfo("font.name"),fontSize);
}
function sell_area(player){
    ret = -1;
    leftButton=16;
    rightButton=4;
    time = 0;
    str = "Please select area to sell...";
    color = "red";
    done = false;

    for(i=0;i<Table.size;i++){
        t = get_item("���",i);
        owner_name = get_item("����",i);
        if(t =="�̳�"&& owner_name==player[NAME] )break;
    }
    if(i==Table.size)return ret;

    x2=-1; y2=-1; z2=-1; flags2=-1;n2=-1;
    while(!done){
        
        getCursorLoc(x, y, z, flags);
        if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
            n = get_position_from_xy(x,y);
            if(n2 !=n )time = 0;
            if(n!=-1){
               p = get_block_position(n);
                makeRectangle(p[0],p[1],p[2],p[3]);
                title = get_item("����",n);
                price = parseInt(get_item("����",n));
                if(isNaN(price))price=0;
                if(price>0){
                    color="red";
                    str=title+" : ���� "+price;
                }else{
                    color="black";
                    str=title+" : not for sale! ";
                }

          
                n2=n;
            }
            if (flags&leftButton!=0 && n!=-1){
                owner_name = get_item("����",n);
                t = get_item("���",n);
                if(t == "�̳�"&& owner_name == player[NAME] ){
                    show_message(get_item("����",n),"����"+price+"�۸�������");
                
                    room_num = parseInt(get_item("������",n));
                    if(isNaN(room_num))room_num=0;
                    if(room_num>0){
                        for(j=0;j<room_num;j++){
                            remove_house(i);
                        }
                    }
                    clear_mark(n,player);
                    player[MNY]=player[MNY]+price;
                    Table.set("������",n,0);
                    Table.set("�ù���",n,0);
                    Table.set("����",n,"");
                    Table.update;
                    done = true;
                    ret = n;
                }
            }
            if(n==-1)str = "Please select area to sell...";
         
            selectWindow("����");
            //run("Select None");
            x2=x; y2=y; z2=z; flags2=flags;
            wait(10);
         }
         if(n2==n){time++;wait(100);}
         display_at_center_area(str,color,time);
    }
    return ret;
}
function draw_mark(n,player){
    setColor("black");
    txtHeight = 1.5*fontHeight;
    setFont("SansSerif",txtHeight);
    setJustification("center");

    selectWindow("����");
    p = get_block_position(n);
    x=p[0];y=p[1];w=p[2];h=p[3];
    side = floor(n/10);
    x1 = x; y1 = y;
    markWidth=getStringWidth(player[NAME]);
    if(side==0){x1=x+w/2;y1=y;}
    if(side==1){x1=x+w+markWidth/2+1;y1=y+h/2+txtHeight/2;}
    if(side==2){x1=x+w/2;y1=y+h+txtHeight;}
    if(side==3){x1=x-markWidth/2;y1=y+h/2+txtHeight/2;}
    drawString(player[NAME],x1,y1);
    setFont("SansSerif",fontHeight );
}
function clear_mark(n,player){
    setColor("white");
    txtHeight = 1.5*fontHeight;
    setFont("SansSerif",txtHeight);

    selectWindow("����");
    p = get_block_position(n);
    x=p[0];y=p[1];w=p[2];h=p[3];
    side = floor(n/10);
    x1 = x; y1 = y;
    markWidth=getStringWidth(player[NAME]);
    if(side==0){x1=x+w/2;y1=y;}
    if(side==1){x1=x+w+markWidth/2+1;y1=y+h/2+txtHeight/2;}
    if(side==2){x1=x+w/2;y1=y+h+txtHeight;}
    if(side==3){x1=x-markWidth/2;y1=y+h/2+txtHeight/2;}
    fillRect(x1-markWidth/2,y1-txtHeight-1,markWidth,txtHeight);

}
function is_occupied(position){
    owner_name = get_item("����",position);
    for(i=0;i<NAMES.length;i++){
        name = NAMES[i];
        if(name!=""){
            if(owner_name==name)return true;
        }
    }
    return false;
}

function open_dialog(player){
    ret = false;

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius*0.6;

    if(player[DO]){
        position = player[POS];
        if(!is_occupied(position)){
            items = newArray("Buy","Pass","Finish!");
        }else{
            items = newArray("Build","Pass" ,"Finish!");
        }

        answer_overlay_index = newArray(items.length);
        txtHeight = 1.5*fontHeight;
        btnWidth = 2*radius/3;
        setFont("SanSerif",txtHeight);
        for(i=0;i<items.length;i++){
            x1 = xc-btnWidth*(items.length/2.0-i);
            y1 = yc+radius;
            answer_overlay_index[i]=Overlay.size;
            makeRectangle(x1,y1,btnWidth,txtHeight );
            Overlay.addSelection("red");
            color = getValue("color.foreground");
            setColor("blue");
            drawString(items[i],x1+btnWidth/2,y1+txtHeight );
            setColor(color);
        }

        ans = "";

        x2=-1; y2=-1; z2=-1; flags2=-1;
        while(ans==""){
            getCursorLoc(x, y, z, flags);
            if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
                if (flags&leftButton!=0){
                    for(i=0;i<items.length;i++){
                        Overlay.activateSelection(answer_overlay_index[i]);
                        wait(10);
                        if(Roi.contains(x, y)){ans = items[i];}
                    }

                    
                }
                if (flags&rightButton!=0){
                }
                selectWindow("����");
                run("Select None");
                x2=x; y2=y; z2=z; flags2=flags;
                wait(10);
            }
            time = getTime()%200;
            if(time > 100){
                x1 = xc-btnWidth*(items.length/2.0);
                y1 = yc+radius;
                makeRectangle(x1,y1,btnWidth*items.length,txtHeight );
            }else{
                run("Select None");
            }

        }
        if(ans == "Buy" ){
            ret = buy_area(player);
            
        }
        if(ans == "Build"){
            ret = build_house(player,player[POS],false);
 
        }
        if(ans == "Sell House"){
            remove_house(player);
        }
        if(ans == "Pass"){
            ret = true;
        }
        if(ans == "Finish!"){
            close("����");
            close("city list");
            exit();
        }
        makeRectangle(xc-(items.length*btnWidth)/2,yc+radius,items.length*btnWidth,txtHeight);
        setColor("white");
        fill();
        for(i=answer_overlay_index.length-1;i>=0;i--){
            Overlay.removeSelection(answer_overlay_index[i]);
        }
    }
    setFont("SanSerif",fontHeight);
    return ret;
}
function do_chance_destiny(type){
    xc=mapWidth/2;yc=mapHeight/2;
    color=getValue("color.foreground");
    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius*0.6;
    setColor("white");
    fillRect(xc-radius, yc-radius, radius*2, radius*2);
    
    setColor("black");    
    run("Select None");
    if(type=="����"){
        i = floor(random*chances_name.length);
        //i=2;
        str0 = chances_name[i];
        str1 = chances_cost[i];
        str2 = chances_text[i];
    }
    if(type=="����"){
        i = floor(random*destiny_name.length);
        str0 = destiny_name[i];
        str1 = destiny_cost[i];
        str2 = destiny_text[i];
    }    
    offsetx = xc-getStringWidth(str2)/5/2;
    offsety = yc-radius+2*fontHeight;
    drawString(str0,xc,offsety);
    drawString(str1,xc,offsety+3*fontHeight);

    loop_str(str2);

    setJustification("center");
    setColor(color);
    setFont("SansSerif",fontHeight);
    return i;
    
}
function loop_str(str){
    ret = false;

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius*0.6;

    x1 = xc;
    y1 = yc+radius;
    button_overlay_index=Overlay.size;
    makeRectangle(x1-cityWidth,y1,2*cityWidth,fontHeight*3);
    Overlay.addSelection("gray");
    color = getValue("color.foreground");
    setColor("blue");
    drawString("OK",x1,y1+fontHeight*2);

    windowSize = 15;
    loopSize = lengthOf(str2)-windowSize;
    txtY = yc+6*fontHeight;
    txtHeight = fontHeight*1.5;
    setFont("SansSerif", txtHeight);
    loopIndex = 0;time=0;time1=0;dt = 200;

    ans="";str = "           "+str + "    ^_^     ";
    x2=-1; y2=-1; z2=-1; flags2=-1;
    while(ans==""){
        getCursorLoc(x, y, z, flags);
        if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
            if (flags&leftButton!=0){
                Overlay.activateSelection(button_overlay_index);
                wait(10);
                if(Roi.contains(x, y)){ans = "OK";}
                ret = true;
            }
        }
        time = getTime()%dt*2;
        if(time > dt && time1 <= dt){
            msg = substring(str,loopIndex,loopIndex+windowSize);
            loopIndex = loopIndex+1;
            if(loopIndex > lengthOf(str)-windowSize)loopIndex=0;
            txtWidth = getStringWidth(str)/(lengthOf(str))*20;
            setColor("white");
            fillRect(xc-txtWidth/2,txtY-txtHeight-2,txtWidth,txtHeight+4);
            setColor("black");
            drawString(msg,xc,txtY);
        }
        time1 = time;

    }
    Overlay.removeSelection(button_overlay_index);
    setColor("white");
    makeRectangle(x1-cityWidth,y1,2*cityWidth,fontHeight*3);
    fill();
    run("Select None");

    return ret;
}
function go_to_prison(player){
    prison_number = 10;
    if(player[KEY]==0){    
        move_player_to(player, prison_number);
        player[PRISON]=IN_PRISON;
        player[SKP]=IN_SKIP;
    }else{
        player[KEY]=0;
    } 
}
function fails_and_exit(player,money2pay){
    ret = false;
    no_money = false;
    currentMoney = parseInt(player[MNY]);
    if(isNaN(currentMoney))currentMoney=0;
    while(currentMoney<money2pay){
        show_message("You need "+(money2pay-currentMoney), " you can sell area to get money...");
        r = sell_area(player);
        if(r==false){
            no_money = true;
            break;
        }
        currentMoney = parseInt(player[MNY]);
        if(isNaN(currentMoney))currentMoney=0; 
        show_player_info();       
    }
    if(no_money){
        show_message(player[NAME]," fails !!!");
        for(i=0;i<Table.size;i++){
            owner_name = get_item("����",i);
        
            if(owner_name == player[NAME]){
                room_num = parseInt(get_item("������",i));
                if(isNaN(room_num))room_num=0;
                if(room_num>0){
                    for(j=0;j<room_num;j++){
                        remove_house(i);
                    }
                }
                Table.set("������",i,0);
                Table.set("����",i,"");
                Table.update;
                clear_mark(i);
            }
        }
        player[FAIL]=true;
        p = get_home_points(player[IDX]);
        Overlay.moveSelection(player[IDX], p[0], p[1]);
        
        ret = true;
    }

    return ret;
        
}

function check_events(player,start,stop){
    ret = true;
    numberOfStop = Table.size;

    position = player[POS];
    type  = get_item("���",position);
    title = get_item("����",position);
    if(type == "����"){
        go_to_prison(player); 
        ret = true;
    }
    if(start<numberOfStop && stop >numberOfStop ){
        if(player[PRISON]!=IN_PRISON){
            show_message(player[NAME]," get 2000 dolar!!");
            player[MNY]=player[MNY]+2000;
            show_player_info();
        }else{
            player[PRISON]=!IN_PRISON;
        }
        ret = true;

    }
    if(stop != start && type=="ͣ��"){ 
        player[SKP]=true;
        //showMessage(player[NAME]+" skip once !");
        ret = true;    
    }
    if(stop != start && type=="˰��"){ 
        if(title=="����˰")fee = 2000;
        if(title=="�Ʋ�˰")fee = 1000;
        
        fail = fails_and_exit(player,fee);
        if(!fail){
            show_message(player[NAME]," pay "+fee+" tax fee!");
            currentMoney = parseInt(player[MNY]);
            if(isNaN(currentMoney))currentMoney=0;
            player[MNY]=currentMoney - fee;
        }else{
          
        }
        ret = true;      
    }
    if(stop != start && (type=="����" || type=="����")){ 
        n = do_chance_destiny(type);
        //n =1;
        change_money = 0;
        max_house_num = 0;
        min_house_num = 4;
        tianzifang = 26;
        if(type=="����"){
            if(n==0)change_money = 850;
            if(n==2){
                tot_num_room=0;
                tot_num_hotel=0;
                for(i=0;i<Table.size;i++){
                    owner_name = get_item("����",i);
                    if(owner_name == player[NAME]){
                        room_num  = parseInt(get_item("������",i));
                        if(isNaN(room_num))room_num=0;
                        hotel_num = parseInt(get_item("�ù���",i));
                        if(isNaN(hotel_num))hotel_num=0;
                        tot_num_room = tot_num_room + room_num;
                        tot_num_hotel = tot_num_hotel + hotel_num;
                    }
                }
                change_money = tot_num_room*(-200);
                change_money = change_money+tot_num_hotel*(-600);            
            }
            if(n==4)change_money = 900;
            if(n==5)change_money = 800;
            if(n==6)change_money = 700;
            if(n==7)change_money = -600;
            if(n==9)change_money = -500;
            if(n==10)change_money = 600;
            if(n==11)change_money = 1000;
            fail = fails_and_exit(player,-change_money);
            currentMoney = parseInt(player[MNY]);
            if(isNaN(currentMoney))currentMoney=0;
            if(!fail){
                player[MNY]=currentMoney + change_money;
            }

            if(n==1){
                offset = floor(Table.size*random);
                for(i=0;i<Table.size;i++){
                    pos = (offset+i)%Table.size;
                    owner_name = get_item("����",pos);
                    t = get_item("���",pos);
                    if(owner_name == player[NAME] && t =="�̳�"){
                        room_num = parseInt(get_item("������",pos));
                        if(isNaN(room_num))room_num=0;
                        if(room_num<4){
                            build_house(player,pos,true);
                            break;
                        }
                    }
                }
                if(i==Table.size)show_message("It's a pity","No area to build!");
            }
            if(n==3){
                player[SKP]=true;
            }
            if(n==8){
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                     name = the_player[NAME];
                    if(name!=player[NAME]){
                        fail = fails_and_exit(player,100);
                        currentMoney = parseInt(player[MNY]);
                        if(isNaN(currentMoney))currentMoney=0;
                        if(!fail){
                            player[MNY]=currentMoney - 100;
                            the_player_money = parseInt(the_player[MNY]);
                            if(isNaN(the_player_money))the_player_money=0;
                            the_player[MNY]=the_player_money+100;
                        }else{
                            the_player[MNY]=the_player_money+currentMoney;
                        }

                    }
                }
            }
        }
        if(type=="����"){
            if(n==0)change_money = -800;
            if(n==3)change_money = 600;
            if(n==5)change_money = -600;
            if(n==11)change_money = -1200;

            fail = fails_and_exit(player,-change_money);
            currentMoney = parseInt(player[MNY]);
            if(isNaN(currentMoney))currentMoney=0;
            if(!fail){
                player[MNY]=currentMoney + change_money;
            }
            if(n==1){
                for(j=0;j<player_number;j++){
                    the_player = get_player_by_idx(j);
                    if(max_house_num<parseInt(the_player[ROOM])){
                        max_house_num=parseInt(the_player[ROOM]);
                    }
                }

                for(j=0;j<player_number;j++){
                    the_player = get_player_by_idx(j);
                    if(the_player[ROOM]==max_house_num){
                        player_name = the_player[NAME];
                        offset = floor(Table.size*random);//start randomly
                        for(i=0;i<Table.size;i++){
                            pos = (offset+i)%Table.size;
                            if(player_name == get_item("����",pos) &&
                               parseInt(get_item("������",pos))>0){
                               remove_house(pos);//delete house
                               the_player[ROOM]=the_player[ROOM]-1;
                            }
                        }
                    }
                }                
            }
            if(n==2){
                for(j=0;j<player_number;j++){
                    the_player = get_player_by_idx(j);
                    if(min_house_num>the_player[ROOM]){
                        min_house_num=the_player[ROOM];
                    }
                }
                for(j=0;j<player_number;j++){
                    the_player = get_player_by_idx(j);
                    if(the_player[ROOM]==min_house_num){
                        player_name = the_player[NAME];
                        offset = floor(Table.size*random);//start randomly
                        for(i=0;i<Table.size;i++){
                            pos = (offset+i)%Table.size;
                            room_num = parseInt(get_item("������",pos));
                            t = get_item("���",pos);
                            if(isNaN(room_num))room_num = 0;
                            if(player_name == get_item("����",pos) &&
                               t == "�̳�" && room_num<4){
                               build_house(the_player,pos,true);//build house non_free
                            }
                        }
                    }
                }                
            }
            if(n==4){
                player[KEY]=1;
            }
            if(n==6){
                go_to_prison(player);
            }
            if(n==7){
                move_player_to(player,0);
                player[MNY]=player[MNY]+2000;
            }
            if(n==8){
                player[SKP]=true;
            }
            if(n==9){
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                    show_message(the_player[NAME]," press ok to roll the dice ...");
                    points = dice();
                    the_player[MNY] = the_player[MNY]+points*10;
                    show_message(the_player[NAME], "got "+(points*10)+":)");
                }
            }
            if(n==10){
                min_d = 40;
                min_player = player0;
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                    d = abs(the_player[POS]-tianzifang);
                    if(d>20)d=40-d;
                    if(min_d>d){
                        min_d=d;
                        min_player = the_player;
                    }
                }
                fail = fails_and_exit(min_player,500);
                currentMoney = parseInt(min_player[MNY]);
                if(isNaN(currentMoney))currentMoney=0;
                if(!fail){
                    min_player[MNY]=currentMoney - 500;
                }
            }
            if(n==12){
                max_money = 0;
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                    if(max_money<the_player[MNY]){
                        max_money=the_player[MNY];
                    }
                }
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                    if(max_money==the_player[MNY]){
                        fail = fails_and_exit(the_player,1000);
                        currentMoney = parseInt(the_player[MNY]);
                        if(isNaN(currentMoney))currentMoney=0;
                        if(!fail){
                            the_player[MNY]=currentMoney-1000;
                        }
                    }
                }
            }
        }
        
        ret = true;      
    }
    owner_name = Table.getString("����",position);
    if(stop != start && is_occupied(position)){
        
        if( owner_name != player[NAME] ){
            owner_player = get_player_by_name(owner_name);
            if(type=="ˮ��"){
                count = count_player_areas(owner_player,type);
                if(count == 2)
                    fee = (stop-start)*100;
                else
                    fee = (stop-start)*10;
            }
            if(type=="��վ"){
                count = count_player_areas(owner_player,type);
                if(count ==1)fee = parseInt(get_item("��·��",position));
                if(count ==2)fee = parseInt(get_item("��·��1",position));
                if(count ==3)fee = parseInt(get_item("��·��2",position));
                if(count ==4)fee = parseInt(get_item("��·��3",position));
            }
            if(type=="�̳�"){
                hotel_number = parseInt(get_item("�ù���",position));
                house_number = parseInt(get_item("������",position));
                if(hotel_number == 1){
                    fee = parseInt(get_item("��·��5",position));
                }else if(house_number==1){
                    fee = parseInt(get_item("��·��1",position)); 
                }else if(house_number==2){
                    fee = parseInt(get_item("��·��2",position));
                }else if(house_number==3){
                    fee = parseInt(get_item("��·��3",position));
                }else if(house_number==4){
                    fee = parseInt(get_item("��·��4",position));
                }else{
                    fee = parseInt(get_item("��·��",position));
                }
            }
            show_message(player[NAME],"Pay "+ fee +" to "+owner_name +" !");

            fail = fails_and_exit(player,fee);
            currentMoney = parseInt(player[MNY]);
            if(isNaN(currentMoney))currentMoney=0;
            if(!fail){
                player[MNY]=currentMoney - fee;
                to_player = get_player_by_name(owner_name);
                to_player_money = to_player[MNY];
                if(isNaN(to_player_money))to_player_money=0;
                to_player[MNY]=to_player_money+fee;
            }

        }
        ret = true;
        
    }
    if(stop != start && type=="�̳�"){
        if(!is_occupied(position) || owner_name == player[NAME])
        ret = open_dialog(player);
    }
    if(stop != start &&  (type=="ˮ��"   || 
                          type=="��վ" )){
        if(!is_occupied(position))
        ret = open_dialog(player);
    }
    show_player_info();
    return ret;
}
function get_item(colname,position){
    item = Table.getString(colname,position);
    return item;
}
function count_player_areas(player,type){
    num_area = 0;
    num_colors = newArray(0,0,0,0,0,0,0,0);
    num_stations = 0;
    num_factorys = 0;
    player_name = player[NAME];
    for(i=0;i<Table.size;i++){
        currentType = get_item("���",i);
        owner_name  = get_item("����",i);

        if(owner_name == player_name){
            if(currentType == "��վ")num_stations++;
            if(currentType == "ˮ��")num_factorys++;
         
        }
    }
    if(type == "��վ") return num_stations;
    if(type == "ˮ��") return num_factorys;
}

var dice_index = 0;
var dice_number = newArray(1,40,1,1,1);
function dice1(){
    ret = dice_number[dice_index];
    dice_index = (dice_index+1)%dice_number.length;
    return ret;
}

function dice(){
    number = 1+floor(random*12) ;
    //return 7;
    //return number;
    color=getValue("color.foreground");

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius * 0.8;

    offset = 360+floor(random*3)*360;

    degree = offset+number/12*360;
    for(i=0;i<=degree;i++){
        x = xc + radius*(cos(i/360*PI*2-PI/2));
        y = yc + radius*(sin(i/360*PI*2-PI/2));
        makeArrow(xc,yc,x,y,"filled");
        Roi.setStrokeWidth(10);
        wait(1);

    }
    makeOval(xc-radius, yc-radius, radius*2, radius*2);
    setColor("white");
    fill();
    
    makeArrow(xc,yc,x,y,"filled");
    Roi.setStrokeWidth(2);
    setForegroundColor(0, 255, 0);
    run("Draw", "slice");

    run("Select None");

    setColor(color);
    return number;
}

function draw_dice(){
    color=getValue("color.foreground");

    setColor("red");
    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    drawOval(xc-radius, yc-radius, radius*2, radius*2);
    
    for(i=1;i<=12;i++){
        x = xc + radius*0.9*(cos(i/12*PI*2-PI/2));
        y = yc + radius*0.9*(sin(i/12*PI*2-PI/2));
        drawString(""+i,x,y);
    }

    makeArrow(xc,yc,xc,yc-radius*0.8,"filled");
    Roi.setStrokeWidth(2);
    setForegroundColor(0, 255, 0);
    run("Draw", "slice");

    setColor(color);
}
function money_inc(player,money){
    currentMoney = parseInt(player[MNY]);
    if(isNaN(currentMoney))currentMoney=0;
    add_money = parseInt(money);
    if(isNaN(add_money))add_money=0;
    player[MNY] = currentMoney+add_money;
}
function play_sound(type){
    if(!PLAY_SOUND)return;

    if(type=="dice"){ music = "c:/windows/media/Alarm02.wav";}
    exec("C:/Program Files (x86)/Windows Media Player/wmplayer.exe",music);

}
