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
TextBox selected_tb;
ColorPicker selected_cp;

MutableBoolean draw_dens;
MutableBoolean draw_field_length_arrows;
MutableBoolean draw_field_norm_arrows;
MutableColor leaf_vector_color;
MutableColor leaf_point_color;

void setup() {
    size = new int[] {150, 150};
    scale = 3;
    size(450, 450, P2D);
    fluid = new Fluid(size, scale);
    leaves = new ArrayList<Leaf>();
    leaf_vector_color = new MutableColor(color(0));
    leaf_point_color = new MutableColor(color(0));

    show_menu = true;
    PVector tb_size = new PVector(50,15);
    PVector button_size = new PVector(15,15);
    menu_list = new ArrayList<Input>();
    menu_list.add(new TextBox(new PVector(5,5), tb_size, fluid.visc));
    menu_list.add(new TextBox(new PVector(5,25), tb_size, fluid.diff));
    menu_list.add(new TextBox(new PVector(5,45), tb_size, fluid.dt));
    menu_list.add(new TextBox(new PVector(5,65), tb_size, fluid.boundary_blower_scale));
    menu_list.add(new TextBox(new PVector(5,85), tb_size, fluid.density_scale));
    menu_list.add(new TextBox(new PVector(5,105), tb_size, fluid.field_scale));
    draw_dens = new MutableBoolean(true);
    draw_field_length_arrows = new MutableBoolean(false);
    draw_field_norm_arrows = new MutableBoolean(true);
    menu_list.add(new Button(new PVector(5,125), button_size, "D", draw_dens));
    menu_list.add(new Button(new PVector(25,125), button_size, "A", draw_field_length_arrows));
    menu_list.add(new Button(new PVector(45,125), button_size, "N", draw_field_norm_arrows));
    menu_list.add(new ColorButton(new PVector(5,145), button_size, fluid.field_color));
    menu_list.add(new ColorButton(new PVector(5,165), button_size, fluid.dens_start_color));
    menu_list.add(new ColorButton(new PVector(5,185), button_size, fluid.dens_end_color));
    menu_list.add(new ColorButton(new PVector(5,205), button_size, leaf_vector_color));
    menu_list.add(new ColorButton(new PVector(5,225), button_size, leaf_point_color));
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
    }
}

void mousePressed() {
    for (ListIterator<Input> itr = menu_list.listIterator(); itr.hasNext(); ) {
        Input input = itr.next();
        if (input.within(mouseX, mouseY)) {
            if (input instanceof TextBox) {
                if (selected_tb != null) selected_tb.unselect();
                key_log = true;
                selected_tb = (TextBox)input;
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
                cp.select(new PVector(mouseX, mouseY));
                break;
            }
        } else if (input.equals(selected_tb)) {
            key_log = false;
            selected_tb = null;
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
        fluid.add_boundary(mouseX/scale, mouseY/scale, 20);
    } else if (keyPressed && key == 'd') {
        fluid.add_dens(mouseX/scale, mouseY/scale, 20);
    } else if (keyPressed && key == 't'){
        LSystem lsys;
        lsys = new LSystem("X", 3, 0.3926991);
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
                cp.select(new PVector(mouseX, mouseY));
                break;
            }
        }
    }
    if (keyPressed && key == 'v') {
        fluid.add_vector(mouseX/scale, mouseY/scale, prevMouseX/scale, prevMouseY/scale, 10);
    } else if (keyPressed && key == 'b') {
        fluid.add_boundary(mouseX/scale, mouseY/scale, 20);
    } else if (keyPressed && key == 'd') {
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
        selected_tb.concatText(key);
    }
}

void mouseUpdate() {
    prevMouseX = mouseX;
    prevMouseY = mouseY;
}
