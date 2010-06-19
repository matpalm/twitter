int size = 60;       // Width of the shape
float xpos, ypos;    // Starting position of shape    

float xspeed = 2.8;  // Speed of the shape
float yspeed = 2.2;  // Speed of the shape

int xdirection = 1;  // Left or Right
int ydirection = 1;  // Top to Bottom

Ball[] balls = {
    new Ball(100,400,20,"ger"),
    new Ball(400,100,30,"aus")
};

void setup() 
{
    size(640, 480);
    stroke(255);

    frameRate(30);
    smooth();
    // Set the starting position of the shape
    //xpos = width/2;
    //ypos = height/2;

    balls[0].edgesTo = new Ball[] { balls[1] };
}

void draw() {
    background(102);

    for(int i=0;i<2;i++) {
	balls[i].drawEdges();
	balls[i].draw();
    }
  
    /*
    // Update the position of the shape
    xpos = xpos + ( xspeed * xdirection );
    ypos = ypos + ( yspeed * ydirection );
  
    // Test to see if the shape exceeds the boundaries of the screen
    // If it does, reverse its direction by multiplying by -1
    if (xpos > width-size || xpos < 0) {
	xdirection *= -1;
    }
    if (ypos > height-size || ypos < 0) {
	ydirection *= -1;
    }

    // Draw the shape
    ellipse(xpos+size/2, ypos+size/2, size, size);

    try {
	Thread.sleep(100);
    }	
    catch (Exception e) {
    }
    */

}

class Ball {
    float x,y,r;
    String text;
    Ball[] edgesTo;

    Ball(float x, float y, float r, String text) {
 	this.x = x;
 	this.y = y;
 	this.r = r;
 	this.text = text;
    }   
    
    void drawEdges() {
	if (edgesTo!=null) {
	    for(int i=0;i<edgesTo.length;i++) {
		line(x, y, edgesTo[i].x, edgesTo[i].y);
	    }
	}	
    }

    void draw() {
	//stroke(255);
	fill(255);
	ellipse(x,y,r*2,r*2);
	fill(100);
	text(text, x-10, y+2);
    }
}