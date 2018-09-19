class TextBox {

    PVector position;
    PVector size;
    String text;
    MutableFloat variable;

    color border_color;
    color fill_color;
    color text_color;

    public TextBox(PVector position, PVector size, MutableFloat variable) {
        this.position = position;
        this.size = size;
        this.variable = variable;
        text = Float.toString(variable.get());
        unselect();
        show();
    }

    public void setVariable() {
        variable.set(Float.parseFloat(text));
    }

    public float getVariable() {
        return variable.get();
    }

    public boolean concatText(char s) {
        if (!Character.isDigit(s) && s != '.') return false;
        if (s=='.' && text.indexOf('.')!=-1) return false; // NB (~a or b) <-> (a -> b)
        text += s;
        return true;
    }

    public void clearText() {
        text = new String("");
    }


    public boolean within(float x, float y) {
        return (x >= position.x && y >= position.y && x <= position.x + size.x && y <= position.y + size.y);
    }

    public void select() {
        clearText();
        border_color = color(255, 70, 0);
        fill_color = color(230);
    }

    public void unselect() {
        if (text.isEmpty()) text = Float.toString(getVariable());
        setVariable();
        text = Float.toString(getVariable());
        border_color = color(150);
        fill_color = color(200);
        text_color = color(0);
    }

    public void show() {
        stroke(border_color);
        fill(fill_color);
        rect(position.x, position.y, size.x, size.y);
        fill(text_color);
        text(text, position.x+3, position.y, size.x, size.y);
    }

}
