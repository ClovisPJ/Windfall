class Input {

    PVector position;
    PVector size;

    color border_color;
    color fill_color;

    public Input(PVector position, PVector size) {
        this.position = position;
        this.size = size;
    }

    public boolean within(float x, float y) {
        return (x >= position.x && y >= position.y && x <= position.x + size.x && y <= position.y + size.y);
    }

    public void show() {
        stroke(border_color);
        fill(fill_color);
        rect(position.x, position.y, size.x, size.y);
    }

    public void select() {
        border_color = color(255, 70, 0);
        fill_color = color(230);
    }

    public void unselect() {
        border_color = color(150);
        fill_color = color(200);
    }

}
