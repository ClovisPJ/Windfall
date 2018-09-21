class Leaf extends Utils {

    ArrayList<Node> nodes;
    ArrayList<Joint> joints;
    LSystem lsys;

    PVector location;
    float ang;

    float node_mass;
    float node_radius;
    float joint_length;
    float joint_stiffness;
    float joint_deflection;
    float joint_breaking_stress;

    //TODO clear args up, make mutable vars
    public Leaf(int[] size, int scale, PVector location, float ang, float node_mass, float node_radius, float joint_length, float joint_stiffness, float joint_deflection, float joint_breaking_stress, LSystem lsys) {
        super(size, scale);

        this.location = location;
        this.ang = ang;
        this.node_mass = node_mass;
        this.node_radius = node_radius;
        this.joint_length = joint_length;
        this.joint_stiffness = joint_stiffness;
        this.joint_deflection = joint_deflection;
        this.joint_breaking_stress = joint_breaking_stress;
        this.lsys = lsys;

        nodes = new ArrayList<Node>();
        joints = new ArrayList<Joint>();
        nodes.add(new Node(size, scale, location, node_mass, node_radius));
    }

    public void build() {
        lsys.generate();
        build(lsys.show(), lsys.mod_ang(), location, ang, 0);
    }

    public void run(float energy_loss) {
        for (Node n : nodes) {
            n.run(energy_loss);
        }
        for (Joint j : joints) {
            j.run();
        }
    }

    private int build(String instr, float mod_angle, PVector turtle_position, float turtle_angle, int node_pos) {
        assert(instr != null || instr.length() > 0);
        PVector turtle_position_copy = turtle_position.copy();
        int len = 0;
        int skip = 0;
        for (char cmd : instr.toCharArray()) {
            len++;
            if (skip > 0) {skip--; continue;}
            switch (cmd) {
                case '[':
                    skip = build(instr.substring(len), mod_angle, turtle_position_copy, turtle_angle, node_pos);
                    break;
                case ']':
                    return len;
                case 'F':
                    turtle_position_copy.add(new PVector(joint_length,0).rotate(turtle_angle));
                    Node node_a = nodes.get(node_pos);
                    node_pos = nodes.size();
                    Node node_b = new Node(size, scale, turtle_position_copy, node_mass, node_radius);
                    float ang = angto(node_a.position, node_b.position);
                    Joint j = new Joint(size, scale, node_a, ang, node_b, ang+PI, joint_length, joint_stiffness, joint_deflection, joint_breaking_stress);
                    nodes.add(node_b);
                    joints.add(j);
                    break;
                case '-':
                    turtle_angle += mod_angle;
                    break;
                case '+':
                    turtle_angle -= mod_angle;
                    break;
                default:
                    break;
            }
        }
        return len + 1; // incase bracket did not close
    }

    public void render() {
        // METHOD 1 BALL JOINTS
        /*for (Node n : nodes) {
            stroke(0);
            strokeWeight(1);
            ellipse(n.position.x, n.position.y, n.radius*2, n.radius*2); 

            stroke(255,0,0);
            float k = 100;
            line(n.position.x, n.position.y, n.position.x + n.acceleration.x*k, n.position.y + n.acceleration.y*k);
        }
        for (Joint j : joints) {
            if (j.broken) {continue;}
            PVector left_point = PVector.add(j.left_node.position,
                                             new PVector(j.left_node.radius,0)
                                                 .rotate(-1*(j.left_node.angle+j.joint_true_left_ang)) );
            PVector right_point = PVector.add(j.right_node.position,
                                             new PVector(j.right_node.radius,0)
                                                 .rotate(-1*(j.right_node.angle+j.joint_true_right_ang)) );
            stroke(0,255,0);
            strokeWeight(1);
            line(left_point.x, left_point.y, right_point.x, right_point.y);
        }*/
        // METHOD 2 LINES
        /*
        for (Joint j : joints) {
            if (j.broken) {continue;}
            PVector joint = wayto(j.left_node.position, j.right_node.position);
            draw_pointvector(j.left_node.position, joint);
            joint = wayto(j.right_node.position, j.left_node.position);
            draw_pointvector(j.right_node.position, joint);
        }*/
        // METHOD 3 LINES AND POINTS
        for (Node n : nodes) {
            draw_point(n.position);
        }
        for (Joint j : joints) {
            if (j.broken) {continue;}
            draw_vector(j.left_node.position, j.right_node.position);
        }
    }

}
