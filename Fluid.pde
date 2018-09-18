class Fluid {

    float[][] u;
    float[][] v;
    float[][] u_prev;
    float[][] v_prev;
    float[][] dens;
    float[][] dens_prev;
    boolean[][] boundary;
    float visc;
    float diff;
    float dt;
    int N;

    color boundary_color;
    color field_color;
    float density_scale;
    float field_scale;

    public Fluid(int N) {
        u = new float[N+2][N+2];
        v = new float[N+2][N+2];
        u_prev = new float[N+2][N+2];
        v_prev = new float[N+2][N+2];
        dens = new float[N+2][N+2];
        dens_prev = new float[N+2][N+2];
        boundary = new boolean[N+2][N+2];
        visc = 0.0001;
        diff = 0.0001;
        dt = 0.2;
        this.N = N;

        boundary_color = color(255,0,0);
        field_color = color(255,0,0);
        density_scale = 10;
        field_scale = 1000;
    }


    private boolean checkBounds(int x, int y) {
        return (x < N+1 && x > 0 && y < N+1 && y > 0);
    }

    public PVector field_vector(int x, int y) {
        if (!checkBounds(x, y)) return new PVector(0,0);
        return new PVector(u[x][y], v[x][y]);
    }

    public float dens(int x, int y) {
        if (!checkBounds(x, y)) return 0.0;
        return dens[x][y];
    }

    // DRAW METHODS

    public void draw() {
        draw_point(dens);
        draw_arrow(u, v);
    }

    private void draw_point(float[][] x) {
        for (int i = 0; i < N+2; i++) {
            for (int j = 0; j < N+2; j++) {
                strokeWeight(1);
                stroke(map(x[i][j], 0, density_scale, 255, 0));
                if (boundary[i][j]) stroke(boundary_color);
                point(i, j);
            }
        }
    }

    private void draw_arrow(float[][] u, float[][] v) {
        for (int i = 0; i < N+2; i+=10) {
            for (int j = 0; j < N+2; j+=10) {
                strokeWeight(1);
                stroke(field_color);
                line(i, j, i + field_scale*u[i][j], j + field_scale*v[i][j]);
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
                if (!checkBounds(i, j)) continue;
                boundary[i][j] = true;
            }
        }
    }

    private void add_brush (float[][] f, int x, int y, int power, int r) {
        for (int i = x - r/2; i <= x + r/2; i++) {
            for (int j = y - r/2; j <= y + r/2; j++) {
                if (!checkBounds(i, j)) continue;
                float strength = sqrt((x-i)*(x-i) + (y-j)*(y-j));
                f[i][j] += (1 - strength / r) * power;
                // 'strength / r' varies on [0, 1/sqrt(2)]
            }
        }
    }

    public void add_field (float[][] x, float[][] s, float dt) {
        for (int i = 0; i <= (N+1); i++) {
            for (int j = 0; j <= (N+1); j++) {
                x[i][j] += dt * s[i][j];
            }
        }
    }

    // FLUID MECH METHODS

    public void simulate() {
        u_prev = new float[N+2][N+2];
        v_prev = new float[N+2][N+2];
        dens_prev = new float[N+2][N+2];
        vel_step(u, v, u_prev, v_prev, visc, dt);
        dens_step(dens, dens_prev, u, v, diff, dt);
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

    public void diffuse (int b, float[][] x, float[][] x0, float diff, float dt) {
        float a = dt*diff*N*N;

        for (int k = 0; k < 20; k++) {
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= N; j++) {
                    x[i][j] = ( x0[i][j] + a * (x[i-1][j] + x[i+1][j] + x[i][j-1] + x[i][j+1]) ) / (1 + 4*a);
                }
            }
            set_bnd(b, x);
        }
    }

    public void advect(int b, float[][] d, float[][] d0, float[][] u, float[][] v, float dt) {
        int i0, j0, i1, j1;
        float x, y, s0, t0, s1, t1, dt0;
        dt0 = dt*N;
        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= N; j++) {
                x = i - dt0 * u[i][j]; y = j - dt0 * v[i][j];
                if (x < 0.5) x = 0.5; if (x > N+0.5) x = N + 0.5; i0 = (int)x; i1 = i0 + 1;
                if (y < 0.5) y = 0.5; if (y > N+0.5) y = N + 0.5; j0 = (int)y; j1 = j0 + 1;
                s1 = x - i0; s0 = 1 - s1; t1 = y - j0; t0 = 1 - t1;
                d[i][j] = s0 * ( t0*d0[i0][j0] + t1*d0[i0][j1] ) +
                    s1 * ( t0*d0[i1][j0] + t1*d0[i1][j1] );
            }
        }
        set_bnd(b, d);
    }

    public void project(float[][] u, float[][] v, float[][] p, float[][] div) {
        float h = 1.0/N;
        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= N; j++) { div[i][j] = -0.5*h*(u[i+1][j] - u[i-1][j] + 
                    v[i][j+1] - v[i][j-1]);
            p[i][j] = 0;
            }
        }
        set_bnd(0, div); set_bnd(0, p);

        for (int k = 0; k < 20; k++) {
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= N; j++) {
                    p[i][j] = (div[i][j] + p[i-1][j] + p[i+1][j] + p[i][j-1] + p[i][j+1]) / 4;
                }
            }
            set_bnd(0, p);
        }

        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= N; j++) {
                u[i][j] -= 0.5 * (p[i+1][j] - p[i-1][j]) / h;
                v[i][j] -= 0.5 * (p[i][j+1] - p[i][j-1]) / h;
            }
        }
        set_bnd(1, u); set_bnd(2, v);
    }

    public void set_bnd(int b, float[][] x) {
        for (int i = 1; i <= N; i++) {
            x[0][i] = (b==1) ? -x[1][i] : x[1][i];
            x[N+1][i] = (b==1) ? -x[N][i] : x[N][i];
            x[i][0] = (b==2) ? -x[i][1] : x[i][1];
            x[i][N+1] = (b==2) ? -x[i][N] : x[i][N];
        }
        x[0][0] = 0.5 * (x[1][0] + x[0][1]);
        x[0][N+1] = 0.5 * (x[1][N+1] + x[0][N]);
        x[N+1][0] = 0.5 * (x[N][0] + x[N+1][1]);
        x[N+1][N+1] = 0.5 * (x[N][N+1] + x[N+1][N]);

        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= N; j++) {
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
