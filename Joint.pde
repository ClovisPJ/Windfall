class Joint {

  Node left;
  float left_ang;
  Node right;
  float right_ang;
  float length;
  float stiffness;
  float deflection;

  public Joint(Node left, float left_ang, Node right, float right_ang, float length) {
    this.left = left;
    this.left_ang = left_ang;
    this.right = right;
    this.right_ang = right_ang;
    this.length = length;
    this.stiffness = 0.05;
    this.deflection = 0.5;
  }

  public void run() {
    tension();
    shear();
  }

  public void tension() {
    PVector force = wayto(left.position, right.position);
    force.sub(force.copy().normalize().mult(length)).mult(stiffness);
    left.applyForce(force);
    right.applyForce(force.mult(-1));
  }

  public void shear() {
    // TODO fix wierd problem where angle flips through 0
    float angle;
    angle = wayto(left.position, right.position).heading();
    angle -= (left.angle + left_ang);
    left.applyAngForce(angle*deflection);
    right.applyForce(wayto(left.position, right.position).normalize().rotate(-1*HALF_PI).mult(angle*deflection));
    angle = wayto(right.position, left.position).heading();
    angle -= (right.angle + right_ang);
    right.applyAngForce(angle*deflection);
    left.applyForce(wayto(right.position, left.position).normalize().rotate(-1*HALF_PI).mult(angle*deflection));
  }

  public PVector wayto(PVector from, PVector to) {
    return PVector.sub(to, from);
  }

}
