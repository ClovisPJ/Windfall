class Joint extends Part {

  Node left;
  float left_ang;
  Node right;
  float right_ang;
  float length;
  float stiffness;
  float deflection;

  float breaking_stress;
  boolean broken;

  public Joint(Node left, float left_ang, Node right, float right_ang, float length) {
    this.left = left;
    this.left_ang = left_ang;
    this.right = right;
    this.right_ang = right_ang;
    this.length = length;
    stiffness = 0.06;
    deflection = 0.01;
    breaking_stress = 10;
    broken = false;
  }

  public void run() {
    if (broken) return;
    tension();
    shear();
  }

  public void tension() {
    PVector force = wayto(left.position, right.position);
    force.sub(force.copy().normalize().mult(length)).mult(stiffness);
    if (force.mag() > breaking_stress) {broken = true; return;}
    left.applyForce(force);
    right.applyForce(force.mult(-1));
  }

  public void shear() {
    float angle;
    angle = -1 * wayto(left.position, right.position).heading();
    angle = angto(left.angle, angle);
    angle = angto(left_ang, angle);
    left.applyAngForce(angle*deflection);
    right.applyForce(wayto(left.position, right.position).normalize().rotate(-1*HALF_PI).mult(angle*deflection));
    angle = -1 * wayto(right.position, left.position).heading();
    angle = angto(right.angle, angle);
    angle = angto(right_ang, angle);
    right.applyAngForce(angle*deflection);
    left.applyForce(wayto(right.position, left.position).normalize().rotate(-1*HALF_PI).mult(angle*deflection));
  }

}
