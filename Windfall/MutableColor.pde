class MutableColor {

    private color c;

    public MutableColor(color c) {
        set(c);
    }

    public void set(color c) {
        this.c = c;
    }

    public color get() {
        return c;
    }

}
