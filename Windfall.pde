Leaf leaf;

void setup() {
  size(640, 320);
  leaf = new Leaf();
}

void draw() {
  background(255);
  leaf.run();
}

void mousePressed() {
  leaf.nodes.get(0).position = new PVector(mouseX, mouseY);
}
