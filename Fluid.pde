class Fluid extends Utils{

    float[][] u;
    float[][] v;
    float[][] u_prev;
    float[][] v_prev;
    float[][] dens;
    float[][] dens_prev;
    boolean[][] boundary;
    MutableFloat visc;
    MutableFloat diff;
    MutableFloat dt;
    int N;

    color boundary_color;
    color field_color;
    float density_scale;
    float field_scale;

    public Fluid(int N) {
        u = new float[N][N];
        v = new float[N][N];
        u_prev = new float[N][N];
        v_prev = new float[N][N];
        dens = new float[N][N];
        dens_prev = new float[N][N];
        boundary = new boolean[N][N];
        visc = new MutableFloat(1);
        diff = new MutableFloat(1);
        dt = new MutableFloat(1);
        this.N = N;

        boundary_color = color(255,0,0);
        field_color = color(255,0,0);
        density_scale = 10;
        field_scale = 1000;
    }

    private boolean checkBounds(int x, int y) {
        return (x <= N && x >= 0 && y <= N && y >= 0);
    }

    public PVector field_vector(int x, int y) {
        if (!checkBounds(x, y)) return new PVector(0,0);
        return new PVector(get(u,x,y), get(v,x,y));
    }

    public float dens(int x, int y) {
        if (!checkBounds(x, y)) return 0.0;
        return get(dens,x,y);
    }

    // FLUID VARS EDIT METHODS

    public float getVisc() { return visc.get(); }
    public void setVisc(float visc) { this.visc.set(visc); }
    public float getDiff() { return diff.get(); }
    public void setDiff(float diff) { this.diff.set(diff); }
    public float getDt() { return dt.get(); }
    public void setDt(float dt) { this.dt.set(dt); }

    // SET/GET METHODS

    private float get(float[][] f, int x, int y) {
        x = mod(x, width);
        y = mod(y, height);
        assert (checkBounds(x, y));
        return f[x][y];
    }

    private boolean get(boolean[][] b, int x, int y) {
        x = mod(x, width);
        y = mod(y, height);
        assert (checkBounds(x, y));
        return b[x][y];
    }

    private void set(float[][] f, int x, int y, float data) {
        x = mod(x, width);
        y = mod(y, height);
        assert (checkBounds(x, y));
        f[x][y] = data;
    }

    private void set(boolean[][] f, int x, int y, boolean data) {
        x = mod(x, width);
        y = mod(y, height);
        assert (checkBounds(x, y));
        f[x][y] = data;
    }

    private void setAdd(float[][] f, int x, int y, float data) {
        x = mod(x, width);
        y = mod(y, height);
        assert (checkBounds(x, y));
        f[x][y] += data;
    }

    // DRAW METHODS

    public void draw() {
        draw_point(dens);
        draw_arrow(u, v);
    }

    private void draw_point(float[][] x) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                strokeWeight(1);
                stroke(map(get(x,i,j), 0, density_scale, 255, 0));
                if (get(boundary,i,j)) stroke(boundary_color);
                point(i, j);
            }
        }
    }

    private void draw_arrow(float[][] u, float[][] v) {
        for (int i = 0; i < N; i+=10) {
            for (int j = 0; j < N; j+=10) {
                strokeWeight(1);
                stroke(field_color);
                line(i, j, i + field_scale*get(u,i,j), j + field_scale*get(v,i,j));
            }
        }
    }

    // CREATE METHODS

    public void add_dens(int x, int y, int r) {
        add_brush(dens, x, y, 1, r);
    }

    public void add_vector(int x, int y, int prev_x, int prev_y, int r) {
        add_brush(u, x, y, x - prev_x, r);
        add_brush(v, x, y, y - prev_y, r);
    }

    public void add_boundary(int x, int y, int r) {
        for (int i = x-r/2; i < x+r/2; i++) {
            for (int j = y-r/2; j < y+r/2; j++) {
                set(boundary,i,j,true);
            }
        }
    }

    private void add_brush (float[][] f, int x, int y, int power, int r) {
        for (int i = x - r/2; i <= x + r/2; i++) {
            for (int j = y - r/2; j <= y + r/2; j++) {
                float strength = sqrt((x-i)*(x-i) + (y-j)*(y-j));
                setAdd(f,i,j,(1 - strength / r) * power);
                // 'strength / r' varies on [0, 1/sqrt(2)]
            }
        }
    }

    public void add_field (float[][] x, float[][] s, float dt) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                setAdd(x,i,j,dt * get(s,i,j));
            }
        }
    }

    // FLUID MECH METHODS

    public void simulate() {
        u_prev = new float[N][N];
        v_prev = new float[N][N];
        dens_prev = new float[N][N];
        vel_step(u, v, u_prev, v_prev, visc.get(), dt.get());
        dens_step(dens, dens_prev, u, v, diff.get(), dt.get());
    }

    public void dens_step(float[][] x, float[][] x0, float[][] u, float[][] v, float diff, float dt) {
        float[][] temp;
        add_field(x, x0, dt);
        temp = x0; x0 = x; x = temp;
        diffuse(0, x, x0, diff, dt);
        temp = x0; x0 = x; x = temp;
        advect(0, x, x0, u, v, dt);
        set_bnd(0, dens);
    }

    public void vel_step(float[][] u, float[][] v, float[][] u0, float[][] v0, float visc, float dt) {
        float[][] temp;
        add_field(u, u0, dt);
        add_field(v, v0, dt);
        temp = u0; u0 = u; u = temp;
        temp = v0; v0 = v; v = temp;
        diffuse(1, u, u0, visc, dt);
        diffuse(2, v, v0, visc, dt);
        project(u, v, u0, v0);
        temp = u0; u0 = u; u = temp;
        temp = v0; v0 = v; v = temp;
        advect(1, u, u0, u0, v0, dt);
        advect(2, v, v0, u0, v0, dt);
        project(u, v, u0, v0);
        set_bnd(1, u);
        set_bnd(2, v);
    }

    public void diffuse (int b, float[][] x, float[][] x0, float rate, float dt) {
        float a = dt*rate;

        for (int k = 0; k < 20; k++) {
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < N; j++) {
                    set(x,i,j, (get(x0,i,j) + a * (get(x,i-1,j) + get(x,i+1,j) + get(x,i,j-1) + get(x,i,j+1))) / (1 + 4*a));
                }
            }
        }
    }

    public void advect(int b, float[][] d, float[][] d0, float[][] u, float[][] v, float dt) {
        int i0, j0, i1, j1;
        float x, y, s0, t0, s1, t1, dt0;
        dt0 = dt*N;
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                x = i - dt0 * get(u,i,j); y = j - dt0 * get(v,i,j);
                if (x < 0.5) x = 0.5; if (x > N+0.5) x = N + 0.5; i0 = (int)x; i1 = i0 + 1;
                if (y < 0.5) y = 0.5; if (y > N+0.5) y = N + 0.5; j0 = (int)y; j1 = j0 + 1;
                s1 = x - i0; s0 = 1 - s1; t1 = y - j0; t0 = 1 - t1;
                set(d,i,j, s0 * ( t0*get(d0,i0,j0) + t1*get(d0,i0,j1) ) +
                    s1 * ( t0*get(d0,i1,j0) + t1*get(d0,i1,j1) ) );
            }
        }
    }

    public void project(float[][] u, float[][] v, float[][] p, float[][] div) {
        float h = 1.0/N;
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                set(div,i,j, -0.5*h*(get(u,i+1,j) - get(u,i-1,j) + get(v,i,j+1) - get(v,i,j-1)));
                set(p,i,j, 0);
            }
        }

        for (int k = 0; k < 20; k++) {
            for (int i = 0; i < N; i++) {
                for (int j = 0; j < N; j++) {
                    set(p,i,j, (get(div,i,j) + get(p,i-1,j) + get(p,i+1,j) + get(p,i,j-1) + get(p,i,j+1)) / 4);
                }
            }
        }

        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                setAdd(u,i,j, -0.5 * (get(p,i+1,j) - get(p,i-1,j)) / h);
                setAdd(v,i,j, -0.5 * (get(p,i,j+1) - get(p,i,j-1)) / h);
            }
        }
    }

    public void set_bnd(int b, float[][] x) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                if (boundary[i][j]) {
                    x[i][j] = 0;
                    int surround = 0;
                    if (!boundary[i-1][j]) {x[i][j] += x[i-1][j]; surround++;}
                    if (!boundary[i+1][j]) {x[i][j] += x[i+1][j]; surround++;}
                    if (!boundary[i][j-1]) {x[i][j] += x[i][j-1]; surround++;}
                    if (!boundary[i][j+1]) {x[i][j] += x[i][j+1]; surround++;}
                    if (surround != 0) x[i][j] /= surround;
                    if ((b==1)||(b==2)) x[i][j] *= -1; // creates reaction & friction force from surface
                    // TODO seperate reaction & friction forces
                }
            }
        }

    }

}
