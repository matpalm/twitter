
final float MAX_TOTAL_SPEED = 200;
final float REPULSION_FORCE_FROM_GROWING_BALL = 1000;

Ball[] balls;

int epoch = 0;

void setup() {
    size(800, 600);
    smooth();
    stroke(255);
    textAlign(CENTER,CENTER);

    List v = new ArrayList();
    String codes[] = { "aus","ger","fra" };
    for(int x=1;x<9;x++) {
	for(int y=1;y<5;y++) {
	    float ball_x = width*((float)x/9);
	    float ball_y = height*((float)y/5);
	    String code = codes[(x+y)%codes.length];
	    v.add(new Ball(ball_x,ball_y,0,0,20,code));
	}
    }
    balls = new Ball[v.size()];
    v.toArray(balls);

    balls[5].growing = true;
}

boolean growing = true;

void draw() {    

    epoch++;
    background(51);

    // move balls
    for (int i=0; i<balls.length; i++){
	balls[i].tick();
	balls[i].draw();
	balls[i].checkBoundaryCollision();
    }

    // do collision checks
    for(int i=0;i<balls.length-1;i++) 
	for(int j=i+1;j<balls.length;j++) 
	    checkObjectCollision(balls[i], balls[j]);
    
    // cap max speed of all balls
    float totalSpeed = 0;
    for(int i=0;i<balls.length;i++)
	totalSpeed += balls[i].speed;
    if (totalSpeed > MAX_TOTAL_SPEED) {
	float reduceRatio = MAX_TOTAL_SPEED / totalSpeed;
	for(int i=0;i<balls.length;i++)
	    balls[i].scaleSpeedBy(reduceRatio);
    }
    
    Ball b = balls[5];
    if (b.growing) {
	b.setRadius(b.r+3);
	if (b.r > 100) {
	    b.r = 100;
	    b.growing = false;
	}
    }
    else {
	b.setRadius(b.r-2);
	if (b.r < 20) {
	    b.setRadius(20);
	    b.growing = true;
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
    
    if (bVectMag < b0.r + b1.r) {

	// only calculate and apply repulsion force when one of the orbs is growing
	// it introduces energy into system we want to limit
	boolean applyRepulsionForce = b0.growing || b1.growing;

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

	// rotate temp accelerations
	float at0x=0, at0y=0, at1x=0, at1y=0;
	if (applyRepulsionForce) {
	    at0x = cosine * b0.ddx + sine * b0.ddy;
	    at0y = cosine * b0.ddy - sine * b0.ddx;
	    at1x = cosine * b1.ddx + sine * b1.ddy;
	    at1y = cosine * b1.ddy - sine * b1.ddx;
	}

	/* Now that velocities are rotated, you can use 1D
	   conservation of momentum equations to calculate 
	   the final velocity along the x-axis. */

	// final rotated velocity for b[0]
	float vf0x = ((b0.m - b1.m) * vt0x + 2 * b1.m * vt1x) / (b0.m + b1.m);
	float vf0y = vt0y;
	// final rotated velocity for b[0]
	float vf1x = ((b1.m - b0.m) * vt1x + 2 * b0.m * vt0x) / (b0.m + b1.m);
	float vf1y = vt1y;

	// calculate overlap between balls
	float overlap = b0.r+b1.r-bVectMag;

	// push away from other ball based on amount of overlap
	float af0x=0, af0y=0, af1x=0, af1y=0;
	if (applyRepulsionForce) {
	    float forceMagnitude = overlap * REPULSION_FORCE_FROM_GROWING_BALL;
	    af0x = -forceMagnitude / b0.m;
	    af0y = -at0y;
	    af1x = forceMagnitude / b1.m;
	    af1y = at1y;	
	}

	// balls have some form of overlap so need to seperate them
	bt0x -= overlap/2;
	bt1x += overlap/2;
	
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

	// update accelerations
	if (applyRepulsionForce) {
	    b0.ddx = cosine * af0x - sine * af0y;
	    b0.ddy = cosine * af0y + sine * af0x;
	    b1.ddx = cosine * af1x - sine * af1y;
	    b1.ddy = cosine * af1y + sine * af1x;
	}
    }
}

class Ball{
    float x, y;
    float dx, dy, speed;
    float ddx, ddy;
    float r, m;
    boolean growing = false;
    String label;

    // default constructor
    Ball() {
    }

    Ball(float x, float y, float dx, float dy, float r, String label) {
	this.x = x;
	this.y = y;
	this.dx = dx;
	this.dy = dy;
	this.ddx = this.ddy = 0;
	this.r = r;
	this.label = label;
	recalcMass();
    }

    void tick() {
	dx += ddx;
	dy += ddy;
	recalcSpeed();
	x += dx;
	y += dy;	
	ddx = ddy = 0;
    }

    void draw() {
	fill(204);
	ellipse(x, y, r*2, r*2);

	fill(255, 0, 0);
	textSize(r * 0.9);
	text(label, x, y-r*0.15); // 0.15 required since vertical centre not honoured
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

    void scaleSpeedBy(float ratio) {
	dx *= ratio;
	dy *= ratio;
	recalcSpeed();
    }

    void setRadius(float r) {
	this.r = r;
	recalcMass();
    }

    void recalcMass() {
       	m = 2 * PI * (r*r);
    }

    void recalcSpeed() {
	speed = (float)sqrt(dx*dx+dy*dy);	
    }

}
