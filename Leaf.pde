class Leaf extends Part {

  ArrayList<Node> nodes;
  ArrayList<Joint> joints;
  LSystem lsys;

  public Leaf(int x, int y) {
    nodes = new ArrayList<Node>();
    joints = new ArrayList<Joint>();
    /*Node n1 = new Node(new PVector(x, y), 0);
    Node n2 = new Node(new PVector(x+30, y), 0);
    Node n3 = new Node(new PVector(x+30, y+30), 0);
    nodes.add(n1);
    nodes.add(n2);
    nodes.add(n3);
    Joint j1 = new Joint(n1, 0, n2, PI, 30);
    Joint j2 = new Joint(n2, 3*PI/2, n3, PI/2, 30);
    joints.add(j1);
    joints.add(j2);*/
    Node n = new Node(new PVector(x, y), 0);
    nodes.add(n);
    lsys = new LSystem("X", 1);
    lsys.addRule(lsys.new LSystemRule("X","F+[[X]-X]-F[-FX]+X"));
    lsys.addRule(lsys.new LSystemRule("F","FF"));
    lsys.generate();
    build(lsys.show(), 20, PI/4, new PVector(0,0), 0);
  }

  public void run() {
    for (Node n : nodes) {
      n.run();
    }
    for (Joint j : joints) {
      j.run();
    }
  }

  public int build(String instr, float size, float mod_angle, PVector turtle_position, float turtle_angle) {
      assert(instr != null || instr.length() > 0);
      int len = 0;
      int skip = 0;
      for (char cmd : instr.toCharArray()) {
          len++;
          if (skip > 0) {skip--; continue;}
          switch (cmd) {
              case '[':
                  skip = build(instr.substring(len), size, mod_angle, turtle_position, turtle_angle);
                  break;
              case ']':
                  return len;
              case 'F':
                  turtle_position.add(new PVector(size,0).rotate(turtle_angle));
                  Node node_a = nodes.get(nodes.size()-1);
                  Node node_b = new Node(turtle_position, 0);
                  // TODO ang needs to be sorted out
                  float ang = wayto(node_a.position, node_b.position).heading();
                  Joint j = new Joint(node_a, ang, node_b, ang+PI, size);
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
      stroke(0);
      fill(0);
      for (Joint j : joints) {
          line(j.left.position.x, j.left.position.y, j.right.position.x, j.right.position.y);
      }
  }

}
