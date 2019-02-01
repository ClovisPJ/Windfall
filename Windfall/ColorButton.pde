class ColorButton extends Input {

    MutableColor col;
    ColorPicker cp;
    PVector cp_size;

    color border_color;
    color fill_color;
    color label_color;

    public ColorButton(PVector position, PVector size, String label, MutableColor col) {
        super(position, size, label);
        this.col = col;
        cp_size = new PVector(120,100);

        colorMode(RGB, 255);
        border_color = color(150);
        fill_color = color(200);
        label_color = color(0);
    }

    public boolean within(float x, float y) {
        return (x >= position.x + size.x - size.y && y >= position.y && x <= position.x + size.x && y <= position.y + size.y);
    }

    public void show() {
        strokeWeight(1);
        stroke(border_color);
        fill(fill_color);
        rect(position.x, position.y, size.x, size.y);
        fill(label_color);
        text(label, position.x+3, position.y, size.x - size.y - 3, size.y);
        stroke(border_color);
        fill(col.get());
        rect(position.x + size.x - size.y, position.y, size.y, size.y);
    }

    public void select() {
        cp = new ColorPicker(new PVector(position.x+size.x+2, position.y), cp_size, col, this);
    }

    public void unselect() {
        cp = null;
    }

    public ColorPicker getCP() {
        return cp;
    }

}
