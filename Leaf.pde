class Leaf extends Utils {

    ArrayList<Node> nodes;
    ArrayList<Joint> joints;
    LSystem lsys;

    float node_mass;
    float node_radius;
    float joint_length;
    float joint_stiffness;
    float joint_deflection;
    float joint_breaking_stress;

    public Leaf(int x, int y) {
        node_mass = 0.01;
        node_radius = 10;
        joint_length = 3;
        joint_stiffness = 0.006;
        joint_deflection = 0.001;
        joint_breaking_stress = 1;

        nodes = new ArrayList<Node>();
        joints = new ArrayList<Joint>();
        Node n = new Node(new PVector(x, y), node_mass, node_radius);
        nodes.add(n);

        lsys = new LSystem("X");
        lsys.addRule(lsys.new LSystemRule("X","F+[[X]-X]-F[-FX]+X"));
        lsys.addRule(lsys.new LSystemRule("F","FF"));
        lsys.generate(3);

        build(lsys.show(), PI/4, new PVector(x,y), 0, 0);

        /*Node n1 = new Node(new PVector(x, y), node_mass, node_radius);
        Node n2 = new Node(new PVector(x+joint_length, y), node_mass, node_radius);
        Node n3 = new Node(new PVector(x+joint_length, y+joint_length), node_mass, node_radius);
        nodes.add(n1);
        nodes.add(n2);
        nodes.add(n3);
        Joint j1 = new Joint(n1, 0, n2, PI, joint_length, joint_stiffness, joint_deflection, joint_breaking_stress);
        Joint j2 = new Joint(n2, 3*PI/2, n3, PI/2, joint_length, joint_stiffness, joint_deflection, joint_breaking_stress);
        joints.add(j1);
        joints.add(j2);*/
    }

    public void run(float energy_loss) {
        for (Node n : nodes) {
            n.run(energy_loss);
        }
        for (Joint j : joints) {
            j.run();
        }
    }

    public int build(String instr, float mod_angle, PVector turtle_position, float turtle_angle, int node_pos) {
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
                    Node node_b = new Node(turtle_position_copy, node_mass, node_radius);
                    float ang = angto(node_a.position, node_b.position);
                    Joint j = new Joint(node_a, ang, node_b, ang+PI, joint_length, joint_stiffness, joint_deflection, joint_breaking_stress);
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
        for (Joint j : joints) {
            if (j.broken) {continue;}
            PVector joint = wayto(j.left_node.position, j.right_node.position);
            draw_pointvector(j.left_node.position, joint);
            joint = wayto(j.right_node.position, j.left_node.position);
            draw_pointvector(j.right_node.position, joint);
        }
    }

}
