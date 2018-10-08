import java.util.ListIterator;

Fluid fluid;
ArrayList<Leaf> leaves;

int[] size;
int scale;

int prevMouseX;
int prevMouseY;

boolean show_menu;
ArrayList<Input> menu_list;
boolean key_log;
NumberBox selected_nb;
ColorPicker selected_cp;

MutableBoolean draw_dens;
MutableBoolean draw_field_length_arrows;
MutableBoolean draw_field_norm_arrows;
MutableColor leaf_vector_color;
MutableColor leaf_point_color;
MutableFloat pusher_force;

void setup() {
    size = new int[] {125, 125};
    scale = 4;
    size(500, 500, P2D);
    fluid = new Fluid(size, scale);
    leaves = new ArrayList<Leaf>();
    leaf_vector_color = new MutableColor(color(0));
    leaf_point_color = new MutableColor(color(0));
    pusher_force = new MutableFloat(10);

    show_menu = true;
    PVector menu_item_size = new PVector(80,15);
    PVector button_size = new PVector(15,15);
    menu_list = new ArrayList<Input>();
    menu_list.add(new NumberBox(new PVector(5,5), menu_item_size, "Visc", fluid.visc));
    menu_list.add(new NumberBox(new PVector(5,25), menu_item_size, "Diff", fluid.diff));
    menu_list.add(new NumberBox(new PVector(5,45), menu_item_size, "Tstep", fluid.dt));
    menu_list.add(new NumberBox(new PVector(5,65), menu_item_size, "Pusher", pusher_force));
    menu_list.add(new NumberBox(new PVector(5,85), menu_item_size, "Push S", fluid.pusher_scale));
    menu_list.add(new NumberBox(new PVector(5,105), menu_item_size, "Dens S", fluid.density_scale));
    menu_list.add(new NumberBox(new PVector(5,125), menu_item_size, "Field S", fluid.field_scale));
    menu_list.add(new ColorButton(new PVector(5,145), menu_item_size, "Field", fluid.field_color));
    menu_list.add(new ColorButton(new PVector(5,165), menu_item_size, "Dens A", fluid.dens_start_color));
    menu_list.add(new ColorButton(new PVector(5,185), menu_item_size, "Dens B", fluid.dens_end_color));
    menu_list.add(new ColorButton(new PVector(5,205), menu_item_size, "Joint", leaf_vector_color));
    menu_list.add(new ColorButton(new PVector(5,225), menu_item_size, "Node", leaf_point_color));
    draw_dens = new MutableBoolean(true);
    draw_field_length_arrows = new MutableBoolean(false);
    draw_field_norm_arrows = new MutableBoolean(true);
    menu_list.add(new Button(new PVector(5,245), button_size, "D", draw_dens));
    menu_list.add(new Button(new PVector(25,245), button_size, "A", draw_field_length_arrows));
    menu_list.add(new Button(new PVector(45,245), button_size, "N", draw_field_norm_arrows));
    key_log = false;
}

void draw() {
    background(255);
    fluid.simulate();
    fluid.draw(draw_dens.get(), draw_field_length_arrows.get(), draw_field_norm_arrows.get());
    for (Leaf leaf : leaves) {
        leaf.run(0.6);
        leaf.render();
        for (Node n : leaf.nodes) {
            int x = (int)n.position.x;
            int y = (int)n.position.y;
            n.applyForce(fluid.field_vector(x, y));
            if (fluid.boundary(x, y)) {
                if (!fluid.boundary(x+1, y)) {
                    n.position.x += 1;
                } else if (!fluid.boundary(x, y+1)) {
                    n.position.y += 1;
                } else if (!fluid.boundary(x-1, y)) {
                    n.position.x -= 1;
                } else if (!fluid.boundary(x, y-1)) {
                    n.position.y -= 1;
                }
            }
        }
    }
    if (show_menu) {
        for (ListIterator<Input> itr = menu_list.listIterator(); itr.hasNext(); ) {
            Input input = itr.next();
            input.show();
        }
        fill(color(0));
        text("Controls", width - 100, 5, width - 3, 15);
        text("s - smoke/dens", width - 100, 20, width - 3, 30);
        text("l - leaf", width - 100, 35, width - 3, 45);
        text("w - wind", width - 100, 50, width - 3, 60);
        text("b - boundary", width - 100, 65, width - 3, 75);
        text("p - pusher", width - 100, 80, width - 3, 90);
        text("m - hide menu", width - 100, 95, width - 3, 105);
    }
}

void mousePressed() {
    for (ListIterator<Input> itr = menu_list.listIterator(); itr.hasNext(); ) {
        Input input = itr.next();
        if (input.within(mouseX, mouseY)) {
            if (input instanceof NumberBox) {
                if (selected_nb != null) selected_nb.unselect();
                key_log = true;
                selected_nb = (NumberBox)input;
                input.select();
                break;
            } else if (input instanceof Button) {
                Button button = (Button)input;
                button.change();
                break;
            } else if (input instanceof ColorButton) {
                ColorButton colorbutton = (ColorButton)input;
                if ((colorbutton.getCP() == null) && (selected_cp == null)) {
                    colorbutton.select();
                    selected_cp = colorbutton.getCP();
                    itr.add(selected_cp);
                    break;
                }
            } else if (input instanceof ColorPicker) {
                ColorPicker cp = (ColorPicker)input;
                cp.mouse(new PVector(mouseX, mouseY));
                cp.select();
                break;
            }
        } else if (input.equals(selected_nb)) {
            key_log = false;
            selected_nb = null;
            input.unselect();
            break;
        } else if (input.equals(selected_cp)) {
            itr.remove();
            selected_cp.unselect();
            selected_cp = null;
            break;
        }
    }
    if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX/scale, mouseY/scale, 20, 1, 0.7);
    } else if (keyPressed && key == 'p') {
        fluid.add_boundary(mouseX/scale, mouseY/scale, 20, pusher_force.get(), 0.7);
    } else if (keyPressed && key == 's') {
        fluid.add_dens(mouseX/scale, mouseY/scale, 20);
    } else if (keyPressed && key == 'l'){
        LSystem lsys;
        lsys = new LSystem("X", int(random(1,5)), 0.3926991);
        lsys.addRule(lsys.new LSystemRule("X","F[+F][-F]X"));
        Leaf leaf = new Leaf(size, scale, new PVector(mouseX/scale, mouseY/scale), 0, lsys);
        leaf.nodeSettings(0.01, 0.01);
        leaf.jointSettings(10, 0.06, 0.01, 0.5);
        leaf.setColors(leaf_vector_color, leaf_point_color);
        leaf.build();
        leaves.add(leaf);
    }
    mouseUpdate();
}

void mouseDragged() {
    for (ListIterator<Input> itr = menu_list.listIterator(); itr.hasNext(); ) {
        Input input = itr.next();
        if (input.within(mouseX, mouseY)) {
            if (input instanceof ColorPicker) {
                ColorPicker cp = (ColorPicker)input;
                cp.mouse(new PVector(mouseX, mouseY));
                cp.select();
                break;
            }
        }
    }
    if (keyPressed && key == 'w') {
        fluid.add_vector(mouseX/scale, mouseY/scale, prevMouseX/scale, prevMouseY/scale, 20);
    } else if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX/scale, mouseY/scale, 20, 1, 0.7);
    } else if (keyPressed && key == 'p') {
        fluid.add_boundary(mouseX/scale, mouseY/scale, 20, pusher_force.get(), 0.7);
    } else if (keyPressed && key == 's') {
        fluid.add_dens(mouseX/scale, mouseY/scale, 20);
    }
    mouseUpdate();
}

void mouseReleased() {
    for (ListIterator<Input> itr = menu_list.listIterator(); itr.hasNext(); ) {
        Input input = itr.next();
        if (input instanceof ColorPicker) {
            ColorPicker cp = (ColorPicker)input;
            cp.unselect();
            break;
        }
    }
}

void keyPressed() {
    if (key == 'm') {
        show_menu = !show_menu;
    }
    if (key_log) {
        selected_nb.concatVarText(key);
    }
}

void mouseUpdate() {
    prevMouseX = mouseX;
    prevMouseY = mouseY;
}
