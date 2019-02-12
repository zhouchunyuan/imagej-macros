IDX=0;NAME=1;PIC=2;POS=3;MNY=4;PRISON=5;SKP=6;DO=7;ROOM=8;KEY=9;FAIL=10; //player=(NAME,POS,MNY,PRISON)
var INIT_MONEY = 20000;
var IN_PRISON = true;
var IN_SKIP = true;

var NAMES = newArray("撒","何","白","娜");
var player0 = newArray(0,NAMES[0],"a.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,true,0,0,0);//(name,current postion, money,in_prison,in_skip)
var player1 = newArray(1,NAMES[1],"b.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false,0,0,0);
var player2 = newArray(2,NAMES[2],"c.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false,0,0,0);
var player3 = newArray(3,NAMES[3],"d.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false,0,0,0);
var player_number = 4;


mapWidth = 1300;
mapHeight = 768;
totalBlocks = 40;
eqBlockNum = 9+2*sqrt(2);
colornames = newArray("粉","黄","紫","橙","红","蓝","棕","绿");
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
    for(i=0;i<NAMES.length;i++){
        Dialog.addCheckbox(NAMES[i],true);
    } 
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
}
function get_player_by_name(name){
    if(name==NAMES[0])return player0;
    if(name==NAMES[1])return player1;
    if(name==NAMES[2])return player2;
    if(name==NAMES[3])return player3;
}
function get_player_by_idx(idx){
    /* type of mix array will change dynamicly */
//print(parseInt(idx));
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
    chances_name = Table.getColumn("【名称】");
    chances_cost = Table.getColumn("【奖惩】");
    chances_text = Table.getColumn("【说明】");
    open("destiny.csv");
    destiny_name = Table.getColumn("【名称】");
    destiny_cost = Table.getColumn("【奖惩】");
    destiny_text = Table.getColumn("【说明】");
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
            selectWindow("大富翁");
            run("Select None");
            x2=x; y2=y; z2=z; flags2=flags;
            wait(10);

      /************ auto skip **************/
            player = get_player_by_idx(loop);
            if(player[SKP]){
                showMessage(player[NAME]+" skip once !");
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
                ret = check_events(player,start,stop);
            }
        }else{
            showMessage("It is not your turn !");
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
    type= get_item("类别",n);
    str0 = get_item("名称",n);

    if(type=="商场"){
        str0 += " $"+get_item("买价",n);
        str1 = "过路费——";
        str2 = "空地\n一幢房屋\n两幢房屋\n三幢房屋\n四幢房屋\n一幢旅馆";
        str2 +="\n房屋建筑费 每幢\n旅馆建筑费 每幢";
        str3 = get_item("过路费",n);
        str3 +="\n"+get_item("过路费1",n);
        str3 +="\n"+get_item("过路费2",n);
        str3 +="\n"+get_item("过路费3",n);
        str3 +="\n"+get_item("过路费4",n);
        str3 +="\n"+get_item("过路费5",n);
        str3 +="\n"+get_item("建房费",n);
        str3 +="\n"+get_item("建旅馆",n);
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
    if(type=="水电"){
        str0 += " $"+get_item("买价",n);
        str1 = "凡拥有电力或水电公司者，其过\n路费得收取所转转盘数之十倍。";
        str2 = "凡拥有电力公司及自来水公司者，其\n过路费得收取所转转盘数之一百倍。";

        offsetx = xc;
        offsety = yc-radius+2*fontHeight;
        drawString(str0,xc,offsety);
        
        drawString(str1,offsetx,offsety+3*fontHeight);
        drawString(str2,offsetx,offsety+6*fontHeight);

    }
    if(type=="火车站"){
        str0 += " $"+get_item("买价",n);
        str1 = "过路费——";
        str2 = "如购得一个车站\n如购得一个车站\n如购得一个车站\n如购得一个车站";
        str3 = get_item("过路费",n);
        str3 +="\n"+get_item("过路费1",n);
        str3 +="\n"+get_item("过路费2",n);
        str3 +="\n"+get_item("过路费3",n);

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
            key_num = 0;
            for(j=0;j<Overlay.size;j++){
                Overlay.activateSelection(j);
                wait(10);
                Roi.getBounds(x0, y0, w, h);
                if(abs(x_key-x0)<10 && abs(y_key-y0)<10){
                    key_num = 1;
                    break;
                } 
            }
            if(key_num==0){
                add_img("key.JPG",x_key,y_key,
                                txtHeight,txtHeight);
            }
        }else{
            setColor("white");
            fillRect(x_key,y_key,txtHeight,txtHeight);
        }
    }

    setFont("SansSerif",fontHeight);
}
function add_img(name,x,y,w,h){
    open(name);
    run("Size...", "width=&w height=&h average interpolation=Bilinear");
    run("Select All");
    run("Copy");
    selectWindow("大富翁");
    makeRectangle(x,y,w,h);
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
    newImage("大富翁", "RGB white", mapWidth , mapHeight , 1);
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

    colorcode = get_block_color(get_item("颜色",n));
    setColor( colorcode );
    /**** out frame ****/
    drawRect(x,y,w,h);

    /**** arrow sign ****/
    side = floor(n/10);
    type = get_item("类别",n);
    if(type=="商场"){
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

        colorcode = get_block_color2(get_item("颜色",n));
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
    drawString(get_item("名称",n), x+w/2, y+h/2+fontHeight);
    price = parseInt(get_item("买价",n));
    if(price != 0)drawString("$"+price, x+w/2, y+h/2+fontHeight*2 );
}

function draw_icons(n){
    p = get_block_position(i);
    x=p[0];y=p[1];w=p[2];h=p[3];
    type = get_item("类别",n);
    name = get_item("名称",n);
    if(type == "火车站")pasteIcon(x+w/2-cityWidth/4,y+2,"train.jpg");
    if(type == "机会")pasteIcon(x+w/2-cityWidth/4,y+2,"chance.jpg");
    if(type == "命运")pasteIcon(x+w/2-cityWidth/4,y+2,"destiny.jpg");
    if(name == "电力公司")pasteIcon(x+w/2-cityWidth/4,y+2,"powerplant.jpg");
    if(name == "自来水公司")pasteIcon(x+w/2-cityWidth/4,y+2,"water.jpg");
    if(name == "所得税")pasteIcon(x+w/2-cityWidth/4,y+2,"tax2.jpg");
    if(name == "财产税")pasteIcon(x+w/2-cityWidth/4,y+2,"tax1.jpg");
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
    selectWindow("大富翁");
    makeRectangle(x, y, w, h);
    run("Paste");

    close(file);
}
function remove_house(position){
    p = get_block_position(position);
    x=p[0];y=p[1];w=p[2];h=p[3];
    room_num = parseInt(get_item("房间数",n));
    player = get_player_by_name(get_item("地主",n));
    if(room_num >0){
        room_num = room_num-1;
        Table.set("房间数",n,room_num);
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
    owner_name = Table.getString("地主",position);
    
    if( owner_name!=player[NAME] ){
        showMessage("It does not belong to you !");
        return ret;
    }
    type = get_item("类别",position);
    if(type=="商场"){
        price = parseInt(get_item("建房费",position));
        currentMoney = player[MNY];
        if(currentMoney > price){
            run("Select None");
            num_house = parseInt(get_item("房间数",position));
            if(isNaN(num_house))num_house=0;
            if(num_house<4){
                player_name = player[NAME];

                num_house=num_house+1;
                Table.set("房间数",position,num_house);
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

            }else{
                showMessage("Maximum house number is 4 !");
            }

            //show_player_info();
        }else{
            showMessage("Not enough money!");
        }
    }else{
        showMessage("It is NOT an area for buildings!");
    }
    return ret;
}
function buy_area(player){
    ret = false;
    position = player[POS];
    type = get_item("类别",position);
    if(type == "商场"   || 
       type == "火车站" ||
       type == "水电" ){
        owner_name = get_item("地主",position);
        if( !is_occupied(position) ){
            price = parseInt(get_item("买价",position));
            currentMoney = player[MNY];
            if(currentMoney > price){
                player[MNY]=currentMoney - price;
                name=player[NAME];
                Table.set("地主",position,name);
                Table.update;
                draw_mark(position,player);
                //show_player_info();
                ret = true;
            }else{
                showMessage("Not enough money!");
            }
        }else{
            showMessage("Occupied already!");
        }
    }else{
        showMessage("Area NOT for sale !");
    }
    return ret;
}
function draw_mark(n,player){
    setColor("black");
    txtHeight = 1.5*fontHeight;
    setFont("SansSerif",txtHeight);
    setJustification("center");

    selectWindow("大富翁");
    p = get_block_position(n);
    x=p[0];y=p[1];w=p[2];h=p[3];
    side = floor(n/10);
    x1 = x; y1 = y;
    markWidth=getStringWidth(player[NAME]);
    if(side==0){x1=x+w/2;y1=y;}
    if(side==1){x1=x+w+markWidth/2+1;y1=y+h/2+txtHeight/2;}
    if(side==2){x1=x+w/2;y1=y+h+txtHeight;}
    if(side==3){x1=x-markWidth/2;y1=y+h/2+txtHeight/2;}
    Overlay.drawString(player[NAME],x1,y1);
    setFont("SansSerif",fontHeight );
}
function is_occupied(position){
    owner_name = get_item("地主",position);
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
                selectWindow("大富翁");
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
            close("大富翁");
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

    color=getValue("color.foreground");

    xc=mapWidth/2;yc=mapHeight/2;
    radius = eqBlockNum * cityWidth /2 - 2*cityHeight;
    radius = radius*0.6;
    setColor("white");
    fillRect(xc-radius, yc-radius, radius*2, radius*2);
    
    setColor("black");    
    run("Select None");
    if(type=="机会"){
        i = floor(random*chances_name.length);
        //i=2;
        str0 = chances_name[i];
        str1 = chances_cost[i];
        str2 = chances_text[i];
    }
    if(type=="命运"){
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
function fails_and_exit(player){

}
function check_events(player,start,stop){
    ret = true;
    numberOfStop = Table.size;

    position = player[POS];
    type  = get_item("类别",position);
    title = get_item("名称",position);
    if(type == "进牢"){
        go_to_prison(player); 
        ret = true;
    }
    if(start<numberOfStop && stop >numberOfStop ){
        if(player[PRISON]!=IN_PRISON){
            showMessage(player[NAME]+" get 2000 dolar!!");
            player[MNY]=player[MNY]+2000;
        }else{
            player[PRISON]=!IN_PRISON;
        }
        ret = true;
        //print(player[NAME],player[PRISON],start,stop,player[MNY]);
    }
    if(stop != start && type=="停车"){ 
        player[SKP]=true;
        //showMessage(player[NAME]+" skip once !");
        ret = true;    
    }
    if(stop != start && type=="税收"){ 
        if(title=="所得税")fee = 2000;
        if(title=="财产税")fee = 1000;
        currentMoney = player[MNY];
        if(currentMoney > fee){
            showMessage(player[NAME]+" pay "+fee+" tax fee!");
            player[MNY]=currentMoney - fee;
        }else{
            showMessage(player[NAME]+" fails !!!");
        }
        ret = true;      
    }
    if(stop != start && (type=="机会" || type=="命运")){ 
        n = do_chance_destiny(type);
        //n =9;
        change_money = 0;
        max_house_num = 0;
        min_house_num = 4;
        tianzifang = 26;
        if(type=="命运"){
            if(n==0)change_money = 850;
            if(n==2){
                num_room=0;
                num_hotel=0;
                for(i=0;i<Table.size;i++){
                    owner_name = get_item("地主",i);
                    if(owner_name == player[NAME]){
                        num_room = num_room + parseInt(get_item("房间数",i));
                        num_hotel = num_hotel + parseInt(get_item("旅馆数",i));
                    }
                }
                change_money = num_room*(-200);
                change_money = change_money+num_hotel*(-600);            
            }
            if(n==4)change_money = 900;
            if(n==5)change_money = 800;
            if(n==6)change_money = 700;
            if(n==7)change_money = -600;
            if(n==9)change_money = -500;
            if(n==10)change_money = 600;
            if(n==11)change_money = 1000;
            if(player[MNY] + change_money >= 0){
                player[MNY]=player[MNY] + change_money;
            }else{
                showMessage(player[NAME]+" fails !!!");
            }
            if(n==1){
                offset = floor(Table.size*random);
                for(i=0;i<Table.size;i++){
                    pos = (offset+i)%Table.size;
                    owner_name = get_item("地主",pos);
                    if(owner_name == player[NAME]){
                        room_num = parseInt(get_item("房间数",pos));
                        if(room_num<4){
                            build_house(player,pos,true);
                            break;
                        }
                    }
                }
                if(i==Table.size)showMessage("No area to build!");
            }
            if(n==3){
                player[SKP]=true;
            }
            if(n==8){
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                     name = the_player[NAME];
                    if(name!=player[NAME]){
                        if(player[MNY]-100>=0){
                            player[MNY]=player[MNY]-100;
                            the_player[MNY]=the_player[MNY]+100;
                        }else{
                            showMessage(player[NAME]+" fails !!!");
                        }
                    }
                }
            }
        }
        if(type=="机会"){
            if(n==0)change_money = -800;
            if(n==3)change_money = 600;
            if(n==5)change_money = -600;
            if(n==11)change_money = -1200;
            if(player[MNY] + change_money >= 0){
                player[MNY]=player[MNY] + change_money;
            }else{
                showMessage(player[NAME]+" fails !!!");
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
                            if(player_name == get_item("地主",pos) &&
                               parseInt(get_item("房间数",pos))>0){
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
                            room_num = parseInt(get_item("房间数",pos));
                            if(isNaN(room_num))room_num = 0;
                            if(player_name == get_item("地主",pos) &&
                               room_num<4){
                               build_house(the_player,pos,false);//build house non_free
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
                    showMessage(the_player[NAME]+" press ok to roll the dice ...");
                    points = dice();
                    the_player[MNY] = the_player[MNY]+points*10;
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
                if(min_player[MNY]-500>=0){
                    min_player[MNY]=min_player[MNY]-500;
                }else{
                    showMessage(min_player[NAME]+" fails !!!");
                }
            }
            if(n==12){
                max_money = 0;
                max_player = player0;
                for(i=0;i<player_number;i++){
                    the_player = get_player_by_idx(i);
                    if(max_money<the_player[MNY]){
                        max_money=the_player[MNY];
                        max_player = the_player;
                    }
                }
                if(max_player[MNY]-1000>=0){
                    max_player[MNY]=max_player[MNY]-1000;
                }else{
                    showMessage(max_player[NAME]+" fails !!!");
                }
            }
        }
        
        ret = true;      
    }
    owner_name = Table.getString("地主",position);
    if(stop != start && is_occupied(position)){
        
        if( owner_name != player[NAME] ){
            owner_player = get_player_by_name(owner_name);
            if(type=="水电"){
                count = count_player_areas(owner_player,type);
                if(count == 2)
                    fee = (stop-start)*100;
                else
                    fee = (stop-start)*10;
            }
            if(type=="火车站"){
                count = count_player_areas(owner_player,type);
                if(count ==1)fee = parseInt(get_item("过路费",position));
                if(count ==2)fee = parseInt(get_item("过路费1",position));
                if(count ==3)fee = parseInt(get_item("过路费2",position));
                if(count ==4)fee = parseInt(get_item("过路费3",position));
            }
            if(type=="商场"){
                hotel_number = parseInt(get_item("旅馆数",position));
                house_number = parseInt(get_item("房间数",position));
                if(hotel_number == 1){
                    fee = parseInt(get_item("过路费5",position));
                }else if(house_number==1){
                    fee = parseInt(get_item("过路费1",position)); 
                }else if(house_number==2){
                    fee = parseInt(get_item("过路费2",position));
                }else if(house_number==3){
                    fee = parseInt(get_item("过路费3",position));
                }else if(house_number==4){
                    fee = parseInt(get_item("过路费4",position));
                }else{
                    fee = parseInt(get_item("过路费",position));
                }
            }
            showMessage("Pay "+ fee +" to "+owner_name +" !");

            currentMoney = player[MNY];
            if(currentMoney > fee){
                player[MNY]=currentMoney - fee;
                to_player = get_player_by_name(owner_name);
                to_player[MNY]=to_player[MNY]+fee;

            }else{
                showMessage(player[NAME]+" fails !!!");
            }
        }
        ret = true;
        
    }
    if(stop != start && type=="商场"){
        if(!is_occupied(position) || owner_name == player[NAME])
        ret = open_dialog(player);
    }
    if(stop != start &&  (type=="水电"   || 
                          type=="火车站" )){
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
        currentType = get_item("类别",i);
        owner_name  = get_item("地主",i);

        if(owner_name == player_name){
            if(currentType == "火车站")num_stations++;
            if(currentType == "水电")num_factorys++;
         
        }
    }
    if(type == "火车站") return num_stations;
    if(type == "水电") return num_factorys;
}
/*
var dice_index = 0;
var dice_number = newArray(1,3,7);
function dice(){
    ret = dice_number[dice_index];
    dice_index = (dice_index+1)%3;
    return ret;
}
*/
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

