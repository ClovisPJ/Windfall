class Leaf {

  ArrayList<Node> nodes;
  ArrayList<Joint> joints;

  public Leaf() {
    nodes = new ArrayList<Node>();
    joints = new ArrayList<Joint>();
    Node n1 = new Node(new PVector(100,100), 0);
    Node n2 = new Node(new PVector(110,100), 0);
    Node n3 = new Node(new PVector(120,100), 0);
    nodes.add(n1);
    nodes.add(n2);
    nodes.add(n3);
    Joint j1 = new Joint(n1, 0, n2, PI, 10);
    Joint j2 = new Joint(n2, 0, n3, PI, 10);
    joints.add(j1);
    joints.add(j2);
  }

  public void run() {
    for (Node n : nodes) {
      n.run();
    }
    for (Joint j : joints) {
      j.run();
    }
  }

  public void render() {
    stroke(0);
    fill(0);
    for (Node n : nodes) {
      pushMatrix();
      translate(n.position.x, n.position.y);
      ellipse(0,0,20,20);
      popMatrix();
    }
  }

}
