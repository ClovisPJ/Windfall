class TextBox extends Input {

    MutableFloat variable;

    public TextBox(PVector position, PVector size, MutableFloat variable) {
        super(position, size, Float.toString(variable.get()));
        this.variable = variable;
        unselect();
    }

    public void setVariable() {
        variable.set(Float.parseFloat(label));
    }

    public float getVariable() {
        return variable.get();
    }

    public boolean concatLabel(char s) {
        if (!Character.isDigit(s) && s != '.') return false;
        if (s=='.' && label.indexOf('.')!=-1) return false; // NB (~a or b) <-> (a -> b)
        label += s;
        return true;
    }

    public void clearLabel() {
        label = new String("");
    }

    public void select() {
        clearLabel();
        super.select();
    }

    public void unselect() {
        if (label.isEmpty()) label = Float.toString(getVariable());
        setVariable();
        label = Float.toString(getVariable());
        super.unselect();
    }

    public void show() {
        super.show();
    }

}
