import java.lang.Math;

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
    }

    public void draw() {
        draw_point(dens);
        draw_arrow(u, v);
    }

    public void draw_point(float[][] x) {
        for (int i = 0; i < N+2; i++) {
            for (int j = 0; j < N+2; j++) {
                strokeWeight(1);
                stroke(255-x[i][j]);
                if (boundary[i][j]) stroke(255,0,0);
                point(i, j);
            }
        }
    }

    public void draw_arrow(float[][] u, float[][] v) {
        for (int i = 0; i < N+2; i+=10) {
            for (int j = 0; j < N+2; j+=10) {
                strokeWeight(1);
                stroke(255, 0, 0);
                line(i, j, i + 1000*u[i][j], j + 1000*v[i][j]);
            }
        }
    }

    public void add_dens(int x, int y, int r) {
        for (int i = x-r/2; i < x+r/2; i++) {
            for (int j = y-r/2; j < y+r/2; j++) {
                if (i > N || j > N) continue;
                dens[i][j] += 100;
            }
        }
    }

    public void add_boundary(int x, int y, int r) {
        for (int i = x-r/2; i < x+r/2; i++) {
            for (int j = y-r/2; j < y+r/2; j++) {
                if (i > N || j > N) continue;
                boundary[i][j] = true;
            }
        }
    }

    public PVector field_vector(int x, int y) {
        return new PVector(u[x][y], v[x][y]);
    }

    public void simulate() {
        u_prev = new float[N+2][N+2];
        v_prev = new float[N+2][N+2];
        dens_prev = new float[N+2][N+2];
        vel_step(N, u, v, u_prev, v_prev, visc, dt);
        dens_step(N, dens, dens_prev, u, v, diff, dt);
    }

    public void divergence (int x, int y, int r) {
        for (int i = x - r; i <= x + r; i++) {
            for (int j = y - r; j <= y + r; j++) {
                float a = Math.signum(i - x) * -map(abs(i - x), 0, r, -1, 0);
                float b = Math.signum(j - y) * -map(abs(j - y), 0, r, -1, 0);
                if (i > N || j > N) continue;
                u[i][j] += 0.1*a;
                v[i][j] += 0.1*b;
            }
        }
    }

    public void dens_step(int N, float[][] x, float[][] x0, float[][] u, float[][] v, float diff, float dt) {
        float[][] temp;
        add_source(N, x, x0, dt);
        temp = x0; x0 = x; x = temp;
        diffuse(N, 0, x, x0, diff, dt);
        temp = x0; x0 = x; x = temp;
        advect(N, 0, x, x0, u, v, dt);
    }

    public void vel_step(int N, float[][] u, float[][] v, float[][] u0, float[][] v0, float visc, float dt) {
        float[][] temp;
        add_source(N, u, u0, dt);
        add_source(N, v, v0, dt);
        temp = u0; u0 = u; u = temp;
        temp = v0; v0 = v; v = temp;
        diffuse(N, 1, u, u0, visc, dt);
        diffuse(N, 2, v, v0, visc, dt);
        project(N, u, v, u0, v0);
        temp = u0; u0 = u; u = temp;
        temp = v0; v0 = v; v = temp;
        advect(N, 1, u, u0, u0, v0, dt);
        advect(N, 2, v, v0, u0, v0, dt);
        project(N, u, v, u0, v0);
    }

    public void add_source(int N, float[][] x, float[][] s, float dt) {
        for (int i = 0; i <= (N+1); i++) {
            for (int j = 0; j <= (N+1); j++) {
                x[i][j] += dt * s[i][j];
            }
        }
    }

    public void diffuse (int N, int b, float[][] x, float[][] x0, float diff, float dt) {
        float a = dt*diff*N*N;

        for (int k = 0; k < 20; k++) {
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= N; j++) {
                    x[i][j] = ( x0[i][j] + a * (x[i-1][j] + x[i+1][j] + x[i][j-1] + x[i][j+1]) ) / (1 + 4*a);
                }
            }
            set_bnd(N, b, x);
        }
    }

    public void advect(int N, int b, float[][] d, float[][] d0, float[][] u, float[][] v, float dt) {
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
        set_bnd(N, b, d);
    }

    public void project(int N, float[][] u, float[][] v, float[][] p, float[][] div) {
        float h = 1.0/N;
        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= N; j++) { div[i][j] = -0.5*h*(u[i+1][j] - u[i-1][j] + 
                    v[i][j+1] - v[i][j-1]);
            p[i][j] = 0;
            }
        }
        set_bnd(N, 0, div); set_bnd(N, 0, p);

        for (int k = 0; k < 20; k++) {
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= N; j++) {
                    p[i][j] = (div[i][j] + p[i-1][j] + p[i+1][j] + p[i][j-1] + p[i][j+1]) / 4;
                }
            }
            set_bnd(N, 0, p);
        }

        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= N; j++) {
                u[i][j] -= 0.5 * (p[i+1][j] - p[i-1][j]) / h;
                v[i][j] -= 0.5 * (p[i][j+1] - p[i][j-1]) / h;
            }
        }
        set_bnd(N, 1, u); set_bnd(N, 2, v);
    }

    public void set_bnd(int N, int b, float[][] x) {
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
