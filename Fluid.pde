class Fluid {

  float[][] u;
  float[][] v;
  float[][] u_prev;
  float[][] v_prev;
  float[][] dens;
  float[][] dens_prev;
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
    visc = 0.1;
    diff = 0.1;
    dt = 0.01;
    this.N = N;
  }

  public void draw() {
    draw_stroke(dens);
  }

  public void draw_stroke(float[][] x) {
    for (int i = 0; i < N+2; i++) {
      for (int j = 0; j < N+2; j++) {
        stroke(x[i][j]);
        point(i, j);
      }
    }
  }

  public void add(int x, int y, int r) {
    float[][] source = new float[N+2][N+2];
    for (int i = x-r/2; i < x+r/2; i++) {
      for (int j = y-r/2; j < y+r/2; j++) {
        source[i][j] = 10000;
      }
    }
    add_source(N, dens, source, dt);
  }

  public void simulate() {
    u_prev = u;
    v_prev = v;
    dens_prev = dens;
    vel_step(N, u, v, u_prev, v_prev, visc, dt);
    dens_step(N, dens, dens_prev, u, v, diff, dt);
  }

  public void dens_step(int N, float[][] x, float[][] x0, float[][] u, float[][] v, float diff, float dt) {
    float[][] temp;
    add_source(N, x, x0, dt);
    diffuse(N, 0, x, x0, diff, dt);
    temp = x0; x0 = x; x = temp;
    advect(N, 0, x, x0, u, v, dt);
    temp = x0; x0 = x; x = temp;
  }

  public void vel_step(int N, float[][] u, float[][] v, float[][] u0, float[][] v0, float vsic, float dt) {
    add_source(N, u, u0, dt);
    add_source(N, v, v0, dt);
    float[][] temp = u0; u0 = u; u = temp;
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
    for (int i = 0; i < (N+2); i++) {
      for (int j = 0; j < (N+2); j++) {
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
        if (y < 0.5) y = 0.5; if (y > N+0.5) y = N + 0.5; j0 = (int)x; j1 = j0 + 1;
        s1 = x - i0; s0 = 1 - s1; t1 = y - j0; t0 = 1 - t1;
        d[i][j] = s0 * ( t0*d0[i][j] + t1*d0[i][j] ) +
                  s1 * ( t0*d0[i][j] + t1*d0[i][j] );
      }
    }
    set_bnd(N, b, d);
  }

  public void project(int N, float[][] u, float[][]v, float[][]p, float[][] div) {
    float h = 1.0/N;
    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= N; j++) {
        div[i][j] = -0.5*h*(u[i+1][j] - u[i-1][j] + 
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
    for (int i = 0; i <= N; i++) {
      x[0][i] = (b==1) ? -x[1][i] : x[1][i];
      x[N+1][i] = (b==1) ? -x[N][i] : x[N][i];
      x[i][0] = (b==2) ? -x[i][1] : x[i][1];
      x[i][N+1] = (b==2) ? -x[i][N] : x[i][N];
    }
    x[0][0] = 0.5 * (x[1][0] + x[0][1]);
    x[0][N+1] = 0.5 * (x[1][N+1] + x[0][N]);
    x[N+1][0] = 0.5 * (x[N][0] + x[N+1][1]);
    x[N+1][N+1] = 0.5 * (x[N][N+1] + x[N+1][N]);
  }

  public void swap(float[][]a, float[][]b) {
    float[][] temp = a;
    a = b;
    b = temp;
  }

}
