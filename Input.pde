abstract class Input {

    PVector position;
    PVector size;

    color border_color;
    color fill_color;
    color label_color;

    String label;

    public Input(PVector position, PVector size, String label) {
        this.position = position;
        this.size = size;
        this.label = label;
    }

    public boolean within(float x, float y) {
        return (x >= position.x && y >= position.y && x <= position.x + size.x && y <= position.y + size.y);
    }

    public void show() {
        strokeWeight(1);
        stroke(border_color);
        fill(fill_color);
        rect(position.x, position.y, size.x, size.y);
        fill(label_color);
        text(label, position.x+3, position.y, size.x-3, size.y);
    }

    public void select() {
        colorMode(RGB, 255);
        border_color = color(255, 70, 0);
        fill_color = color(230);
        label_color = color(0);
    }

    public void unselect() {
        colorMode(RGB, 255);
        border_color = color(150);
        fill_color = color(200);
        label_color = color(0);
    }

}
