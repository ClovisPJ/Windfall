class Button extends Input {

    MutableBoolean value;
    String text;

    public Button(PVector position, PVector size, String text, MutableBoolean value) {
        super(position, size);
        this.text = text;
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
        fill(0);
        text(text, position.x+3, position.y, size.x-3, size.y);
    }

}
