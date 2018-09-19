Fluid fluid;
ArrayList<Leaf> leaves;
int N;

int prevMouseX;
int prevMouseY;

ArrayList<TextBox> tb_list;
boolean key_log;
TextBox selected_tb;

void setup() {
    N = 400;
    size(400, 400, P2D);
    pixelDensity(1);
    fluid = new Fluid(N+1);
    leaves = new ArrayList<Leaf>();

    PVector tb_size = new PVector(50,15);
    tb_list = new ArrayList<TextBox>();
    tb_list.add(new TextBox(new PVector(5,5), tb_size, fluid.visc));
    tb_list.add(new TextBox(new PVector(5,25), tb_size, fluid.diff));
    tb_list.add(new TextBox(new PVector(5,45), tb_size, fluid.dt));

    key_log = false;
}

void draw() {
    background(255);
    fluid.simulate();
    fluid.draw();
    for (Leaf leaf : leaves) {
        leaf.run(0.6);
        leaf.render();
        for (Node n : leaf.nodes) {
            n.applyForce(fluid.field_vector((int)n.position.x, (int)n.position.y));
        }
    }
    for (TextBox tb : tb_list) {
        tb.show();
    }
}

void mouseClicked() {
    if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX, mouseY, 20);
    } else if (keyPressed && key == 'd') {
        fluid.add_dens(mouseX, mouseY, 20);
    } else {
        leaves.add(new Leaf(mouseX, mouseY));
    }
    prevMouseX = mouseX;
    prevMouseY = mouseY;

    for (TextBox tb : tb_list) {
        if (tb.within(mouseX, mouseY)) {
            if (selected_tb != null) selected_tb.unselect();
            tb.select();
            selected_tb = tb;
            key_log = true;
        } else if (tb.equals(selected_tb)) {
            key_log = false;
            tb.unselect();
            selected_tb = null;
        }
    }
}

void mouseDragged() {
    if (keyPressed && key == 'v') {
        fluid.add_vector(mouseX, mouseY, prevMouseX, prevMouseY, 10);
    } else if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX, mouseY, 20);
    } else if (keyPressed && key == 'd') {
        fluid.add_dens(mouseX, mouseY, 20);
    } else {
        leaves.add(new Leaf(mouseX, mouseY));
    }
    prevMouseX = mouseX;
    prevMouseY = mouseY;
}

void keyPressed() {
    if (key_log) {
        selected_tb.concatText(key);
    }
}
