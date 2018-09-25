class TextBox extends Input {

    String text;
    MutableFloat variable;

    color text_color;

    public TextBox(PVector position, PVector size, MutableFloat variable) {
        super(position, size);
        this.variable = variable;
        text = Float.toString(variable.get());
        unselect();
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

    public void select() {
        clearText();
        super.select();
    }

    public void unselect() {
        if (text.isEmpty()) text = Float.toString(getVariable());
        setVariable();
        text = Float.toString(getVariable());
        text_color = color(0);
        super.unselect();
    }

    public void show() {
        super.show();
        fill(text_color);
        text(text, position.x+3, position.y, size.x-3, size.y);
    }

}
