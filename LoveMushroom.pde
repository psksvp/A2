//////////////////////////////////////////////////////////
// LoveMushroom 
// by pongsak.suvanpong@mq.edu.au
//////////////////////////////////////////////////////////

/////////////////////////////////////////////
///// configuration
/////////////////////////////////////////////
final int NROW = 7;
final int NCOL = 7;
final int marginX = 10;
final int marginY = 90;
float gridWidth, gridHeight;
float cellWidth, cellHeight;

/////////////////////////////////////////////
///// states constant
/////////////////////////////////////////////
final int sCleared = -1;
final int sSporing = 0;
final int sRooting = 1;
final int sG1 = 2;
final int sG2 = 3;
final int sG3 = 4;
final int sG4 = 5;
final int sReady = 6;
final int sDead = 7;
final int sEmpty = 8;


/////////////////////////////////////////////
///// game state
/////////////////////////////////////////////
int[][] cellState = new int[NROW][NCOL];
int[][] cellSeedTime = new int[NROW][NCOL];
float[][] cellMoisture = new float[NROW][NCOL];
int money = 200;
int oneDay = 500;

/////////////////////////////////////////////
///// basic information
/////////////////////////////////////////////
int today()
{
  return frameCount / oneDay;
}

int focusCol()
{
  if(mouseX > marginX && mouseX < marginX + gridWidth)
    return (int)((mouseX - marginX) / cellWidth);
  else
    return -1;
}

int focusRow()
{
  if(mouseY > marginY && mouseY < marginY + gridHeight)
    return (int)((mouseY - marginY) / cellHeight);
  else
    return -1;
}

/////////////////////////////////////////////
///// drawing
/////////////////////////////////////////////
void drawBoard()
{
  for(int r = 0; r < NROW; r = r + 1)
  {
    for(int c = 0; c < NCOL; c = c + 1)
    {
      drawCell(r, c);
    }
  }
}

void drawCell(int r, int c)
{
  float x = marginX + (c * cellWidth);
  float y = marginY + (r * cellHeight);
  drawMushroom(x, y, cellWidth, cellHeight, cellState[r][c]);
  if(focusCol() == c && focusRow() == r)
    drawFocus(x, y);
}

void drawFocus(float x, float y)
{
  strokeWeight(2);
  stroke(0, 0, 255);
  noFill();  
  rect(x, y, cellWidth, cellHeight); 
  fill(255);
  strokeWeight(0);
  stroke(0);
}

void drawStatus()
{
  fill(0, 255, 0);
  rect(10, 10, width - 20, 75);
  textAlign(CENTER, CENTER);
  textSize(18);
  fill(0);
  text("Author:Pongsak Suvanpong", width / 2, 18);
  String s = "Money:" + money + "  currentDay:" + today();
  text(s, width / 2, 40);
  int r = focusRow();
  int c = focusCol();
  if(-1 != r && -1 != c)
  {
    textSize(15);
    String[] sName = {"Sporing", "Rooting", "G1", "G2", "G3", "G4", "Ready", "Dead", "Empty"};
    String currentState = -1 == cellState[r][c] ? "Cleared" : sName[cellState[r][c]];
    s = "Focus: (" + r + ", " + c + "), state: " + currentState + ", moisture: " + cellMoisture[r][c];
    text(s, width / 2, 70);
  }
  fill(255);
}


/////////////////////////////////////////////
///// game logic information
/////////////////////////////////////////////
boolean isOneDay()
{
  return frameCount % oneDay == 0;
}

boolean notClearedAndNotEmpty(int r, int c)
{
  return cellState[r][c] != sCleared && 
         cellState[r][c] != sEmpty;
}

boolean shouldChangeState(int r, int c)
{
  return 0 == (frameCount - cellSeedTime[r][c]) % oneDay; 
}

boolean suitableMoisture(int r, int c)
{
  return cellMoisture[r][c] >= 20 && cellMoisture[r][c] <= 90;
}

/////////////////////////////////////////////
///// growing
/////////////////////////////////////////////
void basicGrower()
{
  for(int r = 0; r < NROW; r = r + 1)
  {
    for(int c = 0; c < NCOL; c = c + 1)
    {
      if(isOneDay() && notClearedAndNotEmpty(r, c))
      {
        cellState[r][c] = cellState[r][c] + 1;
      }
    }
  }
}

void intermediateGrower()
{
  for(int r = 0; r < NROW; r = r + 1)
  {
    for(int c = 0; c < NCOL; c = c + 1)
    {
      if(shouldChangeState(r, c) && notClearedAndNotEmpty(r, c))
      {
        cellState[r][c] = cellState[r][c] + 1;
      }
    }
  }
}

void advanceGrower()
{
  for(int r = 0; r < NROW; r = r + 1)
  {
    for(int c = 0; c < NCOL; c = c + 1)
    {
      if(shouldChangeState(r, c) && notClearedAndNotEmpty(r, c))
      {
        if(cellState[r][c] == sDead)
          cellState[r][c] = sEmpty;
        else 
        {
          if(suitableMoisture(r, c))
            cellState[r][c] = cellState[r][c] + 1;
          else
            cellState[r][c] = sDead;
        }
      }
    }
  }
}

void decreaseMoisture()
{
  for(int r = 0; r < NROW; r = r + 1)
  {
    for(int c = 0; c < NCOL; c = c + 1)
    {
      if(notClearedAndNotEmpty(r, c))
      {
        cellMoisture[r][c] = cellMoisture[r][c] - 3;
        if(cellMoisture[r][c] < 0.0)
          cellMoisture[r][c] = 0.0;
      }
    }
  }
}


/////////////////////////////////////////////
///// init basic
/////////////////////////////////////////////
void init()
{
  gridWidth = width - 20;
  gridHeight = height - 100;
  cellWidth = gridWidth / NCOL;
  cellHeight = gridHeight / NROW;
  for(int r = 0; r < NROW; r = r + 1)
  {
    for(int c = 0; c < NCOL; c = c + 1)
    {
      cellState[r][c] = sCleared;
      cellSeedTime[r][c] = -1;
      cellMoisture[r][c] = 0.0;
    }
  }
}

/////////////////////////////////////////////
///// actions on a cell
/////////////////////////////////////////////
void doWatering(int r, int c)
{
  if(notClearedAndNotEmpty(r, c) && 
     money - 2 >= 0 && 
     cellMoisture[r][c] + 30 < 100)
  {
    cellMoisture[r][c] = cellMoisture[r][c] + 30;
    money = money - 2;
    println("money ", money);
  }
}

void doHarvesting(int r, int c)
{
  int d = cellState[r][c];
  if(d == sReady)
  {
    cellState[r][c] = sEmpty;
    money = money + 20;
    println("money ", money);
  }
}

void doClearing(int r, int c)
{
  int d = cellState[r][c];
  if(d == sEmpty && money - 2 >= 0)
  {
    cellState[r][c] = sCleared;
    money = money - 2;
  }
}

void doSeeding(int r, int c)
{
  int d = cellState[r][c];
  if(d == sCleared && money - 10 >= 0)
  {
    cellState[r][c] = sSporing;
    cellSeedTime[r][c] = frameCount;
    cellMoisture[r][c] = 50.0;
    money = money - 10;
  }
}


/////////////////////////////////
///Events handling
/////////////////////////////////
void setup()
{
  size(400, 600);
  init();
}

void draw()
{
  background(255);
  drawStatus();
  drawBoard();
  //basicGrower();
  //intermediateGrower();
  advanceGrower();
  if(isOneDay())
    decreaseMoisture();
}

void mousePressed()
{  
  println("focus row " + focusRow());
  println("focus col " + focusCol());
}

void keyPressed()
{
  int r = focusRow();
  int c = focusCol();
  if(r != -1 && c!= -1)
  {
    if('s' == key)
      doSeeding(r, c);
    else if('h' == key)
      doHarvesting(r, c);
    else if('c' == key)
      doClearing(r, c);
    else if('w' == key)
      doWatering(r, c);
  }
}
