class Joint extends Utils {

    Node left_node;
    float joint_true_left_ang;
    Node right_node;
    float joint_true_right_ang;
    float length;
    float stiffness;
    float deflection;

    float breaking_stress;
    boolean broken;

    public Joint(Node left_node, float joint_true_left_ang, Node right_node, float joint_true_right_ang, float length, float stiffness, float deflection, float breaking_stress) {
        this.left_node = left_node;
        this.joint_true_left_ang = joint_true_left_ang;
        this.right_node = right_node;
        this.joint_true_right_ang = joint_true_right_ang;
        this.length = length;
        this.stiffness = stiffness;
        this.deflection = deflection;
        this.breaking_stress = breaking_stress;
        broken = false;
    }

    public void run() {
        if (broken) return;
        tension();
        shear();
    }

    public void tension() {
        PVector force = wayto(left_node.position, right_node.position);
        force.sub(force.copy().normalize().mult(length)).mult(stiffness);
        if (force.mag() > breaking_stress) {broken = true; println("JOINT BROKEN"); return;}
        left_node.applyForce(force);
        right_node.applyForce(force.mult(-1));
    }

    public void shear() {
        float angle;
        angle = angto(left_node.position, right_node.position);
        angle = angto(left_node.angle, angle);
        angle = angto(joint_true_left_ang, angle);
        left_node.applyAngForce(angle*deflection);
        right_node.applyForce(wayto(left_node.position, right_node.position).normalize().rotate(HALF_PI).mult(angle*deflection*1/length));
        angle = angto(right_node.position, left_node.position);
        angle = angto(right_node.angle, angle);
        angle = angto(joint_true_right_ang, angle);
        right_node.applyAngForce(angle*deflection);
        left_node.applyForce(wayto(right_node.position, left_node.position).normalize().rotate(HALF_PI).mult(angle*deflection*1/length));
    }
}
