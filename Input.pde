abstract class Input {

    PVector position;
    PVector size;

    String label;

    public Input(PVector position, PVector size, String label) {
        this.position = position;
        this.size = size;
        this.label = label;
    }

    public boolean within(float x, float y) {
        return (x >= position.x && y >= position.y && x <= position.x + size.x && y <= position.y + size.y);
    }

    public abstract void show();

    public abstract void select();

    public abstract void unselect();

}
