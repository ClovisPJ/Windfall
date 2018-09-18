Leaf leaf;
Fluid fluid;
int N;
boolean lock;

int prevMouseX;
int prevMouseY;

void setup() {
    lock = false;
    N = 150;
    size(151, 151, P2D);
    leaf = new Leaf(30, 70);
    fluid = new Fluid(N);
}

void draw() {
    background(255);
    lock = true;
    fluid.simulate();
    leaf.run(0.6);
    fluid.draw();
    leaf.render();
    for (Node n : leaf.nodes) {
       n.applyForce(fluid.field_vector((int)n.position.x, (int)n.position.y));
    }
    lock = false;
}

void mouseClicked() {
    if (!lock) {
        if (keyPressed == true && keyCode == CONTROL) {
            fluid.add_boundary(mouseX, mouseY, 20);
        } else {
            fluid.add_dens(mouseX, mouseY, 20);
        }
        prevMouseX = mouseX;
        prevMouseY = mouseY;
    }
}

void mouseDragged() {
    if (!lock) {
        if (keyPressed == true && keyCode == SHIFT) {
            fluid.add_vector(mouseX, mouseY, prevMouseX, prevMouseY, 10);
            //leaf.nodes.get(0).position = new PVector(mouseX, mouseY);
        } else if (keyPressed == true && keyCode == CONTROL) {
            fluid.add_boundary(mouseX, mouseY, 20);
        } else {
            fluid.add_dens(mouseX, mouseY, 20);
        }
        prevMouseX = mouseX;
        prevMouseY = mouseY;
    }
}
