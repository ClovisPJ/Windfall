class Utils {

    public PVector wayto(PVector from, PVector to) {
        PVector vec = new PVector();
        vec.x = mod(to.x - from.x + width/2, width) - width/2;
        vec.y = mod(to.y - from.y + height/2, height) - height/2;
        return vec;
    }

    public float angto(float from, float to) {
        float ang = mod(to - from + PI, TWO_PI) - PI;
        return ang;
    }

    public float angto(PVector from, PVector to) {
        return -1 * wayto(from, to).heading();
    }

    protected float mod(float x, float y) {
        if (x > y) {
            return mod(x - y, y);
        } else if (x < 0) {
            return mod(x + y, y);
        } else {
            return x;
        }
    }

    protected int mod(int x, int y) {
        if (x > y) {
            return mod(x - y, y);
        } else if (x < 0) {
            return mod(x + y, y);
        } else {
            return x;
        }
    }

    protected void draw_pointvector(PVector point, PVector line) {
        stroke(0,255,0);
        strokeWeight(1);
        PVector other = PVector.add(point, line);
        line(point.x, point.y, other.x, other.y);
    }

}
