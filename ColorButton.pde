class ColorButton extends Input {

    MutableColor col;
    ColorPicker cp;
    PVector cp_size;

    public ColorButton(PVector position, PVector size, MutableColor col) {
        super(position, size);
        this.col = col;
        cp_size = new PVector(120,100);
    }

    public void show() {
        strokeWeight(1);
        stroke(border_color);
        fill(col.get());
        rect(position.x, position.y, size.x, size.y);
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
