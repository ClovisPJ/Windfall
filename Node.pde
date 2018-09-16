class Node extends Part {

  PVector position;
  // measured from top-left, down and across
  PVector velocity;
  PVector acceleration;
  float angle;
  // measured counter-clockwise from (1,0)
  float ang_velocity;
  float ang_acceleration;
  float mass;
  float radius;

  public Node(PVector position, float angle) {
    this.position = position;
    this.velocity = new PVector(0,0);
    this.acceleration = new PVector(0,0);
    this.angle = angle;
    this.ang_velocity = 0;
    this.ang_acceleration = 0;
    this.mass = 0.01;
    this.radius = 10;
  }

  public void applyForce(PVector force) {
    acceleration.add(force.copy().div(mass));
    acceleration.limit(1);
  }

  public void applyAngForce(float ang) {
    ang_acceleration += ang;
    constrain(ang_acceleration, -1, 1);
  }

  public void run() {
    show();
    update();
    limits();
  }

  public void update() {
    velocity.mult(0.4);
    ang_velocity *= 0.4;

    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
    ang_velocity += ang_acceleration;
    angle += ang_velocity;
    angle = angto(0, angle);
    ang_acceleration *= 0;
  }

  public void limits() {
 /*   if (position.x < -radius) position.x = width+radius;
    if (position.y < -radius) position.y = height+radius;
    if (position.x > width+radius) position.x = -radius;
    if (position.y > height+radius) position.y = -radius;*/
    if (position.x < 0) {
      position.x = 0;
      velocity.x = abs(velocity.x);
    }
    if (position.y < 0) {
      position.y = 0;
      velocity.y = abs(velocity.y);
    }
    if (position.x > width) {
      position.x = width;
      velocity.x = -1 * abs(velocity.x);
    }
    if (position.y > height) {
      position.y = height;
      velocity.y = -1 * abs(velocity.y);
    }
  }

  public void show() {
    stroke(255, 0, 0);
    float k = 80;
    line(position.x, position.y, position.x + acceleration.x*k, position.y + acceleration.y*k);
  }

}
