class NumberBox extends Input {

    color border_color;
    color fill_color;
    color fill_number_color;
    color label_color;
    color varText_color;

    MutableFloat variable;
    String varText;

    final float label_ratio;

    public NumberBox(PVector position, PVector size, String label, MutableFloat variable) {
        super(position, size, label);
        this.variable = variable;
        this.varText = Float.toString(variable.get());

        unselect();
        colorMode(RGB, 255);
        fill_color = color(200);
        label_color = color(0);
        varText_color = color(0);

        label_ratio = 0.6;
    }

    public void setVariable() {
        variable.set(Float.parseFloat(varText));
    }

    public float getVariable() {
        return variable.get();
    }

    public boolean concatVarText(char s) {
        if (!Character.isDigit(s) && s != '.') return false;
        if (s=='.' && varText.indexOf('.')!=-1) return false; // NB (~a or b) <-> (a -> b)
        varText += s;
        return true;
    }

    public void clearVarText() {
        varText = new String("");
    }

    public void show() {
        strokeWeight(1);
        stroke(border_color);
        fill(fill_color);
        rect(position.x, position.y, size.x, size.y);
        fill(label_color);
        text(label, position.x + 3, position.y, size.x * label_ratio - 3, size.y);
        fill(fill_number_color);
        rect(position.x + size.x * label_ratio, position.y, size.x * (1-label_ratio), size.y);
        fill(varText_color);
        text(varText, position.x + size.x * label_ratio + 3, position.y, size.x * (1-label_ratio) - 3, size.y);
    }

    public void select() {
        clearVarText();

        colorMode(RGB, 255);
        border_color = color(255, 70, 0);
        fill_number_color = color(230);
    }

    public void unselect() {
        if (varText.isEmpty()) varText = Float.toString(getVariable());
        setVariable();
        varText = Float.toString(getVariable());

        colorMode(RGB, 255);
        border_color = color(150);
        fill_number_color = color(200);
    }

}
