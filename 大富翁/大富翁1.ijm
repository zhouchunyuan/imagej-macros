IDX=0;NAME=1;PIC=2;POS=3;MNY=4;PRISON=5;SKP=6;DO=7 //player=(NAME,POS,MNY,PRISON)
var INIT_MONEY = 20000;
var IN_PRISON = true;
var IN_SKIP = true;

var NAMES = newArray("撒","何","白","娜");
var player0 = newArray(0,NAMES[0],"a.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,true);//(name,current postion, money,in_prison,in_skip)
var player1 = newArray(1,NAMES[1],"b.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false);
var player2 = newArray(2,NAMES[2],"c.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false);
var player3 = newArray(3,NAMES[3],"d.JPG",0,INIT_MONEY,!IN_PRISON,!IN_SKIP,false);
var player_number = 4;


mapWidth = 1300;
mapHeight = 768;
totalBlocks = 40;
eqBlockNum = 9+2*sqrt(2);
colornames = newArray("粉","黄","紫","橙","红","蓝","棕","绿");
colorcodes = newArray("#ffcccc","#cccc00","#9900ff","#cc2200","red","blue","#eeaa55","green");
colorcodes2 = newArray("#eeaaaa","yellow","#ff00ff","#ff8800","#ffaaaa","#aaaabb","#aa8822","#aaffaa");

cityWidth = mapHeight/eqBlockNum;
cityHeight = cityWidth*sqrt(2);
cornerWidth = cityWidth*sqrt(2);
cornerHeight = cityHeight;
fontHeight = cityWidth/5;
player_icon_size = cityWidth/2;
house_icon_size = cityWidth/2;

Choose_Players();
open("station_list.csv");
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
    loop_idx = parseInt(idx);
    if(parseInt(player0[IDX])==loop_idx)return player0;
    if(parseInt(player1[IDX])==loop_idx)return player1;
    if(parseInt(player2[IDX])==loop_idx)return player2;
    if(parseInt(player3[IDX])==loop_idx)return player3;
}
function load_players(){
    
    for(i=0;i<NAMES.length;i++){
        if(NAMES[i]!=""){
            /********* load player ************/
            player = get_player_by_name(NAMES[i]);
            pic_file = player[PIC];
            if(pic_file !=""){
                open(pic_file);
                run("Size...", "width=&player_icon_size height=&player_icon_size constrain average interpolation=Bilinear");
                selectWindow("大富翁");
                run("Add Image...", "image="+player[PIC]+" x=0 y=0 opacity=100");
                close(pic_file);
            }

            /********* load player ************/
            name = player[NAME];
            if(name!=""){
                move_player_to(player,0);
                show_player_info();
            }
        }
    }

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
    for(i=0;i<NAMES.length;i++){
        player = get_player_by_name(NAMES[i]);
        player[DO]=(player[IDX]==index);
    }
}
function mainloop(){
    leftButton=16;
    rightButton=4;

    setOption("DisablePopupMenu", true);

    x2=-1; y2=-1; z2=-1; flags2=-1;
    loop = floor(random*4);
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
    }
}
function check_player_click(player,x,y){
    ret = false;
    selectionIndex = player[IDX];
    Overlay.activateSelection(selectionIndex );
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
    if(type=="商场"){
        str0 = get_item("名称",n);
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
        str0 = get_item("名称",n);
        str1 = "凡拥有电力或水电公司者，其过\n路费得收取所转转盘数之十倍。";
        str2 = "凡拥有电力公司及自来水公司者，其\n过路费得收取所转转盘数之一百倍。";

        offsetx = xc;
        offsety = yc-radius+2*fontHeight;
        drawString(str0,xc,offsety);
        
        drawString(str1,offsetx,offsety+3*fontHeight);
        drawString(str2,offsetx,offsety+6*fontHeight);

    }
    if(type=="火车站"){
        str0 = get_item("名称",n);
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
    }

    setFont("SansSerif",fontHeight);
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
function build_house(player){
    ret = false;
    position = player[POS];
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
                player[MNY]=currentMoney - price;
                
                if(num_house==1){
                    if(player_name== NAMES[0])houseName = "housea.JPG";
                    if(player_name== NAMES[1])houseName = "houseb.JPG";
                    if(player_name== NAMES[2])houseName = "housec.JPG";
                    if(player_name== NAMES[3])houseName = "housed.JPG";
                    open(houseName);
                    run("Size...", "width=&house_icon_size height=&house_icon_size average interpolation=Bilinear");
                    run("Add Image...", "image=&houseName x=&x y=&y opacity=100");
                    close(houseName);
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

    if(player[DO]){
        position = player[POS];
        Dialog.create(player[NAME]+"@"+get_item("名称",player[POS]));
        Dialog.addMessage(get_item("名称",player[POS])+"\n$" + get_item("买价",player[POS]));
if(!is_occupied(position)){
    items = newArray("Buy","Pass","Game over!");
}else{
    items = newArray("Build House","Pass" ,"Game over!");
}
Dialog.addRadioButtonGroup("Action", items, 5, 1, items[0]);
        Dialog.show();
        ans = Dialog.getRadioButton;
        if(ans == "Buy" ){
            ret = buy_area(player);
            
        }
        if(ans == "Build House"){
            ret = build_house(player);
 
        }
        if(ans == "Sell House"){
            remove_house(player);
        }
        if(ans == "Pass"){
            ret = true;
        }
        if(ans == "Game over!"){
            close("大富翁");
            close("Results");
            exit();
        }
    }
    return ret;
}

function check_events(player,start,stop){
    ret = true;
    prison_number = 10;
    numberOfStop = Table.size;

    position = player[POS];
    type  = get_item("类别",position);
    title = get_item("名称",position);
    if(type == "进牢"){
        move_player_to(player, prison_number);
        player[PRISON]=IN_PRISON;
        player[SKP]=IN_SKIP; 
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
        fee = 500-round(1000*random);
        if(fee>0){
            msg=":-)\n lucky! \n" +player[NAME]+" get $";
        }else{
            msg=":-(\n unlucky! \n"+player[NAME]+"lost $";}
        showMessage(msg+""+fee+" !");
        currentMoney = player[MNY];
        if(currentMoney + fee > 0){
            player[MNY]=currentMoney + fee;
        }else{
            showMessage(player[NAME]+" fails !!!");
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
    //show_player_info();
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
function dice(){
    number = 1+floor(random*12) ;
    //return 5;
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

