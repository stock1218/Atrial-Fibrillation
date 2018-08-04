/*
John S. Samuels, II
July 2016

Simulation of cells within the heart using a model of cellular automata

written using Processing 3.1.1
*/

int size = 5;
int interval = 1000000;
int lastTime = 0;
//int sx;

//float timer;
//float realTime;

//boolean tmr;
//boolean sw;
//boolean going;

float[][] k;
float[][] cells; 
float[][] buffer;
float[][] t;
float[][] dt;
float[][] last;
float[][] bl;
float[][] waitTime;

boolean[][] deadCells;
boolean[][] waiting;
boolean[][] recover;
boolean[][] halfCells;

color c;

void setup() {
  size (1000, 700);

  cells = new float[width/size][height/size];
  deadCells = new boolean[width/size][height/size];
  buffer = new float[width/size][height/size];
  t = new float[width/size][height/size];
  dt = new float[width/size][height/size];
  k = new float[width/size][height/size];
  last = new float[width/size][height/size];
  bl = new float[width/size][height/size];
  waitTime = new float[width/size][height/size];
  waiting = new boolean[width/size][height/size];
  recover = new boolean[width/size][height/size];
  halfCells = new boolean[width/size][height/size];
  stroke(48);

  //tmr = false;
  //sw = true;
  //going = true;

  for (int x=0; x<cells.length; x++) {
    for (int y=0; y<cells[x].length; y++) {
      cells[x][y] = 5;
      t[x][y] = 1;
      dt[x][y] = 1;
      k[x][y] = random(1.8, 2);
      //k[x][y] = 2;
      last[x][y] = 5;
      bl[x][y] = 5;
      waitTime[x][y] = 1000;
      waiting[x][y] = false;
      recover[x][y] = false;
      
    }
  }
  for (int x=0; x<cells.length; x += 10) {
    for (int y=0; y<cells[x].length; y += 9) {
      float chance = (int)random(0, 100);
      if ((chance/y) > 0.8 )
        generate(x, y);
    }
  }
    
  for (int x=0; x<cells.length; x++) {
   halfCells[x][cells[x].length/2] = true; 
  }

  background(0);
}

void keyPressed() {

  //start horizontal wave
  if (key=='r' || key == 'R') {
    for (int x=0; x<cells.length; x++) {
      for (int y=cells[x].length/2; y<cells[x].length; y++) {
        cells[x][y] = 1;
        last[x][y] = 5;
        dt[x][y] = 1/(k[x][y]*sqrt(t[x][y]));
        t[x][y] = 0;
        waiting[x][y] = false;
        recover[x][y] = true;
        waitTime[x][y] = 2;
      }
    }
  }

  //start vertical wave
  if (key=='o' || key == 'O') {
    for (int x=0; x<cells.length/2; x++) {
      for (int y=0; y<cells[x].length; y++) {
        cells[x][y] = 1;
        last[x][y] = 5;
        dt[x][y] = 1/(k[x][y]*sqrt(t[x][y]));
        t[x][y] = 0;
        waitTime[x][y] = 2;
        waiting[x][y] = false;
        recover[x][y] = true;
      }
    }
  }

  //activate random cell
  if (key=='t' || key == 'T') {
    cells[(int)random(0, width/size)][(int)random(0, height/size)] = 1;
  }


  //if (key=='l' || key == 'L') {
  //  timer = millis();
  //  //cells[(width/size)/2][height/size - 1] = 1;
  //  cells[sx][height/size - 1] = 1;
  //}

  //pause simulation
  if (key=='p' || key == 'P') {
    if (interval <= 10) {
      interval = 10000000;
    } else {
      interval = 1;
    }
  }

  //reset all dead cells
  if (key=='i' || key == 'I') {
    for (int x=0; x<cells.length; x++) {
      for (int y=0; y<cells[x].length; y++) {
        deadCells[x][y] = false;
      }
    }
  }

  //reset all cells
  if (key=='n' || key == 'N') {
    for (int x=0; x<cells.length; x++) {
      for (int y=0; y<cells[x].length; y++) {
        cells[x][y] = 5;
        t[x][y] = 1;
        dt[x][y] = 1;
        last[x][y] = 5;
        waitTime[x][y] = 100;
        waiting[x][y] = false;
      }
    }

    //generate((int)random(0, (width/size)), (int)random(0, (height/size)));
  }

  if (key=='e' || key == 'E') {
    for (int y=0; y<cells[(width/size)/2].length; y++) {
      cells[(width/size)/2][y] = 1;
      last[(width/size)/2][y] = 5;
      dt[(width/size)/2][y] = 1/(k[0][y]*sqrt(t[0][y]));
      t[(width/size)/2][y] = 0;
    }
  }

  if (key==']') {
    update();
  }
}


void draw() {

  //color for cells
  for (int x=0; x<cells.length; x++) {
    for (int y=0; y<cells[x].length; y++) {
      if (cells[x][y]<5 && cells[x][y] >= 4) {
        c = color(0, 51*4, 0);
      } else if (cells[x][y]<4 && cells[x][y] >= 3) {
        c = color(0, 51*3, 0);
      } else if (cells[x][y]<3 && cells[x][y] >=2) {
        c = color(0, 51*2, 0);
      } else if (cells[x][y] < 2) {
        c = color(0, 51, 0);
      } else { 
        c = color(0, 255, 0);
      }

      if (deadCells[x][y] == true) {
        c = color(255, 0, 0);
      }
      
      if (halfCells [x][y] == true) {
       c = color(0); 
      }
      fill(c);
      rect(x*size, y*size, size, size);
    }
  }
  // Iterate if timer ticks
  if (millis()-lastTime>interval) {
    update();
    lastTime = millis();
    //if (tmr) {
    //  realTime = millis() - timer;
    //}
  }


  if (mousePressed) {
    // Map and avoid out of bound errors
    int x = int(map(mouseX, 0, width, 0, width/size));
    x = constrain(x, 0, width/size-1);
    int y = int(map(mouseY, 0, height, 0, height/size));
    y = constrain(y, 0, height/size-1);


    cells[x][y] = 1;
    last[x][y] = 5;
    dt[x][y] = 1/(k[x][y]*sqrt(t[x][y]));
    t[x][y] = 0;
    waitTime[x][y] = 100;
    waiting[x][y] = false;
    recover[x][y] = true;
    
    //uncomment if you would like to click for dead cells
    //deadCells[x][y] = true;
  }
}

void generate(int x1, int y1) {
  for (int x=(int)random((x1 - 10), x1); x<random(x1, (x1 + 10)) && x<width/size; x++) {
    for (int y=(int)random((y1 - 6), y1); y<random(y1, (y1 + 6)) && y<height/size; y++) {
      if (x > 0 && y > 0)
        deadCells[x][y] = true;
    }
  }
}



void update() { 
  for (int x=0; x<width/size; x++) {
    for (int y=0; y<height/size; y++) {
      buffer[x][y] = cells[x][y];
      bl[x][y] = last[x][y];
      //k[x][y] = random(1.8, 2);
    }
  }

  for (int x=0; x<width/size; x++) {
    for (int y=0; y<height/size; y++) {
      for (int xx=x-1; xx<=x+1; xx++) {
        for (int yy=y-1; yy<=y+1; yy++) { 
          if (((xx>=0)&&(xx<width/size))&&((yy>=0)&&(yy<height/size))) {
            if (!((xx==x)&&(yy==y))) { 
              if ((buffer[xx][yy]==1) && deadCells[xx][yy] != true && recover[x][y] == false) {
                if (yy != y && xx != x && waitTime[x][y] > 7) {
                  waitTime[x][y] = 7;
                  waiting[x][y] = true;
                } else if ((xx == x || yy == y) && waitTime[x][y] > 5) {
                  if (xx == x)
                    waitTime[x][y] = 5;
                  if (yy == y)
                    waitTime[x][y] = 5;
                  waiting[x][y] = true;
                }




                //this is for tracking wave time
                //for (int z  = 0; z < width/size; z++) {
                //  if (cells[z][height/size - 1] == 1 && sw && going) {
                //    sx = z;
                //    System.out.println("Down Time: " + (float)millis()/1000);
                //    tmr = true;
                //    sw = false;
                //    for (int x1=0; x1<cells.length; x1++) {
                //      for (int y1=0; y1<cells[x].length; y1++) {
                //        cells[x1][y1] = 5;
                //        t[x1][y1] = 1;
                //        dt[x1][y1] = 1;
                //        last[x1][y1] = 5;
                //      }
                //    }
                //    timer = millis();
                //    //cells[(width/size)/2][height/size - 1] = 1;
                //    cells[sx][height/size - 1] = 1;
                //  }

                //  if (cells[z][0] == 1 && !sw && going) {
                //    System.out.println("Up Time: " + realTime/1000);
                //    tmr = false;
                //    going = false;
                //  }
                //}
              }
            }
          }
        }
      }

      //determine cell state
      if ((buffer[x][y]>=5 && (waitTime[x][y] < 1))) {
        cells[x][y] = 1;
        last[x][y] = 5;
        dt[x][y] = 1/(k[x][y]*sqrt(t[x][y]));
        t[x][y] = 0;
        waitTime[x][y] = 100;
        waiting[x][y] = false;
        recover[x][y] = true;
      } else if (buffer[x][y]<5 && buffer[x][y] >= 4) {
        last[x][y] = cells[x][y];
        t[x][y]++;
        cells[x][y]+= 0.1;
      } else if (buffer[x][y]<4 && buffer[x][y] >= 3) {
        last[x][y] = cells[x][y];
        t[x][y]++;
        cells[x][y]+= 0.1;
      } else if (buffer[x][y]<3 && buffer[x][y] >=2) {
        last[x][y] = cells[x][y];
        t[x][y]++;
        cells[x][y]+= 0.1;
      } else if (buffer[x][y] < 2) {
        t[x][y]++;
        last[x][y] = cells[x][y];
        cells[x][y] += dt[x][y]/2;
        //cells[x][y] += 0.1;
      } else if (buffer[x][y] >= 5) {
        last[x][y] = 5;
        t[x][y]+=0.5;
        if (recover[x][y]) {
          waitTime[x][y] = 100; 
          recover[x][y] = false;
        }
      } else if (deadCells[x][y] == true) {
        cells[x][y] = 0;
      }

      if (waiting[x][y]) {
        waitTime[x][y]--;
      }
    }
  }
}