class Leaf extends Part {

    ArrayList<Node> nodes;
    ArrayList<Joint> joints;
    LSystem lsys;

    float node_mass;
    float node_radius;

    float joint_stiffness;
    float joint_deflection;
    float joint_breaking_stress;

    public Leaf(int x, int y) {
        node_mass = 3;
        node_mass = 0.01;
        joint_stiffness = 0.06;
        joint_deflection = 0.01;
        joint_breaking_stress = 0.0001;

        nodes = new ArrayList<Node>();
        joints = new ArrayList<Joint>();
        Node n = new Node(new PVector(x, y), node_mass, node_radius);
        nodes.add(n);

        lsys = new LSystem("X");
        lsys.addRule(lsys.new LSystemRule("X","F+[[X]-X]-F[-FX]+X"));
        lsys.addRule(lsys.new LSystemRule("F","FF"));
        lsys.generate(3);

        build(lsys.show(), 3, PI/4, new PVector(x,y), 0, 0);
    }

    public void run(float energy_loss) {
        for (Node n : nodes) {
            n.run(energy_loss);
        }
        for (Joint j : joints) {
            j.run();
        }
    }

    public int build(String instr, float size, float mod_angle, PVector turtle_position, float turtle_angle, int node_pos) {
        assert(instr != null || instr.length() > 0);
        PVector turtle_position_copy = turtle_position.copy();
        int len = 0;
        int skip = 0;
        for (char cmd : instr.toCharArray()) {
            len++;
            if (skip > 0) {skip--; continue;}
            switch (cmd) {
                case '[':
                    skip = build(instr.substring(len), size, mod_angle, turtle_position_copy, turtle_angle, node_pos);
                    break;
                case ']':
                    return len;
                case 'F':
                    turtle_position_copy.add(new PVector(size,0).rotate(turtle_angle));
                    Node node_a = nodes.get(node_pos);
                    node_pos = nodes.size();
                    Node node_b = new Node(turtle_position_copy, node_mass, node_radius);
                    float ang = angto(node_a.position, node_b.position);
                    Joint j = new Joint(node_a, ang, node_b, ang+PI, size, joint_stiffness, joint_deflection, joint_breaking_stress);
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
        /* METHOD 1 BALL JOINTS
        for (Node n : nodes) {
            stroke(0);
            strokeWeight(1);
            ellipse(n.position.x, n.position.y, n.radius*2, n.radius*2); 

            stroke(255,0,0);
            float k = 80;
            line(n.position.x, n.position.y, n.position.x + n.acceleration.x*k, n.position.y + n.acceleration.y*k);
        }
        for (Joint j : joints) {
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
            stroke(0,255,0);
            strokeWeight(1);
            line(j.left_node.position.x, j.left_node.position.y, j.right_node.position.x, j.right_node.position.y);
        }
    }

}
