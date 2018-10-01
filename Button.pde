class Button extends Input {

    MutableBoolean value;

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
        super.select();
    }

    public void unselect() {
        value.set(false);
        super.unselect();
    }

    public void show() {
        super.show();
    }

}
