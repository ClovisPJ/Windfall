class Node {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float angle;
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
    this.mass = 1;
    this.radius = 80;
  }

  public void applyForce(PVector force) {
    acceleration.add(force.copy().div(mass).limit(1));
  }

  public void applyAngForce(float ang) {
    ang_acceleration += ang;
  }

  public void run() {
    update();
    limits();
  }

  public void update() {
    velocity.mult(0.9);
    ang_velocity *= 0.9;

    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
    ang_velocity += ang_acceleration;
    angle += ang_velocity;
    ang_acceleration *= 0;
  }

  public void limits() {
    if (position.x < -radius) position.x = width+radius;
    if (position.y < -radius) position.y = height+radius;
    if (position.x > width+radius) position.x = -radius;
    if (position.y > height+radius) position.y = -radius;
    angle %= (2 * PI);
  }

}
