class MutableBoolean {

    private boolean b;

    public MutableBoolean(boolean b) {
        set(b);
    }

    public void set(boolean b) {
        this.b = b;
    }

    public boolean get() {
        return b;
    }


}
