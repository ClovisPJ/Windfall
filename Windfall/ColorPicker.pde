class ColorPicker extends Input {

    private static final float surfaceSliderRatio = 0.8;
    MutableColor col;
    ColorButton cb;
    PVector cursor_pos;

    color border_color;
    color fill_color;

    public ColorPicker(PVector position, PVector size, MutableColor col, ColorButton cb) {
        super(position, size, "");
        this.col = col;
        cMode();
        this.cb = cb;
        unselect();
        cursor_pos = position;
    }

    public void show() {
        cMode();
        pushMatrix();
        translate(position.x, position.y);
        strokeWeight(1);
        stroke(border_color);
        fill(fill_color); // meaningless
        rect(0, 0, size.x+1, size.y+1);
        for (float i = 0; i <= size.x * surfaceSliderRatio - 2; i++) {
            for (float j = 0; j <= size.y - 2; j++) {
                stroke(hue(col.get()), i, j);
                rect(i+1, j+1, 1, 1);
            }
        }
        stroke(0);
        line(size.x * surfaceSliderRatio, 1, size.x * surfaceSliderRatio, size.y);
        for (float i = size.x * surfaceSliderRatio + 1; i <= size.x - 1; i++) {
            for (float j = 0; j <= size.y - 2; j++) {
                stroke(j, size.x * surfaceSliderRatio - 2, size.y - 2);
                rect(i, j+1, 1, 1);
            }
        }
        stroke(border_color);
        fill(fill_color);
        ellipse(saturation(col.get()), brightness(col.get()), size.x/10, size.x/10);
        line(size.x * surfaceSliderRatio, hue(col.get()), size.x, hue(col.get()));
        popMatrix();
    }

    public void mouse(PVector mouse_location) {
        cursor_pos = PVector.sub(mouse_location, position);
        cursor_pos.sub(new PVector(1,1));
    }

    public void select() {
        colorMode(RGB, 255);
        border_color = color(255, 70, 0);
        fill_color = color(230);

        cMode();
        if (cursor_pos.x < size.x * surfaceSliderRatio) {
            col.set(color(hue(col.get()), cursor_pos.x, cursor_pos.y));
        } else if (cursor_pos.x > size.x * surfaceSliderRatio) {
            if (brightness(col.get()) == 0) {
                // Kinda dirty hack to solve annoying behaviour
                colorMode(HSB, 255);
                col.set(color(cursor_pos.y, 255, 255));
            } else {
                col.set(color(cursor_pos.y, saturation(col.get()), brightness(col.get())));
            }
        }
    }

    public void unselect() {
        colorMode(RGB, 255);
        border_color = color(150);
        fill_color = color(200);

        cb.unselect();
    }

    private void cMode() {
        colorMode(HSB, size.y - 2, size.x * surfaceSliderRatio - 2, size.y - 2);
    }

}
