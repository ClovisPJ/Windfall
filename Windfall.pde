Leaf leaf;
Fluid fluid;
int N;
boolean lock;

void setup() {
  lock = false;
  N = 200;
  size(201, 201, P2D);
  leaf = new Leaf(100, 100);
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
  if (!lock) {
    if (keyPressed == true && keyCode == SHIFT) {
      fluid.add_dens(mouseX, mouseY, 20);
    } else if (keyPressed == true && keyCode == CONTROL) {
      fluid.add_boundary(mouseX, mouseY, 20);
    } else {
      //fluid.divergence(mouseX, mouseY, 20);
      leaf.nodes.get(0).position = new PVector(mouseX, mouseY);
    }
  }
}
