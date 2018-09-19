Fluid fluid;
ArrayList<Leaf> leaves;
int N;

int prevMouseX;
int prevMouseY;

boolean show_menu;
ArrayList<Input> menu_list;
boolean key_log;
TextBox selected_tb;

MutableBoolean draw_dens;
MutableBoolean draw_field;

void setup() {
    N = 150;
    size(150, 150, P2D);
    pixelDensity(1);
    fluid = new Fluid(N+1);
    leaves = new ArrayList<Leaf>();

    show_menu = true;
    PVector tb_size = new PVector(50,15);
    PVector button_size = new PVector(15,15);
    menu_list = new ArrayList<Input>();
    menu_list.add(new TextBox(new PVector(5,5), tb_size, fluid.visc));
    menu_list.add(new TextBox(new PVector(5,25), tb_size, fluid.diff));
    menu_list.add(new TextBox(new PVector(5,45), tb_size, fluid.dt));
    draw_dens = new MutableBoolean(true);
    draw_field = new MutableBoolean(true);
    menu_list.add(new Button(new PVector(5,65), button_size, "D", draw_dens));
    menu_list.add(new Button(new PVector(25,65), button_size, "F", draw_field));
    key_log = false;

}

void draw() {
    background(255);
    fluid.simulate();
    fluid.draw(draw_dens.get(), draw_field.get());
    for (Leaf leaf : leaves) {
        leaf.run(0.6);
        leaf.render();
        for (Node n : leaf.nodes) {
            n.applyForce(fluid.field_vector((int)n.position.x, (int)n.position.y));
        }
    }
    if (show_menu) {
        for (Input input : menu_list) {
            input.show();
        }
    }
}

void mouseClicked() {
    if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX, mouseY, 20);
    } else if (keyPressed && key == 'd') {
        fluid.add_dens(mouseX, mouseY, 20);
    } else if (keyPressed && key == 't'){
        LSystem lsys;
        lsys = new LSystem("F", 4, 0.3926991);
        lsys.addRule(lsys.new LSystemRule("F","FF-[-F+F+F]+[+F-F-F]"));
        Leaf leaf = new Leaf(new PVector(mouseX,mouseY), 0, 0.01, 0.01, 0.1, 0.006, 0.001, 0.01, lsys);
        leaf.build();
        leaves.add(leaf);
    }
    for (Input input : menu_list) {
        if (input.within(mouseX, mouseY)) {
            if (input instanceof TextBox) {
                if (selected_tb != null) selected_tb.unselect();
                key_log = true;
                selected_tb = (TextBox)input;
                input.select();
            } else if (input instanceof Button) {
                Button button = (Button)input;
                button.change();
            }
        } else if (input.equals(selected_tb)) {
            if (input instanceof TextBox) {
                key_log = false;
                selected_tb = null;
                input.unselect();
            }
        }
    }
    prevMouseX = mouseX;
    prevMouseY = mouseY;
}

void mouseDragged() {
    if (keyPressed && key == 'v') {
        fluid.add_vector(mouseX, mouseY, prevMouseX, prevMouseY, 10);
    } else if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX, mouseY, 20);
    } else if (keyPressed && key == 'd') {
        fluid.add_dens(mouseX, mouseY, 20);
    }
    prevMouseX = mouseX;
    prevMouseY = mouseY;
}

void keyPressed() {
    if (key == 'm') {
        show_menu = !show_menu;
    }
    if (key_log) {
        selected_tb.concatText(key);
    }
}

