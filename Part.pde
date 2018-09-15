class Part{
    
    public PVector wayto(PVector from, PVector to) {
      return PVector.sub(to, from);
/*    alt method for no borders, not fully working
      PVector vec = new PVector();
      vec.x = to.x - from.x;
      vec.x = (vec.x > width / 2) ? width - vec.x : vec.x;
      vec.y = to.y - from.y;
      vec.y = (vec.y > height/ 2) ? height - vec.y : vec.y;
      return vec;*/
    }

    public float angto(float from, float to) {
      float ang = (to - from) % TWO_PI;
      return (ang > PI) ? TWO_PI - ang : ang;
    }

}
