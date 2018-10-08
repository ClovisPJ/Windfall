class Fluid extends Utils {

    float[][] u;
    float[][] v;
    float[][] u_prev;
    float[][] v_prev;
    float[][] dens;
    float[][] dens_prev;
    MutableFloat visc;
    MutableFloat diff;
    MutableFloat dt;
    float[][] reaction;
    float[][] friction;

    MutableFloat pusher_scale;
    MutableFloat density_scale;
    MutableFloat field_scale;
    MutableColor field_color;
    MutableColor dens_start_color;
    MutableColor dens_end_color;

    public Fluid(int[] size, int scale) {
        super(size, scale);

        u = new float[size[0]][size[1]];
        v = new float[size[0]][size[1]];
        u_prev = new float[size[0]][size[1]];
        v_prev = new float[size[0]][size[1]];
        dens = new float[size[0]][size[1]];
        dens_prev = new float[size[0]][size[1]];
        visc = new MutableFloat(1);
        diff = new MutableFloat(1);
        dt = new MutableFloat(1);
        reaction = new float[size[0]][size[1]];
        friction = new float[size[0]][size[1]];

        pusher_scale = new MutableFloat(100);
        density_scale = new MutableFloat(5);
        field_scale = new MutableFloat(5);
        field_color = new MutableColor(color(255,0,0));
        dens_start_color = new MutableColor(color(255));
        dens_end_color = new MutableColor(color(0));
    }

    private boolean checkBounds(int x, int y) {
        return (x < size[0] && x >= 0 && y < size[1] && y >= 0);
    }

    public PVector field_vector(int x, int y) {
        return new PVector(get(u,x,y), get(v,x,y));
    }

    public float dens(int x, int y) {
        return get(dens,x,y);
    }

    public boolean boundary(int x, int y) {
        return (get(friction,x,y) != 0) || (get(reaction,x,y) != 0);
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
        x = mod(x, size[0]);
        y = mod(y, size[1]);
        assert (checkBounds(x, y));
        return f[x][y];
    }

    private void set(float[][] f, int x, int y, float data) {
        x = mod(x, size[0]);
        y = mod(y, size[1]);
        assert (checkBounds(x, y));
        f[x][y] = data;
    }

    private void setAdd(float[][] f, int x, int y, float data) {
        x = mod(x, size[0]);
        y = mod(y, size[1]);
        assert (checkBounds(x, y));
        f[x][y] += data;
    }

    // DRAW METHODS

    public void draw(boolean draw_dens, boolean draw_field_length_arrows, boolean draw_field_norm_arrows) {
        if (draw_dens) draw_points(dens);
        if (draw_field_length_arrows) draw_length_arrows(u, v);
        if (draw_field_norm_arrows) draw_norm_arrows(u, v);
    }

    private void draw_points(float[][] x) {
        for (int i = 0; i < size[0]; i++) {
            for (int j = 0; j < size[1]; j++) {
                colorMode(RGB, 255);
                if (!boundary(i,j)) {
                    fill(lerpColor(dens_start_color.get(), dens_end_color.get(), map(get(x,i,j), 0, density_scale.get(), 0.0, 1.0))); // grays
                } else if (get(reaction,i,j) <= 1) {
                    fill(0, 0, 0); // black
                } else if (get(reaction,i,j) > 1) {
                    fill(map(get(reaction,i, j), 1, pusher_scale.get(), 0, 255), 0, 0); // reds
                }
                noStroke();
                rect(i*scale, j*scale, (i+1)*scale, (j+1)*scale);
            }
        }
    }

    private void draw_length_arrows(float[][] u, float[][] v) {
        for (int i = 0; i < size[0]; i+=10) {
            for (int j = 0; j < size[1]; j+=10) {
                strokeWeight(scale);
                stroke(field_color.get());
                line((i+0.5)*scale, (j+0.5)*scale,
                     (i+0.5)*scale + field_scale.get() * get(u,i,j),
                     (j+0.5)*scale + field_scale.get() * get(v,i,j));
            }
        }
    }

    private void draw_norm_arrows(float[][] u, float[][] v) {
        for (int i = 0; i < size[0]; i+=10) {
            for (int j = 0; j < size[1]; j+=10) {
                strokeWeight(scale);
                stroke(field_color.get());
                PVector vec = new PVector(get(u,i,j), get(v,i,j)).normalize();
                line((i+0.5)*scale, (j+0.5)*scale,
                     (i+0.5 + field_scale.get() * vec.x)*scale,
                     (j+0.5 + field_scale.get() * vec.y)*scale);
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

    public void add_boundary(int x, int y, int r, float reac, float fric) {
        for (int i = x-r/2; i < x+r/2; i++) {
            for (int j = y-r/2; j < y+r/2; j++) {
                set(reaction,i,j,reac);
                set(friction,i,j,fric);
            }
        }
    }

    private void add_brush (float[][] f, int x, int y, int power, int r) {
        for (int i = x - r/2; i <= x + r/2; i++) {
            for (int j = y - r/2; j <= y + r/2; j++) {
                float strength = sqrt((x-i)*(x-i) + (y-j)*(y-j));
                setAdd(f,i,j,(1 - strength / r) * power);
                // TODO invetigation the following assertion
                // 'strength / r' varies on [0, 1/sqrt(2)]
            }
        }
    }

    public void add_field (float[][] x, float[][] s, float dt) {
        for (int i = 0; i < size[0]; i++) {
            for (int j = 0; j < size[1]; j++) {
                setAdd(x,i,j,dt * get(s,i,j));
            }
        }
    }

    // FLUID MECH METHODS

    public void simulate() {
        u_prev = new float[size[0]][size[1]];
        v_prev = new float[size[0]][size[1]];
        dens_prev = new float[size[0]][size[1]];
        vel_step(u, v, u_prev, v_prev, visc.get(), dt.get());
        dens_step(dens, dens_prev, u, v, diff.get(), dt.get());
        set_bnd(0, dens);
        set_bnd(1, u);
        set_bnd(2, v);
    }

    public void dens_step(float[][] x, float[][] x0, float[][] u, float[][] v, float diff, float dt) {
        float[][] temp;
        add_field(x, x0, dt);
        temp = x0; x0 = x; x = temp;
        diffuse(0, x, x0, diff, dt);
        temp = x0; x0 = x; x = temp;
        advect(0, x, x0, u, v, dt);
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
    }

    public void diffuse (int b, float[][] x, float[][] x0, float rate, float dt) {
        float a = dt*rate;
        for (int k = 0; k < 20; k++) {
            for (int i = 0; i < size[0]; i++) {
                for (int j = 0; j < size[1]; j++) {
                    set(x,i,j, (get(x0,i,j) + a * (get(x,i-1,j) + get(x,i+1,j) + get(x,i,j-1) + get(x,i,j+1))) / (1 + 4*a));
                }
            }
        }
    }

    public void advect(int b, float[][] d, float[][] d0, float[][] u, float[][] v, float dt) {
        int i0, j0, i1, j1;
        float x, y, s0, t0, s1, t1;
        for (int i = 0; i < size[0]; i++) {
            for (int j = 0; j < size[1]; j++) {
                x = i - dt * get(u,i,j); y = j - dt * get(v,i,j);
                x = mod(x, size[0]);
                i0 = (int)x; i1 = i0 + 1;
                y = mod(y, size[1]);
                j0 = (int)y; j1 = j0 + 1;
                s1 = x - i0; s0 = 1 - s1; t1 = y - j0; t0 = 1 - t1;
                set(d,i,j, s0 * ( t0*get(d0,i0,j0) + t1*get(d0,i0,j1) ) +
                           s1 * ( t0*get(d0,i1,j0) + t1*get(d0,i1,j1) ) );
            }
        }
    }

    public void project(float[][] u, float[][] v, float[][] p, float[][] div) {
        float h = 1.0;
        for (int i = 0; i < size[0]; i++) {
            for (int j = 0; j < size[1]; j++) {
                set(div,i,j, -0.5*h*(get(u,i+1,j) - get(u,i-1,j) + get(v,i,j+1) - get(v,i,j-1)));
                set(p,i,j, 0);
            }
        }

        for (int k = 0; k < 20; k++) {
            for (int i = 0; i < size[0]; i++) {
                for (int j = 0; j < size[1]; j++) {
                    set(p,i,j, (get(div,i,j) + get(p,i-1,j) + get(p,i+1,j) + get(p,i,j-1) + get(p,i,j+1)) / 4);
                }
            }
        }

        for (int i = 0; i < size[0]; i++) {
            for (int j = 0; j < size[1]; j++) {
                setAdd(u,i,j, -0.5 * (get(p,i+1,j) - get(p,i-1,j)) / h);
                setAdd(v,i,j, -0.5 * (get(p,i,j+1) - get(p,i,j-1)) / h);
            }
        }
    }

    public void set_bnd(int b, float[][] x) {
        for (int i = 0; i < size[0]; i++) {
            for (int j = 0; j < size[1]; j++) {
                float fric, reac;
                if (boundary(i,j)) {
                    fric = get(friction,i,j);
                    reac = get(reaction,i,j);
                    set(x,i,j, 0);
                    int surround = 0;
                    float k;
                    if (b==1) {
                        k = -reac;
                    } else if (b==2) {
                        k = fric;
                    } else {
                        k = 1;
                    }
                    if (!boundary(i-1,j)) {
                        setAdd(x,i,j, (k*get(x,i-1,j) > 0)&&(b==1) ? 0 : k*get(x,i-1,j));
                        surround++;
                    }
                    if (!boundary(i+1,j)) {
                        setAdd(x,i,j, (k*get(x,i+1,j) < 0)&&(b==1) ? 0 : k*get(x, i+1, j));
                        surround++;
                    }
                    if (b==1) {
                        k = fric;
                    } else if (b==2) {
                        k = -reac;
                    } else {
                        k = 1;
                    }
                    if (!boundary(i,j-1)) {
                        setAdd(x,i,j, (k*get(x,i,j-1) > 0)&&(b==2) ? 0 : k*get(x,i,j-1));
                        surround++;
                    }
                    if (!boundary(i,j+1)) {
                        setAdd(x,i,j, (k*get(x,i,j+1) < 0)&&(b==2) ? 0 : k*get(x,i,j+1));
                        surround++;
                    }
                    if (surround != 0) set(x,i,j, get(x,i,j) / surround);
                }
            }
        }

    }

}
