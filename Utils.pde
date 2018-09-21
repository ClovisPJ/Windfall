class Utils {

    public int[] size;
    public int scale;

    public Utils(int[] size, int scale) {
        assert(size.length == 2);
        this.size = size;
        this.scale = scale;
    }

    public PVector wayto(PVector from, PVector to) {
        PVector vec = new PVector();
        vec.x = mod(to.x - from.x + size[0]/2, size[0]) - size[0]/2;
        vec.y = mod(to.y - from.y + size[1]/2, size[1]) - size[1]/2;
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
        if (x >= y) {
            return mod(x - y, y);
        } else if (x < 0) {
            return mod(x + y, y);
        } else {
            return x;
        }
    }

    protected int mod(int x, int y) {
        if (x >= y) {
            return mod(x - y, y);
        } else if (x < 0) {
            return mod(x + y, y);
        } else {
            return x;
        }
    }

    protected void draw_vector(PVector point1, PVector point2) {
        PVector joint = wayto(point1, point2);
        draw_pointvector(point1, joint);
        joint = joint.mult(-1);
        draw_pointvector(point2, joint);
    }

    protected void draw_pointvector(PVector point, PVector line) {
        stroke(0);
        strokeWeight(1);
        PVector other = PVector.add(point, line);
        line(point.x*scale, point.y*scale, other.x*scale, other.y*scale);
    }

    protected void draw_point(PVector point) {
        stroke(0);
        strokeWeight(scale);
        point(point.x*scale, point.y*scale);
    }

}
