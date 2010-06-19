Ball[] balls =  { 
    new Ball(100, 400, 0, 0, 20), 
    new Ball(700, 600, -1, -5, 160),
    new Ball(300, 350, 0,0, 50),
    new Ball(400, 50, 0,0, 20),
    new Ball(450, 50, 0,0, 20),
    new Ball(500, 50, 0,0, 20),
    new Ball(550, 50, 0,0, 20),
    new Ball(650, 50, 0,0, 20),
    new Ball(700, 50, 0,0, 20),
    new Ball(750, 50, 0,0, 20),
    new Ball(800, 50, 0,0, 20),
    new Ball(400, 100, 0,0, 20),
    new Ball(500, 100, 0,0, 20),
    new Ball(600, 100, 0,0, 20),
    new Ball(700, 100, 0,0, 20),
    new Ball(800, 100, 0,0, 20),
    new Ball(400, 200, 0,0, 20),
    new Ball(500, 200, 0,0, 20),
    new Ball(600, 200, 0,0, 20),
    new Ball(700, 200, 0,0, 20),
    new Ball(800, 200, 0,0, 20)
};

void setup() {
    size(1000, 800);
    smooth();
    noStroke();
}

void draw() {
    background(51);
    fill(204);
    for (int i=0; i<balls.length; i++){
	balls[i].tick();
	balls[i].draw();
	balls[i].checkBoundaryCollision();
    }
    for(int i=0;i<balls.length-1;i++) {
	for(int j=i+1;j<balls.length;j++) {
	    checkObjectCollision(balls[i], balls[j]);
	}
    }
}

void checkObjectCollision(Ball b0, Ball b1) {

    // get distances between the balls components
    //PVector bVect = new PVector();
    float bvx = b1.x - b0.x;
    float bvy = b1.y - b0.y;

    // calculate magnitude of the vector separating the balls
    float bVectMag = sqrt(bvx * bvx + bvy * bvy);
    if (bVectMag < b0.r + b1.r){
	// get angle of bVect
	float theta  = atan2(bvy, bvx);
	// precalculate trig values
	float sine = sin(theta);
	float cosine = cos(theta);
	
	/* bTemp will hold rotated ball positions. You 
	   just need to worry about bTemp[1] position*/
	/* b[1]'s position is relative to b[0]'s
	   so you can use the vector between them (bVect) as the 
	   reference point in the rotation expressions.
	   bTemp[0].x and bTemp[0].y will initialize
	   automatically to 0.0, which is what you want
	   since b[1] will rotate around b[0] */
	float bt0x = 0;
	float bt0y = 0;
	float bt1x = cosine * bvx + sine * bvy;
	float bt1y = cosine * bvy - sine * bvx;

	// rotate Temporary velocities
	float vt0x = cosine * b0.dx + sine * b0.dy;
	float vt0y = cosine * b0.dy - sine * b0.dx;
	float vt1x = cosine * b1.dx + sine * b1.dy;
	float vt1y = cosine * b1.dy - sine * b1.dx;

	/* Now that velocities are rotated, you can use 1D
	   conservation of momentum equations to calculate 
	   the final velocity along the x-axis. */
	// final rotated velocity for b[0]
	float vf0x = ((b0.m - b1.m) * vt0x + 2 * b1.m * vt1x) / (b0.m + b1.m);
	float vf0y = vt0y;
	// final rotated velocity for b[0]
	float vf1x = ((b1.m - b0.m) * vt1x + 2 * b0.m * vt0x) / (b0.m + b1.m);
	float vf1y = vt1y;
	
	// hack to avoid clumping
	bt0x += vf0x;
	bt1x += vf1x;
	
	/* Rotate ball positions and velocities back
	   Reverse signs in trig expressions to rotate 
	   in the opposite direction */
	// rotate balls
	float bf0x = cosine * bt0x - sine * bt0y;
	float bf0y = cosine * bt0y + sine * bt0x;
	float bf1x = cosine * bt1x - sine * bt1y;
	float bf1y = cosine * bt1y + sine * bt1x;

	// update balls to screen position
	b1.x = b0.x + bf1x;
	b1.y = b0.y + bf1y;
	b0.x = b0.x + bf0x;
	b0.y = b0.y + bf0y;

	// update velocities
	b0.dx = cosine * vf0x - sine * vf0y;
	b0.dy = cosine * vf0y + sine * vf0x;
	b1.dx = cosine * vf1x - sine * vf1y;
	b1.dy = cosine * vf1y + sine * vf1x;
    }
}

class Ball{
    float x, y, dx, dy, r, m;

    // default constructor
    Ball() {
    }

    Ball(float x, float y, float dx, float dy, float r) {
	this.x = x;
	this.y = y;
	this.dx = dx;
	this.dy = dy;
	this.r = r;
	m = r*.1;
    }

    void tick() {
	x += dx;
	y += dy;	
    }

    void draw() {
	ellipse(x, y, r*2, r*2);
    }

    void checkBoundaryCollision() {
	if (x > width-r) {
	    x = width-r;
	    dx *= -1;
	} 
	else if (x < r) {
	    x = r;
	    dx *= -1;
	} 
	if (y > height-r) {
	    y = height-r;
	    dy *= -1;
	} 
	else if (y < r) {
	    y = r;
	    dy *= -1;
	}
    }

}
