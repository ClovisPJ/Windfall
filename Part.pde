static class Part{
    
    static public PVector wayto(PVector from, PVector to) {
      return PVector.sub(to, from);
    }

    static public float angto(float from, float to) {
      return to - from;
    }

}
