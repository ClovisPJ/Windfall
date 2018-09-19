Leaf leaf;
Fluid fluid;
int N;

int prevMouseX;
int prevMouseY;

ArrayList<TextBox> tb_list;
boolean key_log;
TextBox selected_tb;

void setup() {
    N = 200;
    size(200, 200, P2D);
    leaf = new Leaf(30, 70);
    fluid = new Fluid(N+1);

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
    leaf.run(0.6);
    fluid.draw();
    leaf.render();
    for (Node n : leaf.nodes) {
        n.applyForce(fluid.field_vector((int)n.position.x, (int)n.position.y));
    }
    for (TextBox tb : tb_list) {
        tb.show();
    }
}

void mouseClicked() {
    if (keyPressed == true && keyCode == CONTROL) {
        fluid.add_boundary(mouseX, mouseY, 20);
    } else {
        fluid.add_dens(mouseX, mouseY, 20);
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

void keyPressed() {
    if (key_log) {
        selected_tb.concatText(key);
    }
}
