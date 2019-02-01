class Button extends Input {

    MutableBoolean value;

    color border_color;
    color fill_color;
    color label_color;

    public Button(PVector position, PVector size, String label, MutableBoolean value) {
        super(position, size, label);
        this.value = value;
        if (value.get()) {
            select();
        } else {
            unselect();
        }
    }

    public void setValue(boolean value) {
        this.value.set(value);
    }

    public boolean getValue() {
        return value.get();
    }

    public void change() {
        if (value.get()) {
            this.unselect();
        } else { 
            this.select();
        }
    }

    public void select() {
        value.set(true);
        colorMode(RGB, 255);
        border_color = color(255, 70, 0);
        fill_color = color(230);
        label_color = color(0);
    }

    public void unselect() {
        value.set(false);
        colorMode(RGB, 255);
        border_color = color(150);
        fill_color = color(200);
        label_color = color(0);
    }

    public void show() {
        strokeWeight(1);
        stroke(border_color);
        fill(fill_color);
        rect(position.x, position.y, size.x, size.y);
        fill(label_color);
        text(label, position.x+3, position.y, size.x-3, size.y);
    }

}
