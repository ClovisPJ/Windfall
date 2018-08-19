Leaf leaf;
Fluid fluid;
int N;
boolean lock;

void setup() {
  lock = false;
  N = 150;
  size(151, 151, P2D);
  leaf = new Leaf();
  fluid = new Fluid(N);
}

void draw() {
  background(255);
  lock = true;
  fluid.simulate();
  leaf.run();
  fluid.draw();
  leaf.render();
  for (Node n : leaf.nodes) {
    n.applyForce(fluid.field_vector((int)n.position.x, (int)n.position.y));
  }
  lock = false;
}

void mouseClicked() {
//  leaf.nodes.get(0).position = new PVector(mouseX, mouseY);
  if (!lock) {
    if (keyPressed == true && keyCode == SHIFT) {
      fluid.add(mouseX, mouseY, 20);
    } else {
      fluid.divergence(mouseX, mouseY, 20);
    }
  }
}
