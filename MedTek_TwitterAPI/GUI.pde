int d = 12; //base divider for gui placement

color c_fade = color(0, 7, 10, 20);
color c_menus = color(30, 35, 40);
color c_text = color(255, 255, 255);
color c_goBut = color(35, 210, 140);
color c_curSelBut = color(10, 170, 200);
color c_selBut = color(75, 100, 140);
color c_back = color(0);
color c_text_bg = color(1, 1, 1, 25);
color c_text_bg2 = color(1, 1, 1, 50);

color c_progress_bg = color(200, 220, 240);
color c_progress = color(100, 160, 255);
int ts_l = 25;
int ts_s = 16;

int rollerSize = 8;
float goBut_widthMod = 0.15;
boolean goBut_over = false;
boolean tBut_over = false;
boolean uBut_over = false;
boolean dbBut_over = false;
boolean sBut_over = false;
boolean bBut_over = false;

public void gui_loop() { 
  //Check if mouse over go button
  if (overCircle(width/2, height*0.917, width*goBut_widthMod))
    goBut_over = true;
  else
    goBut_over = false;

  rectMode(CENTER);
  //Check if mouse over tweet button
  if (overRect(width/d*2.5, height-height/d*1.3, width/d*3, height/d*1.2))
    tBut_over = true;
  else
    tBut_over = false;

  //Check if mouse over user button
  if (overRect(width-width/d*2.5, height-height/d*1.3, width/d*3, height/d*1.2))
    uBut_over = true;
  else
    uBut_over = false;

  //Check if mouse over begin button
  if (overRect(width/2, height-height/d*2.7, width/d*3, height/d*1.2))
    bBut_over = true;
  else
    bBut_over = false;


  //Check if mouse over DB button
  //if (overCircle(width/d*2, height/d*1.85, width/4))
  //rect(width/d*1.35, height/d*2, width/d*2.1, height/d*1.5);
  if (overRect(width/d*1.35, height/d*2, width/d*2.1, height/d*1.5))
    dbBut_over = true;
  else
    dbBut_over = false;

  //Check if mouse over secrets button
  //if (overCircle(width/d*2, height/d*1.85, width/4))
  //rect(width/d*4.1, height/d*2, width/d*2.35, height/d*1.5);
  if (overRect(width/d*4.1, height/d*2, width/d*2.35, height/d*1.5))
    sBut_over = true;
  else
    sBut_over = false;
  rectMode(CORNER);

  gui_top();
  gui_main();
  gui_bottom();
  if (!running) 
    updateRollers();
  gui_fade();
}

public void gui_top() {
  //bar
  fill(c_menus);
  rect(0, 0, width, height/d);

  //text
  fill(c_text);
  textSize(ts_l+4);
  text("MedTek Twitter data", width/d*0.3, height/d-height/d*0.17);
  textSize(ts_s);
  //text("Selected type: "+currentType, width-width/d*5, height/d-height/d/3);
}

public void gui_bottom() {
  //menu
  fill(c_menus);
  rect(0, height-height/d*1.5, width, height/d*1.5);

  if (running) return; //dont do buttons while running

  //go button
  float w_mod = (goBut_over) ? 0.16 : 0.15;
  fill(c_goBut);
  ellipseMode(CENTER);
  ellipse(width/2, height*0.917, width*w_mod, width*w_mod);
  fill(c_text);
  int ts_but = (goBut_over)?ts_l+6:ts_l;
  textAlign(CENTER, CENTER);
  textSize(ts_but);
  text("GO", width/2, height*0.914);
  textAlign(LEFT);

  //tweet button
  float size_mod = (tBut_over) ? 1.05:1;
  //color c = (currentType == "tweet") ? c_goBut : c_selBut;
  fill((currentType == "tweet") ? c_curSelBut : c_selBut);
  rectMode(CENTER);
  rect(width/d*2.5, height-height/d*1.3, width/d*3*size_mod, height/d*1.2*size_mod, 7);
  rectMode(CORNER);
  ts_but = (tBut_over)?ts_l:ts_l-4;
  fill(c_text);
  textAlign(CENTER, CENTER);
  textSize(ts_but);
  text("Tweets", width/d*2.5, height-height/d*1.35);
  textAlign(LEFT);


  //user button
  size_mod = (uBut_over) ? 1.05:1;
  fill((currentType == "user") ? c_curSelBut : c_selBut);
  rectMode(CENTER);
  rect(width-width/d*2.5, height-height/d*1.3, width/d*3*size_mod, height/d*1.2*size_mod, 7);
  rectMode(CORNER);
  ts_but = (uBut_over)?ts_l:ts_l-4;
  fill(c_text);
  textAlign(CENTER, CENTER);
  textSize(ts_but);
  text("Users", width-width/d*2.5, height-height/d*1.35);
  textAlign(LEFT);
}

public void gui_main() {
  if (running)
    gui_running();
  else gui_waiting();
}

public void gui_waiting() {
  //background
  rectMode(CENTER);
  fill(c_text_bg);
  rect(width/2, height/2, width/3, height/3);
  rectMode(CORNER);

  //dots
  fill(c_text);
  ellipseMode(CENTER);
  ellipse(width/2-width/d, height*0.45+rollers[0].num, width/d/2, width/d/2);
  ellipse(width/2, height*0.45+rollers[1].num, width/d/2, width/d/2);
  ellipse(width/2+width/d, height*0.45+rollers[2].num, width/d/2, width/d/2);

  //text
  fill(c_text);
  textAlign(CENTER, CENTER);
  textSize(ts_l);
  text(status, width*0.5, height*0.6);
  textSize(ts_s);
  text(infoText, width*0.5, height*0.68);
  if (endpoint != "")
    text("endpoint: "+endpoint, width*0.5, height*0.75);
  textAlign(LEFT);

  //select DB button
  float w_mod = (dbBut_over) ? 0.18 : 0.15;
  fill(c_selBut);
  ellipseMode(CENTER);
  ellipse(width/d*2, height/d*1.85, width/5*w_mod, width/5*w_mod);
  int ts_but = (dbBut_over)?ts_s-4:ts_s-5;
  fill(c_text);
  textSize(ts_but);
  text("Select DB: ", width/d/2, height/d*2);

  //select Secrets button
  w_mod = (sBut_over) ? 0.18 : 0.15;
  fill(c_selBut);
  ellipseMode(CENTER);
  ellipse(width/d*5, height/d*1.85, width/5*w_mod, width/5*w_mod);
  ts_but = (sBut_over)?ts_s-4:ts_s-5;
  fill(c_text);
  textSize(ts_but);
  text("Select Secrets: ", width/d*3, height/d*2);

  textSize(ts_s-5);
  text("DB path       : "+db_path, width/d/2, height/d*3);
  text("Secrets path: "+secrets_path, width/d/2, height/d*3.5);
}

public void gui_running() {
  //progress ellipses
  fill(random(150), random(95)+160, random(55)+200);
  //ellipse(random(width/3)+width/3, random(height/3)+height/3, random(7)+5, random(7)+5);
  //ellipse(random(width-width/3)+width/3/2, random(height/6)+height/d*1.5, random(7)+5, random(7)+5);
  ellipse(random(width/3)+width/3, random(height/4)+height/d*1.5, random(12)+4, random(12)+4);

  //text background
  fill(c_text_bg);
  rectMode(CENTER);
  rect(width/2, height/2-height/d/2, width/3, height/d);
  rectMode(CORNER);
  //task text
  fill(c_text);
  textAlign(CENTER, CENTER);
  if (!processingRequests)
    text("Ready to send "+requests.size()+" "+currentType+" requests.. (between "+(requests.size()*100-100)+" and "+(requests.size()*100)+" "+currentType+"s)", width/2, height/2-height/d/2);
  else {
    fill(0);
    rect(width/d, height/2-height/d, width-width/d*2, height/d);
    fill(c_text);
    text("Working", width/2, height/2-height/d*0.4);
  }
  //fill(240);


  //progress bar
  fill(c_progress_bg);
  rect(width/d, height/2+height/d, width-width/d*2, height/d, 15);
  fill(c_progress);
  if (progress_lim > 0)
    rect(width/d, height/2+height/d, map(progress, 0, progress_lim, width/d, width-width/d*2), height/d, 15);
  fill(15);
  text(progress+"/"+progress_lim+" done", width/2, height/d*7.5);
  textAlign(LEFT);

  //begin button
  if (!processingRequests) {
    float size_mod = (bBut_over) ? 1.05:1;
    //color c = (currentType == "tweet") ? c_goBut : c_selBut;
    //fill((currentType == "tweet") ? c_curSelBut : c_selBut);
    fill(c_progress);
    rectMode(CENTER);
    rect(width/2, height-height/d*2.7, width/d*3*size_mod, height/d*1.2*size_mod, 7);
    rectMode(CORNER);
    int ts_but = (bBut_over)?ts_l:ts_l-4;
    fill(c_text);
    textAlign(CENTER, CENTER);
    textSize(ts_but);
    text("Begin?", width/2, height-height/d*2.8);
    textAlign(LEFT);
  }
} 

public void gui_fade() {
  fill(c_fade);
  rect(0, 0, width, height);
  //rect(width/3, height/d*1.5, width/3, height/d*1.5);
}

void setupRollers() {
  rollers = new Roller[3];
  rollers[0] = new Roller(rollerSize/2);
  rollers[1] =  new Roller(0);
  rollers[2] = new Roller(-rollerSize/2);
}

void updateRollers() {
  if (!(frameCount%5==0)) return;

  for (Roller r : rollers) {
    if (r.num == rollerSize)
      r.dir = -1;
    else if (r.num == -rollerSize)
      r.dir = 1;
    r.num = r.num+=r.dir;
  }
}

void loadingScreen() {
  background(0);
  fill(255);
  textSize(ts_l);
  textAlign(CENTER);
  text("One moment..", width/2, height/2);
  textAlign(LEFT);
}

boolean overCircle(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

boolean overRect(float x, float y, float width, float height) {
  if (mouseX >= x-width/2 && mouseX <= x+width/2 && 
    mouseY >= y-height/2 && mouseY <= y+height/2) {
    return true;
  } else {
    return false;
  }
}

class Roller {
  public int num;
  public int dir;

  Roller(int size) {
    num = size;//(int)random(-size, size);
    dir = (num>0)?-1:1;
  }
}
