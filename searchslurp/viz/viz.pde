
final float MAX_TOTAL_SPEED = 50;
final float REPULSION_FORCE_FROM_GROWING_BALL = 1000;
final int TICKS_PER_HOUR = 10; // ticks in simulation ticks, hours from load data
final float MIN_BALL_SIZE = 2;

float TOTAL_AREA = 0; // across all balls

Ball[] balls;
Map ballsByCode = new HashMap();

int tick = 0;

void setup() {
    size(800, 600);
    smooth();
    stroke(255);
    textAlign(CENTER,CENTER);

    List v = new ArrayList();
    int c = 0;
    for(int col=1;col<9;col++) {
	for(int row=1;row<5;row++) {
	    float x = width*((float)col/9) + random(-5,5);
	    float y = height*((float)row/5) + random(-5,5);
	    float r = 20;
	    Ball b = new Ball(x,y, 0,0, r, codes[c]);
	    v.add(b);
	    ballsByCode.put(b.label,b);
	    TOTAL_AREA += PI * r * r;
	    c++;
	}
    }
    balls = new Ball[v.size()];
    v.toArray(balls);

    loadSizeDataIntoBalls();
    loadEdgeDataIntoBalls();

}

void draw() {        
    background(51);

    /*
    float[] r = (float[])records.get("alg");
    for (int i=0;i<r.length;i++) {
	System.out.println("r["+i+"]="+r[i]);
    }
    */

    // set target ball sizes!
    if (tick%TICKS_PER_HOUR==0) {
	int idx = tick/TICKS_PER_HOUR;
	//	System.out.println("tick="+tick+" idx="+idx);
	for (int i=0; i<balls.length; i++) {
	    balls[i].setTargetSizeForRecord(idx);
	}
    }

    // move balls
    for (int i=0; i<balls.length; i++) {
	balls[i].tick();
	balls[i].checkBoundaryCollision();
	balls[i].resize();
    }

    // draw connectors, then balls themselves
    for (int i=0; i<balls.length; i++) {
	balls[i].drawConnectors();
    }
    for (int i=0; i<balls.length; i++) {
	balls[i].drawSelf();
    }

    // do collision checks
    for(int i=0;i<balls.length-1;i++) {
	for(int j=i+1;j<balls.length;j++) {
	    checkObjectCollision(balls[i], balls[j]);
	}
    }
    
    // cap max speed of all balls
    float totalSpeed = 0;
    for(int i=0;i<balls.length;i++) {
	totalSpeed += balls[i].speed;
    }
    if (totalSpeed > MAX_TOTAL_SPEED) {
	float reduceRatio = MAX_TOTAL_SPEED / totalSpeed;
	for(int i=0;i<balls.length;i++) {
	    balls[i].scaleSpeedBy(reduceRatio);
	}
    }

    // change sizes
    for(int i=0;i<balls.length;i++) {

    }

    tick++;

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

    float radiusDeltaPerTick;
    float[] targetProportion;

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

    void drawConnectors() {

    }

    void drawSelf() {
	fill(204);
	ellipse(x, y, r*2, r*2);

	fill(255, 0, 255);
	float textSize = r * 0.9;
	if (textSize<20) textSize = 20;
	textSize(textSize);
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

    void resize() {
	r += radiusDeltaPerTick;
	if (r<MIN_BALL_SIZE) { r=MIN_BALL_SIZE; }
	growing = (radiusDeltaPerTick > 0);
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

    void setTargetSizeForRecord(int recordIdx) {
	// calculate target radius to move towards for next HOURS worth of TICKS
	float targetArea = TOTAL_AREA * targetProportion[recordIdx];
	float targetRadius = (float)sqrt(targetArea/PI);
	radiusDeltaPerTick = (targetRadius - r) / TICKS_PER_HOUR;
    }

}
